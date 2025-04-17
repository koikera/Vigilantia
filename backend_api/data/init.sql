CREATE DATABASE hages148_vigilantia_db;

USE vigilantia_db;

CREATE TABLE pessoa (
    id INT NOT NULL AUTO_INCREMENT,
    CPF VARCHAR(256),
    Nome_Completo VARCHAR(256),
    Data_Nascimento VARCHAR(256),
    Numero_Telefone VARCHAR(256),
    CEP VARCHAR(256),
    Rua VARCHAR(256),
    Numero INT,
    Complemento VARCHAR(256),
    Senha VARCHAR(256),
    Codigo_Validacao VARCHAR(6),
    Expiracao_Codigo DATETIME
    PRIMARY KEY (id)
);