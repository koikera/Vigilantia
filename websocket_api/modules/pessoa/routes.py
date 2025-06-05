import datetime
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token, decode_token
from jwt import ExpiredSignatureError, InvalidTokenError
from modules.pessoa.services import PessoaService
from logger import setup_logger
import json

def create_pessoa_blueprint(pessoa_service: PessoaService):
    pessoa_bp = Blueprint('pessoa', __name__)
    logger = setup_logger(__name__)

    @pessoa_bp.route('/create', methods=['POST'])
    def create_people():
        try:
            data = request.get_json()
            logger.info(data)
            has_cpf = pessoa_service.verify_cpf(data['CPF'])
            if has_cpf:
                return jsonify({"message": "CPF já cadastrado."}), 409
            pessoa_service.create_people(data)

            return jsonify({"success": "Pessoa cadastrada com sucesso"}), 201
        except ValueError as e:
            return jsonify({"error": str(e)}), 401

    @pessoa_bp.route('/login', methods=['POST'])
    def get_people():
        try:
            data = request.get_json()
            json = pessoa_service.get_people(data)

            return jsonify(json), 200
        except ValueError as e:
            return jsonify({"error": str(e)}), 401

    @pessoa_bp.route('/refresh', methods=['POST'])
    @jwt_required(refresh=True)
    def refresh():

        current_people_id = get_jwt_identity()  # Retorna '1' como string

        new_access_token = create_access_token(identity=current_people_id)
        return jsonify({"access_token": new_access_token}), 200
    
    @pessoa_bp.route('/valida-token', methods=['POST'])
    def valida_token():
        token = request.json.get('token', None)

        if not token:
            return jsonify({"msg": "Token não fornecido"}), 400

        try:
            decoded_token = decode_token(token)
            user_id = decoded_token.get('sub')

            return jsonify({
                "msg": "Token válido",
                "user_id": user_id,
                "claims": decoded_token  # opcional: mostra todo o payload do token
            }), 200

        except ExpiredSignatureError:
            return jsonify({"msg": "Token expirado"}), 401
        except InvalidTokenError as e:
            return jsonify({"msg": "Token inválido", "erro": str(e)}), 401
        except Exception as e:
            return jsonify({"msg": "Erro ao validar token", "erro": str(e)}), 500

    @pessoa_bp.route('/esqueceu-senha', methods=['POST'])
    def esqueceu_senha():
        # Recebe o CPF do usuário
        cpf = request.json.get('cpf')
        
        if not cpf:
            return jsonify({"error": "CPF não fornecido"}), 400
        
        # Verifica se o CPF está no banco de dados
        usuario = pessoa_service.get_numTelefone_by_cpf(cpf)
        if not usuario:
            return jsonify({"error": "Usuário não encontrado"}), 404
        
        telefone = usuario['telefone']
        
        # Gerar um código aleatório
        codigo = pessoa_service.gerar_codigo()
        expiracao = datetime.datetime.now() + datetime.timedelta(minutes=5)  # O código expira em 5 minutos
        pessoa_service.update_codigo(codigo, expiracao, cpf)
        # Armazenar o código e a data de expiração no banco de dados
        usuario['codigo'] = codigo
        usuario['expiracao'] = expiracao
        
        # Enviar o código por SMS
        pessoa_service.enviar_sms(telefone, codigo)
        
        return jsonify({"msg": "Código enviado para o número registrado. O código expira em 5 minutos."}), 200
    
    @pessoa_bp.route('/validar-codigo', methods=['POST'])
    def validar_codigo():
        cpf = request.json.get('cpf')
        codigo_digitado = request.json.get('codigo')

        if not cpf or not codigo_digitado:
            return jsonify({"error": "CPF e código são necessários"}), 400
        
        usuario = pessoa_service.get_numTelefone_by_cpf(cpf)
        if not usuario:
            return jsonify({"error": "Usuário não encontrado"}), 404

        # Verificar se o código está correto e se não expirou
        if usuario['codigo'] == codigo_digitado:
            if pessoa_service.codigo_expirado(usuario['expiracao']):
                return jsonify({"error": "Código expirado"}), 400
            return jsonify({"msg": "Código válido. Você pode prosseguir para redefinir sua senha."}), 200
        else:
            return jsonify({"error": "Código incorreto"}), 400
        
    @pessoa_bp.route('/alterar-senha', methods=['POST'])
    def alterar_senha():
        cpf = request.json.get('cpf')
        codigo_digitado = request.json.get('codigo')
        senha = request.json.get('senha')
        if not cpf or not codigo_digitado:
            return jsonify({"error": "CPF e código são necessários"}), 400
        
        usuario = pessoa_service.get_numTelefone_by_cpf(cpf)
        if not usuario:
            return jsonify({"error": "Usuário não encontrado"}), 404

        # Verificar se o código está correto e se não expirou
        if usuario['codigo'] == codigo_digitado:
            if pessoa_service.codigo_expirado(usuario['expiracao']):
                return jsonify({"error": "Ops! O tempo limite para trocar a senha acabou."}), 400
            
            pessoa_service.alterar_senha(codigo_digitado, senha, cpf)
            return jsonify({"msg": "Tudo certo! Agora é só entrar com sua nova senha."}), 200
        else:
            return jsonify({"error": "Código incorreto"}), 400

    return pessoa_bp