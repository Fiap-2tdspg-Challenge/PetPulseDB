------------------------------------------------------------
-- PROJETO: CLYVO VET - SAÚDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- OBJETIVO: POPULAR AS TABELAS 
------------------------------------------------------------



INSERT INTO T_CLY_USUARIO (
    nome, cpf, email, senha, telefone, endereco
) VALUES (
    'Ana Souza',
    '12345678901',
    'ana.souza@email.com',
    'senha_hash_123',
    '11999990001',
    'Rua das Flores, 100'
);

INSERT INTO T_CLY_USUARIO (
    nome, cpf, email, senha, telefone, endereco
) VALUES (
    'Carlos Lima',
    '98765432100',
    'carlos.lima@email.com',
    'senha_hash_456',
    '11988880002',
    'Av. Brasil, 250'
);

INSERT INTO T_CLY_PET (
    id_usuario, nome, especie, raca, dt_nascimento, peso, sexo, castrado, porte
) VALUES (
    1,
    'Thor',
    'CACHORRO',
    'Golden Retriever',
    TO_DATE('2021-04-10', 'YYYY-MM-DD'),
    28.50,
    'MACHO',
    'S',
    'GRANDE'
);

INSERT INTO T_CLY_PET (
    id_usuario, nome, especie, raca, dt_nascimento, peso, sexo, castrado, porte
) VALUES (
    1,
    'Mel',
    'GATO',
    'Siamês',
    TO_DATE('2022-08-15', 'YYYY-MM-DD'),
    4.20,
    'FEMEA',
    'N',
    'PEQUENO'
);

INSERT INTO T_CLY_PET (
    id_usuario, nome, especie, raca, dt_nascimento, peso, sexo, castrado, porte
) VALUES (
    2,
    'Bob',
    'CACHORRO',
    'Vira-lata',
    TO_DATE('2020-02-20', 'YYYY-MM-DD'),
    12.80,
    'MACHO',
    'S',
    'MEDIO'
);

INSERT INTO T_CLY_HISTORICO_CLINICO (
    id_pet, tipo_registro, descricao, dt_registro, dt_retorno, profissional_clinica, observacoes
) VALUES (
    1,
    'VACINA',
    'Vacina V10 aplicada',
    TO_DATE('2026-04-10', 'YYYY-MM-DD'),
    TO_DATE('2027-04-10', 'YYYY-MM-DD'),
    'Clínica Pet Vida',
    'Pet sem reação adversa.'
);

INSERT INTO T_CLY_HISTORICO_CLINICO (
    id_pet, tipo_registro, descricao, dt_registro, dt_retorno, profissional_clinica, observacoes
) VALUES (
    1,
    'CONSULTA',
    'Check-up anual',
    TO_DATE('2026-04-20', 'YYYY-MM-DD'),
    NULL,
    'Clínica Pet Vida',
    'Exames solicitados para acompanhamento.'
);

INSERT INTO T_CLY_HISTORICO_CLINICO (
    id_pet, tipo_registro, descricao, dt_registro, dt_retorno, profissional_clinica, observacoes
) VALUES (
    2,
    'MEDICAMENTO',
    'Antibiótico por 7 dias',
    TO_DATE('2026-04-25', 'YYYY-MM-DD'),
    NULL,
    'Clínica Felina Saúde',
    'Administrar a cada 12 horas.'
);

INSERT INTO T_CLY_DISPOSITIVO_IOT (
    id_pet, intervalo_coleta_minutos, frequencia_cardiaca, nivel_atividade, pressao, dt_ultima_leitura, status
) VALUES (
    1,
    30,
    95,
    72.50,
    12.80,
    SYSDATE,
    'ATIVO'
);

INSERT INTO T_CLY_DISPOSITIVO_IOT (
    id_pet, intervalo_coleta_minutos, frequencia_cardiaca, nivel_atividade, pressao, dt_ultima_leitura, status
) VALUES (
    2,
    60,
    110,
    45.00,
    11.30,
    SYSDATE,
    'ATIVO'
);

INSERT INTO T_CLY_ALERTA_INTELIGENTE (
    id_pet, tipo_alerta, nivel_risco, origem_alerta, mensagem, recomendacao, status
) VALUES (
    1,
    'ATIVIDADE',
    'MEDIO',
    'DISPOSITIVO_IOT',
    'O nível de atividade do pet está abaixo do padrão esperado.',
    'Observar o comportamento nas próximas 24 horas e procurar a clínica se persistir.',
    'ABERTO'
);

INSERT INTO T_CLY_ALERTA_INTELIGENTE (
    id_pet, tipo_alerta, nivel_risco, origem_alerta, mensagem, recomendacao, status
) VALUES (
    2,
    'MEDICAMENTO',
    'BAIXO',
    'HISTORICO_CLINICO',
    'Existe medicamento em uso registrado no histórico clínico.',
    'Confirmar se a medicação foi administrada corretamente.',
    'VISUALIZADO'
);

COMMIT;