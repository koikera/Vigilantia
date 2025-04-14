from typing import Dict
from modules.pessoa.repositories import PessoaRepository


class PessoaService:
    def __init__(self, repository: PessoaRepository):
        self.repository = repository

    def get_people(self, data: Dict):
        return self.repository.get_mysql_user(data)

    def create_people(self, data: Dict):
        return self.repository.create(data)