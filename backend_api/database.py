import mysql.connector
from _config import Config


class DatabaseFactory:
    def __init__(self):
        self.mysql_config = Config.MYSQL_DATABASE
    
    def get_mysql_connection(self):
        return mysql.connector.connect(
            host=self.mysql_config['host'],
            user=self.mysql_config['user'],
            password=self.mysql_config['password'],
            database=self.mysql_config['database'],
        )