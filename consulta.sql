------------------------------------------------------------
-- PROJETO: CLYVO VET - SAÚDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- OBJETIVO: CONSULTAR AS TABELAS 
------------------------------------------------------------


-- Consulta simples
SELECT * FROM T_CLY_USUARIO;

SELECT * FROM T_CLY_PET;

SELECT * FROM T_CLY_HISTORICO_CLINICO;

SELECT * FROM T_CLY_DISPOSITIVO_IOT;

SELECT * FROM T_CLY_ALERTA_INTELIGENTE;



-- Consulta com filtros
SELECT 
    id_pet,
    nome,
    especie,
    raca,
    peso,
    porte
FROM T_CLY_PET
WHERE especie = 'CACHORRO'
ORDER BY nome;

SELECT
    id_alerta,
    id_pet,
    tipo_alerta,
    nivel_risco,
    mensagem,
    status
FROM T_CLY_ALERTA_INTELIGENTE
WHERE status = 'ABERTO'
ORDER BY dt_geracao DESC;

SELECT
    id_historico,
    id_pet,
    tipo_registro,
    descricao,
    dt_registro
FROM T_CLY_HISTORICO_CLINICO
WHERE tipo_registro = 'VACINA'
ORDER BY dt_registro DESC;


-- Consultas com JOIN

------------------------------------
-- Pets com seus tutores
------------------------------------
SELECT
    p.id_pet,
    p.nome AS nome_pet,
    p.especie,
    p.raca,
    u.nome AS nome_tutor,
    u.email,
    u.telefone
FROM T_CLY_PET p
INNER JOIN T_CLY_USUARIO u
    ON p.id_usuario = u.id_usuario
ORDER BY u.nome, p.nome;

------------------------------------
-- Histórico clínico por pet
------------------------------------
SELECT
    p.nome AS nome_pet,
    h.tipo_registro,
    h.descricao,
    h.dt_registro,
    h.dt_retorno,
    h.profissional_clinica
FROM T_CLY_HISTORICO_CLINICO h
INNER JOIN T_CLY_PET p
    ON h.id_pet = p.id_pet
ORDER BY p.nome, h.dt_registro;

------------------------------------
-- Alertas com pet e tutor
------------------------------------
SELECT
    a.id_alerta,
    p.nome AS nome_pet,
    u.nome AS nome_tutor,
    a.tipo_alerta,
    a.nivel_risco,
    a.mensagem,
    a.status,
    a.dt_geracao
FROM T_CLY_ALERTA_INTELIGENTE a
INNER JOIN T_CLY_PET p
    ON a.id_pet = p.id_pet
INNER JOIN T_CLY_USUARIO u
    ON p.id_usuario = u.id_usuario
ORDER BY a.dt_geracao DESC;

------------------------------------
-- Dispositivos IoT ativos
------------------------------------
SELECT
    d.id_dispositivo,
    p.nome AS nome_pet,
    d.frequencia_cardiaca,
    d.nivel_atividade,
    d.pressao,
    d.dt_ultima_leitura,
    d.status
FROM T_CLY_DISPOSITIVO_IOT d
INNER JOIN T_CLY_PET p
    ON d.id_pet = p.id_pet
WHERE d.status = 'ATIVO'
ORDER BY d.dt_ultima_leitura DESC;
