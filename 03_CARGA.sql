------------------------------------------------------------
-- PROJETO: CLYVO VET - SAUDE PREDITIVA PET
-- DISCIPLINA: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- ARQUIVO: 03_CARGA.sql
-- DESCRICAO: BLOCOS ANONIMOS DE INSERCAO DE DADOS VIA PROCEDURES
-- EXECUCAO: 3 - executar apos 02_PROCEDURES.sql
------------------------------------------------------------

SET SERVEROUTPUT ON;

------------------------------------------------------------
-- ESTADOS
------------------------------------------------------------
BEGIN
    PRC_CARGA_ESTADO('SP', 'Sao Paulo');
    PRC_CARGA_ESTADO('RJ', 'Rio de Janeiro');
    PRC_CARGA_ESTADO('MG', 'Minas Gerais');
END;
/

------------------------------------------------------------
-- CIDADES
------------------------------------------------------------
BEGIN
    PRC_CARGA_CIDADE(1, 'SP', 'Sao Paulo');
    PRC_CARGA_CIDADE(2, 'SP', 'Campinas');
    PRC_CARGA_CIDADE(3, 'RJ', 'Rio de Janeiro');
    PRC_CARGA_CIDADE(4, 'MG', 'Belo Horizonte');
    PRC_CARGA_CIDADE(5, 'SP', 'Campos do Jordao');
END;
/

------------------------------------------------------------
-- TIPOS DE ENDERECO
------------------------------------------------------------
BEGIN
    PRC_CARGA_TIPO_ENDERECO(1, 'Residencial');
    PRC_CARGA_TIPO_ENDERECO(2, 'Comercial');
END;
/

------------------------------------------------------------
-- ESPECIES
------------------------------------------------------------
BEGIN
    PRC_CARGA_ESPECIE('CACHORRO');
    PRC_CARGA_ESPECIE('GATO');
    PRC_CARGA_ESPECIE('COELHO');
    PRC_CARGA_ESPECIE('HAMSTER');
    PRC_CARGA_ESPECIE('PASSARO');
END;
/

------------------------------------------------------------
-- PORTES
------------------------------------------------------------
BEGIN
    PRC_CARGA_PORTE('PEQUENO');
    PRC_CARGA_PORTE('MEDIO');
    PRC_CARGA_PORTE('GRANDE');
END;
/

------------------------------------------------------------
-- RACAS
-- ID_ESPECIE: 1=CACHORRO | 2=GATO
------------------------------------------------------------
BEGIN
    PRC_CARGA_RACA(1, 'Golden Retriever');
    PRC_CARGA_RACA(1, 'Labrador');
    PRC_CARGA_RACA(1, 'Bulldog');
    PRC_CARGA_RACA(1, 'Poodle');
    PRC_CARGA_RACA(1, 'Shih Tzu');
    PRC_CARGA_RACA(2, 'Siames');
    PRC_CARGA_RACA(2, 'Persa');
END;
/

------------------------------------------------------------
-- TIPOS DE ALERTA
------------------------------------------------------------
BEGIN
    PRC_CARGA_TIPO_ALERTA('FREQUENCIA_CARDIACA');
    PRC_CARGA_TIPO_ALERTA('PRESSAO');
    PRC_CARGA_TIPO_ALERTA('ATIVIDADE');
    PRC_CARGA_TIPO_ALERTA('VACINA');
    PRC_CARGA_TIPO_ALERTA('ALIMENTACAO');
    PRC_CARGA_TIPO_ALERTA('MEDICAMENTO');
    PRC_CARGA_TIPO_ALERTA('CHECK_UP');
END;
/

------------------------------------------------------------
-- CLINICAS
------------------------------------------------------------
BEGIN
    PRC_CARGA_CLINICA('Clinica VetCare');
    PRC_CARGA_CLINICA('Hospital Veterinario PetSaude');
END;
/

------------------------------------------------------------
-- PROFISSIONAIS
-- ID_CLINICA: 1=VetCare | 2=PetSaude
------------------------------------------------------------
BEGIN
    PRC_CARGA_PROFISSIONAL(1, 'Dr. Carlos Andrade');
    PRC_CARGA_PROFISSIONAL(1, 'Dra. Fernanda Lima');
    PRC_CARGA_PROFISSIONAL(2, 'Dr. Roberto Souza');
