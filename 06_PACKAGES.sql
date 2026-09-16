------------------------------------------------------------
-- PROJETO: CLYVO VET - SAUDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- ARQUIVO: 06_PACKAGES.sql
-- DESCRICAO: Entrega da Sprint 4 - Empacotamento (PACKAGE) de todas
--            as procedures, funcoes e da logica do gatilho de
--            auditoria criados nas Sprints 3 e anteriores, para
--            garantir modularidade e reutilizacao de codigo.
--
-- IMPORTANTE SOBRE TRIGGERS EM PACKAGES:
-- O Oracle nao permite que uma TRIGGER seja declarada dentro de um
-- PACKAGE (trigger e sempre um objeto de schema independente). Para
-- atender ao espirito do "empacotamento de gatilhos", a logica de
-- negocio da auditoria foi movida para dentro do PKG_AUDITORIA
-- (procedure REGISTRAR_AUDITORIA_PET), e a trigger TRG_AUDITORIA_PET
-- foi reduzida a uma casca fina que apenas identifica a operacao
-- (:OLD/:NEW) e delega toda a gravacao para o pacote.
--
-- PRE-REQUISITO: executar 01_DDL.sql, 02_PROCEDURES.sql, 03_CARGA.sql
--                e 05_SPRINT3_BD.sql antes deste script (os dados ja
--                devem estar carregados - este script so reorganiza
--                o CODIGO em pacotes, nao recarrega dados).
------------------------------------------------------------

SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PACKAGE 1: PKG_CARGA
-- Agrupa as 17 procedures de carga inicial de dados (uma por
-- tabela), garantindo modularidade e reutilizacao do codigo.
------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_CARGA IS

    PROCEDURE PRC_CARGA_ESTADO (
        p_cod_estado    IN CHAR,
    p_nome_estado   IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_CIDADE (
        p_cod_cidade    IN NUMBER,
    p_cod_estado    IN CHAR,
    p_nome_cidade   IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_TIPO_ENDERECO (
        p_cod_tipo_endereco   IN NUMBER,
    p_des_tipo_endereco   IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_USUARIO (
        p_nome      IN VARCHAR2,
    p_cpf       IN VARCHAR2,
    p_email     IN VARCHAR2,
    p_senha     IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_ENDERECO_USUARIO (
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
    );
    PROCEDURE PRC_CARGA_TELEFONE_USUARIO (
        p_id_telefone     IN NUMBER,
    p_id_usuario      IN NUMBER,
    p_numero_telefone IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_ESPECIE (
        p_nome_especie IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_PORTE (
        p_descricao IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_RACA (
        p_id_especie  IN NUMBER,
    p_nome_raca   IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_PET (
        p_id_usuario    IN NUMBER,
    p_nome          IN VARCHAR2,
    p_id_especie    IN NUMBER,
    p_id_raca       IN NUMBER,
    p_id_porte      IN NUMBER,
    p_dt_nascimento IN DATE,
    p_peso          IN NUMBER,
    p_sexo          IN CHAR,
    p_castrado      IN CHAR
    );
    PROCEDURE PRC_CARGA_DISPOSITIVO (
        p_id_pet          IN NUMBER,
    p_intervalo       IN NUMBER,
    p_frequencia      IN NUMBER,
    p_nivel_atividade IN NUMBER,
    p_pressao         IN NUMBER,
    p_status          IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_LEITURA_IOT (
        p_id_dispositivo      IN NUMBER,
    p_dt_leitura          IN DATE,
    p_frequencia_cardiaca IN NUMBER,
    p_nivel_atividade     IN NUMBER,
    p_pressao             IN NUMBER
    );
    PROCEDURE PRC_CARGA_TIPO_ALERTA (
        p_descricao IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_ALERTA (
        p_id_pet          IN NUMBER,
    p_id_tipo_alerta  IN NUMBER,
    p_nivel_risco     IN VARCHAR2,
    p_origem_alerta   IN VARCHAR2,
    p_mensagem        IN VARCHAR2,
    p_recomendacao    IN VARCHAR2,
    p_status          IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_CLINICA (
        p_nome_clinica IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_PROFISSIONAL (
        p_id_clinica          IN NUMBER,
    p_nome_profissional   IN VARCHAR2,
    p_email               IN VARCHAR2,
    p_senha               IN VARCHAR2,
    p_crmv                IN VARCHAR2
    );
    PROCEDURE PRC_CARGA_HISTORICO (
        p_id_pet            IN NUMBER,
    p_id_profissional   IN NUMBER,
    p_tipo_registro     IN VARCHAR2,
    p_descricao         IN VARCHAR2,
    p_dt_retorno        IN DATE,
    p_observacoes       IN VARCHAR2
    );

END PKG_CARGA;
/

CREATE OR REPLACE PACKAGE BODY PKG_CARGA IS

PROCEDURE PRC_CARGA_ESTADO (
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
END PRC_CARGA_ESTADO;

PROCEDURE PRC_CARGA_CIDADE (
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
END PRC_CARGA_CIDADE;

PROCEDURE PRC_CARGA_TIPO_ENDERECO (
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
END PRC_CARGA_TIPO_ENDERECO;

PROCEDURE PRC_CARGA_USUARIO (
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
END PRC_CARGA_USUARIO;

PROCEDURE PRC_CARGA_ENDERECO_USUARIO (
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
END PRC_CARGA_ENDERECO_USUARIO;

PROCEDURE PRC_CARGA_TELEFONE_USUARIO (
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
END PRC_CARGA_TELEFONE_USUARIO;

PROCEDURE PRC_CARGA_ESPECIE (
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
END PRC_CARGA_ESPECIE;

PROCEDURE PRC_CARGA_PORTE (
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
END PRC_CARGA_PORTE;

PROCEDURE PRC_CARGA_RACA (
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
END PRC_CARGA_RACA;

PROCEDURE PRC_CARGA_PET (
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
END PRC_CARGA_PET;

PROCEDURE PRC_CARGA_DISPOSITIVO (
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
END PRC_CARGA_DISPOSITIVO;

PROCEDURE PRC_CARGA_LEITURA_IOT (
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
END PRC_CARGA_LEITURA_IOT;

PROCEDURE PRC_CARGA_TIPO_ALERTA (
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
END PRC_CARGA_TIPO_ALERTA;

PROCEDURE PRC_CARGA_ALERTA (
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
END PRC_CARGA_ALERTA;

PROCEDURE PRC_CARGA_CLINICA (
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
END PRC_CARGA_CLINICA;

PROCEDURE PRC_CARGA_PROFISSIONAL (
    p_id_clinica          IN NUMBER,
    p_nome_profissional   IN VARCHAR2,
    p_email               IN VARCHAR2,
    p_senha               IN VARCHAR2,
    p_crmv                IN VARCHAR2
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
    INSERT INTO T_CLY_PROFISSIONAL (ID_CLINICA, NOME_PROFISSIONAL, EMAIL, SENHA, CRMV)
    VALUES (p_id_clinica, p_nome_profissional, p_email, p_senha, p_crmv);
    DBMS_OUTPUT.PUT_LINE('Profissional cadastrado: ' || p_nome_profissional);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
        VALUES ('PRC_CARGA_PROFISSIONAL', 1, 'Email ou CRMV ja cadastrado', SYSDATE, USER);
        DBMS_OUTPUT.PUT_LINE('Erro: Email ou CRMV ja existente');
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
END PRC_CARGA_PROFISSIONAL;

PROCEDURE PRC_CARGA_HISTORICO (
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
END PRC_CARGA_HISTORICO;

END PKG_CARGA;
/

------------------------------------------------------------
-- PACKAGE 2: PKG_RELATORIOS
-- Agrupa as 2 funcoes e as 2 procedures analiticas da Sprint 3:
-- conversao manual para JSON, validacao de peso x porte, e o
-- relatorio de subtotal de leituras IoT por dispositivo.
------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_RELATORIOS IS

    FUNCTION FUNC_PET_TO_JSON (
        p_id_pet   IN NUMBER,
    p_nome_pet IN VARCHAR2,
    p_tutor    IN VARCHAR2,
    p_especie  IN VARCHAR2,
    p_raca     IN VARCHAR2,
    p_porte    IN VARCHAR2,
    p_peso     IN NUMBER,
    p_sexo     IN VARCHAR2
    ) RETURN VARCHAR2;
    FUNCTION FUNC_VALIDA_PESO_PORTE (
        p_porte IN VARCHAR2,
    p_peso  IN NUMBER
    ) RETURN VARCHAR2;
    PROCEDURE PRC_REL_PETS_JSON;
    PROCEDURE PRC_REL_LEITURAS_SUBTOTAL;

END PKG_RELATORIOS;
/

CREATE OR REPLACE PACKAGE BODY PKG_RELATORIOS IS

FUNCTION FUNC_PET_TO_JSON (
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
END FUNC_PET_TO_JSON;

FUNCTION FUNC_VALIDA_PESO_PORTE (
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
END FUNC_VALIDA_PESO_PORTE;

PROCEDURE PRC_REL_PETS_JSON
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
END PRC_REL_PETS_JSON;

PROCEDURE PRC_REL_LEITURAS_SUBTOTAL
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
END PRC_REL_LEITURAS_SUBTOTAL;

END PKG_RELATORIOS;
/

------------------------------------------------------------
-- PACKAGE 3: PKG_AUDITORIA
-- Concentra a logica de gravacao da auditoria de T_CLY_PET, que
-- antes estava embutida diretamente no corpo da trigger. Isso
-- torna a logica reutilizavel (pode ser chamada de outros pontos
-- do sistema, nao so da trigger) e testavel isoladamente.
------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_AUDITORIA IS

    PROCEDURE REGISTRAR_AUDITORIA_PET (
        p_tipo_operacao      IN VARCHAR2,
        p_id_pet_ref         IN NUMBER,
        p_valores_anteriores IN VARCHAR2,
        p_valores_novos      IN VARCHAR2
    );

END PKG_AUDITORIA;
/

CREATE OR REPLACE PACKAGE BODY PKG_AUDITORIA IS

    PROCEDURE REGISTRAR_AUDITORIA_PET (
        p_tipo_operacao      IN VARCHAR2,
        p_id_pet_ref         IN NUMBER,
        p_valores_anteriores IN VARCHAR2,
        p_valores_novos      IN VARCHAR2
    )
    IS
    BEGIN
        INSERT INTO T_CLY_AUDITORIA_PET (
            NOME_USUARIO, TIPO_OPERACAO, ID_PET_REF,
            VALORES_ANTERIORES, VALORES_NOVOS
        )
        VALUES (
            USER, p_tipo_operacao, p_id_pet_ref,
            p_valores_anteriores, p_valores_novos
        );
    EXCEPTION
        WHEN OTHERS THEN
            -- A auditoria nunca deve impedir a operacao original em
            -- T_CLY_PET; registra o problema no log central e segue.
            INSERT INTO T_CLY_LOG_ERRO (NOME_PROCEDURE, CODIGO_ERRO, MENSAGEM_ERRO, DATA_ERRO, USUARIO_BANCO)
            VALUES ('PKG_AUDITORIA.REGISTRAR_AUDITORIA_PET', SQLCODE, SQLERRM, SYSDATE, USER);
    END REGISTRAR_AUDITORIA_PET;

END PKG_AUDITORIA;
/

------------------------------------------------------------
-- TRIGGER TRG_AUDITORIA_PET (recriada)
-- Agora e apenas uma casca fina: identifica a operacao (:OLD/:NEW)
-- e delega toda a gravacao para PKG_AUDITORIA.REGISTRAR_AUDITORIA_PET.
------------------------------------------------------------
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

    PKG_AUDITORIA.REGISTRAR_AUDITORIA_PET(v_tipo, v_id_ref, v_anterior, v_novo);
END;
/

------------------------------------------------------------
-- REMOCAO DOS OBJETOS AVULSOS (agora substituidos pelos pacotes)
-- Os dados carregados anteriormente pelas versoes avulsas destas
-- procedures/funcoes permanecem intactos nas tabelas - so o CODIGO
-- e removido, ja que agora vive dentro dos pacotes acima.
------------------------------------------------------------
DROP PROCEDURE PRC_CARGA_ESTADO;
DROP PROCEDURE PRC_CARGA_CIDADE;
DROP PROCEDURE PRC_CARGA_TIPO_ENDERECO;
DROP PROCEDURE PRC_CARGA_USUARIO;
DROP PROCEDURE PRC_CARGA_ENDERECO_USUARIO;
DROP PROCEDURE PRC_CARGA_TELEFONE_USUARIO;
DROP PROCEDURE PRC_CARGA_ESPECIE;
DROP PROCEDURE PRC_CARGA_PORTE;
DROP PROCEDURE PRC_CARGA_RACA;
DROP PROCEDURE PRC_CARGA_PET;
DROP PROCEDURE PRC_CARGA_DISPOSITIVO;
DROP PROCEDURE PRC_CARGA_LEITURA_IOT;
DROP PROCEDURE PRC_CARGA_TIPO_ALERTA;
DROP PROCEDURE PRC_CARGA_ALERTA;
DROP PROCEDURE PRC_CARGA_CLINICA;
DROP PROCEDURE PRC_CARGA_PROFISSIONAL;
DROP PROCEDURE PRC_CARGA_HISTORICO;
DROP FUNCTION FUNC_PET_TO_JSON;
DROP FUNCTION FUNC_VALIDA_PESO_PORTE;
DROP PROCEDURE PRC_REL_PETS_JSON;
DROP PROCEDURE PRC_REL_LEITURAS_SUBTOTAL;

------------------------------------------------------------
-- DEMONSTRACAO / TESTES DOS PACOTES
-- Blocos anonimos chamando os pacotes com sintaxe qualificada
-- (PKG_NOME.MEMBRO), para gerar os prints exigidos na
-- documentacao da Sprint 4.
------------------------------------------------------------

-- Teste 1: carregar um novo estado via PKG_CARGA (mostra reutilizacao)
BEGIN
    PKG_CARGA.PRC_CARGA_ESTADO('PR', 'Parana');
END;
/

-- Teste 2: gerar o relatorio de pets em JSON via PKG_RELATORIOS
EXEC PKG_RELATORIOS.PRC_REL_PETS_JSON;

-- Teste 3: gerar o relatorio de subtotal de leituras via PKG_RELATORIOS
EXEC PKG_RELATORIOS.PRC_REL_LEITURAS_SUBTOTAL;

-- Teste 4: validar peso x porte via PKG_RELATORIOS (chamada direta da funcao)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Validacao: ' || PKG_RELATORIOS.FUNC_VALIDA_PESO_PORTE('GRANDE', 30));
END;
/

-- Teste 5: disparar a trigger (que agora delega para PKG_AUDITORIA) e conferir
BEGIN
    UPDATE T_CLY_PET SET PESO = PESO + 1 WHERE ID_PET = 1;
    COMMIT;
END;
/

SELECT ID_AUDITORIA, NOME_USUARIO, TIPO_OPERACAO, DATA_OPERACAO, ID_PET_REF
FROM T_CLY_AUDITORIA_PET
ORDER BY ID_AUDITORIA DESC
FETCH FIRST 5 ROWS ONLY;
