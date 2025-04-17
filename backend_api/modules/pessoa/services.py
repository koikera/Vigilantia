from typing import Dict
from modules.pessoa.repositories import PessoaRepository


class PessoaService:
    def __init__(self, repository: PessoaRepository):
        self.repository = repository

    def get_people(self, data: Dict):
        return self.repository.get_mysql_user(data)

    def create_people(self, data: Dict):
        return self.repository.create(data)
    
    def get_numTelefone_by_cpf(self, cpf: str):
        return self.repository.get_numTelefone_by_cpf(cpf)
    def gerar_codigo(self):
        return self.repository.gerar_codigo()
    
    def enviar_sms(self, telefone: str, codigo: str):
        return self.repository.enviar_sms(telefone, codigo)
    
    def codigo_expirado(self, expiracao):
        return self.repository.codigo_expirado(expiracao)
    
    def update_codigo(self, codigo, expiracao, cpf):
        return self.repository.update_codigo(codigo, expiracao, cpf)