------------------------------------------------------------
-- PROJETO: CLYVO VET - SAUDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- ARQUIVO: 07_EXPORTACAO_JSON.sql
-- DESCRICAO: Sprint 4 - exporta as leituras IoT do banco relacional
--            para um arquivo JSON, que sera importado no MongoDB.
--            Cada leitura vira um documento. O JSON e montado
--            manualmente, sem funcoes nativas de JSON do Oracle.
-- PRE-REQUISITO: 06_PACKAGES.sql executado.
------------------------------------------------------------

------------------------------------------------------------
-- PACKAGE: PKG_EXPORTACAO
------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_EXPORTACAO IS

    -- Monta o documento JSON de uma leitura IoT
    FUNCTION FUNC_LEITURA_TO_JSON (p_id_leitura IN NUMBER) RETURN VARCHAR2;

    -- Imprime um array JSON com todas as leituras (um documento por
    -- linha), para ser gravado em arquivo via SPOOL
    PROCEDURE PRC_EXPORTA_LEITURAS_JSON;

END PKG_EXPORTACAO;
/

CREATE OR REPLACE PACKAGE BODY PKG_EXPORTACAO IS

    ----------------------------------------------------------
    -- Funcoes auxiliares (privadas) de formatacao JSON
    ----------------------------------------------------------

    -- Decimal com ponto fixo como separador (independe do NLS da sessao)
    FUNCTION f_num (p IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p IS NULL THEN
            RETURN 'null';
        END IF;
        RETURN TO_CHAR(p, 'FM9999990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
    END f_num;

    -- Inteiro
    FUNCTION f_int (p IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF p IS NULL THEN
            RETURN 'null';
        END IF;
        RETURN TO_CHAR(TRUNC(p));
    END f_int;

    -- Data no formato Extended JSON do MongoDB ({"$date": ...}), com o fuso
    -- do servidor, para o mongoimport gravar o campo como Date e nao texto
    FUNCTION f_data (p IN DATE) RETURN VARCHAR2 IS
    BEGIN
        IF p IS NULL THEN
            RETURN 'null';
        END IF;
        RETURN '{"$date":"' || TO_CHAR(p, 'YYYY-MM-DD"T"HH24:MI:SS') || '.000'
               || TO_CHAR(SYSTIMESTAMP, 'TZH:TZM') || '"}';
    END f_data;

    ----------------------------------------------------------
    -- FUNC_LEITURA_TO_JSON
    -- Documento de uma leitura, com referencia ao dispositivo e ao pet.
    -- Trata 4 excecoes: id invalido, leitura inexistente,
    -- erro de valor e OTHERS.
    ----------------------------------------------------------
    FUNCTION FUNC_LEITURA_TO_JSON (p_id_leitura IN NUMBER) RETURN VARCHAR2
    IS
        CURSOR c_leitura IS
            SELECT l.ID_LEITURA, l.ID_DISPOSITIVO, d.ID_PET, l.DT_LEITURA,
                   l.FREQUENCIA_CARDIACA, l.NIVEL_ATIVIDADE, l.PRESSAO
            FROM T_CLY_LEITURA_IOT l
            INNER JOIN T_CLY_DISPOSITIVO_IOT d ON d.ID_DISPOSITIVO = l.ID_DISPOSITIVO
            WHERE l.ID_LEITURA = p_id_leitura;

        v_leitura     c_leitura%ROWTYPE;
        e_id_invalido EXCEPTION;
    BEGIN
        IF p_id_leitura IS NULL OR p_id_leitura <= 0 THEN
            RAISE e_id_invalido;
        END IF;

        OPEN c_leitura;
        FETCH c_leitura INTO v_leitura;
        IF c_leitura%NOTFOUND THEN
            CLOSE c_leitura;
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_leitura;

        RETURN '{"_id":'               || v_leitura.ID_LEITURA
            || ',"idDispositivo":'      || v_leitura.ID_DISPOSITIVO
            || ',"idPet":'              || v_leitura.ID_PET
            || ',"dtLeitura":'          || f_data(v_leitura.DT_LEITURA)
            || ',"frequenciaCardiaca":' || f_int(v_leitura.FREQUENCIA_CARDIACA)
            || ',"nivelAtividade":'     || f_num(v_leitura.NIVEL_ATIVIDADE)
            || ',"pressao":'            || f_num(v_leitura.PRESSAO)
            || '}';
    EXCEPTION
        WHEN e_id_invalido THEN
            RAISE_APPLICATION_ERROR(-20120, 'FUNC_LEITURA_TO_JSON: id da leitura invalido (nulo ou <= 0)');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20121, 'FUNC_LEITURA_TO_JSON: leitura ' || p_id_leitura || ' nao encontrada');
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20122, 'FUNC_LEITURA_TO_JSON: erro de conversao de valor na leitura ' || p_id_leitura);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20123, 'FUNC_LEITURA_TO_JSON: erro inesperado - ' || SQLERRM);
    END FUNC_LEITURA_TO_JSON;

    ----------------------------------------------------------
    -- PRC_EXPORTA_LEITURAS_JSON
    -- Imprime "[", um documento por linha e "]". A saida e o proprio
    -- arquivo JSON, entao erros vao so para T_CLY_LOG_ERRO, nunca para
    -- a tela. Uma leitura com problema nao interrompe as demais.
    -- Trata 3 excecoes: NO_DATA_FOUND, VALUE_ERROR e OTHERS.
    ----------------------------------------------------------
    PROCEDURE PRC_EXPORTA_LEITURAS_JSON
    IS
        v_doc    VARCHAR2(4000);
        v_qtd    PLS_INTEGER := 0;
        v_codigo NUMBER;
        v_erro   VARCHAR2(4000);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('[');

        FOR rl IN (
            SELECT ID_LEITURA
            FROM T_CLY_LEITURA_IOT
            ORDER BY ID_DISPOSITIVO, DT_LEITURA
        ) LOOP
            BEGIN
                v_doc := FUNC_LEITURA_TO_JSON(rl.ID_LEITURA);
                DBMS_OUTPUT.PUT_LINE(CASE WHEN v_qtd > 0 THEN ',' END || v_doc);
                v_qtd := v_qtd + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    v_codigo := SQLCODE;
                    v_erro   := SQLERRM;
                    INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
                    VALUES ('PKG_EXPORTACAO.PRC_EXPORTA_LEITURAS_JSON', v_codigo, v_erro, SYSDATE, USER);
            END;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(']');

        IF v_qtd = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
            VALUES ('PKG_EXPORTACAO.PRC_EXPORTA_LEITURAS_JSON', 100, 'Nenhuma leitura exportada', SYSDATE, USER);
        WHEN VALUE_ERROR THEN
            INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
            VALUES ('PKG_EXPORTACAO.PRC_EXPORTA_LEITURAS_JSON', 2, 'Erro de valor na exportacao', SYSDATE, USER);
        WHEN OTHERS THEN
            v_codigo := SQLCODE;
            v_erro   := SQLERRM;
            INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
            VALUES ('PKG_EXPORTACAO.PRC_EXPORTA_LEITURAS_JSON', v_codigo, v_erro, SYSDATE, USER);
    END PRC_EXPORTA_LEITURAS_JSON;