END;
/

------------------------------------------------------------
-- USUARIOS
------------------------------------------------------------
BEGIN
    PRC_CARGA_USUARIO('Armando Souza',   '12345678900', 'armando@email.com',  '123456');
    PRC_CARGA_USUARIO('Beatriz Costa',   '98765432100', 'beatriz@email.com',  '654321');
    PRC_CARGA_USUARIO('Carlos Pereira',  '11122233344', 'carlos@email.com',   'abc123');
    PRC_CARGA_USUARIO('Daniela Martins', '55566677788', 'daniela@email.com',  'xyz789');
    PRC_CARGA_USUARIO('Eduardo Ramos',   '99988877766', 'eduardo@email.com',  'pass99');
END;
/

------------------------------------------------------------
-- ENDERECOS DOS USUARIOS
-- SEQ | ID_USUARIO | COD_TIPO | COD_CIDADE | ENDERECO | NUM | COMP | CEP | BAIRRO | ATIVO
------------------------------------------------------------
BEGIN
    PRC_CARGA_ENDERECO_USUARIO(1, 1, 1, 1, 'Rua das Flores',   '100', 'Apto 12', '01310-100', 'Centro',      'S');
    PRC_CARGA_ENDERECO_USUARIO(2, 2, 1, 2, 'Av. Brasil',       '200', NULL,      '13010-001', 'Vila Nova',   'S');
    PRC_CARGA_ENDERECO_USUARIO(3, 3, 2, 3, 'Rua da Paz',       '50',  'Sala 3',  '20040-020', 'Flamengo',    'S');
    PRC_CARGA_ENDERECO_USUARIO(4, 4, 1, 4, 'Rua Minas Gerais', '300', NULL,      '30130-010', 'Lourdes',     'S');
    PRC_CARGA_ENDERECO_USUARIO(5, 5, 1, 5, 'Rua das Flores',   '10',  NULL,      '12460-000', 'Vila Aberne', 'S');
END;
/

------------------------------------------------------------
-- TELEFONES DOS USUARIOS
------------------------------------------------------------
BEGIN
    PRC_CARGA_TELEFONE_USUARIO(1, 1, '11999999999');
    PRC_CARGA_TELEFONE_USUARIO(2, 2, '19988888888');
    PRC_CARGA_TELEFONE_USUARIO(3, 3, '21977777777');
    PRC_CARGA_TELEFONE_USUARIO(4, 4, '31966666666');
    PRC_CARGA_TELEFONE_USUARIO(5, 5, '12955555555');
END;
/

------------------------------------------------------------
-- PETS
-- Decimais com VIRGULA por causa do NLS_NUMERIC_CHARACTERS do Oracle BR
-- ID_ESPECIE: 1=CACHORRO 2=GATO
-- ID_RACA: 1=Golden 2=Labrador 3=Bulldog 4=Poodle 5=ShihTzu 6=Siames 7=Persa
-- ID_PORTE: 1=PEQUENO 2=MEDIO 3=GRANDE
------------------------------------------------------------
BEGIN
    PRC_CARGA_PET(1, 'Rex',     1, 1, 3, TO_DATE('10/05/2021','DD/MM/YYYY'), 25, 'M', 'S');
    PRC_CARGA_PET(2, 'Mel',     2, 6, 1, TO_DATE('03/08/2020','DD/MM/YYYY'), 4,  'F', 'S');
    PRC_CARGA_PET(3, 'Thor',    1, 2, 3, TO_DATE('15/01/2019','DD/MM/YYYY'), 30, 'M', 'N');
    PRC_CARGA_PET(4, 'Luna',    1, 5, 1, TO_DATE('22/11/2022','DD/MM/YYYY'), 5,  'F', 'S');
    PRC_CARGA_PET(5, 'Bolinha', 1, 3, 2, TO_DATE('07/04/2018','DD/MM/YYYY'), 12, 'M', 'N');
END;
/

