-- 1. Crie uma tabela aluno com as colunas matrícula e nome.
-- Depois crie um trigger que não permita o cadastro de alunos cujo nome começa com a letra “a”.
CREATE TABLE ALUNO (
	COD_ALUNO SERIAL PRIMARY KEY,
	NOME VARCHAR(30) NULL,
	MATRICULA VARCHAR(20) NULL
);

CREATE FUNCTION IMPEDE_CADASTRO_ALUNO_A()
RETURNS TRIGGER AS $$
BEGIN 
IF NEW.NOME ILIKE 'A%' THEN
	RAISE EXCEPTION 'O nome do aluno não pode começar com a letra A.';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER PROIBE_ALUNO_A BEFORE INSERT ON ALUNO FOR EACH ROW EXECUTE PROCEDURE IMPEDE_CADASTRO_ALUNO_A();

INSERT INTO ALUNO VALUES (2, 'Alanda', '123');

-- Primeiro crie uma tabela chamada Funcionário com os seguintes campos: código (int), nome (varchar(30)), 
-- salário(int), data_última_atualização (timestamp), usuário_que_atualizou (varchar(30)). Na inserção 
-- desta tabela, você deve informar apenas o código, nome e salário do funcionário. Agora crie um Trigger
-- que não permita o nome nulo, a salário nulo e nem negativo. Faça testes que comprovem o funcionamento
-- do Trigger. Obs: Raise Exception, ‘now’ e current_user

CREATE TABLE FUNCIONARIO (
	COD_FUNC SERIAL PRIMARY KEY, 
	NOME VARCHAR(30) NULL,
	SALARIO FLOAT NULL,
	DT_ULTIMA_ATUALIZACAO TIMESTAMP,
	USUARIO_QUE_ATUALIZOU VARCHAR(30)
);

-- não permita o nome nulo, a salário nulo e nem negativo
CREATE FUNCTION IMPEDE_VALORES_NULOS()
RETURNS TRIGGER AS $$
BEGIN 
IF NEW.NOME IS NULL THEN
	RAISE EXCEPTION 'O nome do funcionário não pode ser nulo.';
ELSIF NEW.SALARIO IS NULL THEN
	RAISE EXCEPTION 'O salário do funcionário não pode ser nulo.';
ELSIF NEW.SALARIO < 0 THEN
	RAISE EXCEPTION 'O salário do funcionário não pode ser valor negativo.';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER VERIFICA_ATRIBUTOS_FUNCIONARIO BEFORE INSERT ON FUNCIONARIO FOR EACH ROW EXECUTE PROCEDURE
IMPEDE_VALORES_NULOS();

INSERT INTO FUNCIONARIO (NOME, SALARIO) VALUES (NULL, 3100);
INSERT INTO FUNCIONARIO (NOME, SALARIO) VALUES ('Enzo', -9);
INSERT INTO FUNCIONARIO (NOME, SALARIO) VALUES ('Enzo', NULL);
INSERT INTO FUNCIONARIO (NOME, SALARIO) VALUES ('Enzo', 3100);

-- Agora crie uma tabela chamada Empregado com os atributos nome e salário. Crie também outra tabela 
-- chamada Empregado_auditoria com os atributos: operação (char(1)), usuário (varchar), data (timestamp), 
-- nome (varchar), salário (integer) . Agora crie um trigger que registre na tabela Empregado_auditoria a 
-- modificação que foi feita na tabela empregado (E,A,I), quem fez a modificação, a data da modificação, 
-- o nome do empregado que foi alterado e o salário atual dele.
-- Obs: variável especial TG_OP

CREATE TABLE EMPREGADO(
	COD_EMP SERIAL PRIMARY KEY,
	NOME VARCHAR(30) NULL,
	SALARIO FLOAT NULL
);

CREATE TABLE EMPREGADO_AUDITORIA(
	COD_EMP SERIAL PRIMARY KEY,
	OPERACAO CHAR(1),
	USUARIO VARCHAR(30), 
	DATA TIMESTAMP,
	NOME VARCHAR (30),
	SALARIO FLOAT
);

CREATE OR REPLACE FUNCTION AUDITA_EMPREGADO()
RETURNS TRIGGER AS $$ 
BEGIN
	IF TG_OP = 'INSERT' THEN
		INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO)
		VALUES ('I', current_user, current_timestamp, NEW.NOME, NEW.SALARIO);
	ELSIF TG_OP = 'UPDATE' THEN 
	    INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO)
		VALUES ('U', current_user, current_timestamp, NEW.NOME, NEW.SALARIO);
	ELSIF TG_OP = 'DELETE' THEN
		INSERT INTO EMPREGADO_AUDITORIA (OPERACAO, USUARIO, DATA, NOME, SALARIO)
		VALUES ('E', current_user, current_timestamp, NEW.NOME, NEW.SALARIO);
	END IF;
	
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER AUDITORIA_EMPREGADO
AFTER INSERT OR UPDATE OR DELETE ON EMPREGADO
FOR EACH ROW
EXECUTE FUNCTION AUDITA_EMPREGADO();

-- Crie a tabela Empregado2 com os atributos código (serial e chave primária), nome (varchar) e salário (integer). Crie
-- também a tabela Empregado2_audit com os seguintes atributos: usuário (varchar), data (timestamp), id (integer),
-- coluna (text), valor_antigo (text), valor_novo(text). Agora crie um trigger que não permita a alteração da chave primária e
-- insira registros na tabela Empregado2_audit para refletir as alterações realizadas na tabela Empregado2.

CREATE TABLE EMPREGADO2 (
	COD_EMP SERIAL PRIMARY KEY,
	NOME VARCHAR(30),
	SALARIO FLOAT
);

CREATE TABLE EMPREGADO2_AUDIT(
	COD_EMP SERIAL PRIMARY KEY,
	USUARIO VARCHAR(30),
	DATA TIMESTAMP,
	ID INT,
	COLUNA TEXT,
	VALOR_ANTIGO TEXT, 
	VALOR_NOVO TEXT
);

CREATE OR REPLACE FUNCTION TRG_AUDIT_EMPREGADO2()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.COD_EMP <> OLD.COD_EMP THEN
		RAISE EXCEPTION 'A chave primária não pode ser alterada.';
	END IF;
	
	-- Auditoria para alteração do nome
	IF NEW.NOME IS DISTINCT FROM OLD.NOME THEN
		INSERT INTO EMPREGADO2_AUDIT (USUARIO, DATA, ID, COLUNA, VALOR_ANTIGO, VALOR_NOVO) VALUES
		(CURRENT_USER, CURRENT_TIMESTAMP, OLD.COD_EMP, 'NOME', OLD.NOME, NEW.NOME);
	END IF;
	
	-- Auditoria para alteração do salário
	IF NEW.SALARIO IS DISTINCT FROM OLD.SALARIO THEN
		INSERT INTO EMPREGADO2_AUDIT (USUARIO, DATA, ID, COLUNA, VALOR_ANTIGO, VALOR_NOVO) VALUES
		(CURRENT_USER, CURRENT_TIMESTAMP, OLD.COD_EMP, 'SALARIO', OLD.SALARIO, NEW.SALARIO);
	END IF;
	
	RETURN NEW;
	
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TGR_EMPREGADO2 
BEFORE UPDATE ON EMPREGADO2
FOR EACH ROW
EXECUTE FUNCTION TRG_AUDIT_EMPREGADO2();

