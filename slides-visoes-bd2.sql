-- Crie a tabela venda com os seguintes atributos:
-- Cod_venda, Nome_vendedor, data_venda, Valor_vendido

CREATE TABLE VENDA (
	COD_VENDA SERIAL PRIMARY KEY,
	NOME_VENDEDOR VARCHAR(30),
	DATA_VENDA DATE DEFAULT CURRENT_DATE,
	VALOR_VENDIDO FLOAT
);

-- 1) Povoe a tabela com 10 vendas, considerando que existam apenas 4 vendedores na loja.
INSERT INTO VENDA (NOME_VENDEDOR, DATA_VENDA, VALOR_VENDIDO) VALUES
('Sammya', '2024-04-01', 200),
('Sammya', '2024-03-01', 300),
('Sammya', '2024-03-06', 250),
('Sammya', '2024-03-22', 100),
('Enzo', '2024-03-01', 200),
('Enzo', '2024-03-01', 500),
('Enzo', '2024-03-01', 800),
('Jota', '2024-03-01', 230),
('Jota', '2024-03-01', 589),
('Jota', '2024-03-01', 178);

-- 2.1) Mostre o nome dos vendedores que venderam mais de X reais no mês de março de 2024.
SELECT NOME_VENDEDOR FROM VENDA WHERE DATA_VENDA BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY NOME_VENDEDOR HAVING SUM(VALOR_VENDIDO) > 1000;

-- 2.2) Mostre o nome de um dos vendedores que mais vendeu no mês de março de 2024
SELECT NOME_VENDEDOR, SUM(VALOR_VENDIDO) AS TOTAL_VENDIDO FROM VENDA WHERE DATA_VENDA BETWEEN '2024-03-01' AND 
'2024-03-31' GROUP BY NOME_VENDEDOR ORDER BY TOTAL_VENDIDO DESC LIMIT 1;

-- 3) Sem usar “select na cláusula from,”qual o nome do(s) vendedor(es) que mais vendeu no mês de março de 2024?
SELECT NOME_VENDEDOR, SUM(VALOR_VENDIDO) AS TOTAL_VENDIDO FROM VENDA WHERE DATA_VENDA BETWEEN '2024-03-01' AND 
'2024-03-31' GROUP BY NOME_VENDEDOR HAVING SUM(VALOR_VENDIDO) = (SELECT MAX(total) FROM (SELECT SUM(VALOR_VENDIDO) 
AS total FROM VENDA WHERE DATA_VENDA BETWEEN '2024-03-01' AND '2024-03-31' GROUP BY NOME_VENDEDOR) vendas);
