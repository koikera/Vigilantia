from logger import setup_logger
from flask import Flask, Blueprint, jsonify, request
from flask_cors import CORS
import argparse
from flask_jwt_extended import JWTManager
import os
from database import DatabaseFactory

from modules.pessoa.repositories import PessoaRepository
from modules.pessoa.routes import create_pessoa_blueprint
from modules.pessoa.services import PessoaService

# Configurações do Flask
logger = setup_logger(__name__)

app = Flask(__name__)
CORS(app)

# Configurações do JWT
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 900  # 15 minutos
app.config['JWT_REFRESH_TOKEN_EXPIRES'] = 86400  # 1 dia

jwt = JWTManager(app)

# Conjunto de clientes conectados
clientes_conectados = set()

# Repositórios e Serviços
db_factory = DatabaseFactory()
api = Blueprint('api', __name__)

pessoa_repository = PessoaRepository(db_factory)
pessoa_service = PessoaService(pessoa_repository)
pessoa_bp = create_pessoa_blueprint(pessoa_service)
api.register_blueprint(pessoa_bp, url_prefix='/pessoa')

# Rota para verificar o status da API e o número de clientes conectados
@api.route('/status', methods=['GET'])
def status():
    return jsonify({
        "status": "API is running",
        "version": "v1",
        "clientes_conectados": len(clientes_conectados)  # Exibe número de clientes conectados
    }), 200

@api.route('/send-alert', methods=['POST'])
def send_alert():
    data = request.get_json()

    alert = {
        'alert_id': data.get('alert_id'),
        'severity': data.get('severity'),
        'title': data.get('title'),
        'body': data.get('body'),
        'footer': data.get('footer'),
        'regiao': data.get('regiao'),
        'estado': data.get('estado'),
    }

    return jsonify({"status": "mensagem enviada", "data": alert}), 200


app.register_blueprint(api)

# Argumentos para definir o modo de execução (desenvolvimento ou produção)
parser = argparse.ArgumentParser()
parser.add_argument('--mode', default='production', help='App mode: "developer" or "production"', required=True)
args = parser.parse_args()
app_debug = args.mode

if app_debug.lower() == 'developer':
    print(' * Running: Flask Development...')
    app.run(host='0.0.0.0', port=3002, debug=True, use_reloader=True)

elif app_debug.lower() == 'production':
    print(' * Running: Production...')
    app.run(host='0.0.0.0', port=3002, debug=False, use_reloader=False)

else:
    print('Invalid app mode. Use "developer" or "production".')
