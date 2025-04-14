from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token
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
            response = pessoa_service.create_people(data)

            return jsonify({"success": "Pessoa cadastrada com sucesso"}), 201
        except ValueError as e:
            return jsonify({"error": str(e)}), 401

    @pessoa_bp.route('/login', methods=['POST'])
    def get_people():
        try:
            data = request.get_json()
            access_token, refresh_token = pessoa_service.get_people(data)

            return jsonify({"access_token": access_token, "refresh_token": refresh_token}), 200
        except ValueError as e:
            return jsonify({"error": str(e)}), 401

    @pessoa_bp.route('/refresh', methods=['POST'])
    @jwt_required(refresh=True)
    def refresh():

        current_people_id = get_jwt_identity()  # Retorna '1' como string

        new_access_token = create_access_token(identity=current_people_id)
        return jsonify({"access_token": new_access_token}), 200

    return pessoa_bp