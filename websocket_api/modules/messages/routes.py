import datetime
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token, decode_token
from jwt import ExpiredSignatureError, InvalidTokenError
from modules.messages.services import MessageService
from logger import setup_logger
import json

def create_message_blueprint(message_service: MessageService):
    message_bp = Blueprint('message', __name__)
    logger = setup_logger(__name__)

    @message_bp.route('/enviar', methods=['POST'])
    @jwt_required()
    def enviar_mensagem():
        try:
            data = request.get_json()
            texto = data.get("texto")
            destinatarios = data.get("destinatarios")  # lista de IDs
            remetente_id = get_jwt_identity()

            if not texto or not destinatarios:
                return jsonify({"error": "Texto e destinatários são obrigatórios"}), 400

            # 1. Salva a mensagem no banco
            mensagem_id = message_service.criar_mensagem(remetente_id, texto)
            logger.info(remetente_id)
            # 2. Salva os destinatários
            message_service.registrar_envio_para_usuarios(mensagem_id, destinatarios)

            # 3. Emite mensagem via WebSocket
            socketio.emit('nova_mensagem', {
                "id": mensagem_id,
                "texto": texto,
                "from": remetente_id,
                "to": destinatarios
            }, broadcast=True)  # ou individual se tiver canais específicos

            return jsonify({"msg": "Mensagem enviada com sucesso", "mensagem_id": mensagem_id}), 200

        except Exception as e:
            logger.error(f"Erro ao enviar mensagem: {str(e)}")
            return jsonify({"error": "Erro ao enviar mensagem"}), 500
    @message_bp.route('/')
    def index():
        return "Servidor WebSocket ativo!"

    

    return message_bp