END PKG_EXPORTACAO;
/

------------------------------------------------------------
-- TESTES (prints para a documentacao)
------------------------------------------------------------
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Sucesso: primeira leitura cadastrada
DECLARE
    v_id NUMBER;
BEGIN
    SELECT MIN(ID_LEITURA) INTO v_id FROM T_CLY_LEITURA_IOT;
    DBMS_OUTPUT.PUT_LINE(PKG_EXPORTACAO.FUNC_LEITURA_TO_JSON(v_id));
END;
/

-- Excecao tratada: leitura inexistente
BEGIN
    DBMS_OUTPUT.PUT_LINE(PKG_EXPORTACAO.FUNC_LEITURA_TO_JSON(99999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/


------------------------------------------------------------
-- EXPORTACAO: gera o arquivo leituras_iot.json
-- Rodar com F5 (Run Script). A pasta de destino precisa existir.
-- Fica no fim do script para o pacote ja estar criado, e o SPOOL so
-- grava o que vem depois dele, entao a saida dos testes acima nao
-- entra no arquivo.
------------------------------------------------------------
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 32767
SET PAGESIZE 0
SET FEEDBACK OFF
SET ECHO OFF
SET VERIFY OFF
SET TRIMSPOOL ON

SPOOL E:\2TDSPG\challenge\PetPulseDB\leituras_iot.json
EXEC PKG_EXPORTACAO.PRC_EXPORTA_LEITURAS_JSON;
SPOOL OFF

SET FEEDBACK ON
SET PAGESIZE 14

SELECT COUNT(*) FROM T_CLY_LEITURA_IOT;