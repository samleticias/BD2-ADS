-- 1) Implemente o banco de dados que controla as compras de livros de uma livraria em seus
-- respectivos fornecedores, de acordo com o esquema abaixo. Os domínios dos atributos ficarão
-- a seu critério. Não se esqueça de povoar as tabelas.
-- Obs: Durante a criação das tabelas, não implemente restrições de chaves primárias e
-- estrangeiras e nem restrições de valores não nulos nas tabelas Pedido e Item_pedido.

-- Fornecedor (cod_fornecedor, nome_fornenecdor, endereco_fornecedor)
-- Livro (cod_livro, cod_titulo, quant_estoque, valor_unitario)
-- Titulo (cod_titulo, descr_titulo)
-- Pedido (cod_pedido, cod_fornecedor, data_pedido, hora_pedido, valor_total_pedido, quant_itens_pedidos)
-- Item_pedido (cod_livro, cod_pedido, quantidade_item, valor_total_item)

CREATE TABLE FORNECEDOR(
	COD_FORNECEDOR SERIAL PRIMARY KEY,
	NOME_FORNECEDOR VARCHAR(30),
	ENDERECO_FORNECEDOR VARCHAR(50)
);

CREATE TABLE LIVRO(
	COD_LIVRO SERIAL PRIMARY KEY,
	COD_TITULO INT REFERENCES TITULO(COD_TITULO),
	QUANT_ESTOQUE INT,
	VALOR_UNITARIO FLOAT
);

CREATE TABLE TITULO(
	COD_TITULO SERIAL PRIMARY KEY,
	DESCR_TITULO VARCHAR(30)
);

CREATE TABLE PEDIDO(
	COD_PEDIDO SERIAL PRIMARY KEY,
	COD_FORNECEDOR INT REFERENCES FORNECEDOR(COD_FORNECEDOR),
	DATA_PEDIDO DATE,
	HORA_PEDIDO TIME,
	VALOR_TOTAL_PEDIDO FLOAT,
	QUANT_ITENS_PEDIDO INT
);

CREATE TABLE ITEM_PEDIDO(
	COD_ITEM SERIAL PRIMARY KEY,
	COD_LIVRO INT REFERENCES LIVRO(COD_LIVRO),
	COD_PEDIDO INT REFERENCES PEDIDO(COD_PEDIDO),
	QUANT_ITEM INT,
	VALOR_TOTAL_ITEM FLOAT
);

INSERT INTO TITULO (DESCR_TITULO) VALUES
('O Senhor dos Anéis'),
('1984'),
('A Revolução dos Bichos'),
('Dom Quixote'),
('Harry Potter');

INSERT INTO LIVRO (COD_TITULO, VALOR_UNITARIO, QUANT_ESTOQUE) VALUES
(1, 100, 50),
(2, 50, 30),
(3, 40, 20),
(4, 80, 15),
(5, 90, 25);

INSERT INTO FORNECEDOR (NOME_FORNECEDOR, ENDERECO_FORNECEDOR) VALUES
('Editora A', 'Rua das Flores'),
('Editora B', 'Rua das Tulipas'),
('Editora C', 'Rua das Margaridas'),
('Editora D', 'Rua das Rosas'),
('Editora E', 'Rua das Orquídeas');

INSERT INTO PEDIDO (COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO) VALUES
(1, '10:30:00', '2025-04-01', 500),
(2, '11:00:00', '2025-04-02', 300),
(3, '14:45:00', '2025-04-03', 200),
(4, '09:15:00', '2025-04-04', 400),
(5, '16:00:00', '2025-04-05', 600),
(1, '16:00:00', '2024-02-05', 600),
(1, '16:00:00', '2024-02-05', 600),
(5, '16:00:00', '2025-04-05', 600);


INSERT INTO ITEM_PEDIDO (COD_PEDIDO, COD_LIVRO) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5);

