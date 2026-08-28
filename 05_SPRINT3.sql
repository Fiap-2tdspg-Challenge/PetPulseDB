------------------------------------------------------------
-- PROJETO: CLYVO VET - SAUDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- ARQUIVO: 05_SPRINT3_BD.sql
-- DESCRICAO: Entrega da Sprint 3 - 2 procedures, 2 funcoes, 1 trigger
--            de auditoria, com tratamento de excecoes e conversao
--            manual de dados relacionais para JSON (sem funcoes
--            nativas de JSON do Oracle).
-- PRE-REQUISITO: executar 01_DDL.sql, 02_PROCEDURES.sql e
--                03_CARGA.sql antes deste script.
------------------------------------------------------------

SET SERVEROUTPUT ON;

------------------------------------------------------------
-- BLOCO 0: CARGA COMPLEMENTAR
-- Garante que todas as tabelas usadas nos objetos abaixo
-- tenham pelo menos 5 registros validos, conforme exigido.
------------------------------------------------------------

-- T_CLY_PORTE tinha apenas 3 registros (PEQUENO, MEDIO, GRANDE).
-- Completando para 5 registros para atender ao Procedimento 1.
BEGIN
    PRC_CARGA_PORTE('MINI');
    PRC_CARGA_PORTE('GIGANTE');
END;
/

-- Leituras IoT complementares, para enriquecer a demonstracao
-- de subtotal por dispositivo no Procedimento 2.
BEGIN
    PRC_CARGA_LEITURA_IOT(1, SYSDATE - 3,  78, 3,  12);
    PRC_CARGA_LEITURA_IOT(2, SYSDATE - 1, 155, 2,  10);
    PRC_CARGA_LEITURA_IOT(3, SYSDATE - 2,  70, 5,  11);
END;
/


------------------------------------------------------------
-- BLOCO 1: FUNCAO 1
-- FUNC_PET_TO_JSON
-- Recebe dados relacionais de um pet (ja resolvidos via JOIN)
-- e retorna uma string no formato JSON, montada manualmente
-- por concatenacao (PROIBIDO usar TO_JSON, JSON_OBJECT, etc).
-- Trata 3 excecoes distintas: id invalido (customizada),
-- VALUE_ERROR e OTHERS.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION FUNC_PET_TO_JSON (
    p_id_pet   IN NUMBER,
    p_nome_pet IN VARCHAR2,
    p_tutor    IN VARCHAR2,
    p_especie  IN VARCHAR2,
    p_raca     IN VARCHAR2,
    p_porte    IN VARCHAR2,
    p_peso     IN NUMBER,
    p_sexo     IN VARCHAR2
) RETURN VARCHAR2
IS
    e_id_invalido EXCEPTION;
    v_json      VARCHAR2(2000);
    v_nome_esc  VARCHAR2(200);
    v_tutor_esc VARCHAR2(200);
    v_peso_str  VARCHAR2(30);
BEGIN
    IF p_id_pet IS NULL OR p_id_pet <= 0 THEN
        RAISE e_id_invalido;
    END IF;

    -- Escapa aspas duplas manualmente para nao quebrar o JSON
    v_nome_esc  := REPLACE(NVL(p_nome_pet, ''), '"', '\"');
    v_tutor_esc := REPLACE(NVL(p_tutor, ''), '"', '\"');

    -- Peso agora é sempre inteiro no projeto (sem casas decimais),
    -- entao basta um TO_CHAR simples, sem depender de mascara de formato.
    IF p_peso IS NULL THEN
        v_peso_str := 'null';
    ELSE
        v_peso_str := TO_CHAR(p_peso);
    END IF;

    v_json := '{'
        || '"idPet":' || p_id_pet || ','
        || '"nomePet":"' || v_nome_esc || '",'
        || '"tutor":"' || v_tutor_esc || '",'
        || '"especie":"' || REPLACE(NVL(p_especie,''), '"','\"') || '",'
        || '"raca":"' || REPLACE(NVL(p_raca,''), '"','\"') || '",'
        || '"porte":"' || REPLACE(NVL(p_porte,''), '"','\"') || '",'
        || '"peso":' || v_peso_str || ','
        || '"sexo":"' || NVL(p_sexo,'') || '"'
        || '}';

    RETURN v_json;
