SELECT * FROM EMPLOYEES;

SELECT FIRST_NAME FROM EMPLOYEES
ORDER BY FIRST_NAME ASC;

SELECT FIRST_NAME PRIMEIRO_NOME, LAST_NAME AS SOBRENOME, 
FIRST_NAME || ' ' || LAST_NAME AS "NOME_COMPLETO"
FROM EMPLOYEES
ORDER BY FIRST_NAME ASC;

-- Retornar o nome completo dos funcionários entre parenteses e ID de cada um 
SELECT FIRST_NAME PRIMEIRO_NOME, LAST_NAME AS SOBRENOME, 
FIRST_NAME || ' ' || LAST_NAME || ' ' || '(' || EMPLOYEE_ID || ')' AS "NOME_COMPLETO"
FROM EMPLOYEES
ORDER BY FIRST_NAME ASC;

-- Listagem de todos os funcionario com o salario atual e o salário acrescido de 5,5% para projeção do aumento
SELECT EMPLOYEE_ID AS "ID_FUNCIONARIO",
FIRST_NAME || ' ' || LAST_NAME AS "NOME_COMPLETO",
SALARY AS "SALARIO_ATUAL",
SALARY * 1.055 AS "SALARIO_COM_AUMENTO"
FROM EMPLOYEES;

select hire_date
from employees;

-- Faça uma listagem com o primeiro nome do funcionario e o tempo em anos que ele tem de empresa, trazer todos os funcionarios com base na coluna hire_date
SELECT FIRST_NAME AS "PRIMEIRO_NOME",
TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) AS "TEMPO_DE_EMPRESA"
FROM EMPLOYEES;

-- Listagem de funcionarios e cargos
SELECT EMPLOYEE_ID, FIRST_NAME, JOB_TITLE
FROM EMPLOYEES EMP
RIGHT JOIN JOBS J 
ON EMP.JOB_ID = J.JOB_ID;

-- Listagem de funcionarios com o nome do departamento que trabalham (tabelas EMPLOYEES e DEPARTMENTS, coluna DEPARTMENT_ID)
SELECT EMPLOYEE_ID, FIRST_NAME, DEPARTMENT_NAME
FROM EMPLOYEES EMP
LEFT JOIN DEPARTMENTS D
ON EMP.DEPARTMENT_ID = D.DEPARTMENT_ID

-- Listar employee_id, first_name, job_title, department_name, trazer todos os funcionarios
SELECT EMPLOYEE_ID, FIRST_NAME, JOB_TITLE, DEPARTMENT_NAME
FROM EMPLOYEES EMP
INNER JOIN JOBS JOB
ON EMP.JOB_ID = JOB.JOB_ID
LEFT JOIN DEPARTAMENTS DEP
ON EMP.DEPARTMENT_ID = DEP.DEPARTMENT_ID;

-- Listar todas as cidades da europa (tabela LOCATIONS e REGIONS)