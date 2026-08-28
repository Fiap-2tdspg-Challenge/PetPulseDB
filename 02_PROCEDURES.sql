------------------------------------------------------------
-- PROJETO: CLYVO VET - SAUDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- ARQUIVO: 02_PROCEDURES.sql
-- DESCRICAO: PROCEDURES DE CARGA PARA TODAS AS TABELAS
-- EXECUCAO: 2 - executar apos 01_DDL.sql
------------------------------------------------------------

SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_ESTADO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_ESTADO (
    p_cod_estado    IN CHAR,
    p_nome_estado   IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    INSERT INTO T_CLY_ESTADO (COD_ESTADO, NOME_ESTADO)
    VALUES (UPPER(p_cod_estado), p_nome_estado);
    DBMS_OUTPUT.PUT_LINE('Estado cadastrado: ' || p_nome_estado);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ESTADO', 1, 'Estado ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Estado ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ESTADO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ESTADO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_CIDADE
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_CIDADE (
    p_cod_cidade    IN NUMBER,
    p_cod_estado    IN CHAR,
    p_nome_cidade   IN VARCHAR2
)
IS
    v_estado  NUMBER;
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_estado
    FROM T_CLY_ESTADO WHERE COD_ESTADO = UPPER(p_cod_estado);
    IF v_estado = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Estado nao encontrado');
    END IF;
    INSERT INTO T_CLY_CIDADE (COD_CIDADE, COD_ESTADO, NOME_CIDADE)
    VALUES (p_cod_cidade, UPPER(p_cod_estado), p_nome_cidade);
    DBMS_OUTPUT.PUT_LINE('Cidade cadastrada: ' || p_nome_cidade);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_CIDADE', 1, 'Cidade ja cadastrada', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Cidade ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_CIDADE', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_CIDADE', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_TIPO_ENDERECO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_TIPO_ENDERECO (
    p_cod_tipo_endereco   IN NUMBER,
    p_des_tipo_endereco   IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    INSERT INTO T_CLY_TIPO_ENDERECO (COD_TIPO_ENDERECO, DES_TIPO_ENDERECO)
    VALUES (p_cod_tipo_endereco, p_des_tipo_endereco);
    DBMS_OUTPUT.PUT_LINE('Tipo de endereco cadastrado: ' || p_des_tipo_endereco);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TIPO_ENDERECO', 1, 'Tipo de endereco ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Tipo de endereco ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TIPO_ENDERECO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TIPO_ENDERECO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_USUARIO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_USUARIO (
    p_nome      IN VARCHAR2,
    p_cpf       IN VARCHAR2,
    p_email     IN VARCHAR2,
    p_senha     IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    IF LENGTH(REGEXP_REPLACE(p_cpf, '[^0-9]', '')) < 11 THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF invalido');
    END IF;
    INSERT INTO T_CLY_USUARIO (NOME, CPF, EMAIL, SENHA)
    VALUES (p_nome, p_cpf, p_email, p_senha);
    DBMS_OUTPUT.PUT_LINE('Usuario cadastrado: ' || p_nome);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_USUARIO', 1, 'CPF ou EMAIL ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: CPF ou EMAIL ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_USUARIO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_USUARIO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_ENDERECO_USUARIO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_ENDERECO_USUARIO (
    p_seq_endereco      IN NUMBER,
    p_id_usuario        IN NUMBER,
    p_cod_tipo_end      IN NUMBER,
    p_cod_cidade        IN NUMBER,
    p_des_endereco      IN VARCHAR2,
    p_num_endereco      IN VARCHAR2,
    p_des_complemento   IN VARCHAR2,
    p_num_cep           IN VARCHAR2,
    p_des_bairro        IN VARCHAR2,
    p_sta_ativo         IN CHAR
)
IS
    v_usuario NUMBER;
    v_cidade  NUMBER;
    v_tipo    NUMBER;
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_usuario FROM T_CLY_USUARIO      WHERE ID_USUARIO        = p_id_usuario;
    SELECT COUNT(*) INTO v_cidade  FROM T_CLY_CIDADE        WHERE COD_CIDADE        = p_cod_cidade;
    SELECT COUNT(*) INTO v_tipo    FROM T_CLY_TIPO_ENDERECO WHERE COD_TIPO_ENDERECO = p_cod_tipo_end;
    IF v_usuario = 0 THEN RAISE_APPLICATION_ERROR(-20020, 'Usuario nao encontrado');           END IF;
    IF v_cidade  = 0 THEN RAISE_APPLICATION_ERROR(-20021, 'Cidade nao encontrada');            END IF;
    IF v_tipo    = 0 THEN RAISE_APPLICATION_ERROR(-20022, 'Tipo de endereco nao encontrado');  END IF;
    INSERT INTO T_CLY_ENDERECO_USUARIO (
        SEQ_ENDERECO_USUARIO, ID_USUARIO, COD_TIPO_ENDERECO, COD_CIDADE,
        DES_ENDERECO, NUM_ENDERECO, DES_COMPLEMENTO, NUM_CEP, DES_BAIRRO, STA_ATIVO
    )
    VALUES (
        p_seq_endereco, p_id_usuario, p_cod_tipo_end, p_cod_cidade,
        p_des_endereco, p_num_endereco, p_des_complemento, p_num_cep, p_des_bairro, UPPER(p_sta_ativo)
    );
    DBMS_OUTPUT.PUT_LINE('Endereco cadastrado com sucesso');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ENDERECO_USUARIO', 1, 'Endereco ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Endereco ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ENDERECO_USUARIO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ENDERECO_USUARIO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_TELEFONE_USUARIO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_TELEFONE_USUARIO (
    p_id_telefone     IN NUMBER,
    p_id_usuario      IN NUMBER,
    p_numero_telefone IN VARCHAR2
)
IS
    v_usuario NUMBER;
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_usuario FROM T_CLY_USUARIO WHERE ID_USUARIO = p_id_usuario;
    IF v_usuario = 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Usuario nao encontrado');
    END IF;
    INSERT INTO T_CLY_TELEFONE_USUARIO (ID_TELEFONE, ID_USUARIO, NUMERO_TELEFONE)
    VALUES (p_id_telefone, p_id_usuario, p_numero_telefone);
    DBMS_OUTPUT.PUT_LINE('Telefone cadastrado: ' || p_numero_telefone);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TELEFONE_USUARIO', 1, 'Telefone ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Telefone ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TELEFONE_USUARIO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TELEFONE_USUARIO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_ESPECIE
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_ESPECIE (
    p_nome_especie IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    INSERT INTO T_CLY_ESPECIE (NOME_ESPECIE)
    VALUES (UPPER(p_nome_especie));
    DBMS_OUTPUT.PUT_LINE('Especie cadastrada: ' || p_nome_especie);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ESPECIE', 1, 'Especie ja cadastrada', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Especie ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ESPECIE', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ESPECIE', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_PORTE
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_PORTE (
    p_descricao IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    INSERT INTO T_CLY_PORTE (DESCRICAO)
    VALUES (UPPER(p_descricao));
    DBMS_OUTPUT.PUT_LINE('Porte cadastrado: ' || p_descricao);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PORTE', 1, 'Porte ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Porte ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PORTE', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PORTE', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_RACA
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_RACA (
    p_id_especie  IN NUMBER,
    p_nome_raca   IN VARCHAR2
)
IS
    v_especie NUMBER;
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_especie FROM T_CLY_ESPECIE WHERE ID_ESPECIE = p_id_especie;
    IF v_especie = 0 THEN
        RAISE_APPLICATION_ERROR(-20040, 'Especie nao encontrada');
    END IF;
    INSERT INTO T_CLY_RACA (ID_ESPECIE, NOME_RACA)
    VALUES (p_id_especie, p_nome_raca);
    DBMS_OUTPUT.PUT_LINE('Raca cadastrada: ' || p_nome_raca);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_RACA', 1, 'Raca ja cadastrada', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Raca ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_RACA', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_RACA', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_PET
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_PET (
    p_id_usuario    IN NUMBER,
    p_nome          IN VARCHAR2,
    p_id_especie    IN NUMBER,
    p_id_raca       IN NUMBER,
    p_id_porte      IN NUMBER,
    p_dt_nascimento IN DATE,
    p_peso          IN NUMBER,
    p_sexo          IN CHAR,
    p_castrado      IN CHAR
)
IS
    v_usuario NUMBER;
    v_especie NUMBER;
    v_raca    NUMBER;
    v_porte   NUMBER;
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_usuario FROM T_CLY_USUARIO WHERE ID_USUARIO = p_id_usuario;
    SELECT COUNT(*) INTO v_especie FROM T_CLY_ESPECIE  WHERE ID_ESPECIE = p_id_especie;
    SELECT COUNT(*) INTO v_raca    FROM T_CLY_RACA     WHERE ID_RACA    = p_id_raca;
    SELECT COUNT(*) INTO v_porte   FROM T_CLY_PORTE    WHERE ID_PORTE   = p_id_porte;
    IF v_usuario = 0 THEN RAISE_APPLICATION_ERROR(-20002, 'Usuario nao encontrado'); END IF;
    IF v_especie = 0 THEN RAISE_APPLICATION_ERROR(-20003, 'Especie nao encontrada'); END IF;
    IF v_raca    = 0 THEN RAISE_APPLICATION_ERROR(-20004, 'Raca nao encontrada');    END IF;
    IF v_porte   = 0 THEN RAISE_APPLICATION_ERROR(-20005, 'Porte nao encontrado');   END IF;
    INSERT INTO T_CLY_PET (
        ID_USUARIO, NOME, ID_ESPECIE, ID_RACA, ID_PORTE,
        DT_NASCIMENTO, PESO, SEXO, CASTRADO
    )
    VALUES (
        p_id_usuario, p_nome, p_id_especie, p_id_raca, p_id_porte,
        p_dt_nascimento, p_peso, UPPER(p_sexo), UPPER(p_castrado)
    );
    DBMS_OUTPUT.PUT_LINE('Pet cadastrado: ' || p_nome);
EXCEPTION
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PET', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PET', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_DISPOSITIVO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_DISPOSITIVO (
    p_id_pet          IN NUMBER,
    p_intervalo       IN NUMBER,
    p_frequencia      IN NUMBER,
    p_nivel_atividade IN NUMBER,
    p_pressao         IN NUMBER,
    p_status          IN VARCHAR2
)
IS
    v_pet    NUMBER;
    v_erro   VARCHAR2(4000);
    v_codigo NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_pet FROM T_CLY_PET WHERE ID_PET = p_id_pet;
    IF v_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20050, 'Pet nao encontrado');
    END IF;
    INSERT INTO T_CLY_DISPOSITIVO_IOT (
        ID_PET, INTERVALO_COLETA_MIN, FREQUENCIA_CARDIACA,
        NIVEL_ATIVIDADE, PRESSAO, DT_ULTIMA_LEITURA, STATUS
    )
    VALUES (
        p_id_pet, p_intervalo, p_frequencia,
        p_nivel_atividade, p_pressao, SYSDATE, p_status
    );
    DBMS_OUTPUT.PUT_LINE('Dispositivo cadastrado para o pet ID: ' || p_id_pet);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_DISPOSITIVO', 1, 'Pet ja possui dispositivo cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Dispositivo duplicado');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_DISPOSITIVO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_DISPOSITIVO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_LEITURA_IOT
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_LEITURA_IOT (
    p_id_dispositivo      IN NUMBER,
    p_dt_leitura          IN DATE,
    p_frequencia_cardiaca IN NUMBER,
    p_nivel_atividade     IN NUMBER,
    p_pressao             IN NUMBER
)
IS
    v_dispositivo NUMBER;
    v_erro        VARCHAR2(4000);
    v_codigo      NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_dispositivo
    FROM T_CLY_DISPOSITIVO_IOT WHERE ID_DISPOSITIVO = p_id_dispositivo;
    IF v_dispositivo = 0 THEN
        RAISE_APPLICATION_ERROR(-20060, 'Dispositivo nao encontrado');
    END IF;
    INSERT INTO T_CLY_LEITURA_IOT (
        ID_DISPOSITIVO, DT_LEITURA,
        FREQUENCIA_CARDIACA, NIVEL_ATIVIDADE, PRESSAO
    )
    VALUES (
        p_id_dispositivo, p_dt_leitura,
        p_frequencia_cardiaca, p_nivel_atividade, p_pressao
    );
    DBMS_OUTPUT.PUT_LINE('Leitura IoT registrada com sucesso');
EXCEPTION
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_LEITURA_IOT', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_LEITURA_IOT', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_TIPO_ALERTA
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_TIPO_ALERTA (
    p_descricao IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    INSERT INTO T_CLY_TIPO_ALERTA (DESCRICAO)
    VALUES (p_descricao);
    DBMS_OUTPUT.PUT_LINE('Tipo de alerta cadastrado: ' || p_descricao);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TIPO_ALERTA', 1, 'Tipo de alerta ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Tipo de alerta ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TIPO_ALERTA', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_TIPO_ALERTA', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_ALERTA
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_ALERTA (
    p_id_pet          IN NUMBER,
    p_id_tipo_alerta  IN NUMBER,
    p_nivel_risco     IN VARCHAR2,
    p_origem_alerta   IN VARCHAR2,
    p_mensagem        IN VARCHAR2,
    p_recomendacao    IN VARCHAR2,
    p_status          IN VARCHAR2
)
IS
    v_pet    NUMBER;
    v_tipo   NUMBER;
    v_erro   VARCHAR2(4000);
    v_codigo NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_pet  FROM T_CLY_PET         WHERE ID_PET        = p_id_pet;
    SELECT COUNT(*) INTO v_tipo FROM T_CLY_TIPO_ALERTA WHERE ID_TIPO_ALERTA = p_id_tipo_alerta;
    IF v_pet  = 0 THEN RAISE_APPLICATION_ERROR(-20070, 'Pet nao encontrado');             END IF;
    IF v_tipo = 0 THEN RAISE_APPLICATION_ERROR(-20071, 'Tipo de alerta nao encontrado');  END IF;
    INSERT INTO T_CLY_ALERTA_INTELIGENTE (
        ID_PET, ID_TIPO_ALERTA, NIVEL_RISCO,
        ORIGEM_ALERTA, MENSAGEM, RECOMENDACAO, STATUS
    )
    VALUES (
        p_id_pet, p_id_tipo_alerta, p_nivel_risco,
        p_origem_alerta, p_mensagem, p_recomendacao, p_status
    );
    DBMS_OUTPUT.PUT_LINE('Alerta cadastrado com sucesso');
EXCEPTION
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ALERTA', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_ALERTA', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_CLINICA
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_CLINICA (
    p_nome_clinica IN VARCHAR2
)
IS
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    INSERT INTO T_CLY_CLINICA (NOME_CLINICA)
    VALUES (p_nome_clinica);
    DBMS_OUTPUT.PUT_LINE('Clinica cadastrada: ' || p_nome_clinica);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_CLINICA', 1, 'Clinica ja cadastrada', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Clinica ja existente');
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_CLINICA', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_CLINICA', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_PROFISSIONAL
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_PROFISSIONAL (
    p_id_clinica          IN NUMBER,
    p_nome_profissional   IN VARCHAR2
)
IS
    v_clinica NUMBER;
    v_erro    VARCHAR2(4000);
    v_codigo  NUMBER;
BEGIN
    IF p_id_clinica IS NOT NULL THEN
        SELECT COUNT(*) INTO v_clinica FROM T_CLY_CLINICA WHERE ID_CLINICA = p_id_clinica;
        IF v_clinica = 0 THEN
            RAISE_APPLICATION_ERROR(-20080, 'Clinica nao encontrada');
        END IF;
    END IF;
    INSERT INTO T_CLY_PROFISSIONAL (ID_CLINICA, NOME_PROFISSIONAL)
    VALUES (p_id_clinica, p_nome_profissional);
    DBMS_OUTPUT.PUT_LINE('Profissional cadastrado: ' || p_nome_profissional);
EXCEPTION
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PROFISSIONAL', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PROFISSIONAL', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

------------------------------------------------------------
-- PROCEDURE: PRC_CARGA_HISTORICO
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_CARGA_HISTORICO (
    p_id_pet            IN NUMBER,
    p_id_profissional   IN NUMBER,
    p_tipo_registro     IN VARCHAR2,
    p_descricao         IN VARCHAR2,
    p_dt_retorno        IN DATE,
    p_observacoes       IN VARCHAR2
)
IS
    v_pet          NUMBER;
    v_profissional NUMBER;
    v_erro         VARCHAR2(4000);
    v_codigo       NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_pet FROM T_CLY_PET WHERE ID_PET = p_id_pet;
    IF v_pet = 0 THEN RAISE_APPLICATION_ERROR(-20090, 'Pet nao encontrado'); END IF;
    IF p_id_profissional IS NOT NULL THEN
        SELECT COUNT(*) INTO v_profissional
        FROM T_CLY_PROFISSIONAL WHERE ID_PROFISSIONAL = p_id_profissional;
        IF v_profissional = 0 THEN
            RAISE_APPLICATION_ERROR(-20091, 'Profissional nao encontrado');
        END IF;
    END IF;
    INSERT INTO T_CLY_HISTORICO_CLINICO (
        ID_PET, ID_PROFISSIONAL, TIPO_REGISTRO,
        DESCRICAO, DT_RETORNO, OBSERVACOES
    )
    VALUES (
        p_id_pet, p_id_profissional, p_tipo_registro,
        p_descricao, p_dt_retorno, p_observacoes
    );
    DBMS_OUTPUT.PUT_LINE('Historico clinico inserido com sucesso');
EXCEPTION
    WHEN VALUE_ERROR THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_HISTORICO', 2, 'Erro de valor informado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro de valor');
    WHEN OTHERS THEN
        v_codigo := SQLCODE;
        v_erro   := SQLERRM;
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_HISTORICO', v_codigo, v_erro, SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro [' || v_codigo || ']: ' || v_erro);
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE('MARCADOR: ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS.FF3'));
END;
/