------------------------------------------------------------
-- PROJETO: CLYVO VET - SCRIPT DE LIMPEZA (DROP)
-- ORDEM: procedures primeiro, depois tabelas filhas -> pais
------------------------------------------------------------

------------------------------------------------------------
-- DROP DAS PROCEDURES
------------------------------------------------------------

DROP PROCEDURE PRC_CARGA_HISTORICO;
DROP PROCEDURE PRC_CARGA_ALERTA;
DROP PROCEDURE PRC_CARGA_LEITURA_IOT;
DROP PROCEDURE PRC_CARGA_DISPOSITIVO;
DROP PROCEDURE PRC_CARGA_PET;
DROP PROCEDURE PRC_CARGA_RACA;
DROP PROCEDURE PRC_CARGA_ESPECIE;
DROP PROCEDURE PRC_CARGA_PORTE;
DROP PROCEDURE PRC_CARGA_PROFISSIONAL;
DROP PROCEDURE PRC_CARGA_CLINICA;
DROP PROCEDURE PRC_CARGA_TIPO_ALERTA;
DROP PROCEDURE PRC_CARGA_TELEFONE_USUARIO;
DROP PROCEDURE PRC_CARGA_ENDERECO_USUARIO;
DROP PROCEDURE PRC_CARGA_USUARIO;
DROP PROCEDURE PRC_CARGA_TIPO_ENDERECO;
DROP PROCEDURE PRC_CARGA_CIDADE;
DROP PROCEDURE PRC_CARGA_ESTADO;

------------------------------------------------------------
-- DROP DOS OBJETOS DA SPRINT 3 (05_SPRINT3_BD.sql)
------------------------------------------------------------
------------------------------------------------------------
-- DROP DOS PACOTES (06_PACKAGES.sql - Sprint 4)
-- Se o schema ainda estiver na versao pre-empacotamento (so
-- Sprint 3), estes DROPs falham silenciosamente (ORA-04043) e
-- o SQL*Plus segue para a proxima linha sem interromper o script.
------------------------------------------------------------
DROP PACKAGE PKG_AUDITORIA;
DROP PACKAGE PKG_RELATORIOS;
DROP PACKAGE PKG_CARGA;

DROP TRIGGER TRG_AUDITORIA_PET;
DROP TABLE T_CLY_AUDITORIA_PET CASCADE CONSTRAINTS;
DROP PROCEDURE PRC_REL_LEITURAS_SUBTOTAL;
DROP PROCEDURE PRC_REL_PETS_JSON;
DROP FUNCTION FUNC_VALIDA_PESO_PORTE;
DROP FUNCTION FUNC_PET_TO_JSON;


------------------------------------------------------------
-- DROP DAS TABELAS
-- Ordem: filhas antes das pais (respeitar FKs)
------------------------------------------------------------

-- Nivel 4: tabelas que dependem de PET e de outras normalizadas
DROP TABLE T_CLY_ALERTA_INTELIGENTE  CASCADE CONSTRAINTS;
DROP TABLE T_CLY_LEITURA_IOT         CASCADE CONSTRAINTS;
DROP TABLE T_CLY_HISTORICO_CLINICO   CASCADE CONSTRAINTS;

-- Nivel 3: tabelas que dependem de PET
DROP TABLE T_CLY_DISPOSITIVO_IOT     CASCADE CONSTRAINTS;

-- Nivel 3: tabelas que dependem de USUARIO
DROP TABLE T_CLY_ENDERECO_USUARIO    CASCADE CONSTRAINTS;
DROP TABLE T_CLY_TELEFONE_USUARIO    CASCADE CONSTRAINTS;

-- Nivel 2: PET (depende de USUARIO, ESPECIE, RACA, PORTE)
DROP TABLE T_CLY_PET                 CASCADE CONSTRAINTS;

-- Nivel 2: RACA (depende de ESPECIE)
DROP TABLE T_CLY_RACA                CASCADE CONSTRAINTS;

-- Nivel 2: PROFISSIONAL (depende de CLINICA)
DROP TABLE T_CLY_PROFISSIONAL        CASCADE CONSTRAINTS;

-- Nivel 2: CIDADE (depende de ESTADO)
DROP TABLE T_CLY_CIDADE              CASCADE CONSTRAINTS;

-- Nivel 1: tabelas independentes (pais)
DROP TABLE T_CLY_USUARIO             CASCADE CONSTRAINTS;
DROP TABLE T_CLY_ESPECIE             CASCADE CONSTRAINTS;
DROP TABLE T_CLY_PORTE               CASCADE CONSTRAINTS;
DROP TABLE T_CLY_TIPO_ALERTA         CASCADE CONSTRAINTS;
DROP TABLE T_CLY_CLINICA             CASCADE CONSTRAINTS;
DROP TABLE T_CLY_ESTADO              CASCADE CONSTRAINTS;
DROP TABLE T_CLY_TIPO_ENDERECO       CASCADE CONSTRAINTS;

-- Log (sem dependencias)
DROP TABLE T_CLY_LOG_ERRO            CASCADE CONSTRAINTS;