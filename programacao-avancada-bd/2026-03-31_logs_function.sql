DROP TABLE FUNCIONARIOS_AQB;
CREATE TABLE FUNCIONARIOS_AQB AS (SELECT * FROM HR.EMPLOYEES);

CREATE OR REPLACE FUNCTION AUMENTA_SALARIO_AQB(P_PERC IN NUMBER)
RETURN NUMBER
IS
    V_RETORNO NUMBER(5);
    V_NOVO_SALARIO EMPLOYEES.SALARY%TYPE;
BEGIN
    IF P_PERC > 0 AND P_PERC <= 15 THEN
        FOR I IN (SELECT EMPLOYEE_ID, DEPARTMENT_ID, SALARY FROM FUNCIONARIOS_AQB WHERE JOB_ID != 'AD_PRES' AND JOB_ID != 'AD_VP')
        LOOP
            v_SALARY_NOVO := RS.SALARY + (RS.SALARY * P_PERC / 100);
            IF I.SALARY < 10000 THEN
                IF v_SALARY_NOVO > 10000 THEN
                    v_SALARY_NOVO := 10000;
                END IF;
            END IF;
            UPDATE FUNCIONARIOS_AQB SET SALARY = V_NOVO_SALARIO
                WHERE EMPLOYEE_ID = I.EMPLOYEE_ID;
            END LOOP;
            V_RET := 0; --SUCESSO
            ELSE
                V_RET := -1; --PERCENTUAL FORA DA FAIXA ACEITÁVEL
            END IF;
            COMMIT;
    RETURN V_RET;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN SQLCODE;
END;

-- CASOS DE TESTE

DECLARE
    v_perc   NUMBER := 10;
    v_ret    NUMBER;
    v_antes  NUMBER;
    v_depois NUMBER;
    v_emp_id FUNCIONARIOS_AQB.EMPLOYEE_ID%TYPE;
BEGIN
    -- escolhe 1 funcionário elegível (não presidente e não vice) para conferir antes/depois
    SELECT employee_id
      INTO v_emp_id
      FROM FUNCIONARIOS_AQB
     WHERE job_id NOT IN ('AD_PRES', 'AD_VP')
       AND ROWNUM = 1;

    SELECT salary INTO v_antes FROM FUNCIONARIOS_AQB WHERE employee_id = v_emp_id;

    SAVEPOINT sp_teste_1;

    v_ret := AUMENTA_SALARIO_AQB(v_perc);

    SELECT salary INTO v_depois FROM FUNCIONARIOS_AQB WHERE employee_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Teste 1 (sucesso)');
    DBMS_OUTPUT.PUT_LINE('  Perc=' || v_perc || ' Retorno=' || v_ret);
    DBMS_OUTPUT.PUT_LINE('  Emp=' || v_emp_id || ' Salário antes=' || v_antes || ' depois=' || v_depois);

    -- desfaz alterações do teste (a função COMMITA, então o ROLLBACK não desfaz).
    -- Se você quer testes que não alterem dados, remova o COMMIT de dentro da função.
    -- Aqui, o ROLLBACK só funciona se a função NÃO fizer COMMIT.
    ROLLBACK TO sp_teste_1;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Teste 1: não há funcionário elegível em FUNCIONARIOS_AQB.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Teste 1: erro: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END;
/

-- Teste 2: caminho de erro (percentual fora da faixa: <=0).
DECLARE
    v_ret NUMBER;
BEGIN
    v_ret := AUMENTA_SALARIO_AQB(0);
    DBMS_OUTPUT.PUT_LINE('Teste 2 (inválido <=0) Retorno=' || v_ret);
END;
/

-- Teste 3: caminho de erro (percentual fora da faixa: >15).
DECLARE
    v_ret NUMBER;
BEGIN
    v_ret := AUMENTA_SALARIO_AQB(16);
    DBMS_OUTPUT.PUT_LINE('Teste 3 (inválido >15) Retorno=' || v_ret);