EXCEPTION
    WHEN e_id_invalido THEN
        RAISE_APPLICATION_ERROR(-20100, 'FUNC_PET_TO_JSON: id do pet invalido (nulo ou <= 0)');
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20101, 'FUNC_PET_TO_JSON: erro de conversao de valor ao montar o JSON');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20102, 'FUNC_PET_TO_JSON: erro inesperado - ' || SQLERRM);
END;
/


------------------------------------------------------------
-- BLOCO 2: FUNCAO 2
-- FUNC_VALIDA_PESO_PORTE
-- Substitui um processo logico do projeto: verifica se o peso
-- informado e compativel com o porte cadastrado do pet.
-- Trata 4 excecoes distintas: peso invalido, porte invalido,
-- VALUE_ERROR e OTHERS.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION FUNC_VALIDA_PESO_PORTE (
    p_porte IN VARCHAR2,
    p_peso  IN NUMBER
) RETURN VARCHAR2
IS
    e_porte_invalido EXCEPTION;
    e_peso_invalido  EXCEPTION;
    v_porte VARCHAR2(30);
BEGIN
    IF p_peso IS NULL OR p_peso <= 0 THEN
        RAISE e_peso_invalido;
    END IF;

    v_porte := UPPER(TRIM(p_porte));

    IF v_porte NOT IN ('PEQUENO', 'MEDIO', 'GRANDE', 'MINI', 'GIGANTE') THEN
        RAISE e_porte_invalido;
    END IF;

    IF v_porte = 'MINI' AND p_peso > 5 THEN
        RETURN 'Peso incompativel (acima do esperado para MINI)';
    ELSIF v_porte = 'PEQUENO' AND (p_peso <= 5 OR p_peso > 10) THEN
        RETURN 'Peso incompativel com o porte PEQUENO';
    ELSIF v_porte = 'MEDIO' AND (p_peso <= 10 OR p_peso > 25) THEN
        RETURN 'Peso incompativel com o porte MEDIO';
    ELSIF v_porte = 'GRANDE' AND (p_peso <= 25 OR p_peso > 45) THEN
        RETURN 'Peso incompativel com o porte GRANDE';
    ELSIF v_porte = 'GIGANTE' AND p_peso <= 45 THEN
        RETURN 'Peso incompativel (abaixo do esperado para GIGANTE)';
    ELSE
        RETURN 'Peso compativel com o porte';
    END IF;
EXCEPTION
    WHEN e_peso_invalido THEN
        RAISE_APPLICATION_ERROR(-20110, 'FUNC_VALIDA_PESO_PORTE: peso invalido (nulo ou <= 0)');
    WHEN e_porte_invalido THEN
        RAISE_APPLICATION_ERROR(-20111, 'FUNC_VALIDA_PESO_PORTE: porte invalido - use PEQUENO, MEDIO, GRANDE, MINI ou GIGANTE');
    WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(-20112, 'FUNC_VALIDA_PESO_PORTE: erro de conversao de valor');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20113, 'FUNC_VALIDA_PESO_PORTE: erro inesperado - ' || SQLERRM);
END;
/