-- 2) Responda as questões a seguir:
-- a) Mostre o nome dos fornecedores que venderam mais de X reais no mês de fevereiro de 2024.
SELECT NOME_FORNECEDOR FROM FORNECEDOR F JOIN PEDIDO P ON F.COD_FORNECEDOR = P.COD_FORNECEDOR WHERE 
DATA_PEDIDO BETWEEN '2024-02-01' AND '2024-02-28' GROUP BY NOME_FORNECEDOR HAVING 
SUM(VALOR_TOTAL_PEDIDO) > 300;

-- b) Mostre o nome de um dos fornecedores que mais vendeu no mês de fevereiro de 2024.
SELECT NOME_FORNECEDOR, SUM(VALOR_TOTAL_PEDIDO) AS TOTAL_VENDIDO FROM FORNECEDOR F JOIN PEDIDO P ON 
F.COD_FORNECEDOR = P.COD_FORNECEDOR WHERE DATA_PEDIDO BETWEEN '2024-02-01' AND '2024-02-28' GROUP BY 
NOME_FORNECEDOR ORDER BY TOTAL_VENDIDO DESC LIMIT 1;

-- 3) Usando trigger, responda as questões a seguir.
-- a) Crie triggers que implementem todas essas restrições de chave primária, chave estrangeira
-- e valores não nulos nas tabelas Pedido e Item_pedido.
CREATE FUNCTION IMPEDE_VALOR_NULO_PEDIDO()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.COD_FORNECEDOR IS NULL THEN
		RAISE EXCEPTION 'O código do fornecedor não pode ser nulo.';
	ELSIF NEW.DATA_PEDIDO IS NULL THEN
		RAISE EXCEPTION 'A data do pedido não pode ser nula.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IMPEDE_VALOR_NULO_CADASTRO_PEDIDO BEFORE INSERT ON PEDIDO FOR EACH ROW EXECUTE 
PROCEDURE IMPEDE_VALOR_NULO_PEDIDO();

INSERT INTO PEDIDO (COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO) VALUES
(1, '10:30:00', NULL, 500); -- ERROR:  A data do pedido não pode ser nula.

INSERT INTO PEDIDO (COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO) VALUES
(NULL, '10:30:00', '2025-04-02', 500); -- ERROR:  O código do fornecedor não pode ser nulo.

CREATE FUNCTION IMPEDE_VALOR_NULO_ITENS()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.COD_PEDIDO IS NULL THEN
		RAISE EXCEPTION 'O código do pedido não pode ser nulo ao cadastrar o item do pedido.';
	ELSIF NEW.COD_LIVRO IS NULL THEN
		RAISE EXCEPTION 'O código do livro não pode ser nulo ao cadastrar o item do pedido.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IMPEDE_VALOR_NULO_CADASTRO_ITENS_PEDIDO BEFORE INSERT ON ITEM_PEDIDO FOR EACH ROW 
EXECUTE PROCEDURE IMPEDE_VALOR_NULO_ITENS();

INSERT INTO ITEM_PEDIDO (COD_PEDIDO, COD_LIVRO) VALUES
(NULL, 1); -- ERROR:  O código do pedido não pode ser nulo ao cadastrar o item do pedido.

INSERT INTO ITEM_PEDIDO (COD_PEDIDO, COD_LIVRO) VALUES
(2, NULL); -- ERROR:  O código do livro não pode ser nulo ao cadastrar o item do pedido.

CREATE FUNCTION IMPEDE_DUPLICIDADE_PK_PEDIDO()
RETURNS TRIGGER AS $$
BEGIN 
	IF EXISTS (SELECT 1 FROM PEDIDO WHERE COD_PEDIDO = NEW.COD_PEDIDO) THEN
		RAISE EXCEPTION 'Chave primária violada: já existe um pedido com código %', NEW.COD_PEDIDO;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER VERIFICA_PK_PEDIDO BEFORE INSERT ON PEDIDO FOR EACH ROW EXECUTE PROCEDURE 
IMPEDE_DUPLICIDADE_PK_PEDIDO();

INSERT INTO PEDIDO (COD_PEDIDO, COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO) VALUES
(1, 1, '10:30:00', '2025-04-01', 500); -- ERROR:  Chave primária violada: já existe um pedido com código 1

