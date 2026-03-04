CREATE TABLE PESSOA (
    ID NUMBER(5) PRIMARY KEY,
    NOME VARCHAR2(60) NOT NULL,
    SALARIO NUMBER(10,2) NOT NULL
);

CREATE OR REPLACE
PROCEDURE PROC_INSERIR_PESSOA (P_ID IN HR.PESSOA.ID%TYPE,
    P_NOME IN HR.PESSOA.NOME%TYPE,
    P_SALARIO IN HR.PESSOA.SALARIO%TYPE,
    P_SAIDA OUT NUMBER)
IS
    V_QTDE NUMBER(5);
BEGIN
    IF P_ID >= 1 AND P_ID <= 99999 THEN
        IF LENGTH(P_NOME) >= 1 AND LENGTH(P_NOME) <= 60 THEN
            IF P_SALARIO >= 0 AND P_SALARIO <= 99999999.99 THEN
                SELECT COUNT(*) INTO V_QTDE FROM PESSOA WHERE ID = P_ID;
                IF V_QTDE = 0 THEN
                    INSERT INTO PESSOA (ID, NOME, SALARIO)
                    VALUES (P_ID, P_NOME, P_SALARIO);
                    P_SAIDA := 0; -- INSERIDO COM SUCESSO
                ELSE
                    P_SAIDA := -1; -- ID JA EXISTE NA TABELA
                END IF;
            ELSE
                P_SAIDA := -4; -- SALARIO FORA DA FAIXA ACEITÁVEL
            END IF;
        ELSE
            P_SAIDA := -3; -- NOME TEM QUE TER ENTRE 1 E 60 CARACTERES
        END IF;
    ELSE
        P_SAIDA := -2; -- ID FORA DA FAIXA ACEITÁVEL
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_SAIDA := SQLCODE;
END PROC_INSERIR_PESSOA;

-- TESTE DA PROCEDURE
SET SERVEROUTPUT ON;

-- Limpa a tabela antes dos testes
BEGIN
    DELETE FROM PESSOA;
    COMMIT;
END;
/

-- TEST 1: Inserção válida (esperado P_SAIDA = 0)
DECLARE
    v_saida NUMBER;
BEGIN
    PROC_INSERIR_PESSOA(1, 'Fulano', 1000.00, v_saida);
    DBMS_OUTPUT.PUT_LINE('TEST 1 - INSERCAO VALIDA: P_SAIDA='||v_saida);
END;
/

-- TEST 2: Inserção duplicada (esperado P_SAIDA = -1)
DECLARE
    v_saida NUMBER;
BEGIN
    PROC_INSERIR_PESSOA(1, 'Fulano', 1000.00, v_saida);
    DBMS_OUTPUT.PUT_LINE('TEST 2 - ID_DUPLICADO: P_SAIDA='||v_saida);
END;
/

-- TEST 3: ID fora da faixa (0) (esperado P_SAIDA = -2)
DECLARE
    v_saida NUMBER;
BEGIN
    PROC_INSERIR_PESSOA(0, 'Teste', 100.00, v_saida);
    DBMS_OUTPUT.PUT_LINE('TEST 3 - ID_FORA_DA_FAIXA: P_SAIDA='||v_saida);
END;
/

-- TEST 4: Nome muito longo (61 caracteres) (esperado P_SAIDA = -3)
DECLARE
    v_saida NUMBER;
    v_nome VARCHAR2(100) := RPAD('A',61,'A');
BEGIN
    PROC_INSERIR_PESSOA(2, v_nome, 100.00, v_saida);
    DBMS_OUTPUT.PUT_LINE('TEST 4 - NOME_LONGO: P_SAIDA='||v_saida);
END;
/

-- TEST 5: Salário inválido (negativo) (esperado P_SAIDA = -4)
DECLARE
    v_saida NUMBER;
BEGIN
    PROC_INSERIR_PESSOA(3, 'Beltrano', -1, v_saida);
    DBMS_OUTPUT.PUT_LINE('TEST 5 - SALARIO_INVALIDO: P_SAIDA='||v_saida);
END;
/