------------------------------------------------------------
-- BLOCO 3: PROCEDIMENTO 1
-- PRC_REL_PETS_JSON
-- Realiza JOIN entre 5 tabelas relacionais (PET, USUARIO,
-- ESPECIE, RACA, PORTE - todas com >= 5 registros) e exibe
-- cada pet no formato JSON, usando a FUNC_PET_TO_JSON para a
-- conversao manual. Trata 3 excecoes distintas.
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_REL_PETS_JSON
IS
    CURSOR c_pets IS
        SELECT p.ID_PET, p.NOME AS NOME_PET, u.NOME AS TUTOR,
               e.NOME_ESPECIE, r.NOME_RACA, po.DESCRICAO AS PORTE,
               p.PESO, p.SEXO
        FROM T_CLY_PET p
        INNER JOIN T_CLY_USUARIO u  ON p.ID_USUARIO = u.ID_USUARIO
        INNER JOIN T_CLY_ESPECIE e  ON p.ID_ESPECIE = e.ID_ESPECIE
        INNER JOIN T_CLY_RACA r     ON p.ID_RACA    = r.ID_RACA
        INNER JOIN T_CLY_PORTE po   ON p.ID_PORTE   = po.ID_PORTE
        ORDER BY p.ID_PET;

    v_json_item  VARCHAR2(2000);
    v_json_array VARCHAR2(4000) := '[';
    v_primeiro   BOOLEAN := TRUE;
    v_qtd        PLS_INTEGER := 0;
    v_erro       VARCHAR2(4000);
    v_codigo     NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PROCEDIMENTO 1: PETS EM FORMATO JSON (JOIN MANUAL) ===');

    FOR r IN c_pets LOOP
        v_qtd := v_qtd + 1;

        v_json_item := FUNC_PET_TO_JSON(
            r.ID_PET, r.NOME_PET, r.TUTOR, r.NOME_ESPECIE,
            r.NOME_RACA, r.PORTE, r.PESO, r.SEXO
        );

        DBMS_OUTPUT.PUT_LINE(v_json_item);

        IF NOT v_primeiro THEN
            v_json_array := v_json_array || ',';
        END IF;
        v_json_array := v_json_array || v_json_item;
        v_primeiro := FALSE;
    END LOOP;

    IF v_qtd = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;

    v_json_array := v_json_array || ']';

    DBMS_OUTPUT.PUT_LINE('--- Array JSON completo (' || v_qtd || ' pets) ---');
    DBMS_OUTPUT.PUT_LINE(v_json_array);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_PETS_JSON', 100, 'Nenhum pet encontrado para montar o JSON', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: nenhum pet encontrado');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_PETS_JSON', 2, 'Erro de valor ao montar o JSON', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_PETS_JSON', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/


------------------------------------------------------------
-- BLOCO 4: PROCEDIMENTO 2
-- PRC_REL_LEITURAS_SUBTOTAL
-- Tabela de fatos: T_CLY_LEITURA_IOT
--   Categoria 1: ID_DISPOSITIVO
--   Categoria 2: dia da leitura (TRUNC(DT_LEITURA))
--   Numerico somado: FREQUENCIA_CARDIACA (soma ilustrativa,
--   usada apenas para demonstrar a tecnica de subtotalizacao
--   manual exigida pelo enunciado - nao representa uma metrica
--   clinica real, ja que BPM nao e uma grandeza aditiva).
-- Calcula subtotal por dispositivo e total geral manualmente,
-- sem ROLLUP/CUBE/GROUPING SETS/GROUPING. Trata 4 excecoes.
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_REL_LEITURAS_SUBTOTAL
IS
    CURSOR c_leituras IS
        SELECT ID_DISPOSITIVO, TRUNC(DT_LEITURA) AS DIA, FREQUENCIA_CARDIACA
        FROM T_CLY_LEITURA_IOT
        ORDER BY ID_DISPOSITIVO, TRUNC(DT_LEITURA);

    v_disp_atual  T_CLY_LEITURA_IOT.ID_DISPOSITIVO%TYPE;
    v_disp_ant    T_CLY_LEITURA_IOT.ID_DISPOSITIVO%TYPE := NULL;
    v_subtotal    NUMBER := 0;
    v_total_geral NUMBER := 0;
    v_qtd_linhas  PLS_INTEGER := 0;
    v_erro        VARCHAR2(4000);
    v_codigo      NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PROCEDIMENTO 2: LEITURAS IOT COM SUBTOTAL POR DISPOSITIVO ===');
    DBMS_OUTPUT.PUT_LINE(RPAD('Dispositivo',13) || RPAD('Dia',14) || 'BPM');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',12,'-') || ' ' || RPAD('-',12,'-') || ' ' || RPAD('-',5,'-'));

    FOR r IN c_leituras LOOP
        v_qtd_linhas := v_qtd_linhas + 1;
        v_disp_atual := r.ID_DISPOSITIVO;

        -- Ao trocar de dispositivo, fecha o subtotal do grupo anterior
        IF v_disp_ant IS NOT NULL AND v_disp_atual <> v_disp_ant THEN
            DBMS_OUTPUT.PUT_LINE(RPAD(' ',13) || RPAD('Sub Total',14) || TO_CHAR(v_subtotal));
            v_subtotal := 0;
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(TO_CHAR(r.ID_DISPOSITIVO),13) ||
            RPAD(TO_CHAR(r.DIA,'DD/MM/YYYY'),14) ||
            TO_CHAR(r.FREQUENCIA_CARDIACA)
        );

        v_subtotal    := v_subtotal + NVL(r.FREQUENCIA_CARDIACA, 0);
        v_total_geral := v_total_geral + NVL(r.FREQUENCIA_CARDIACA, 0);
        v_disp_ant    := v_disp_atual;
    END LOOP;

    IF v_qtd_linhas = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;

    -- Fecha o subtotal do ultimo grupo e imprime o total geral
    DBMS_OUTPUT.PUT_LINE(RPAD(' ',13) || RPAD('Sub Total',14) || TO_CHAR(v_subtotal));
    DBMS_OUTPUT.PUT_LINE(RPAD(' ',13) || RPAD('Total Geral',14) || TO_CHAR(v_total_geral));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_LEITURAS_SUBTOTAL', 101, 'Nenhuma leitura IoT encontrada', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: nenhuma leitura encontrada');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_LEITURAS_SUBTOTAL', 2, 'Erro de valor no calculo de subtotal', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN ZERO_DIVIDE THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_LEITURAS_SUBTOTAL', 3, 'Divisao por zero', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de divisao por zero');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_REL_LEITURAS_SUBTOTAL', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/