CREATE OR REPLACE FUNCTION TRIGGER_FK_PEDIDO_FORNECEDOR()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM FORNECEDOR WHERE COD_FORNECEDOR = NEW.COD_FORNECEDOR
	) THEN
		RAISE EXCEPTION 'Chave estrangeira violada: fornecedor % não existe', NEW.COD_FORNECEDOR;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER VERIFICA_FK_PEDIDO_FORNECEDOR BEFORE INSERT ON PEDIDO FOR EACH ROW EXECUTE PROCEDURE
TRIGGER_FK_PEDIDO_FORNECEDOR();

CREATE FUNCTION VERIFICA_FK_ITEM_PEDIDO()
RETURNS TRIGGER AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM PEDIDO WHERE PEDIDO.COD_PEDIDO = NEW.COD_PEDIDO) THEN
		RAISE EXCEPTION 'Chave estrangeira violada: pedido % não existe', NEW.COD_PEDIDO;
	END IF;
	
	IF NOT EXISTS (SELECT 1 FROM LIVRO WHERE COD_LIVRO = NEW.COD_LIVRO) THEN
		RAISE EXCEPTION 'Chave estrangeira violada: livro % não existe', NEW.COD_LIVRO;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER VERIFICA_FK_ITEM_PEDIDO BEFORE INSERT ON ITEM_PEDIDO FOR EACH ROW EXECUTE PROCEDURE 
VERIFICA_FK_ITEM_PEDIDO();

INSERT INTO PEDIDO (COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO) 
VALUES (999, '12:00:00', '2025-05-01', 250.00); -- ERROR:  Chave estrangeira violada: fornecedor 999 não existe

INSERT INTO ITEM_PEDIDO (COD_LIVRO, COD_PEDIDO, QUANT_ITEM, VALOR_TOTAL_ITEM) 
VALUES (1, NULL, 2, 200.00); -- ERROR:  O código do pedido não pode ser nulo ao cadastrar o item do pedido.

INSERT INTO ITEM_PEDIDO (COD_LIVRO, COD_PEDIDO, QUANT_ITEM, VALOR_TOTAL_ITEM) 
VALUES (NULL, 1, 2, 200.00); -- ERROR:  O código do livro não pode ser nulo ao cadastrar o item do pedido.

INSERT INTO ITEM_PEDIDO (COD_LIVRO, COD_PEDIDO, QUANT_ITEM, VALOR_TOTAL_ITEM) 
VALUES (1, 999, 2, 200.00); -- ERROR:  Chave estrangeira violada: pedido 999 não existe

INSERT INTO ITEM_PEDIDO (COD_LIVRO, COD_PEDIDO, QUANT_ITEM, VALOR_TOTAL_ITEM) 
VALUES (999, 1, 2, 200.00); -- ERROR:  Chave estrangeira violada: livro 999 não existe


-- b) Crie um trigger na tabela Livro que não permita quantidade em estoque negativa e sempre
-- que a quantidade em estoque atingir 10 ou menos unidades, um aviso de quantidade mínima
-- deve ser emitido ao usuário (para emitir alertas sem interromper a execução da transação,
-- você pode usar "raise notice" ou "raise info").
CREATE FUNCTION VERIFICA_ESTOQUE()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.QUANT_ESTOQUE < 0 THEN
		RAISE EXCEPTION 'A quantidade em estoque não pode ser negativa.';
	END IF;
	
	IF NEW.QUANT_ESTOQUE <= 10 THEN
		RAISE NOTICE 'Estoque do livro % está baixo (% unidades restantes).', NEW.COD_LIVRO,
		NEW.QUANT_ESTOQUE;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRIGGER_VERIFICA_ESTOQUE BEFORE INSERT OR UPDATE ON LIVRO FOR EACH ROW EXECUTE
PROCEDURE VERIFICA_ESTOQUE();

UPDATE LIVRO SET QUANT_ESTOQUE = -1 WHERE COD_LIVRO = 1; -- ERROR:  A quantidade em estoque não pode ser negativa.

UPDATE LIVRO SET QUANT_ESTOQUE = 7 WHERE COD_LIVRO = 1; -- NOTA:  Estoque do livro 1 está baixo (7 unidades restantes).

