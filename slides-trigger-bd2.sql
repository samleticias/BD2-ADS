-- Crie uma tabela aluno com as colunas matrícula e nome. Depois crie um trigger que não permita o cadastro de 
-- alunos cujo nome começa com a letra “a”.

CREATE TABLE ALUNO (
	COD_ALUNO SERIAL PRIMARY KEY,
	MATRICULA VARCHAR(10),
	NOME VARCHAR(20)
);

CREATE FUNCTION PROIBE_NOMES_LETRA_A()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.NOME ILIKE 'A%' THEN
		RAISE EXCEPTION 'Não é permitido cadastro de aluno com nome iniciado com a letra A.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER PROIBE_NOMES_LETRA_A AFTER INSERT ON ALUNO FOR EACH ROW EXECUTE PROCEDURE PROIBE_NOMES_LETRA_A();

INSERT INTO ALUNO (MATRICULA, NOME) VALUES ('5678', 'Alanda');
INSERT INTO ALUNO (MATRICULA, NOME) VALUES ('1234', 'Sammya');

-- Primeiro crie uma tabela chamada Funcionário com os seguintes campos: código (int), nome (varchar(30)), salário
-- (float), data_última_atualização (timestamp), usuário_que_atualizou (varchar(30)). Na inserção desta tabela, 
-- você deve informar apenas o código, nome e salário do funcionário. Agora crie um Trigger que não permita o nome
-- nulo, a salário nulo e nem negativo. Faça testes que comprovem o funcionamento do Trigger.
-- Obs: Raise Exception, ‘now’ e current_user

CREATE TABLE FUNCIONARIO (
	COD_FUNC SERIAL PRIMARY KEY,
	NOME VARCHAR(30),
	SALARIO FLOAT,
	DATA_ULTIMA_ATUALIZACAO TIMESTAMP DEFAULT CURRENT_DATE,
	USUARIO_QUE_ATUALIZOU VARCHAR(30)
);

-- nome nulo, a salário nulo e nem negativo
CREATE FUNCTION VALIDA_CADASTRO_FUNCIONARIO()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.NOME IS NULL THEN
		RAISE EXCEPTION 'Não é permitido cadastro de funcionário com nome nulo.';
	END IF;
	
	IF NEW.SALARIO IS NULL THEN
		RAISE EXCEPTION 'Não é permitido cadastro de funcionário com salário nulo.';
	END IF;
	
	IF NEW.SALARIO < 0 THEN
		RAISE EXCEPTION 'Não é permitido cadastro de funcionário com valor de salário negativo.';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER VALIDA_VALORES_FUNCIONARIO AFTER INSERT ON FUNCIONARIO FOR EACH ROW EXECUTE PROCEDURE VALIDA_CADASTRO_FUNCIONARIO();

INSERT INTO FUNCIONARIO (NOME, SALARIO, DATA_ULTIMA_ATUALIZACAO, USUARIO_QUE_ATUALIZOU) VALUES
(NULL, NULL, CURRENT_DATE, CURRENT_USER);

-- Agora crie uma tabela chamada Empregado com os atributos nome e salário. Crie também outra tabela chamada
-- Empregado_auditoria com os atributos: operação (char(1)), usuário (varchar), data (timestamp), nome (varchar), 
-- salário(float). Agora crie um trigger que registre na tabela Empregado_auditoria a modificação que foi feita 
-- na tabela empregado (E,A,I), quem fez a modificação, a data da modificação, o nome do empregado que foi alterado
-- e o salário atual dele. Obs: variável especial TG_OP

CREATE TABLE EMPREGADO (
	COD_EMP SERIAL PRIMARY KEY,
	NOME VARCHAR(30),
	SALARIO FLOAT
);

CREATE TABLE EMPREGADO_AUDITORIA (
	COD_AUDITORIA SERIAL PRIMARY KEY,
	OPERACAO VARCHAR(1),
	USUARIO VARCHAR(20),
	DATA TIMESTAMP,
	NOME VARCHAR(20),
	SALARIO FLOAT
);

-- Agora crie um trigger que registre na tabela Empregado_auditoria a modificação que foi feita 
-- na tabela empregado (E,A,I), quem fez a modificação, a data da modificação, o nome do empregado que foi alterado
-- e o salário atual dele. Obs: variável especial TG_OP

