------------------------------------------------------------
-- PROJETO: CLYVO VET - SAUDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- ARQUIVO: 04_RELATORIOS.sql
-- DESCRICAO: BLOCO ANTERIOR/ATUAL/PROXIMO + CURSORES EXPLICITOS
--            + RELATORIOS COM JOIN, GROUP BY E ORDER BY
-- EXECUCAO: 4º - executar apos 03_CARGA.sql
------------------------------------------------------------


------------------------------------------------------------
-- BLOCO ANTERIOR / ATUAL / PROXIMO
-- Exibe o peso de cada pet com o peso anterior e proximo
-- O relatorio possui 5 linhas de dados conforme exigido
------------------------------------------------------------
SET SERVEROUTPUT ON;


DECLARE

    CURSOR c_pet IS
        SELECT ID_PET, NOME, PESO
        FROM T_CLY_PET
        ORDER BY ID_PET;

    TYPE t_registro IS RECORD (
        id_pet NUMBER,
        nome   VARCHAR2(100),
        peso   NUMBER
    );
    TYPE t_lista IS TABLE OF t_registro INDEX BY PLS_INTEGER;

    v_lista  t_lista;
    v_index  NUMBER := 0;

BEGIN

    FOR r IN c_pet LOOP
        v_index := v_index + 1;
        v_lista(v_index).id_pet := r.ID_PET;
        v_lista(v_index).nome   := r.NOME;
        v_lista(v_index).peso   := r.PESO;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: PESO ANTERIOR / ATUAL / PROXIMO ===');

    FOR i IN 1 .. v_lista.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || v_lista(i).nome ||
            ' | Anterior: ' ||
            CASE WHEN i = 1 THEN 'Vazio'
                 ELSE TO_CHAR(v_lista(i - 1).peso) END ||
            ' | Atual: ' || TO_CHAR(v_lista(i).peso) ||
            ' | Proximo: ' ||
            CASE WHEN i = v_lista.COUNT THEN 'Vazio'
                 ELSE TO_CHAR(v_lista(i + 1).peso) END
        );
    END LOOP;

END;
/

------------------------------------------------------------
-- RELATORIO 1 (CURSOR EXPLICITO)
-- Usuarios cadastrados
------------------------------------------------------------
DECLARE
    CURSOR c_usuarios IS
        SELECT NOME, EMAIL
        FROM T_CLY_USUARIO
        ORDER BY NOME;

    v_nome  VARCHAR2(150);
    v_email VARCHAR2(150);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: USUARIOS CADASTRADOS ===');
    OPEN c_usuarios;
    LOOP
        FETCH c_usuarios INTO v_nome, v_email;
        EXIT WHEN c_usuarios%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nome: ' || v_nome || ' | Email: ' || v_email);
    END LOOP;
    CLOSE c_usuarios;
END;
/

------------------------------------------------------------
-- RELATORIO 2 (CURSOR EXPLICITO)
-- Pets com especie e porte normalizados
------------------------------------------------------------
DECLARE
    CURSOR c_pets IS
        SELECT p.NOME, e.NOME_ESPECIE, po.DESCRICAO AS PORTE, p.PESO
        FROM T_CLY_PET p
        INNER JOIN T_CLY_ESPECIE e  ON p.ID_ESPECIE = e.ID_ESPECIE
        INNER JOIN T_CLY_PORTE   po ON p.ID_PORTE   = po.ID_PORTE
        ORDER BY p.NOME;

    v_nome    VARCHAR2(100);
    v_especie VARCHAR2(50);
    v_porte   VARCHAR2(30);
    v_peso    NUMBER;
    v_diagnostico_porte VARCHAR2(60);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: PETS CADASTRADOS ===');
    OPEN c_pets;
    LOOP
        FETCH c_pets INTO v_nome, v_especie, v_porte, v_peso;
        EXIT WHEN c_pets%NOTFOUND;

        -- DECISAO: peso informado eh compativel com o porte cadastrado?
        IF v_peso IS NULL THEN
            v_diagnostico_porte := 'Peso nao informado';
        ELSIF v_porte = 'PEQUENO' AND v_peso > 10 THEN
            v_diagnostico_porte := 'Peso incompativel (acima do esperado)';
        ELSIF v_porte = 'MEDIO' AND (v_peso <= 10 OR v_peso > 25) THEN
            v_diagnostico_porte := 'Peso incompativel com o porte';
        ELSIF v_porte = 'GRANDE' AND v_peso <= 25 THEN
            v_diagnostico_porte := 'Peso incompativel (abaixo do esperado)';
        ELSE
            v_diagnostico_porte := 'Peso compativel com o porte';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Pet: '      || v_nome    ||
            ' | Especie: ' || v_especie ||
            ' | Porte: '   || v_porte   ||
            ' | Peso: '    || v_peso    ||
            ' | Diagnostico: ' || v_diagnostico_porte
        );
    END LOOP;
    CLOSE c_pets;
