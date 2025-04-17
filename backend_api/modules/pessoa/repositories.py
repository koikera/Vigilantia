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

logger = setup_logger(__name__)

ConditionKey = Literal[
    'id',
    'CPF',
    'Nome_Completo',
    'Data_Nascimento',
    'Numero_Telefone',
    'CEP',
    'Rua',
    'Numero',
    'Complemento',
    'Senha'
]

class PessoaRepository:
    def __init__(self, db_factory: DatabaseFactory) -> None:
        self.db_factory = db_factory

    def get_mysql_user(self, json: Dict) -> Dict:
        mysql_conn = self.db_factory.get_mysql_connection()

        def sha256_hash(value: str) -> str:
            return hashlib.sha256(value.encode()).hexdigest()

        hashed_senha = sha256_hash(json.get('senha'))

        query = """SELECT id, senha, Data_Nascimento, Nome_Completo, CEP FROM pessoa WHERE CPF = %s"""
        with mysql_conn.cursor(dictionary=True) as cursor:
            cursor.execute(query, [json.get('cpf')])
            result = cursor.fetchone()
            logger.info(result)
            if result and hashed_senha == result['senha']:

                user_identity = str(result['id'])  # Converta para string
                
                access_token = create_access_token(identity=user_identity)
                refresh_token = create_refresh_token(identity=user_identity)
                json_response = {
                    "Nome": result['Nome_Completo'],
                    "Data_Nascimento": result['Data_Nascimento'],
                    "CEP": result['CEP'],
                    "access_token": access_token,
                    "refresh_token": refresh_token
                }
                return json_response

        raise ValueError("CPF ou senha inválidos.")

    def create(self , json: Dict) -> Dict:
       
        if not json:
            raise ValueError("Nenhum dado fornecido para inserção.")

        mysql_conn = self.db_factory.get_mysql_connection()

        def sha256_hash(value: str) -> str:
            return hashlib.sha256(value.encode()).hexdigest()

        # Verifica se os campos foram fornecidos e aplica SHA-256
        if "Senha" in json:
            json["Senha"] = sha256_hash(json["Senha"])
        columns = list(json.keys())
        values = list(json.values())
        query = f"""INSERT INTO pessoa ({', '.join(columns)}) VALUES ({', '.join(['%s'] * len(values))})"""

        try:
            with mysql_conn.cursor(dictionary=True) as cursor:
                cursor.execute(query, tuple(values))
                mysql_conn.commit()
                json["id"] = cursor.lastrowid  # Adiciona o ID gerado ao retorno

                return json["id"]
        except Exception as e:
            mysql_conn.rollback()
            raise RuntimeError(f"Erro ao inserir usuário: {str(e)}")
        finally:
            mysql_conn.close()
        return json
    
    def get_numTelefone_by_cpf(self, cpf: str) -> Dict:
        mysql_conn = self.db_factory.get_mysql_connection()
        query = """SELECT Numero_Telefone as telefone, Codigo_Validacao as codigo, Expiracao_Codigo as expiracao FROM pessoa WHERE CPF = %s"""
        with mysql_conn.cursor(dictionary=True) as cursor:
            cursor.execute(query, [cpf])
            result = cursor.fetchone()
        return result
    
    def gerar_codigo(self):
        return ''.join(random.choices(string.digits, k=6))
    
    def enviar_sms(self, telefone, codigo):
        # Exemplo usando a Twilio
        # client = Client(account_sid, auth_token)
        # message = client.messages.create(
        #     body=f"Seu código de recuperação é: {codigo}",
        #     from_='+1415XXXXXXX',
        #     to=telefone
        # )
        logger.info(f"Enviado para {telefone}: Seu código de recuperação é: {codigo}")

    def codigo_expirado(self, expiracao):
        return datetime.datetime.now() > expiracao
    
    def update_codigo(self, codigo: str, expiracao, cpf: str) -> None:
        mysql_conn = self.db_factory.get_mysql_connection()
        query = """UPDATE pessoa SET Codigo_Validacao = %s, Expiracao_Codigo = %s WHERE CPF = %s"""
        with mysql_conn.cursor(dictionary=True) as cursor:
            cursor.execute(query, [codigo, expiracao ,cpf])
            mysql_conn.commit()

    