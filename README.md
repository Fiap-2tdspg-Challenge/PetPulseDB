# 🐾 CLYVO VET — Banco de Dados (Oracle PL/SQL)

Disciplina: **Mastering Relational and Non-Relational Database**
Challenge FIAP 2026 — 2TDSPG

---

## 📋 Sobre o projeto

O CLYVO VET é uma plataforma de saúde preditiva para pets. O banco de dados é o núcleo que sustenta:

- Cadastro de **tutores** e **pets**
- Monitoramento via **dispositivo IoT** (coleira PetPulse), com leituras de frequência cardíaca, atividade e pressão
- **Histórico clínico** (vacinas, consultas, exames, medicamentos), registrado por **profissionais veterinários**
- **Alertas inteligentes** gerados a partir de regras de negócio sobre os dados coletados
- Suporte a **dois perfis de usuário autenticáveis**: `TUTOR` e `PROFISSIONAL`, para consumo via JWT pela API (Java/.NET)

---

## 🗂️ Arquivos do projeto e ordem de execução

Execute **sempre nesta ordem**, em uma sessão nova do SQL Developer (sem abas antigas em cache):

| # | Arquivo | O que faz |
|---|---|---|
| 1 | `00_DROP.sql` | Remove todos os objetos (procedures, tabelas, trigger) — use para reset completo |
| 2 | `01_DDL.sql` | Cria todas as 18 tabelas em 3FN |
| 3 | `02_PROCEDURES.sql` | Cria as 17 procedures de carga (`PRC_CARGA_*`), uma por tabela |
| 4 | `03_CARGA.sql` | Executa blocos anônimos que chamam as procedures de carga com dados de exemplo |
| 5 | `04_RELATORIOS.sql` | Cursores explícitos e relatórios com `JOIN`/`GROUP BY`/`ORDER BY` |
| 6 | `05_SPRINT3_BD.sql` | Entrega da Sprint 3: 2 procedures, 2 funções, 1 trigger de auditoria, com tratamento de exceções e conversão manual para JSON |

