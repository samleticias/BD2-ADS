-- obter o nome dos hospedes que nunca se hospedaram (sem usar "not in" e "except")
SELECT NOME FROM HOSPEDE WHERE COD_HOSP NOT IN (SELECT COD_HOSP FROM HOSPEDAGEM);

SELECT NOME FROM (SELECT COD_HOSP, NOME FROM HOSPEDE EXCEPT SELECT H.COD_HOSP, NOME FROM 
HOSPEDAGEM HO, HOSPEDE H WHERE HO.COD_HOSP = HO.COD_HOSP);

-- inner join ou só join - junção interna
-- outer join - junção externa
  -- left outer join
  -- right outer join
  -- full outer join
  
-- nome de todas as categorias e, quando possivel, o numero dos respectivos apartamentos
-- seleciona todas as linhas da tabela da direita que se relacionam com a tabela da esquerda
SELECT NOME, NUM FROM APARTAMENTO A RIGHT JOIN CATEGORIA C ON A.COD_CAT = C.COD_CAT;

SELECT NOME FROM HOSPEDE H LEFT JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP WHERE HO.COD_HOSPEDA IS NULL;

-- nome de todos os hospedes de forma ordenada
SELECT * FROM HOSPEDE ORDER BY NOME ASC; -- ascendente
SELECT * FROM HOSPEDE ORDER BY NOME DESC; -- descendente

SELECT * FROM HOSPEDE ORDER BY NOME DESC, DT_NASC ASC;

-- DISTINCT: elimina valores iguais
SELECT DISTINCT NOME FROM HOSPEDE;

-- GROUP BY: agrupa tudo que é igual
SELECT NOME FROM HOSPEDE GROUP BY NOME
SELECT NOME, COUNT(NOME) AS QUANTIDADE FROM HOSPEDE GROUP BY NOME ORDER BY QUANTIDADE

-- GROUP BY

-- 1. Listagem dos hóspedes contendo nome e data de nascimento, ordenada em ordem
-- crescente por nome e decrescente por data de nascimento
SELECT NOME, DT_NASC FROM HOSPEDE ORDER BY NOME ASC, DT_NASC DESC;

-- obter a quantidade de hospedagens realizadas por cada nome de hospede 
SELECT NOME, COUNT(NOME) AS QUANTIDADE FROM HOSPEDE H, HOSPEDAGEM HO WHERE H.COD_HOSP = HO.COD_HOSP 
GROUP BY NOME;

SELECT NOME, COUNT(NOME) AS QUANTIDADE FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP
GROUP BY NOME;

-- 2. Listagem contendo os nomes das categorias, ordenados alfabeticamente. A coluna de
-- nomes deve ter a palavra ‘Categoria’ como título.
SELECT NOME AS CATEGORIA FROM CATEGORIA ORDER BY CATEGORIA ASC;

-- 3. Listagem contendo os valores de diárias e os números dos apartamentos, ordenada em
-- ordem decrescente de valor.
SELECT VALOR_DIA, NUM FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT ORDER BY VALOR_DIA DESC;

-- obter, para cada nome de categoria, a quantidade de hospedagens realizadas
SELECT NOME, COUNT(NOME) AS QUANTIDADE FROM CATEGORIA C JOIN APARTAMENTO A ON C.COD_CAT = A.COD_CAT JOIN HOSPEDAGEM
HO ON A.NUM = HO.NUM GROUP BY NOME;




