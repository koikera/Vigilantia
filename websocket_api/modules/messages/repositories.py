import datetime
from typing import Dict, Literal, cast
from database import DatabaseFactory
from werkzeug.security import check_password_hash
import bcrypt
from flask_jwt_extended import create_access_token, create_refresh_token
import hashlib
from logger import setup_logger
import random
import string
import time
import requests
logger = setup_logger(__name__)

ConditionKey = Literal[
    'id'
]

class MessageRepository:
    def __init__(self, db_factory: DatabaseFactory) -> None:
        self.db_factory = db_factory

    def criar_mensagem(self, remetente_id, texto):
        mysql_conn = self.db_factory.get_mysql_connection()
        query = """
            INSERT INTO mensagens (remetente_id, texto, timestamp)
            VALUES (%s, %s, %s)
        """
        now = datetime.datetime.utcnow()
        with mysql_conn.cursor() as cursor:
            cursor.execute(query, (remetente_id, texto, now))
            mysql_conn.commit()
            return cursor.lastrowid


    def registrar_envio_para_usuarios(self, mensagem_id, destinatarios):
        mysql_conn = self.db_factory.get_mysql_connection()
        logger.info(mensagem_id)
        logger.info(destinatarios)
        query = """
            INSERT INTO usuarios_mensagem (mensagem_id, destinatario_id, recebido)
            VALUES (%s, %s, %s)
        """
        values = [(mensagem_id, uid, False) for uid in destinatarios]

        with mysql_conn.cursor() as cursor:
            cursor.executemany(query, values)
            mysql_conn.commit()

    
    