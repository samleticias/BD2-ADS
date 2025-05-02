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

-- 4. Categorias que possuem apenas um apartamento.
SELECT NOME FROM (SELECT NOME, COUNT(NOME) QUANTIDADE FROM APARTAMENTO A JOIN CATEGORIA C ON A.COD_CAT
 = C.COD_CAT GROUP BY NOME) WHERE QUANTIDADE = 1;
 
SELECT NOME FROM APARTAMENTO A JOIN CATEGORIA C ON A.COD_CAT = C.COD_CAT GROUP BY NOME 
HAVING COUNT(NOME) = 1;

-- 5. Listagem dos nomes dos hóspedes brasileiros com mês e ano de nascimento, por ordem
-- decrescente de idade e por ordem crescente de nome do hóspede.
SELECT NOME FROM HOSPEDE WHERE NACIONALIDADE ILIKE 'BRASILEIRO' ORDER BY DT_NASC ASC, NOME ASC;

-- 6. Listagem com 3 colunas, nome do hóspede, número do apartamento e quantidade (número
-- de vezes que aquele hóspede se hospedou naquele apartamento), em ordem decrescente de
-- quantidade.
SELECT NOME, NUM, COUNT(*) QUANTIDADE FROM HOSPEDE H JOIN HOSPEDAGEM HO ON H.COD_HOSP = HO.COD_HOSP GROUP
BY NOME, NUM ORDER BY QUANTIDADE DESC;

-- 7. Categoria cujo nome tenha comprimento superior a 15 caracteres.
SELECT NOME FROM CATEGORIA WHERE LENGTH(NOME) > 5;

-- 8. Número dos apartamentos ocupados no ano de 2017 com o respectivo nome da sua categoria.


-- 9. Título do livro, nome da editora que o publicou e a descrição do assunto.


-- 10. Crie a tabela funcionário com as atributos: cod_func, nome, dt_nascimento e salário.
-- Depois disso, acrescente o cod_func como chave estrangeira nas tabelas hospedagem e
-- reserva.
ALTER TABLE FUNCIONARIO ADD COLUMN SALARIO FLOAT NOT NULL DEFAULT 0;

-- 11. Mostre o nome e o salário de cada funcionário. Extraordinariamente, cada funcionário
-- receberá um acréscimo neste salário de 10 reais para cada hospedagem realizada.
SELECT NOME, SALARIO + COUNT(COD_HOSPEDA) * 10 FROM FUNCIONARIO F LEFT JOIN HOSPEDAGEM H ON F.COD_FUNC = H.COD_FUNC
GROUP BY NOME, SALARIO;

-- 12. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar
-- também o número do apartamento, ordenada pelo nome da categoria e pelo número do
-- apartamento.


-- 13. Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar
-- também o número do apartamento, ordenada pelo nome da categoria e pelo número do
-- apartamento. Para aquelas que não possuem apartamentos associados, escrever "não possui
-- apartamento"

-- A FUNÇÃO COALESCE(PARAM, PARAM, PARAM ...) BUSCA O PRIMEIRO CAMPO QUE O ATRIBUTO FOR NULO E PREENCHE
-- COM O TEXTO SE NÃO ACHAR O ATRIBUTO PROCURADO 
-- SE A CATEGORIA NÃO TEM APARTAMENTO, PREENCHE 'NÃO TEM APARTAMENTO'
SELECT NOME, COALESCE(CAST(NUM AS TEXT), 'NÃO TEM APARTAMENTO') FROM CATEGORIA C LEFT JOIN APARTAMENTO
A ON C.COD_CAT = A.COD_CAT

-- 14. O nome dos funcionário que atenderam o João (hospedando ou reservando) ou que
-- hospedaram ou reservaram apartamentos da categoria luxo.


-- 15. O código das hospedagens realizadas pelo hóspede mais velho que se hospedou no
-- apartamento mais caro.
SELECT COD_HOSPEDA FROM HOSPEDAGEM WHERE COD_HOSP IN (SELECT COD_HOSP FROM HOSPEDE WHERE DT_NASC IN(
SELECT MIN(DT_NASC) FROM HOSPEDE WHERE COD_HOSP IN(SELECT COD_HOSP FROM HOSPEDAGEM WHERE NUM IN(SELECT
NUM FROM APARTAMENTO WHERE COD_CAT IN (SELECT COD_CAT FROM CATEGORIA WHERE VALOR_DIA ))))

-- 16. Sem usar subquery, o nome dos hóspedes que nasceram na mesma data do hóspede de
-- código 2.
-- COM SUB-QUERY
SELECT NOME FROM HOSPEDE WHERE DT_NASC IN (SELECT DT_NASC FROM HOSPEDE WHERE COD_HOSP = 2);

-- SEM SUB-QUERY
SELECT H1.NOME FROM HOSPEDE H1 JOIN HOSPEDE H2 ON H1.COD_HOSP <> H2.COD_HOSP AND H1.COD_HOSP = 2 AND
H1.DT_NASC = H2.DT_NASC;