--c) Crie um trigger que sempre que houver inserções, remoções ou alterações na tabela
-- "Item_pedido", haja a atualização da "quant_itens_pedidos" e do "valor_total_pedido" da
-- tabela "pedido", bem como a atualização da quantidade em estoque da tabela Livro.
CREATE OR REPLACE FUNCTION FUNCAO_CONTROLA_ITEM()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE LIVRO
        SET QUANT_ESTOQUE = QUANT_ESTOQUE - NEW.QUANT_ITEM
        WHERE COD_LIVRO = NEW.COD_LIVRO;

        UPDATE PEDIDO
        SET QUANT_ITENS_PEDIDO = QUANT_ITENS_PEDIDO + NEW.QUANT_ITEM,
            VALOR_TOTAL_PEDIDO = VALOR_TOTAL_PEDIDO + NEW.VALOR_TOTAL_ITEM
        WHERE COD_PEDIDO = NEW.COD_PEDIDO;
    
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE LIVRO
        SET QUANT_ESTOQUE = QUANT_ESTOQUE + OLD.QUANT_ITEM
        WHERE COD_LIVRO = OLD.COD_LIVRO;

        UPDATE PEDIDO
        SET QUANT_ITENS_PEDIDO = QUANT_ITENS_PEDIDO - OLD.QUANT_ITEM,
            VALOR_TOTAL_PEDIDO = VALOR_TOTAL_PEDIDO - OLD.VALOR_TOTAL_ITEM
        WHERE COD_PEDIDO = OLD.COD_PEDIDO;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE LIVRO
        SET QUANT_ESTOQUE = QUANT_ESTOQUE + OLD.QUANT_ITEM
        WHERE COD_LIVRO = OLD.COD_LIVRO;

        UPDATE PEDIDO
        SET QUANT_ITENS_PEDIDO = QUANT_ITENS_PEDIDO - OLD.QUANT_ITEM,
            VALOR_TOTAL_PEDIDO = VALOR_TOTAL_PEDIDO - OLD.VALOR_TOTAL_ITEM
        WHERE COD_PEDIDO = OLD.COD_PEDIDO;

        UPDATE LIVRO
        SET QUANT_ESTOQUE = QUANT_ESTOQUE - NEW.QUANT_ITEM
        WHERE COD_LIVRO = NEW.COD_LIVRO;

        UPDATE PEDIDO
        SET QUANT_ITENS_PEDIDO = QUANT_ITENS_PEDIDO + NEW.QUANT_ITEM,
            VALOR_TOTAL_PEDIDO = VALOR_TOTAL_PEDIDO + NEW.VALOR_TOTAL_ITEM
        WHERE COD_PEDIDO = NEW.COD_PEDIDO;
    END IF;

    RETURN NEW; 
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER CONTROLA_ITEM AFTER INSERT OR DELETE OR UPDATE
ON ITEM_PEDIDO FOR EACH ROW EXECUTE FUNCTION FUNCAO_CONTROLA_ITEM();

INSERT INTO PEDIDO (COD_FORNECEDOR, HORA_PEDIDO, DATA_PEDIDO, VALOR_TOTAL_PEDIDO) VALUES
(1, '10:30:00', '2025-04-01', 0);

INSERT INTO ITEM_PEDIDO (COD_PEDIDO, COD_LIVRO, QUANT_ITEM, VALOR_TOTAL_ITEM) 
VALUES (14, 6, 3, 150.00);

-- d) Crie uma tabela chamada "controla_alteracao". Nesta tabela, deverão ser armazenadas as
-- alterações (update, delete) feitas na tabela "livro". Deverão ser registrados as seguintes
-- informações: operação que foi realizada, a data e hora, além do usuário que realizou a
-- modificação. No caso de acontecer uma atualização, deverão ser registrados os valores novos
-- e os valores antigos da coluna "cod_titulo" do livro e quantidade em estoque. No caso de
-- acontecer uma deleção, basta armazenar o "cod_titulo" do livro e a respectiva quantidade em
-- estoque que foi deletada. 
