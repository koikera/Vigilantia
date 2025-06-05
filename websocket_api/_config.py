import os
from dotenv import load_dotenv
load_dotenv()

class Config:
    MYSQL_DATABASE = {
        'host': os.getenv('MYSQL_HOST'),
        'user': os.getenv('MYSQL_USER'),
        'password': os.getenv('MYSQL_PASS'),
        'database': os.getenv('MYSQL_DATA'),
        'port': os.getenv('MYSQL_PORT'),
    }