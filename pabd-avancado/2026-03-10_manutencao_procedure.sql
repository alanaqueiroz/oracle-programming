-- Conversão da procedure PROC_INSERIR_PESSOA para SQL Server (T-SQL)
CREATE OR ALTER PROCEDURE dbo.PROC_INSERIR_PESSOA
    @P_ID      INT,
    @P_NOME    NVARCHAR(60),
    @P_SALARIO DECIMAL(11,2),
    @P_SAIDA   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Valida ID
        IF (@P_ID < 1 OR @P_ID > 99999)
        BEGIN
            SET @P_SAIDA = -2;
            ROLLBACK TRAN;
            RETURN;
        END

        -- Valida NOME (1..60)
        IF (@P_NOME IS NULL OR LEN(@P_NOME) < 1 OR LEN(@P_NOME) > 60)
        BEGIN
            SET @P_SAIDA = -3;
            ROLLBACK TRAN;
            RETURN;
        END

        -- Valida SALARIO (0..99999999.99)
        IF (@P_SALARIO < 0 OR @P_SALARIO > 99999999.99)
        BEGIN
            SET @P_SAIDA = -4;
            ROLLBACK TRAN;
            RETURN;
        END

        -- Verifica duplicidade do ID (evita corrida)
        IF EXISTS (SELECT 1 FROM dbo.PESSOA WITH (UPDLOCK, HOLDLOCK) WHERE ID = @P_ID)
        BEGIN
            SET @P_SAIDA = -1;
            ROLLBACK TRAN;
            RETURN;
        END

        INSERT INTO dbo.PESSOA (ID, NOME, SALARIO)
        VALUES (@P_ID, @P_NOME, @P_SALARIO);

        SET @P_SAIDA = 0;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        SET @P_SAIDA = -ERROR_NUMBER();
    END CATCH
END;
GO

-- Conversão da procedure PROC_INSERIR_PESSOA para MySQL

DROP PROCEDURE IF EXISTS PROC_INSERIR_PESSOA;
DELIMITER $$

CREATE PROCEDURE PROC_INSERIR_PESSOA (
    IN  P_ID      INT,
    IN  P_NOME    VARCHAR(60),
    IN  P_SALARIO DECIMAL(10,2),
    OUT P_SAIDA   INT
)
proc:BEGIN
    DECLARE V_QTDE INT DEFAULT 0;

    -- Captura erro inesperado e faz rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- Opcional: devolver um código genérico de erro
        SET P_SAIDA = -999;
    END;

    START TRANSACTION;

    -- Validação ID (corrigido: OR, não AND)
    IF P_ID < 1 OR P_ID > 99999 THEN
        SET P_SAIDA = -2; -- ID fora da faixa aceitável
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- Validação NOME
    IF CHAR_LENGTH(P_NOME) < 1 OR CHAR_LENGTH(P_NOME) > 60 THEN
        SET P_SAIDA = -3; -- nome precisa ter entre 1 e 60 caracteres
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- Validação SALARIO
    IF P_SALARIO < 0 OR P_SALARIO > 99999999.99 THEN
        SET P_SAIDA = -4; -- salário fora da faixa aceitável
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- Verifica se ID já existe
    SELECT COUNT(*)
      INTO V_QTDE
      FROM PESSOA
     WHERE ID = P_ID;

    IF V_QTDE > 0 THEN
        SET P_SAIDA = -1; -- ID já existe
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- Insere
    INSERT INTO PESSOA (ID, NOME, SALARIO)
    VALUES (P_ID, P_NOME, P_SALARIO);

    COMMIT;
    SET P_SAIDA = 0; -- inserido com sucesso
END$$

DELIMITER ;

-- Adição da coluna EMAIL na tabela PESSOA
ALTER TABLE PESSOA ADD EMAIL VARCHAR2(240);

CREATE OR REPLACE
PROCEDURE PROC_INSERIR_PESSOA (P_ID IN HR.PESSOA.ID%TYPE,
    P_NOME IN HR.PESSOA.NOME%TYPE,
    P_SALARIO IN HR.PESSOA.SALARIO%TYPE,
    P_EMAIL IN HR.PESSOA.EMAIL%TYPE, -- nova entrada para email
    P_SAIDA OUT NUMBER)
IS
    V_QTDE NUMBER(5);
