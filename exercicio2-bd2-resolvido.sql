-- 1. Listagem dos hóspedes contendo nome e data de nascimento, ordenada em ordem crescente por nome e decrescente por 
-- data de nascimento.
SELECT NOME, DT_NASC FROM HOSPEDE ORDER BY NOME ASC, DT_NASC DESC;

-- 2. Listagem contendo os nomes das categorias, ordenados alfabeticamente. A coluna de nomes deve ter a palavra ‘Categoria’ 
-- como título.
SELECT NOME AS CATEGORIA FROM CATEGORIA ORDER BY NOME;

-- 3. Listagem contendo os valores de diárias e os números dos apartamentos, ordenada em ordem decrescente de valor.
SELECT NUM AS NUMERO_APTO, VALOR_DIA FROM CATEGORIA C, APARTAMENTO A WHERE C.COD_CAT = A.COD_CAT ORDER BY VALOR_DIA DESC;

SELECT NUM AS NUMERO_APTO, VALOR_DIA FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT ORDER BY VALOR_DIA DESC;

-- 4. Categorias que possuem apenas um apartamento.
SELECT NOME FROM CATEGORIA C, APARTAMENTO A WHERE C.COD_CAT = A.COD_CAT GROUP BY NOME HAVING COUNT(A.NUM) = 1;

SELECT NOME FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT GROUP BY NOME HAVING COUNT(A.NUM) = 1;

-- 5. Listagem dos nomes dos hóspedes brasileiros com mês e ano de nascimento, por ordem decrescente de idade e por ordem 
-- crescente de nome do hóspede.
SELECT NOME, EXTRACT(YEAR FROM DT_NASC) AS ANO, EXTRACT(MONTH FROM DT_NASC) AS MES FROM HOSPEDE ORDER BY ANO DESC, NOME ASC; 

-- 6. Listagem com 3 colunas, nome do hóspede, número do apartamento e quantidade (número de vezes que aquele hóspede se 
-- hospedou naquele apartamento), em ordem decrescente de quantidade.
SELECT NOME, HO.NUM, COUNT(*) AS QUANTIDADE FROM HOSPEDE H, HOSPEDAGEM HO, APARTAMENTO A WHERE H.COD_HOSP = HO.COD_HOSP AND
HO.NUM = A.NUM GROUP BY NOME, HO.NUM ORDER BY QUANTIDADE DESC;

SELECT NOME, HO.NUM, COUNT(*) AS QUANTIDADE FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP JOIN APARTAMENTO A
ON HO.NUM = A.NUM GROUP BY NOME, HO.NUM ORDER BY QUANTIDADE DESC;

-- 7. Categoria cujo nome tenha comprimento superior a 15 caracteres.
SELECT NOME FROM CATEGORIA WHERE LENGTH(NOME) > 15;

-- 8. Número dos apartamentos ocupados no ano de 2017 com o respectivo nome da sua categoria.
SELECT NOME AS CATEGORIA, A.NUM FROM CATEGORIA C, APARTAMENTO A, HOSPEDAGEM HO WHERE C.COD_CAT = A.COD_CAT AND A.NUM = HO.NUM 
AND DT_ENT BETWEEN '2017-01-01' AND '2017-12-31';

SELECT NOME AS CATEGORIA, A.NUM FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT JOIN HOSPEDAGEM HO ON A.NUM = 
HO.NUM AND DT_ENT BETWEEN '2017-01-01' AND '2017-12-31';

-- 9. Título do livro, nome da editora que o publicou e a descrição do assunto.

-- 10. Crie a tabela funcionário com as atributos: cod_func, nome, dt_nascimento e salário. Depois disso, acrescente o 
-- cod_func como chave estrangeira nas tabelas hospedagem e reserva.
CREATE TABLE FUNCIONARIO (
	COD_FUNC SERIAL PRIMARY KEY, 
	NOME VARCHAR(30),
	DT_NASC DATE,
	SALARIO FLOAT
);

ALTER TABLE HOSPEDAGEM ADD COLUMN COD_FUNC INT;
ALTER TABLE RESERVA ADD COLUMN COD_FUNC INT;

