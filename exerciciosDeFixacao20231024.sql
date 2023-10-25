CREATE DATABASE exercicios_trigger;
USE exercicios_trigger;

-- Criação das tabelas
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE Auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE Pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto_id INT,
    quantidade INT NOT NULL,
    FOREIGN KEY (produto_id) REFERENCES Produtos(id)
);

-- Exercicio 1

DELIMITER //
CREATE TRIGGER mensagemCliente AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Novo cliente inserido: ', NEW.nome, '. Data e hora da inserção: ', NOW()));
END;
//
DELIMITER ;

INSERT INTO Clientes
VALUES(1, "Jaqueline");

SELECT * FROM Auditoria;


-- Exercicio 2
DELIMITER //
CREATE TRIGGER deleteClientes BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Tentativa de exclusão do cliente: ', OLD.nome));
END;
//
DELIMITER ;

DELETE FROM Clientes WHERE id = 1;

SELECT * FROM Auditoria;

-- Exercicio 3

DELIMITER //
CREATE TRIGGER atualizarCliente AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Cliente ', OLD.nome, ' teve seu nome atualizado para ', NEW.nome));
END;
//
DELIMITER ;

INSERT INTO Clientes
VALUES(2, "Mariana");

UPDATE Clientes SET nome = "Mari"
WHERE id = 2;

SELECT * FROM Auditoria;



-- Exercicio 4 

DELIMITER //

CREATE TRIGGER atualizarClienteNulo BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        INSERT INTO Auditoria (mensagem)
        VALUES (CONCAT('Não é permitido atualizar o nome do cliente para uma string vazia ou NULL'));
        
        SET NEW.nome = OLD.nome;
    END IF;
END;
//

DELIMITER ;

UPDATE Clientes SET nome = ""
WHERE id = 2;

SELECT * FROM Auditoria;

DELIMITER //



-- Exercicio 5

CREATE TRIGGER DecrementarEstoque AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    UPDATE Produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;

    IF (SELECT estoque FROM Produtos WHERE id = NEW.produto_id) < 5 THEN
        INSERT INTO Auditoria (mensagem)
        VALUES (CONCAT('Estoque do produto com ID ', NEW.produto_id, ' ficou abaixo de 5 unidades.'));
    END IF;
END;
//

DELIMITER ;

INSERT INTO Produtos (nome, estoque)
VALUES ('Escova', 8);

INSERT INTO Pedidos (produto_id, quantidade)
VALUES (1, 4);
 
SELECT * FROM Auditoria;