> ⚠️ **Importante:** feche completamente o SQL Developer e reabra os arquivos direto do disco antes de rodar. Abas antigas em cache já causaram falsos erros de conversão numérica no nosso ambiente — veja a seção [Troubleshooting](#-troubleshooting) no fim deste README.

---

## 🧬 Modelo de dados

### Domínio: Localização e Endereço
| Tabela | Descrição |
|---|---|
| `T_CLY_ESTADO` | UF (`COD_ESTADO` CHAR(2) como PK) |
| `T_CLY_CIDADE` | Cidade, FK para `T_CLY_ESTADO` |
| `T_CLY_TIPO_ENDERECO` | Residencial / Comercial |

### Domínio: Usuários e Autenticação
| Tabela | Descrição |
|---|---|
| `T_CLY_USUARIO` | **Tutor.** Login via `CPF` (único) + `EMAIL` (único) + `SENHA` |
| `T_CLY_ENDERECO_USUARIO` | Endereços do tutor (1:N) |
| `T_CLY_TELEFONE_USUARIO` | Telefones do tutor (1:N) |
| `T_CLY_PROFISSIONAL` | **Veterinário.** Login via `EMAIL` (único) + `SENHA` + `CRMV` (único) |
| `T_CLY_CLINICA` | Clínica à qual o profissional pode estar vinculado (`ID_CLINICA` opcional) |

> 🔑 **Não existe uma tabela única de "usuário".** `T_CLY_USUARIO` e `T_CLY_PROFISSIONAL` são independentes, cada uma com seu próprio conjunto de credenciais. Veja a seção [Autenticação e perfis](#-autenticação-e-perfis-tutor-x-profissional) para o que isso implica na API.

### Domínio: Pet
| Tabela | Descrição |
|---|---|
| `T_CLY_ESPECIE` | Cachorro, Gato, Coelho, Hamster, Pássaro |
| `T_CLY_PORTE` | Pequeno, Médio, Grande |
| `T_CLY_RACA` | FK para `T_CLY_ESPECIE` |
| `T_CLY_PET` | Entidade central. FK para `USUARIO` (tutor dono), `ESPECIE`, `RACA`, `PORTE` |

### Domínio: IoT
| Tabela | Descrição |
|---|---|
| `T_CLY_DISPOSITIVO_IOT` | Um dispositivo por pet (`UNIQUE(ID_PET)`) — estado atual/último snapshot |
| `T_CLY_LEITURA_IOT` | Histórico de leituras do dispositivo ao longo do tempo (1:N) |

### Domínio: Clínico
| Tabela | Descrição |
|---|---|
| `T_CLY_HISTORICO_CLINICO` | Vacina/Consulta/Doença/Medicamento/Observação/Exame. FK para `PET` e, opcionalmente, para `PROFISSIONAL` |
| `T_CLY_TIPO_ALERTA` | Categoria do alerta (FC, Pressão, Atividade, Vacina, etc.) |
| `T_CLY_ALERTA_INTELIGENTE` | Alertas gerados pelo sistema. FK para `PET` e `TIPO_ALERTA` |

### Domínio: Auditoria e Log
| Tabela | Descrição |
|---|---|
| `T_CLY_LOG_ERRO` | Toda procedure grava aqui quando cai em `EXCEPTION` |
| `T_CLY_AUDITORIA_PET` | Trigger `TRG_AUDITORIA_PET` grava `INSERT`/`UPDATE`/`DELETE` em `T_CLY_PET`, com `:OLD`/`:NEW` |

---

## 🔗 Diagrama de relacionamento (simplificado)

```
T_CLY_ESTADO ──< T_CLY_CIDADE
                       │
T_CLY_TIPO_ENDERECO    │
        │              │
        └──< T_CLY_ENDERECO_USUARIO >──┐
                                        │
T_CLY_USUARIO (tutor) ──────────────────┘
     │  │
     │  └──< T_CLY_TELEFONE_USUARIO
     │
     └──< T_CLY_PET >── T_CLY_ESPECIE ──< T_CLY_RACA
              │      >── T_CLY_PORTE
              │
              ├──< T_CLY_DISPOSITIVO_IOT ──< T_CLY_LEITURA_IOT
              ├──< T_CLY_HISTORICO_CLINICO >── T_CLY_PROFISSIONAL >── T_CLY_CLINICA
              ├──< T_CLY_ALERTA_INTELIGENTE >── T_CLY_TIPO_ALERTA
              └──< T_CLY_AUDITORIA_PET  (via trigger, não FK)
```

---

## 📏 Regras de negócio (CHECK constraints)

Estas são as regras que a **API precisa replicar** (como enum/validação) antes de mandar o dado pro banco — o banco vai rejeitar qualquer valor fora dessas listas:

| Tabela.Coluna | Valores aceitos |
|---|---|
| `T_CLY_ENDERECO_USUARIO.STA_ATIVO` | `'S'`, `'N'` |
| `T_CLY_PET.SEXO` | `'M'`, `'F'` |
| `T_CLY_PET.CASTRADO` | `'S'`, `'N'` (default `'N'`) |
| `T_CLY_PET.PESO` | `NULL` ou `> 0` |
| `T_CLY_DISPOSITIVO_IOT.STATUS` | `'ATIVO'`, `'INATIVO'`, `'MANUTENCAO'` |
| `T_CLY_DISPOSITIVO_IOT.INTERVALO_COLETA_MIN` | `NULL` ou `> 0` |
| `T_CLY_DISPOSITIVO_IOT.FREQUENCIA_CARDIACA` | `NULL` ou `> 0` |
| `T_CLY_DISPOSITIVO_IOT.NIVEL_ATIVIDADE` | `NULL` ou `>= 0` |
| `T_CLY_DISPOSITIVO_IOT.PRESSAO` | `NULL` ou `> 0` |
| `T_CLY_ALERTA_INTELIGENTE.NIVEL_RISCO` | `'BAIXO'`, `'MEDIO'`, `'ALTO'` |
| `T_CLY_ALERTA_INTELIGENTE.ORIGEM_ALERTA` | `'HISTORICO_CLINICO'`, `'DISPOSITIVO_IOT'`, `'SISTEMA'`, `'USUARIO'` |
| `T_CLY_ALERTA_INTELIGENTE.STATUS` | `'ABERTO'`, `'VISUALIZADO'`, `'RESOLVIDO'` |
| `T_CLY_HISTORICO_CLINICO.TIPO_REGISTRO` | `'VACINA'`, `'CONSULTA'`, `'DOENCA'`, `'MEDICAMENTO'`, `'OBSERVACAO'`, `'EXAME'` |

---

## ⚙️ Procedures de carga (`02_PROCEDURES.sql`)

Uma procedure `PRC_CARGA_*` por tabela, todas seguindo o mesmo padrão: validam FKs antes de inserir, tratam `DUP_VAL_ON_INDEX` (duplicidade) e `VALUE_ERROR`, e logam qualquer erro em `T_CLY_LOG_ERRO`.

| Procedure | Parâmetros (ordem) |
|---|---|
| `PRC_CARGA_ESTADO` | cod_estado, nome_estado |
| `PRC_CARGA_CIDADE` | cod_cidade, cod_estado, nome_cidade |
| `PRC_CARGA_TIPO_ENDERECO` | cod_tipo, descricao |
| `PRC_CARGA_USUARIO` | nome, cpf, email, senha |
| `PRC_CARGA_ENDERECO_USUARIO` | seq, id_usuario, cod_tipo_end, cod_cidade, endereco, num, complemento, cep, bairro, ativo |
| `PRC_CARGA_TELEFONE_USUARIO` | id_telefone, id_usuario, numero |
| `PRC_CARGA_ESPECIE` | nome_especie |
| `PRC_CARGA_PORTE` | descricao |
| `PRC_CARGA_RACA` | id_especie, nome_raca |
| `PRC_CARGA_PET` | id_usuario, nome, id_especie, id_raca, id_porte, dt_nascimento, peso, sexo, castrado |
| `PRC_CARGA_DISPOSITIVO` | id_pet, intervalo, frequencia, atividade, pressao, status |
| `PRC_CARGA_LEITURA_IOT` | id_dispositivo, dt_leitura, frequencia, atividade, pressao |
| `PRC_CARGA_TIPO_ALERTA` | descricao |
| `PRC_CARGA_ALERTA` | id_pet, id_tipo_alerta, nivel_risco, origem, mensagem, recomendacao, status |
| `PRC_CARGA_CLINICA` | nome_clinica |
| `PRC_CARGA_PROFISSIONAL` | id_clinica, nome, **email, senha, crmv** |
| `PRC_CARGA_HISTORICO` | id_pet, id_profissional, tipo, descricao, dt_retorno, observacoes |

---

## 🧩 Objetos da Sprint 3 (`05_SPRINT3_BD.sql`)

| Objeto | O que faz |
|---|---|
| `FUNC_PET_TO_JSON` | Recebe dados de um pet (já resolvidos via JOIN) e monta uma **string JSON manualmente** (sem `TO_JSON`/`JSON_OBJECT`), com escape de aspas |
| `FUNC_VALIDA_PESO_PORTE` | Verifica se o peso do pet é compatível com o porte cadastrado — reaproveitável tanto em relatórios quanto na API |
| `PRC_REL_PETS_JSON` | JOIN entre `PET`, `USUARIO`, `ESPECIE`, `RACA`, `PORTE`; imprime cada pet e um array JSON completo |
| `PRC_REL_LEITURAS_SUBTOTAL` | Subtotal manual (sem `ROLLUP`/`CUBE`) das leituras IoT, agrupado por dispositivo, com total geral |
| `TRG_AUDITORIA_PET` + `T_CLY_AUDITORIA_PET` | Audita `INSERT`/`UPDATE`/`DELETE` em `T_CLY_PET`, com usuário, tipo de operação, `:OLD` e `:NEW` |

---

## 🔐 Autenticação e perfis (TUTOR x PROFISSIONAL)

O banco não tem uma tabela de "role" — o perfil do usuário é **implícito pela tabela onde o login foi encontrado**:

```
POST /auth/login  { email, senha }
        │
        ├── encontrou em T_CLY_USUARIO?       → gera JWT com role = "TUTOR"
        └── encontrou em T_CLY_PROFISSIONAL?  → gera JWT com role = "PROFISSIONAL"
```

**Campos de login disponíveis:**

| Tabela | Campo de identificação | Campo de senha | Campo extra de identidade |
|---|---|---|---|
| `T_CLY_USUARIO` | `EMAIL` (único) ou `CPF` (único) | `SENHA` | — |
| `T_CLY_PROFISSIONAL` | `EMAIL` (único) | `SENHA` | `CRMV` (único, registro profissional) |

> ⚠️ A senha está armazenada em **texto puro** no banco (mesmo padrão nas duas tabelas). O hash (BCrypt ou similar) é responsabilidade da camada Java/.NET — nunca grave a senha em claro numa aplicação real, isso é aceitável aqui só pelo escopo didático da disciplina de banco.

**Sugestão de regras de autorização por perfil:**

| Ação | TUTOR | PROFISSIONAL |
|---|---|---|
| CRUD do próprio pet | ✅ | ❌ (só leitura, se necessário) |
| Ver histórico clínico do próprio pet | ✅ | ✅ (de qualquer pet) |
| Criar/editar registro em `T_CLY_HISTORICO_CLINICO` | ❌ | ✅ |
| Ver alertas do próprio pet | ✅ | ✅ |
| Atualizar `STATUS` de um alerta | ❌ | ✅ |

---

## ✅ Checklist de alinhamento para o time de Java

Use isto como conferência ao mapear as entidades JPA. **Envie o código pra eu revisar item a item.**

### Geração de ID
- [ ] Todas as PKs são `NUMBER GENERATED BY DEFAULT AS IDENTITY` → no JPA, use `@GeneratedValue(strategy = GenerationType.IDENTITY)`. **Não** use `SEQUENCE` nem `AUTO` puro — pode gerar conflito de estratégia.

### Nulabilidade — confira se as entidades JPA respeitam exatamente isto:
- [ ] `T_CLY_PET.DT_NASCIMENTO` e `PESO` são **opcionais** (nullable) — não marque como `@Column(nullable = false)`
- [ ] `T_CLY_HISTORICO_CLINICO.ID_PROFISSIONAL`, `DT_RETORNO`, `OBSERVACOES` são **opcionais**
- [ ] `T_CLY_PROFISSIONAL.ID_CLINICA` é **opcional** (profissional pode não ter clínica vinculada)
- [ ] `T_CLY_PROFISSIONAL.EMAIL`, `SENHA`, `CRMV` são **obrigatórios** (adicionados na Sprint 3 pra suportar login)

### Enums — crie enums Java espelhando exatamente os `CHECK` constraints da tabela acima
- [ ] `Sexo { M, F }`
- [ ] `StatusDispositivo { ATIVO, INATIVO, MANUTENCAO }`
- [ ] `NivelRisco { BAIXO, MEDIO, ALTO }`
- [ ] `OrigemAlerta { HISTORICO_CLINICO, DISPOSITIVO_IOT, SISTEMA, USUARIO }`
- [ ] `StatusAlerta { ABERTO, VISUALIZADO, RESOLVIDO }`
- [ ] `TipoRegistroClinico { VACINA, CONSULTA, DOENCA, MEDICAMENTO, OBSERVACAO, EXAME }`
- [ ] Campos `'S'`/`'N'` (`CASTRADO`, `STA_ATIVO`) — mapear como `boolean` com `@Convert` customizado, ou como `char` mesmo, mas nunca aceitar outro valor

### Uniques — a API precisa tratar a violação dessas constraints com uma mensagem amigável (409 Conflict), não deixar estourar 500:
- [ ] `T_CLY_USUARIO.CPF`
- [ ] `T_CLY_USUARIO.EMAIL`
- [ ] `T_CLY_PROFISSIONAL.EMAIL`
- [ ] `T_CLY_PROFISSIONAL.CRMV`
- [ ] `T_CLY_DISPOSITIVO_IOT.ID_PET` (um dispositivo por pet)

### Tipos numéricos — cuidado especial (histórico do projeto com bug de conversão)
- [ ] `PESO` é `NUMBER(6,2)`, `NIVEL_ATIVIDADE` é `NUMBER(5,2)`, `PRESSAO` é `NUMBER(6,2)` — mapear como `BigDecimal` no Java (nunca `float`/`double` puro, para evitar problema de arredondamento e de conversão de tipo)
- [ ] Datas: todas as colunas `DATE` do Oracle armazenam data+hora. Mapear como `LocalDateTime` (não `LocalDate`), a menos que você queira truncar a hora explicitamente na aplicação

### Autenticação
- [ ] Confirmar que o `UserDetailsService` (ou equivalente) consulta **as duas tabelas** (`T_CLY_USUARIO` e `T_CLY_PROFISSIONAL`) no login, não só uma
- [ ] Confirmar que a claim de `role` no JWT reflete de qual tabela veio o usuário autenticado
- [ ] Hash de senha (BCrypt) aplicado **antes** do INSERT — nunca gravar senha em claro

---

## 🚀 Como executar

1. Abra o SQL Developer, conecte no schema do projeto (ex: `RM561378`)
2. **Feche todas as abas antigas** relacionadas a este projeto
3. Abra e rode, em ordem, direto do disco: `00_DROP.sql` → `01_DDL.sql` → `02_PROCEDURES.sql` → `03_CARGA.sql` → `04_RELATORIOS.sql` → `05_SPRINT3_BD.sql`
4. Confira a saída no painel **Script Output** (não Query Result) com `SET SERVEROUTPUT ON` habilitado

---

## 🛠️ Troubleshooting

**Erro `ORA-06502: numeric or value error` em blocos de carga:**
Não é bug de dado — historicamente, nesse projeto, esse erro apareceu por **cache de aba antiga** no SQL Developer executando conteúdo diferente do salvo em disco. Se acontecer:
1. Fechar o SQL Developer inteiro (não só a aba)
2. Reabrir e importar o `.sql` do zero via *File → Open*
3. Rodar com F5

**Erro `ORA-00955: name is already used`:**
Você rodou um script de criação (`CREATE TABLE`) duas vezes sem dropar antes. Rode `00_DROP.sql` primeiro, ou adicione um bloco de `DROP` defensivo (`EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE`) como já fizemos em `05_SPRINT3_BD.sql`.

**Erro `ORA-20xxx` customizado (ex: "Pet nao encontrado"):**
Verifique se as tabelas-pai (`USUARIO`, `ESPECIE`, `RACA`, `PORTE`, etc.) foram carregadas **antes** da tabela filha — a ordem do `03_CARGA.sql` respeita as dependências, não pule blocos.

---

## 👥 Integrantes

Gabriel Neris Losano — RM564093 — 2TDSPG
João Vitor Biribilli Ravelli — RM565594 — 2TDSPG
Pedro de Matos Previtali — RM564184 — 2TDSPG
Pietro Paranhos Wilhelm — RM561378 — 2TDSPG