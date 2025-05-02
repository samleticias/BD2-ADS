-- LISTA DE EXERCICIOS 2 

-- 1. Listagem dos hóspedes contendo nome e data de nascimento, ordenada em ordem
-- crescente por nome e decrescente por data de nascimento.
SELECT NOME, DT_NASC FROM HOSPEDE ORDER BY NOME ASC, DT_NASC DESC;

-- 2. Listagem contendo os nomes das categorias, ordenados alfabeticamente. A coluna de
-- nomes deve ter a palavra ‘Categoria’ como título.
SELECT NOME AS CATEGORIA FROM CATEGORIA ORDER BY NOME;

-- 3. Listagem contendo os valores de diárias e os números dos apartamentos, ordenada em
-- ordem decrescente de valor.
SELECT VALOR_DIA AS DIARIA_APTO, A.NUM FROM APARTAMENTO A JOIN CATEGORIA C ON A.COD_CAT = C.COD_CAT
ORDER BY VALOR_DIA DESC;

-- VALOR_DIA - TABELA CATEGORIA - COD_CAT
-- NUM - TABELA APARTAMENTO - COD_CAT

-- 4. Categorias que possuem apenas um apartamento.

-- TABELA CATEGORIA - COD_CAT
-- TABELA APARTAMENTO - COD_CAT 

SELECT NOME, COUNT(*) AS QUANTIDADE_APTO FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT
= A.COD_CAT GROUP BY NOME HAVING COUNT(*) = 1;

INSERT INTO CATEGORIA (COD_CAT, NOME, VALOR_DIA) VALUES (4, 'CATEGORIA TESTE', 300);
INSERT INTO APARTAMENTO (NUM, COD_CAT) VALUES (404, 4);

-- 5. Listagem dos nomes dos hóspedes brasileiros com mês e ano de nascimento, por ordem
-- decrescente de idade e por ordem crescente de nome do hóspede.
SELECT NOME, EXTRACT(MONTH FROM DT_NASC) AS MES, EXTRACT(YEAR FROM DT_NASC) AS ANO FROM HOSPEDE WHERE
NACIONALIDADE ILIKE 'BRASILEIRO' ORDER BY DT_NASC ASC, NOME ASC;

-- 6. Listagem com 3 colunas, nome do hóspede, número do apartamento e quantidade (número
-- de vezes que aquele hóspede se hospedou naquele apartamento), em ordem decrescente de
-- quantidade.
SELECT NOME, NUM, COUNT(*) AS QUANTIDADE_HO FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP
GROUP BY NOME, NUM ORDER BY QUANTIDADE_HO DESC;

INSERT INTO HOSPEDAGEM (COD_HOSPEDA, COD_HOSP, COD_FUNC, NUM, DT_ENT, DT_SAI) 
VALUES (4, 2, 2, 607, '2025-03-03', '2025-03-10');

-- 7. Categoria cujo nome tenha comprimento superior a 15 caracteres.
SELECT NOME FROM CATEGORIA WHERE LENGTH(NOME) > 15;

INSERT INTO CATEGORIA (COD_CAT, NOME, VALOR_DIA) VALUES (5, '123456789012345', 300);

-- 8. Número dos apartamentos ocupados no ano de 2017 com o respectivo nome da sua categoria.
SELECT A.NUM, NOME FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT JOIN HOSPEDAGEM HO ON A.NUM
= HO.NUM WHERE DT_ENT BETWEEN '2017-01-01' AND '2017-12-31';

INSERT INTO HOSPEDAGEM (COD_HOSPEDA, COD_HOSP, COD_FUNC, NUM, DT_ENT, DT_SAI) 
VALUES (5, 2, 2, 607, '2017-03-03', '2017-03-10');

-- 10. Crie a tabela funcionário com as atributos: cod_func, nome, dt_nascimento e salário.
-- Depois disso, acrescente o cod_func como chave estrangeira nas tabelas hospedagem e reserva.

-- 11. Mostre o nome e o salário de cada funcionário. Extraordinariamente, cada funcionário
-- receberá um acréscimo neste salário de 10 reais para cada hospedagem realizada.
SELECT NOME, SALARIO + COUNT(COD_HOSPEDA) * 10 AS NOVO_SALARIO FROM FUNCIONARIO F LEFT JOIN HOSPEDAGEM HO 
ON F.COD_FUNC = HO.COD_FUNC GROUP BY NOME, SALARIO;

-- LEFT JOIN: PODE HAVER FUNCIONARIO CADASTRADO QUE NÃO REALIZOU NENHUMA HOSPEDAGEM AINDA

INSERT INTO FUNCIONARIO (COD_FUNC, NOME, DT_NASC, SALARIO) 
VALUES (5, 'JOSE', '2001-02-02', 5000);

-- 12. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar
-- também o número do apartamento, ordenada pelo nome da categoria e pelo número do apartamento.
SELECT NOME, NUM FROM CATEGORIA C LEFT JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT ORDER BY NOME, NUM;

-- 13. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar
-- também o número do apartamento, ordenada pelo nome da categoria e pelo número do
-- apartamento. Para aquelas que não possuem apartamentos associados, escrever "não tem apartamento"