------------------------------------------------------------
-- BLOCO 5: TRIGGER DE AUDITORIA
-- Tabela de auditoria + trigger AFTER INSERT OR UPDATE OR
-- DELETE ON T_CLY_PET, registrando usuario, tipo de operacao,
-- data/hora e valores anteriores (:OLD) e novos (:NEW).
------------------------------------------------------------
-- Remove a tabela se ja existir (permite reexecutar o script sem erro
-- ORA-00955), ignorando o erro ORA-00942 caso ela ainda nao exista.
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE T_CLY_AUDITORIA_PET CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE T_CLY_AUDITORIA_PET (
    ID_AUDITORIA        NUMBER GENERATED BY DEFAULT AS IDENTITY,
    NOME_USUARIO         VARCHAR2(100)  NOT NULL,
    TIPO_OPERACAO         VARCHAR2(10)   NOT NULL,
    DATA_OPERACAO         DATE DEFAULT SYSDATE NOT NULL,
    ID_PET_REF            NUMBER,
    VALORES_ANTERIORES    VARCHAR2(1000),
    VALORES_NOVOS         VARCHAR2(1000),

    CONSTRAINT PK_CLY_AUDITORIA_PET
        PRIMARY KEY (ID_AUDITORIA),

    CONSTRAINT CK_CLY_AUDIT_TIPO
        CHECK (TIPO_OPERACAO IN ('INSERT', 'UPDATE', 'DELETE'))
);

CREATE OR REPLACE TRIGGER TRG_AUDITORIA_PET
AFTER INSERT OR UPDATE OR DELETE ON T_CLY_PET
FOR EACH ROW
DECLARE
    v_tipo     VARCHAR2(10);
    v_anterior VARCHAR2(1000);
    v_novo     VARCHAR2(1000);
    v_id_ref   NUMBER;