END;
/

------------------------------------------------------------
-- RELATORIO 3 (CURSOR EXPLICITO)
-- Historico clinico com profissional e clinica
------------------------------------------------------------
DECLARE
    CURSOR c_historico IS
        SELECT h.TIPO_REGISTRO, h.DESCRICAO,
               pr.NOME_PROFISSIONAL, c.NOME_CLINICA, h.DT_RETORNO
        FROM T_CLY_HISTORICO_CLINICO h
        LEFT JOIN T_CLY_PROFISSIONAL pr ON h.ID_PROFISSIONAL = pr.ID_PROFISSIONAL
        LEFT JOIN T_CLY_CLINICA      c  ON pr.ID_CLINICA     = c.ID_CLINICA
        ORDER BY h.DT_REGISTRO DESC;

    v_tipo         VARCHAR2(50);
    v_descricao    VARCHAR2(500);
    v_profissional VARCHAR2(150);
    v_clinica      VARCHAR2(150);
    v_dt_retorno   DATE;
    v_situacao_retorno VARCHAR2(40);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: HISTORICO CLINICO ===');
    OPEN c_historico;
    LOOP
        FETCH c_historico INTO v_tipo, v_descricao, v_profissional, v_clinica, v_dt_retorno;
        EXIT WHEN c_historico%NOTFOUND;

        -- DECISAO: situacao do retorno agendado
        IF v_dt_retorno IS NULL THEN
            v_situacao_retorno := 'Sem retorno agendado';
        ELSIF v_dt_retorno < TRUNC(SYSDATE) THEN
            v_situacao_retorno := 'RETORNO ATRASADO';
        ELSIF v_dt_retorno <= TRUNC(SYSDATE) + 7 THEN
            v_situacao_retorno := 'Retorno proximo (ate 7 dias)';
        ELSE
            v_situacao_retorno := 'Retorno agendado';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Tipo: '            || v_tipo ||
            ' | Descricao: '    || v_descricao ||
            ' | Profissional: ' || NVL(v_profissional, 'Nao informado') ||
            ' | Clinica: '      || NVL(v_clinica, 'Nao informada') ||
            ' | Situacao Retorno: ' || v_situacao_retorno
        );
    END LOOP;
    CLOSE c_historico;
END;
/

------------------------------------------------------------
-- RELATORIO 4 (CURSOR EXPLICITO)
-- Alertas com tipo normalizado e nivel de risco
------------------------------------------------------------
DECLARE
    CURSOR c_alerta IS
        SELECT ta.DESCRICAO AS TIPO, a.NIVEL_RISCO, a.STATUS, a.MENSAGEM
        FROM T_CLY_ALERTA_INTELIGENTE a
        INNER JOIN T_CLY_TIPO_ALERTA ta ON a.ID_TIPO_ALERTA = ta.ID_TIPO_ALERTA
        ORDER BY
            CASE a.NIVEL_RISCO WHEN 'ALTO' THEN 1
                               WHEN 'MEDIO' THEN 2
                               ELSE 3 END;

    v_tipo     VARCHAR2(100);
    v_risco    VARCHAR2(20);
    v_status   VARCHAR2(20);
    v_mensagem VARCHAR2(500);
    v_acao     VARCHAR2(40);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: ALERTAS INTELIGENTES ===');
    OPEN c_alerta;
    LOOP
        FETCH c_alerta INTO v_tipo, v_risco, v_status, v_mensagem;
        EXIT WHEN c_alerta%NOTFOUND;

        -- DECISAO: acao recomendada conforme risco x status
        IF v_status = 'RESOLVIDO' THEN
            v_acao := 'CONCLUIDO';
        ELSIF v_risco = 'ALTO' AND v_status IN ('ABERTO', 'VISUALIZADO') THEN
            v_acao := 'ACAO IMEDIATA';
        ELSIF v_risco = 'MEDIO' AND v_status = 'ABERTO' THEN
            v_acao := 'MONITORAR';
        ELSIF v_risco = 'BAIXO' THEN
            v_acao := 'ACOMPANHAR';
        ELSE
            v_acao := 'AVALIAR';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Tipo: '       || v_tipo    ||
            ' | Risco: '   || v_risco   ||
            ' | Status: '  || v_status  ||
            ' | Mensagem: '|| v_mensagem ||
            ' | Acao recomendada: ' || v_acao
        );
    END LOOP;
    CLOSE c_alerta;
END;
/