-- A FUNÇÃO COALESCE(PARAM, PARAM, PARAM ...) BUSCA O PRIMEIRO CAMPO QUE O ATRIBUTO FOR NULO E PREENCHE
-- COM O TEXTO SE NÃO ACHAR O ATRIBUTO PROCURADO 
-- SE A CATEGORIA NÃO TEM APARTAMENTO, PREENCHE 'NÃO TEM APARTAMENTO'
SELECT NOME, COALESCE(CAST(NUM AS TEXT), 'NÃO TEM APARTAMENTO') FROM CATEGORIA C LEFT JOIN APARTAMENTO
A ON C.COD_CAT = A.COD_CAT ORDER BY NOME, NUM;

-- 14. O nome dos funcionários que atenderam o João (hospedando) ou que
-- hospedaram apartamentos da categoria luxo.
SELECT DISTINCT NOME FROM FUNCIONARIO F JOIN HOSPEDAGEM HO ON F.COD_FUNC = HO.COD_FUNC WHERE COD_HOSP IN 
(SELECT COD_HOSP FROM HOSPEDE WHERE NOME ILIKE 'JOÃO')
UNION
SELECT DISTINCT NOME FROM FUNCIONARIO F JOIN HOSPEDAGEM HO ON F.COD_FUNC = HO.COD_FUNC WHERE NUM IN (
SELECT NUM FROM APARTAMENTO WHERE COD_CAT IN (SELECT COD_CAT FROM CATEGORIA WHERE NOME ILIKE 'LUXO'));

-- 15. O código das hospedagens realizadas pelo hóspede mais velho que se hospedou no
-- apartamento mais caro.
SELECT COD_HOSPEDA FROM HOSPEDAGEM WHERE COD_HOSP IN (SELECT COD_HOSP FROM HOSPEDE WHERE DT_NASC IN (
SELECT MIN(DT_NASC) FROM HOSPEDE WHERE COD_HOSP IN (SELECT COD_HOSP FROM HOSPEDAGEM WHERE NUM IN (SELECT
NUM FROM APARTAMENTO WHERE COD_CAT IN (SELECT COD_CAT FROM CATEGORIA WHERE VALOR_DIA = (SELECT 
MAX(VALOR_DIA) FROM CATEGORIA))))));

-- 16. Sem usar subquery, o nome dos hóspedes que nasceram na mesma data do hóspede de
-- código 2.
SELECT H1.NOME FROM HOSPEDE H1 JOIN HOSPEDE H2 ON H1.COD_HOSP <> H2.COD_HOSP AND H1.COD_HOSP = 2 AND
H1.DT_NASC = H2.DT_NASC;

-- 17. O nome do hóspede mais velho que se hospedou na categoria mais cara no ano de 2017.
SELECT NOME FROM HOSPEDE WHERE DT_NASC IN (SELECT MIN(DT_NASC) FROM HOSPEDE) AND COD_HOSP IN (SELECT
COD_HOSP FROM HOSPEDAGEM WHERE DT_ENT BETWEEN '2017-01-01' AND '2017-12-31' AND NUM IN (SELECT NUM FROM 
APARTAMENTO WHERE COD_CAT IN (SELECT COD_CAT FROM CATEGORIA WHERE VALOR_DIA IN (SELECT MAX(VALOR_DIA)
FROM CATEGORIA))));

-- 18. O nome das categorias que foram ocupadas pela Maria ou que foram ocupadas pelo João
-- quando ele foi atendido pelo Joaquim.
SELECT C.NOME FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT JOIN HOSPEDAGEM HO ON A.NUM =
HO.NUM JOIN HOSPEDE H ON HO.COD_HOSP = H.COD_HOSP WHERE H.NOME ILIKE 'MARIA'
UNION 
SELECT C.NOME FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT JOIN HOSPEDAGEM HO ON A.NUM =
HO.NUM JOIN HOSPEDE H ON HO.COD_HOSP = H.COD_HOSP JOIN FUNCIONARIO F ON HO.COD_FUNC = F.COD_FUNC
WHERE H.NOME ILIKE 'JOÃO' AND F.NOME ILIKE 'JOAQUIM';

-- 19. O nome e a data de nascimento dos funcionários, além do valor de diária mais cara
-- reservado por cada um deles.
SELECT F.NOME, F.DT_NASC, MAX(VALOR_DIA) FROM FUNCIONARIO F JOIN HOSPEDAGEM HO ON F.COD_FUNC = HO.COD_FUNC JOIN 
APARTAMENTO A ON HO.NUM = A.NUM JOIN CATEGORIA C ON A.COD_CAT = C.COD_CAT GROUP BY F.NOME, F.DT_NASC;

-- 20. A quantidade de apartamentos ocupados por cada um dos hóspedes (mostrar o nome).
SELECT NOME, COUNT(DISTINCT HO.NUM) AS QUANTIDADE_APTO FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = 
HO.COD_HOSP GROUP BY H.NOME ORDER BY H.NOME;

-- 21. A relação com o nome dos hóspedes, a data de entrada, a data de saída e o valor total
-- pago em diárias (não é necessário considerar a hora de entrada e saída, apenas as datas).
SELECT H.NOME, HO.DT_ENT, HO.DT_SAI, COALESCE((HO.DT_SAI - HO.DT_ENT) * C.VALOR_DIA, 0) AS VALOR_TOTAL
FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP JOIN APARTAMENTO A ON HO.NUM = A.NUM JOIN
CATEGORIA C ON A.COD_CAT = C.COD_CAT ORDER BY H.NOME;

-- 22. O nome dos hóspedes que já se hospedaram em todos os apartamentos do hotel.
SELECT H.NOME FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP GROUP BY H.NOME, H.COD_HOSP
HAVING COUNT(DISTINCT HO.NUM) = (SELECT COUNT(*) FROM APARTAMENTO);