------------------------------------------------------------
-- DISPOSITIVOS IOT (um por pet)
-- ID_PET | INTERVALO | FREQUENCIA | ATIVIDADE | PRESSAO | STATUS
------------------------------------------------------------
BEGIN
    PRC_CARGA_DISPOSITIVO(1,  5,  80, 3, 12, 'ATIVO');
    PRC_CARGA_DISPOSITIVO(2, 10, 160, 1, 9,  'ATIVO');
    PRC_CARGA_DISPOSITIVO(3,  5,  72, 5, 11, 'ATIVO');
    PRC_CARGA_DISPOSITIVO(4, 15, 140, 2, 10, 'INATIVO');
    PRC_CARGA_DISPOSITIVO(5,  5,  95, 4, 13, 'MANUTENCAO');
END;
/

------------------------------------------------------------
-- LEITURAS IOT
-- ID_DISPOSITIVO | DT_LEITURA | FREQUENCIA | ATIVIDADE | PRESSAO
------------------------------------------------------------
BEGIN
    PRC_CARGA_LEITURA_IOT(1, SYSDATE - 1,  80, 3, 12);
    PRC_CARGA_LEITURA_IOT(1, SYSDATE,      85, 4, 12);
    PRC_CARGA_LEITURA_IOT(2, SYSDATE - 2, 160, 1, 9);
    PRC_CARGA_LEITURA_IOT(3, SYSDATE - 1,  72, 5, 11);
    PRC_CARGA_LEITURA_IOT(3, SYSDATE,      75, 5, 11);
END;
/

------------------------------------------------------------
-- HISTORICO CLINICO
-- ID_PET | ID_PROFISSIONAL | TIPO | DESCRICAO | DT_RETORNO | OBSERVACOES
------------------------------------------------------------
BEGIN
    PRC_CARGA_HISTORICO(1, 1, 'VACINA',      'Vacina antirabica aplicada',      TO_DATE('10/06/2026','DD/MM/YYYY'), 'Retorno em 1 ano');
    PRC_CARGA_HISTORICO(1, 1, 'CONSULTA',    'Consulta de rotina - saudavel',   TO_DATE('01/12/2025','DD/MM/YYYY'), 'Sem alteracoes');
    PRC_CARGA_HISTORICO(2, 2, 'EXAME',       'Hemograma completo solicitado',   TO_DATE('15/06/2026','DD/MM/YYYY'), 'Aguardando resultados');
    PRC_CARGA_HISTORICO(3, 3, 'DOENCA',      'Diagnostico de leishmaniose',     TO_DATE('20/06/2026','DD/MM/YYYY'), 'Iniciar tratamento');
    PRC_CARGA_HISTORICO(4, 1, 'MEDICAMENTO', 'Vermifugo aplicado - dose mensal',NULL,                              'Repetir em 30 dias');
    PRC_CARGA_HISTORICO(5, 2, 'CONSULTA',    'Avaliacao pos-operatoria',        TO_DATE('05/07/2026','DD/MM/YYYY'), 'Recuperacao normal');
END;
/

------------------------------------------------------------
-- ALERTAS INTELIGENTES
-- ID_PET | ID_TIPO_ALERTA | NIVEL_RISCO | ORIGEM | MENSAGEM | RECOMENDACAO | STATUS
-- ID_TIPO_ALERTA: 1=FC 2=PRESSAO 3=ATIVIDADE 4=VACINA 5=ALIMENTACAO
------------------------------------------------------------
BEGIN
    PRC_CARGA_ALERTA(1, 1, 'ALTO',  'DISPOSITIVO_IOT',   'Frequencia cardiaca elevada detectada', 'Consulte um veterinario imediatamente', 'ABERTO');
    PRC_CARGA_ALERTA(2, 4, 'MEDIO', 'HISTORICO_CLINICO', 'Vacina anual vencida ha 30 dias',       'Agende a vacinacao o quanto antes',    'ABERTO');
    PRC_CARGA_ALERTA(3, 2, 'ALTO',  'DISPOSITIVO_IOT',   'Pressao arterial acima do normal',      'Avaliacao veterinaria urgente',        'VISUALIZADO');
    PRC_CARGA_ALERTA(4, 5, 'BAIXO', 'SISTEMA',           'Pet nao se alimentou nas ultimas 8h',   'Verifique a alimentacao do pet',       'RESOLVIDO');
    PRC_CARGA_ALERTA(5, 3, 'MEDIO', 'DISPOSITIVO_IOT',   'Nivel de atividade muito baixo',        'Aumente os passeios diarios',          'ABERTO');
END;
/
