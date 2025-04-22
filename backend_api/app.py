from logger import setup_logger
from flask import Flask, Blueprint, jsonify, request
from flask_cors import CORS
from flask_socketio import SocketIO, emit
import argparse
from flask_jwt_extended import JWTManager
import eventlet

from database import DatabaseFactory

from modules.pessoa.repositories import PessoaRepository
from modules.pessoa.routes import create_pessoa_blueprint
from modules.pessoa.services import PessoaService

from modules.messages.repositories import MessageRepository
from modules.messages.routes import create_message_blueprint
from modules.messages.services import MessageService

# Configurações do Flask
logger = setup_logger(__name__)

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")
eventlet.monkey_patch()  # Para usar com SocketIO

# Configurações do JWT
app.config['JWT_SECRET_KEY'] = 'QAJPzrZz6nHiI9qKnlgojGzP2'
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

message_repository = MessageRepository(db_factory)
message_service = MessageService(message_repository)
message_bp = create_message_blueprint(message_service)
api.register_blueprint(message_bp, url_prefix='/message')

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

    # Envia a mensagem via WebSocket para todos os clientes
    socketio.emit('mensagem', alert, namespace='/')
    
    return jsonify({"status": "mensagem enviada", "data": alert}), 200

@socketio.on('message')
def handle_message(data):
    print(f'Mensagem recebida do cliente: {data}')
    
    # Enviando uma resposta para o cliente (Flutter)
    emit('message', {'response': data}, broadcast=True)
# Eventos de WebSocket
@socketio.on('connect')
def handle_connect():
    sid = request.sid
    clientes_conectados.add(sid)
    logger.info(f'✅ Novo cliente conectado: {sid}. Total: {len(clientes_conectados)}')

@socketio.on('disconnect')
def handle_disconnect():
    sid = request.sid
    clientes_conectados.discard(sid)
    logger.info(f'❌ Cliente desconectado: {sid}. Total: {len(clientes_conectados)}')

# Registrando o Blueprint da API
app.register_blueprint(api, url_prefix='/api')

# Argumentos para definir o modo de execução (desenvolvimento ou produção)
parser = argparse.ArgumentParser()
parser.add_argument('--mode', default='production', help='App mode: "developer" or "production"', required=True)
args = parser.parse_args()
app_debug = args.mode

if app_debug.lower() == 'developer':
    print(' * Running: Flask Development...')
    socketio.run(app, host='0.0.0.0', port=3000, debug=True, use_reloader=True)

elif app_debug.lower() == 'production':
    print(' * Running: Production...')
    socketio.run(app, host='0.0.0.0', port=3000, debug=False, use_reloader=False)

else:
    print('Invalid app mode. Use "developer" or "production".')