BEGIN
    IF INSERTING THEN
        v_tipo     := 'INSERT';
        v_id_ref   := :NEW.ID_PET;
        v_anterior := NULL;
        v_novo     := 'NOME=' || :NEW.NOME || ';PESO=' || :NEW.PESO || ';ID_PORTE=' || :NEW.ID_PORTE;
    ELSIF UPDATING THEN
        v_tipo     := 'UPDATE';
        v_id_ref   := :NEW.ID_PET;
        v_anterior := 'NOME=' || :OLD.NOME || ';PESO=' || :OLD.PESO || ';ID_PORTE=' || :OLD.ID_PORTE;
        v_novo     := 'NOME=' || :NEW.NOME || ';PESO=' || :NEW.PESO || ';ID_PORTE=' || :NEW.ID_PORTE;
    ELSIF DELETING THEN
        v_tipo     := 'DELETE';
        v_id_ref   := :OLD.ID_PET;
        v_anterior := 'NOME=' || :OLD.NOME || ';PESO=' || :OLD.PESO || ';ID_PORTE=' || :OLD.ID_PORTE;
        v_novo     := NULL;
    END IF;

    INSERT INTO T_CLY_AUDITORIA_PET (
        NOME_USUARIO, TIPO_OPERACAO, ID_PET_REF, VALORES_ANTERIORES, VALORES_NOVOS
    )
    VALUES (
        USER, v_tipo, v_id_ref, v_anterior, v_novo
    );
END;
/


------------------------------------------------------------
-- BLOCO 6: DEMONSTRACAO / TESTES
-- Blocos anonimos para gerar os prints exigidos na
-- documentacao, incluindo pelo menos um caso de erro tratado
-- por funcao e por procedimento.
------------------------------------------------------------

-- Teste 1: FUNC_PET_TO_JSON - caso de sucesso
DECLARE
    v_json VARCHAR2(2000);
BEGIN
    v_json := FUNC_PET_TO_JSON(1, 'Rex', 'Armando Souza', 'CACHORRO', 'Golden Retriever', 'GRANDE', 25, 'M');
    DBMS_OUTPUT.PUT_LINE('Teste Funcao 1 (sucesso): ' || v_json);
END;
/

-- Teste 2: FUNC_PET_TO_JSON - caso de erro proposital (id_pet nulo)
BEGIN
    DBMS_OUTPUT.PUT_LINE(FUNC_PET_TO_JSON(NULL, 'Teste', 'Teste', 'CACHORRO', 'SRD', 'PEQUENO', 5, 'M'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Teste Funcao 1 (erro esperado): ' || SQLERRM);
END;
/

-- Teste 3: FUNC_VALIDA_PESO_PORTE - caso de sucesso
BEGIN
    DBMS_OUTPUT.PUT_LINE('Teste Funcao 2 (sucesso): ' || FUNC_VALIDA_PESO_PORTE('GRANDE', 30));
END;
/

-- Teste 4: FUNC_VALIDA_PESO_PORTE - caso de erro proposital (porte invalido)
BEGIN
    DBMS_OUTPUT.PUT_LINE(FUNC_VALIDA_PESO_PORTE('XG', 10));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Teste Funcao 2 (erro esperado): ' || SQLERRM);
END;
/

-- Teste 5: PRC_REL_PETS_JSON - caso de sucesso
EXEC PRC_REL_PETS_JSON;

-- Teste 6: PRC_REL_LEITURAS_SUBTOTAL - caso de sucesso
EXEC PRC_REL_LEITURAS_SUBTOTAL;

-- Teste 7: Trigger de auditoria - dispara em INSERT, UPDATE e DELETE
BEGIN
    -- UPDATE (deve gerar 1 registro de auditoria tipo UPDATE)
    UPDATE T_CLY_PET SET PESO = PESO + 1 WHERE ID_PET = 1;
    COMMIT;
END;
/

BEGIN
    -- INSERT de um pet de teste (deve gerar 1 registro tipo INSERT)
    PRC_CARGA_PET(1, 'Pet Auditoria Teste', 1, 1, 2, SYSDATE, 15, 'M', 'N');
    COMMIT;
END;
/

-- Conferindo os registros gerados na tabela de auditoria
SELECT ID_AUDITORIA, NOME_USUARIO, TIPO_OPERACAO, DATA_OPERACAO,
       ID_PET_REF, VALORES_ANTERIORES, VALORES_NOVOS
FROM T_CLY_AUDITORIA_PET
ORDER BY ID_AUDITORIA DESC;