------------------------------------------------------------
-- RELATORIO 5: JOIN + GROUP BY + ORDER BY
-- Total de pets por tutor
------------------------------------------------------------
DECLARE
    CURSOR c_relatorio IS
        SELECT u.NOME AS tutor, COUNT(p.ID_PET) AS total_pets
        FROM T_CLY_USUARIO u
        INNER JOIN T_CLY_PET p ON u.ID_USUARIO = p.ID_USUARIO
        GROUP BY u.NOME
        ORDER BY total_pets DESC;

    v_tutor      VARCHAR2(150);
    v_total_pets NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: TOTAL DE PETS POR TUTOR ===');
    OPEN c_relatorio;
    LOOP
        FETCH c_relatorio INTO v_tutor, v_total_pets;
        EXIT WHEN c_relatorio%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Tutor: ' || v_tutor ||
            ' | Total Pets: ' || v_total_pets
        );
    END LOOP;
    CLOSE c_relatorio;
END;
/

------------------------------------------------------------
-- RELATORIO 6: JOIN + ORDER BY
-- Pets e seus alertas com nivel de risco
------------------------------------------------------------
DECLARE
    CURSOR c_relatorio IS
        SELECT p.NOME AS nome_pet, ta.DESCRICAO AS tipo_alerta, a.NIVEL_RISCO
        FROM T_CLY_PET p
        INNER JOIN T_CLY_ALERTA_INTELIGENTE a  ON p.ID_PET        = a.ID_PET
        INNER JOIN T_CLY_TIPO_ALERTA        ta ON a.ID_TIPO_ALERTA = ta.ID_TIPO_ALERTA
        ORDER BY
            CASE a.NIVEL_RISCO WHEN 'ALTO' THEN 1
                               WHEN 'MEDIO' THEN 2
                               ELSE 3 END,
            p.NOME;

    v_pet    VARCHAR2(100);
    v_alerta VARCHAR2(100);
    v_risco  VARCHAR2(20);
    v_prioridade VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: PETS E SEUS ALERTAS ===');
    OPEN c_relatorio;
    LOOP
        FETCH c_relatorio INTO v_pet, v_alerta, v_risco;
        EXIT WHEN c_relatorio%NOTFOUND;

        -- DECISAO: prioridade de atendimento conforme nivel de risco
        v_prioridade := CASE v_risco
                            WHEN 'ALTO'  THEN 'P1 - URGENTE'
                            WHEN 'MEDIO' THEN 'P2 - MODERADA'
                            ELSE 'P3 - BAIXA'
                         END;

        DBMS_OUTPUT.PUT_LINE(
            'Pet: '     || v_pet    ||
            ' | Alerta: ' || v_alerta ||
            ' | Risco: '  || v_risco  ||
            ' | Prioridade: ' || v_prioridade
        );
    END LOOP;
    CLOSE c_relatorio;
END;
/

------------------------------------------------------------
-- RELATORIO 7: JOIN + GROUP BY + ORDER BY
-- Total de registros clinicos por especie
------------------------------------------------------------
DECLARE
    CURSOR c_relatorio IS
        SELECT e.NOME_ESPECIE, COUNT(h.ID_HISTORICO) AS total_registros
        FROM T_CLY_PET p
        INNER JOIN T_CLY_ESPECIE           e ON p.ID_ESPECIE = e.ID_ESPECIE
        INNER JOIN T_CLY_HISTORICO_CLINICO h ON p.ID_PET     = h.ID_PET
        GROUP BY e.NOME_ESPECIE
        ORDER BY total_registros DESC;

    v_especie VARCHAR2(50);
    v_total   NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO: REGISTROS CLINICOS POR ESPECIE ===');
    OPEN c_relatorio;
    LOOP
        FETCH c_relatorio INTO v_especie, v_total;
        EXIT WHEN c_relatorio%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Especie: ' || v_especie ||
            ' | Total registros: ' || v_total
        );
    END LOOP;
    CLOSE c_relatorio;
END;
/

