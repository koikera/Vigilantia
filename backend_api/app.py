from flask import Blueprint, Flask, jsonify
from flask_cors import CORS
import argparse
from flask_jwt_extended import JWTManager

from database import DatabaseFactory

from modules.pessoa.repositories import PessoaRepository
from modules.pessoa.routes import create_pessoa_blueprint
from modules.pessoa.services import PessoaService


if __name__ == '__main__':
    app = Flask(__name__)
    CORS(app)

    app.config['JWT_SECRET_KEY'] = 'QAJPzrZz6nHiI9qKnlgojGzP2'
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 900  # 15 minutos
    app.config['JWT_REFRESH_TOKEN_EXPIRES'] = 86400  # 1 dia

    jwt = JWTManager(app)


    parser = argparse.ArgumentParser()
    db_factory = DatabaseFactory()
    
    api = Blueprint('api', __name__)

    pessoa_repository = PessoaRepository(db_factory)
    pessoa_service = PessoaService(pessoa_repository)
    pessoa_bp = create_pessoa_blueprint(pessoa_service)
    api.register_blueprint(pessoa_bp, url_prefix='/pessoa')

    

    @api.route('/status', methods=['GET'])
    def status():
        return jsonify({"status": "API is running", "version": "v1"}), 200
    

    app.register_blueprint(api, url_prefix='/api')

    parser.add_argument('--mode', default='production', \
                        help='App mode: "developer" or "production"', \
                        required=True)
    args = parser.parse_args()
    app_debug = args.mode

    if app_debug.lower() == 'developer':
        print(' * Running: Flask Development...')
        app.run(host='0.0.0.0', port=3000, debug=True, use_reloader=True)

    elif app_debug.lower() == 'production':
        print(' * Running:  Production...')
        app.run(host='0.0.0.0', port=3000, debug=False, use_reloader=False)

    else:
        print('Invalid app mode. Use "developer" or "production".')