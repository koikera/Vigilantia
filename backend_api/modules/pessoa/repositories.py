from typing import Dict, Literal, cast
from database import DatabaseFactory
from werkzeug.security import check_password_hash
import bcrypt
from flask_jwt_extended import create_access_token, create_refresh_token
import hashlib
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
        """
        Query MySQL users based on the provided conditions.

        :param json: Dictionary containing 'cpf' and 'senha'.
        :return: Access token and refresh token.
        """
        mysql_conn = self.db_factory.get_mysql_connection()

        def sha256_hash(value: str) -> str:
            return hashlib.sha256(value.encode()).hexdigest()

        hashed_senha = sha256_hash(json.get('senha'))
        hashed_cpf = sha256_hash(json.get('cpf'))

        query = """SELECT id, senha FROM pessoa WHERE CPF = %s"""
        with mysql_conn.cursor(dictionary=True) as cursor:
            cursor.execute(query, [hashed_cpf])
            result = cursor.fetchone()

            if result and hashed_senha == result['senha']:
                user_identity = str(result['id'])  # Converta para string
                access_token = create_access_token(identity=user_identity)
                refresh_token = create_refresh_token(identity=user_identity)
                return access_token, refresh_token

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
        if "CPF" in json:
            json["CPF"] = sha256_hash(json["CPF"])
        if "Numero_Telefone" in json:
            json["Numero_Telefone"] = sha256_hash(json["Numero_Telefone"])
        if "CEP" in json:
            json["CEP"] = sha256_hash(json["CEP"])
        if "Rua" in json:
            json["Rua"] = sha256_hash(json["Rua"])
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