CREATE OR REPLACE FUNCTION REGISTRA_OPERACOES_EMPREGADO()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO) VALUES 
		('I', CURRENT_USER, CURRENT_DATE, NEW.NOME, NEW.SALARIO);
		RETURN NEW;
	ELSIF TG_OP = 'UPDATE' THEN
		INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO) VALUES 
		('U', CURRENT_USER, CURRENT_DATE, NEW.NOME, NEW.SALARIO);
		RETURN NEW;
	ELSIF TG_OP = 'DELETE' THEN
		INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO) VALUES 
		('D', CURRENT_USER, CURRENT_DATE, OLD.NOME, OLD.SALARIO);
		RETURN OLD;
	END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TRG_OPERACOES_EMPREGADO BEFORE INSERT OR DELETE OR UPDATE ON EMPREGADO FOR EACH ROW 
EXECUTE PROCEDURE REGISTRA_OPERACOES_EMPREGADO();

INSERT INTO EMPREGADO (NOME, SALARIO) VALUES 
('SAMMYA', 1070),
('ENZO', 3100),
('JOTA', 3100),
('NICOLAS', 3100),
('XAMÃ', 3100),
('ARTHUR', 3100),
('IGLESIO', 3100);

SELECT * FROM EMPREGADO_AUDITORIA

UPDATE EMPREGADO SET NOME = 'JOÃO VICTOR SANTOS' WHERE NOME ILIKE 'JOTA'

DELETE FROM EMPREGADO WHERE NOME ILIKE 'SAMMYA'

-- Crie a tabela Empregado2 com os atributos código (serial e chave primária), nome (varchar) e salário (float). 
-- Crie também a tabela Empregado2_audit com os seguintes atributos: usuário (varchar), data (timestamp), id 
-- (integer), coluna (text), valor_antigo (text), valor_novo(text). Agora crie um trigger que não permita a 
-- alteração da chave primária e insira registros na tabela Empregado2_audit para refletir as alterações 
-- realizadas na tabela Empregado2.

CREATE TABLE EMPREGADO2 (
	CODIGO SERIAL PRIMARY KEY, 
	NOME VARCHAR(30), 
	SALARIO FLOAT
);

CREATE TABLE EMPREGADO2_AUDIT (
	CODIGO SERIAL PRIMARY KEY, 
	USUARIO VARCHAR(30), 
	DATA TIMESTAMP,
	ID INT,
	COLUNA TEXT,
	VALOR_ANTIGO TEXT,
	VALOR_NOVO TEXT
);

CREATE OR REPLACE FUNCTION AUDITA_EMPREGADO2()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.CODIGO <> OLD.CODIGO THEN
		RAISE EXCEPTION 'Não é permitido alterar a chave primária CODIGO.';
	END IF;
	
	IF NEW.NOME IS DISTINCT FROM OLD.NOME THEN
		INSERT INTO EMPREGADO2_AUDIT (USUARIO, DATA, ID, COLUNA, VALOR_ANTIGO, VALOR_NOVO) VALUES
		(CURRENT_USER, CURRENT_TIMESTAMP, OLD.CODIGO, 'NOME', OLD.NOME, NEW.NOME);
	END IF;
	
	IF NEW.SALARIO IS DISTINCT FROM OLD.SALARIO THEN
		INSERT INTO EMPREGADO2_AUDIT (USUARIO, DATA, ID, COLUNA, VALOR_ANTIGO, VALOR_NOVO) VALUES
		(CURRENT_USER, CURRENT_TIMESTAMP, OLD.CODIGO, 'SALARIO', OLD.SALARIO::TEXT, NEW.SALARIO::TEXT);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER TGR_AUDITA_EMPREGADO2 BEFORE UPDATE ON EMPREGADO2 FOR EACH ROW EXECUTE 
FUNCTION AUDITA_EMPREGADO2();

INSERT INTO EMPREGADO2 (NOME, SALARIO) VALUES ('João', 3000);

SELECT * FROM EMPREGADO2_AUDIT;

SELECT * FROM EMPREGADO2;

UPDATE EMPREGADO2 SET SALARIO = 3500 WHERE CODIGO = 1;

UPDATE EMPREGADO2 SET CODIGO = 999 WHERE CODIGO = 1;