END;
/

-- Teste 4: caminho do teto (funcionário com salário < 10000 não pode ultrapassar 10000).
-- OBS: este teste só valida se existir alguém com salário entre um valor próximo do teto.
DECLARE
    v_perc   NUMBER := 15;
    v_ret    NUMBER;
    v_antes  NUMBER;
    v_depois NUMBER;
    v_emp_id FUNCIONARIOS_AQB.EMPLOYEE_ID%TYPE;
BEGIN
    SELECT employee_id
      INTO v_emp_id
      FROM FUNCIONARIOS_AQB
     WHERE job_id NOT IN ('AD_PRES', 'AD_VP')
       AND salary < 10000
       AND salary >= 9000
       AND ROWNUM = 1;

    SELECT salary INTO v_antes FROM FUNCIONARIOS_AQB WHERE employee_id = v_emp_id;

    SAVEPOINT sp_teto;

    v_ret := AUMENTA_SALARIO_AQB(v_perc);

    SELECT salary INTO v_depois FROM FUNCIONARIOS_AQB WHERE employee_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Teste 4 (teto)');
    DBMS_OUTPUT.PUT_LINE('  Perc=' || v_perc || ' Retorno=' || v_ret);
    DBMS_OUTPUT.PUT_LINE('  Emp=' || v_emp_id || ' Salário antes=' || v_antes || ' depois=' || v_depois);
    DBMS_OUTPUT.PUT_LINE('  Esperado: depois <= 10000');

    ROLLBACK TO sp_teto;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Teste 4: não encontrei funcionário com salário entre 9000 e 9999 para validar o teto.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Teste 4: erro: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END;
/

-- Teste 5: caminho > 10000 (se já ganha > 10000, deve continuar > 10000 e aplicar aumento).
DECLARE
    v_perc   NUMBER := 5;
    v_ret    NUMBER;
    v_antes  NUMBER;
    v_depois NUMBER;
    v_emp_id FUNCIONARIOS_AQB.EMPLOYEE_ID%TYPE;
BEGIN
    SELECT employee_id
      INTO v_emp_id
      FROM FUNCIONARIOS_AQB
     WHERE job_id NOT IN ('AD_PRES', 'AD_VP')
       AND salary > 10000
       AND ROWNUM = 1;

    SELECT salary INTO v_antes FROM FUNCIONARIOS_AQB WHERE employee_id = v_emp_id;

    SAVEPOINT sp_maior_10000;

    v_ret := AUMENTA_SALARIO_AQB(v_perc);

    SELECT salary INTO v_depois FROM FUNCIONARIOS_AQB WHERE employee_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Teste 5 (>10000)');
    DBMS_OUTPUT.PUT_LINE('  Perc=' || v_perc || ' Retorno=' || v_ret);
    DBMS_OUTPUT.PUT_LINE('  Emp=' || v_emp_id || ' Salário antes=' || v_antes || ' depois=' || v_depois);
    DBMS_OUTPUT.PUT_LINE('  Esperado: depois = antes * (1 + perc/100)');

    ROLLBACK TO sp_maior_10000;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Teste 5: não encontrei funcionário com salário > 10000 para validar este caminho.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Teste 5: erro: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END;

--------------------------------------

DECLARE
    RETORNO NUMBER(5);
BEGIN
    RETORNO := AUMENTA_SALARIO_AQB(10);
    DBMS_OUTPUT.PUT_LINE('Retorno da função: ' || RETORNO);
END;

--------------------------------------
DROP TABLE FUNCIONARIOS_AQB_LOG;
CREATE TABLE FUNCIONARIOS_AQB_LOG (
    ID_LOG NUMBER PRIMARY KEY,
    EMPLOYEE_ID NUMBER(6) NOT NULL,
    SALARY_ANTES NUMBER(10,2) NOT NULL,
    SALARY_DEPOIS NUMBER(10,2) NOT NULL,
    USUARIO VARCHAR2(30) NOT NULL,
    DTH_REGISTRO DATE NOT NULL
);

