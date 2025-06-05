from typing import Dict
from modules.messages.repositories import MessageRepository


class MessageService:
    def __init__(self, repository: MessageRepository):
        self.repository = repository
    def criar_mensagem(self, remetente_id: str, texto: str, regiao: str):
        return self.repository.criar_mensagem(remetente_id, texto, regiao)
    
    def registrar_envio_para_usuarios(self, mensagem_id: str, destinatarios: str):
        return self.repository.registrar_envio_para_usuarios(mensagem_id, destinatarios)
    
    def send_notification(self, token: str, title: str, body: str):
        return self.repository.send_notification(token, title, body)