BEGIN
    IF P_ID < 1 OR P_ID > 99999 THEN
        P_SAIDA := -2; -- ID fora da faixa aceitável
        RETURN;
    END IF;

    IF LENGTH(P_NOME) < 1 OR LENGTH(P_NOME) > 60 THEN
        P_SAIDA := -3; -- nome fora da faixa aceitável
        RETURN;
    END IF;

    IF P_SALARIO < 0 OR P_SALARIO > 99999999.99 THEN
        P_SAIDA := -4; -- salário fora da faixa aceitável
        RETURN;
    END IF;

    IF LENGTH(P_EMAIL) < 1 OR LENGTH(P_EMAIL) > 240 THEN
        P_SAIDA := -5; -- email fora da faixa aceitável
        RETURN;
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_SAIDA := SQLCODE;
        --DBMS_OUTPUT.PUT_LINE('CÓDIGO DO ERRO: ' || SQLCODE);
        --DBMS_OUTPUT.PUT_LINE('DESCRICAO DO ERRO: ' || SQLERRM);
        --DBMS_OUTPUT.PUT_LINE('LINHA DO ERRO: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;

DECLARE
    V_SAIDA NUMBER;
    V_EMAIL_240 VARCHAR2(240);
    V_EMAIL_241 VARCHAR2(241);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TESTE 1: Inserção válida (esperado P_SAIDA = 0)');
    
    V_EMAIL_240 := RPAD('a', 240, 'a'); -- email com 240 caracteres
    V_EMAIL_241 := RPAD('b', 241, 'b'); -- email com 241 caracteres

    PROC_INSERIR_PESSOA(1, 'João Silva', 5000.00, V_EMAIL_240, V_SAIDA);
    DBMS_OUTPUT.PUT_LINE('P_SAIDA: ' || V_SAIDA);

    DBMS_OUTPUT.PUT_LINE('TESTE 2: Inserção inválida (esperado P_SAIDA = -2)');
    PROC_INSERIR_PESSOA(0, 'Maria Souza', 6000.00, V_EMAIL_240, V_SAIDA);
    DBMS_OUTPUT.PUT_LINE('P_SAIDA: ' || V_SAIDA);

    DBMS_OUTPUT.PUT_LINE('TESTE 3: Inserção inválida (esperado P_SAIDA = -3)');
    PROC_INSERIR_PESSOA(2, RPAD('b', 61, 'b'), 7000.00, V_EMAIL_240, V_SAIDA);
    DBMS_OUTPUT.PUT_LINE('P_SAIDA: ' || V_SAIDA);

    DBMS_OUTPUT.PUT_LINE('TESTE 4: Inserção inválida (esperado P_SAIDA = -4)');
    PROC_INSERIR_PESSOA(3, 'Carlos Pereira', -100.00, V_EMAIL_240, V_SAIDA);
    DBMS_OUTPUT.PUT_LINE('P_SAIDA: ' || V_SAIDA);

    DBMS_OUTPUT.PUT_LINE('TESTE 5: Inserção inválida (esperado P_SAIDA = -5)');
    V_EMAIL_241 := RPAD('c', 241, 'c'); -- email com 241 caracteres
    PROC_INSERIR_PESSOA(4, 'Ana Costa', 8000.00, V_EMAIL_241, V_SAIDA);
    DBMS_OUTPUT.PUT_LINE('P_SAIDA: ' || V_SAIDA);
END;

-- Desenvolver uma procedure que receba um id do funcionario e um número que represente o percentual de aumento do salario do funcionário. 
-- Para realizar o aumento do funcionario o id do funcionario de existir o percentual deve estar entre maior que zero e menor que 10. 
-- Retornar 0 para indicar que deu certo o processo e o salario do funcionario aumentou.
-- Se der erro, retornar -999, -998, etc (documente). o teto de salário máximo é 10000, chegou a 10000 não aumenta mais o salário.

CREATE OR REPLACE PROCEDURE PROC_AUMENTAR_SALARIO (
    P_ID IN HR.PESSOA.ID%TYPE,
    P_PERCENTUAL IN NUMBER,
    P_SAIDA OUT NUMBER
)
IS
    V_QTDE NUMBER(5);
    V_SALARIO HR.PESSOA.SALARIO%TYPE;
    V_NOVO_SALARIO HR.PESSOA.SALARIO%TYPE;
BEGIN
    /*
      P_SAIDA:
        0    = sucesso (salário atualizado)
       -999  = ID inexistente
       -998  = percentual inválido (deve ser > 0 e < 10)
       -997  = não atualiza pois atingiria/excederia teto (10000)
    */

    SELECT COUNT(*)
      INTO V_QTDE
      FROM HR.PESSOA
     WHERE ID = P_ID;

    IF V_QTDE = 0 THEN
        P_SAIDA := -999;
    ELSE
        IF P_PERCENTUAL <= 0 OR P_PERCENTUAL >= 10 THEN
            P_SAIDA := -998;
        ELSE
            SELECT SALARIO
              INTO V_SALARIO,
              FROM HR.PESSOA
             WHERE ID = P_ID;

            V_NOVO_SALARIO := V_SALARIO + (V_SALARIO * P_PERCENTUAL / 100);

            IF V_SALARIO >= 10000 OR V_NOVO_SALARIO > 10000 THEN
                P_SAIDA := -997;
            ELSE
                UPDATE HR.PESSOA
                   SET SALARIO = V_NOVO_SALARIO
                 WHERE ID = P_ID;

                P_SAIDA := 0;
            END IF;
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        P_SAIDA := SQLCODE;
END;