DROP SEQUENCE SEQ_FUNCIONARIOS_AQB_LOG;
CREATE SEQUENCE SEQ_FUNCIONARIOS_AQB_LOG
NO CACHE
NO CYCLE;

CREATE OR REPLACE FUNCTION AUMENTA_SALARIO_AQB(P_PERC IN NUMBER)
RETURN NUMBER
IS
    V_RETORNO NUMBER(5);
    V_NOVO_SALARIO EMPLOYEES.SALARY%TYPE;
    V_ERRO NUMBER;
    V_DESC_ERRO VARCHAR2(1000);
BEGIN

    IF P_PERC > 0 AND P_PERC <= 15 THEN
        FOR I IN (SELECT EMPLOYEE_ID, DEPARTMENT_ID, SALARY FROM FUNCIONARIOS_AQB WHERE JOB_ID != 'AD_PRES' AND JOB_ID != 'AD_VP')
        LOOP
            IF I.SALARY < 10000 THEN
            END IF;
            UPDATE FUNCIONARIOS_AQB SET SALARY = V_NOVO_SALARIO
                WHERE EMPLOYEE_ID = RS.EMPLOYEE_ID;

            INSERT INTO FUNCIONARIOS_AQB_LOG 
                (ID_LOG, EMPLOYEE_ID, SALARY_ANTES, SALARY_DEPOIS, USUARIO, DTH_REGISTRO)
            VALUES(SEQ_FUNCIONARIOS_AQB_LOG.NEXTVAL, I.EMPLOYEE_ID, I.SALARY, V_NOVO_SALARIO, USER, SYSDATE);

        END LOOP;
        V_RET := 0; --SUCESSO
    ELSE
        V_RET := -1; --PERCENTUAL FORA DA FAIXA ACEIT
    END IF;
    COMMIT;
    RETURN V_RET;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN SQLCODE;

        V_ERRO := SQLCODE;
        V_DESERRO := SQLERRM;

        INSERT INTO LOG_EXECUCAO
        (ID_LOG, ERRO, DESC_ERRO, NOME_CODIGO, PARAMETROS, DTH_ERRO, USUARIO, RESOLVIDO, DESC_RESOLVIDO)
        VALUES(SEQ_LOG_EXECUCAO.NEXTVAL, V_
        ERRO, V_DESC_ERRO, 'XXXXXXX', 'AUMENTA_SALARIO_AQB', 'P_PERC = ' || P_PERC, SYSDATE, USER, 'N', NULL);
        COMMIT;
    RETURN SQLCODE;
END;

SELECT * FROM ID_LOG, EMPLOYEE_ID, SALARY_ANTES, SALARY_DEPOIS,
USUARIO, TO_CHAR(DTH_REGISTRO, 'DD/MM/YYYY HH24:MI:SS') , USUARIO
FROM FUNCIONARIOS_AQB_LOG WHERE EMPLOYEE_ID = 108
ORDER BY DTH_REGISTRO DESC;

DROP TABLE LOG_EXECUCAO;
CREATE TABLE LOG_EXECUCAO(
    ID_LOG NUMBER PRIMARY KEY,
    ERRO NUMBER NOT NULL,
    DESC_ERRO VARCHAR2(1000) NOT NULL,
    NOME_CODIGO VARCHAR2(30) NOT NULL,
    PARAMETROS VARCHAR2(1000) NULL,
    DTH_ERRO DATE NOT NULL,
    USUARIO VARCHAR2(30) NOT NULL,
    RESOLVIDO CHAR(1) NOT NULL,
    DESC_RESOLVIDO VARCHAR2(1000) NULL
)

DROP SEQUENCE SEQ_LOG_EXECUCAO;
CREATE SEQUENCE SEQ_LOG_EXECUCAO
NO CACHE
NO CYCLE;