ALTER TABLE HOSPEDAGEM ADD CONSTRAINT fk_hospedagem_func FOREIGN KEY (COD_FUNC) REFERENCES FUNCIONARIO(COD_FUNC);
ALTER TABLE RESERVA ADD CONSTRAINT fk_reserva_func FOREIGN KEY (COD_FUNC) REFERENCES FUNCIONARIO(COD_FUNC);

-- 11. Mostre o nome e o salário de cada funcionário. Extraordinariamente, cada funcionário receberá um acréscimo neste 
-- salário de 10 reais para cada hospedagem realizada.
SELECT NOME, SALARIO + (COUNT(*) * 10) AS SALARIO_ATUALIZADO FROM FUNCIONARIO F LEFT JOIN HOSPEDAGEM HO ON F.COD_FUNC = 
HO.COD_FUNC GROUP BY NOME, SALARIO;

-- 12. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar também o número do apartamento,
-- ordenada pelo nome da categoria e pelo número do apartamento.
SELECT NOME, NUM FROM CATEGORIA C LEFT JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT GROUP BY NOME, NUM ORDER BY NOME, NUM;

-- 13. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar também o número do apartamento,
-- ordenada pelo nome da categoria e pelo número do apartamento. Para aquelas que não possuem apartamentos associados, escrever 
-- "não possui apartamento".
SELECT NOME AS CATEGORIA, COALESCE(A.NUM::TEXT, 'não possui apartamento') AS NUMERO_APTO FROM CATEGORIA C LEFT JOIN 
APARTAMENTO A ON C.COD_CAT = A.COD_CAT GROUP BY NOME, NUM ORDER BY NOME, A.NUM;

-- 14. O nome dos funcionário que atenderam o João (hospedando) ou que hospedaram apartamentos da categoria luxo.
SELECT NOME FROM FUNCIONARIO F, HOSPEDAGEM HO WHERE F.COD_FUNC = HO.COD_FUNC AND COD_HOSP IN (SELECT COD_HOSP FROM 
HOSPEDE WHERE NOME ILIKE 'João')
UNION
SELECT NOME FROM FUNCIONARIO F, HOSPEDAGEM HO WHERE F.COD_FUNC = HO.COD_FUNC AND HO.NUM IN (SELECT NUM FROM APARTAMENTO
WHERE COD_CAT IN (SELECT COD_CAT FROM CATEGORIA WHERE NOME ILIKE 'Luxo'));

-- 15. O código das hospedagens realizadas pelo hóspede mais velho que se hospedou no apartamento mais caro.
SELECT COD_HOSPEDA FROM HOSPEDAGEM HO, HOSPEDE H, APARTAMENTO A WHERE HO.COD_HOSP = H.COD_HOSP AND HO.NUM = A.NUM AND 
H.DT_NASC IN (SELECT MIN(DT_NASC) FROM HOSPEDE) AND A.NUM IN (SELECT NUM FROM APARTAMENTO WHERE COD_CAT IN (SELECT COD_CAT 
FROM CATEGORIA WHERE VALOR_DIA IN (SELECT MAX(VALOR_DIA) FROM CATEGORIA)));

-- 16. Sem usar subquery, o nome dos hóspedes que nasceram na mesma data do hóspede de código 2.
SELECT H1.NOME FROM HOSPEDE H1, HOSPEDE H2 WHERE H1.DT_NASC = H2.DT_NASC AND H1.COD_HOSP <> H2.COD_HOSP AND H2.COD_HOSP = 2;

SELECT H1.NOME FROM HOSPEDE H1 JOIN HOSPEDE H2 ON H1.DT_NASC = H2.DT_NASC WHERE H1.COD_HOSP <> H2.COD_HOSP AND H2.COD_HOSP = 2;

-- 17. O nome do hóspede mais velho que se hospedou na categoria mais cara no ano de 2017.
SELECT NOME FROM HOSPEDE H, HOSPEDAGEM HO, APARTAMENTO A WHERE H.COD_HOSP = HO.COD_HOSP AND HO.NUM = A.NUM AND H.DT_NASC IN (
SELECT MIN(DT_NASC) FROM HOSPEDE) AND A.COD_CAT IN (SELECT COD_CAT FROM CATEGORIA WHERE VALOR_DIA IN (SELECT MAX(VALOR_DIA) 
FROM CATEGORIA)) AND DT_ENT BETWEEN '2017-01-01' AND '2017-12-31' ORDER BY H.DT_NASC LIMIT 1;

