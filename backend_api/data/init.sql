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
    Expiracao_Codigo DATETIME,
    PRIMARY KEY (id)
);

CREATE TABLE mensagens (
    id INT NOT NULL AUTO_INCREMENT,
    remetente_id INT NOT NULL,
    texto TEXT NOT NULL,
    regiao VARCHAR(50),
    timestamp DATETIME NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (remetente_id) REFERENCES pessoa(id)
);

CREATE TABLE usuarios_mensagem (
    id INT NOT NULL AUTO_INCREMENT,
    mensagem_id INT NOT NULL,
    destinatario_id INT NOT NULL,
    recebido BOOLEAN DEFAULT FALSE,
    data_recebimento DATETIME DEFAULT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (mensagem_id) REFERENCES mensagens(id),
    FOREIGN KEY (destinatario_id) REFERENCES pessoa(id),
    INDEX (mensagem_id),
    INDEX (destinatario_id)
);