------------------------------------------------------------
-- RELATORIO 8: CONSOLIDADO COM SUMARIZACAO
-- Reune indicadores agregados de varias tabelas (COUNT, AVG, SUM)
-- em um unico painel e aplica decisao sobre a situacao geral
-- do sistema (percentual de alertas em aberto/alto risco).
------------------------------------------------------------
DECLARE
    v_total_usuarios     NUMBER;
    v_total_pets         NUMBER;
    v_peso_medio         NUMBER;
    v_total_dispositivos NUMBER;
    v_disp_ativos        NUMBER;
    v_disp_inativos      NUMBER;
    v_disp_manutencao    NUMBER;
    v_total_leituras     NUMBER;
    v_total_historico    NUMBER;
    v_total_alertas      NUMBER;
    v_alertas_abertos    NUMBER;
    v_alertas_alto_risco NUMBER;
    v_alertas_resolvidos NUMBER;
    v_pct_abertos        NUMBER;
    v_situacao_geral     VARCHAR2(60);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELATORIO 8: CONSOLIDADO GERAL (SUMARIZACAO) ===');

    -- Indicadores de USUARIO / PET
    SELECT COUNT(*) INTO v_total_usuarios FROM T_CLY_USUARIO;
    SELECT COUNT(*), AVG(PESO) INTO v_total_pets, v_peso_medio FROM T_CLY_PET;

    -- Indicadores de DISPOSITIVO IOT (contagem por status na mesma consulta)
    SELECT COUNT(*),
           SUM(CASE WHEN STATUS = 'ATIVO'      THEN 1 ELSE 0 END),
           SUM(CASE WHEN STATUS = 'INATIVO'    THEN 1 ELSE 0 END),
           SUM(CASE WHEN STATUS = 'MANUTENCAO' THEN 1 ELSE 0 END)
    INTO v_total_dispositivos, v_disp_ativos, v_disp_inativos, v_disp_manutencao
    FROM T_CLY_DISPOSITIVO_IOT;

    -- Indicadores de LEITURA IOT e HISTORICO CLINICO
    SELECT COUNT(*) INTO v_total_leituras  FROM T_CLY_LEITURA_IOT;
    SELECT COUNT(*) INTO v_total_historico FROM T_CLY_HISTORICO_CLINICO;

    -- Indicadores de ALERTA INTELIGENTE
    SELECT COUNT(*),
           SUM(CASE WHEN STATUS = 'ABERTO'                        THEN 1 ELSE 0 END),
           SUM(CASE WHEN NIVEL_RISCO = 'ALTO' AND STATUS <> 'RESOLVIDO' THEN 1 ELSE 0 END),
           SUM(CASE WHEN STATUS = 'RESOLVIDO'                     THEN 1 ELSE 0 END)
    INTO v_total_alertas, v_alertas_abertos, v_alertas_alto_risco, v_alertas_resolvidos
    FROM T_CLY_ALERTA_INTELIGENTE;

    -- DECISAO: percentual de alertas em aberto e classificacao da situacao geral
    IF v_total_alertas = 0 THEN
        v_pct_abertos := 0;
    ELSE
        v_pct_abertos := ROUND((v_alertas_abertos / v_total_alertas) * 100, 1);
    END IF;

    IF v_alertas_alto_risco > 0 THEN
        v_situacao_geral := 'CRITICA - existem alertas de alto risco nao resolvidos';
    ELSIF v_pct_abertos > 50 THEN
        v_situacao_geral := 'ATENCAO - mais da metade dos alertas segue em aberto';
    ELSIF v_pct_abertos > 0 THEN
        v_situacao_geral := 'ESTAVEL - alertas em aberto sob controle';
    ELSE
        v_situacao_geral := 'NORMAL - nenhum alerta pendente';
    END IF;

    DBMS_OUTPUT.PUT_LINE('--- Usuarios e Pets ---');
    DBMS_OUTPUT.PUT_LINE('Total de usuarios cadastrados : ' || v_total_usuarios);
    DBMS_OUTPUT.PUT_LINE('Total de pets cadastrados      : ' || v_total_pets);
    DBMS_OUTPUT.PUT_LINE('Peso medio dos pets (kg)        : ' || ROUND(NVL(v_peso_medio, 0), 2));

    DBMS_OUTPUT.PUT_LINE('--- Dispositivos IoT ---');
    DBMS_OUTPUT.PUT_LINE('Total de dispositivos           : ' || v_total_dispositivos);
    DBMS_OUTPUT.PUT_LINE('  Ativos      : ' || v_disp_ativos);
    DBMS_OUTPUT.PUT_LINE('  Inativos    : ' || v_disp_inativos);
    DBMS_OUTPUT.PUT_LINE('  Manutencao  : ' || v_disp_manutencao);
    DBMS_OUTPUT.PUT_LINE('Total de leituras registradas   : ' || v_total_leituras);

    DBMS_OUTPUT.PUT_LINE('--- Historico Clinico ---');
    DBMS_OUTPUT.PUT_LINE('Total de registros clinicos     : ' || v_total_historico);

    DBMS_OUTPUT.PUT_LINE('--- Alertas Inteligentes ---');
    DBMS_OUTPUT.PUT_LINE('Total de alertas                : ' || v_total_alertas);
    DBMS_OUTPUT.PUT_LINE('  Em aberto        : ' || v_alertas_abertos || ' (' || v_pct_abertos || '%)');
    DBMS_OUTPUT.PUT_LINE('  Alto risco ativo : ' || v_alertas_alto_risco);
    DBMS_OUTPUT.PUT_LINE('  Resolvidos       : ' || v_alertas_resolvidos);

    DBMS_OUTPUT.PUT_LINE('--- Situacao Geral do Sistema ---');
    DBMS_OUTPUT.PUT_LINE('Diagnostico: ' || v_situacao_geral);
END;
/