INSERT INTO HOSPEDE (COD_HOSP, NOME, DT_NASC) VALUES
(17, 'Ana', '1921-05-01'),
(20, 'Carlos', '1990-08-15'),
(34, 'João Teste', '1975-03-10');

INSERT INTO CATEGORIA (COD_CAT, NOME, VALOR_DIA) VALUES
(34, 'Luxuoso', 500.00),
(35, 'Econômico', 200.00);

INSERT INTO APARTAMENTO (NUM, COD_CAT) VALUES
(143, 34),
(144, 35);

INSERT INTO HOSPEDAGEM (COD_HOSPEDA, COD_HOSP, COD_FUNC, NUM, DT_ENT) VALUES
(26, 1, 1, 143, '2017-06-10'),
(27, 2, 1, 144, '2017-06-11'), 
(28, 3, 1, 143, '2018-01-05'); 

-- 18. O nome das categorias que foram ocupadas pela Maria ou que foram ocupadas pelo João quando ele foi atendido pelo Joaquim.
SELECT DISTINCT C.NOME FROM CATEGORIA C, HOSPEDAGEM HO, APARTAMENTO A, HOSPEDE H WHERE H.COD_HOSP = HO.COD_HOSP AND HO.NUM = A.NUM AND
A.COD_CAT = C.COD_CAT AND H.NOME ILIKE 'Maria' 
UNION 
SELECT DISTINCT C.NOME FROM CATEGORIA C, HOSPEDAGEM HO, FUNCIONARIO F, APARTAMENTO A, HOSPEDE H WHERE H.COD_HOSP = HO.COD_HOSP AND 
HO.NUM = A.NUM AND A.COD_CAT = C.COD_CAT AND F.COD_FUNC = HO.COD_FUNC AND H.NOME ILIKE 'João' AND F.NOME ILIKE 'Joaquim';

-- 19. O nome e a data de nascimento dos funcionários, além do valor de diária mais cara reservado por cada um deles.
SELECT F.NOME, F.DT_NASC, MAX(C.VALOR_DIA) AS VALOR_MAIS_CARO FROM FUNCIONARIO F JOIN HOSPEDAGEM H ON F.COD_FUNC = H.COD_FUNC
JOIN APARTAMENTO A ON H.NUM = A.NUM JOIN CATEGORIA C ON A.COD_CAT = C.COD_CAT GROUP BY F.NOME, F.DT_NASC;

-- 20. A quantidade de apartamentos ocupados por cada um dos hóspedes (mostrar o nome).
SELECT NOME, COUNT(DISTINCT A.NUM) AS QUANTIDADE_APTO FROM HOSPEDE H, HOSPEDAGEM HO, APARTAMENTO A WHERE H.COD_HOSP = HO.COD_HOSP AND
HO.NUM = A.NUM GROUP BY NOME;

-- 21. A relação com o nome dos hóspedes, a data de entrada, a data de saída e o valor total pago em diárias (não é necessário
-- considerar a hora de entrada e saída, apenas as datas).
SELECT H.NOME, HO.DT_ENT, HO.DT_SAI, (HO.DT_SAI - HO.DT_ENT) * C.VALOR_DIA AS VALOR_TOTAL FROM HOSPEDE H JOIN HOSPEDAGEM HO 
ON H.COD_HOSP = HO.COD_HOSP JOIN APARTAMENTO A ON HO.NUM = A.NUM JOIN CATEGORIA C ON A.COD_CAT = C.COD_CAT;

-- 22. O nome dos hóspedes que já se hospedaram em todos os apartamentos do hotel.
SELECT H.NOME FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP GROUP BY H.COD_HOSP, H.NOME HAVING COUNT(DISTINCT
HO.NUM) = (SELECT COUNT(*) FROM APARTAMENTO);