# Fluxo e Arquitetura do Sistema

## Visao geral

Este projeto e um sistema interno de Help Desk + manutencao preventiva construido com Next.js App Router e PostgreSQL.

Hoje o sistema tem 4 blocos principais:

1. Autenticacao e sessao no frontend
2. Gestao de chamados de suporte
3. Gestao de ativos e manutencao preventiva
4. Gestao de usuarios

## Arquitetura atual

### Frontend

- As paginas ficam em `app/`
- O layout autenticado fica em `components/dashboard-layout.tsx`
- A sessao do usuario e guardada no `localStorage`
- Nao existe autenticacao server-side; a protecao de tela acontece no client

### Backend

- As APIs ficam em `app/api/**/route.ts`
- O acesso ao banco passa por `lib/db.ts`
- O codigo usa `search_path` dinamico e, por padrao, trabalha no schema `ti`

### Banco

- O schema esperado pela aplicacao atual e `ti`
- A tabela `usuarios` e usada para login, perfil, papel e setor
- A tabela `chamados` guarda os tickets
- A tabela `comentarios` guarda o andamento dos chamados
- As tabelas `ativos`, `ciclos_manutencao`, `itens_checklist` e `registros_manutencao` sustentam a manutencao preventiva

## Fluxo funcional

### 1. Login

Fluxo:

1. O usuario acessa `/login`
2. O frontend chama `POST /api/auth`
3. A API consulta `usuarios`
4. Se o login for valido, os dados do usuario vao para `localStorage`
5. Se o usuario comum estiver com `must_change_password = true`, ele vai para `/alterar-senha`
6. Caso contrario, vai para `/dashboard`

Observacao importante:

- A API de auth chama `ensureUserSectorColumn()`, que tenta criar a coluna `setor` em runtime caso ela nao exista

### 2. Dashboard

Fluxo:

1. A pagina `/dashboard` le o usuario do `localStorage`
2. Busca os chamados via `GET /api/chamados`
3. Se o usuario nao for admin, a API filtra por `solicitante`
4. Exibe indicadores e os chamados recentes

### 3. Chamados

Fluxo principal:

1. O usuario cria um chamado em `/chamados/novo`
2. O frontend chama `POST /api/chamados`
3. O chamado nasce com status `Aberto`
4. Admins podem definir `responsavel` na criacao
5. A listagem em `/chamados` usa filtros client-side e polling para admins
6. O detalhe `/chamados/[id]` permite:
   - usuario comum: apenas visualizar o proprio chamado
   - admin: editar prioridade, status, responsavel e solucao
7. Comentarios de andamento ficam em `/api/chamados/[id]/comentarios`
8. Apenas admin pode registrar comentarios e evoluir o chamado

Regras de permissao atuais:

- Usuario comum abre e acompanha apenas os proprios chamados
- Admin visualiza tudo
- Admin e o unico que pode editar, excluir, fechar e comentar chamados

### 4. Usuarios

Fluxo:

1. A tela `/usuarios` e exclusiva de admin
2. A API `GET /api/usuarios` lista usuarios
3. `POST /api/usuarios` cria usuario com:
   - `role`
   - `setor`
   - `must_change_password`
4. `PUT /api/usuarios/[id]` atualiza dados e senha
5. Usuario comum normalmente entra com troca obrigatoria de senha no primeiro login

Campos importantes esperados pelo codigo:

- `username`
- `password`
- `nome`
- `role`
- `setor`
- `must_change_password`

### 5. Manutencao preventiva

Fluxo:

1. A tela `/manutencao` lista ativos
2. O admin pode criar ativo em `/manutencao/novo-ativo`
3. Cada ativo possui criticidade, status, ultima e proxima manutencao
4. O detalhe `/manutencao/[id]` busca:
   - o ativo
   - os ciclos do ativo
   - os registros de manutencao
5. Quando a manutencao e concluida, `PUT /api/ativos/[id]`:
   - atualiza `ultima_manutencao`
   - recalcula `proxima_manutencao`
   - conclui o ciclo pendente
   - insere um registro em `registros_manutencao`
   - cria um novo ciclo pendente
   - cria novos itens padrao em `itens_checklist`

Observacao importante:

- A pagina de detalhe de manutencao hoje ainda usa um checklist padrao em memoria no frontend
- A API ja tem estrutura para `itens_checklist`, mas a tela ainda nao consome os itens reais do banco

## Situacao atual dos scripts SQL

Resposta curta: a consolidacao principal foi preparada, mas os scripts historicos antigos continuam no repositrio apenas como legado.

Hoje o caminho recomendado e:

1. usar `database/setup.sql` para instalacao limpa
2. usar `scripts/010_consolidacao_schema_ti.sql` para consolidar ambientes antigos

### O que esta alinhado agora

- Existe cobertura para as tabelas principais: `usuarios`, `chamados`, `comentarios`, `ativos`, `ciclos_manutencao`, `itens_checklist` e `registros_manutencao`
- `database/setup.sql` ja usa o schema `ti`, que e o esperado por `lib/db.ts`
- `database/setup.sql` agora contempla `usuarios.setor`
- `database/setup.sql` e `scripts/010_consolidacao_schema_ti.sql` usam os mesmos nomes principais de colunas e tabelas
- O script `010_consolidacao_schema_ti.sql` consolida dados antigos e normaliza diferencas de status/colunas

### O que ainda exige cuidado

1. Os scripts `001` a `009` continuam representando etapas antigas, muitas delas no schema `public`
2. O script `004_create_preventive_maintenance_tables.sql` faz `DROP TABLE`, entao nao deve ser usado como base em ambiente ja populado
3. O endpoint de comentarios ainda possui criacao defensiva de tabela/indice em runtime, embora a estrutura ja esteja consolidada no SQL
4. A tela de manutencao ainda nao consome os itens reais do checklist vindos do banco

## Schema minimo esperado hoje pela aplicacao

Se o objetivo for representar o sistema atual, o banco precisa refletir pelo menos:

### usuarios

- `id`
- `username`
- `nome`
- `password`
- `role`
- `setor`
- `must_change_password`
- `created_at`
- `updated_at` opcional, mas recomendado

### chamados

- `id`
- `titulo`
- `descricao`
- `solicitante`
- `prioridade`
- `status`
- `responsavel`
- `solucao`
- `created_at`
- `updated_at`

### comentarios

- `id`
- `chamado_id`
- `user_id`
- `comentario`
- `created_at`

### ativos

- `id`
- `nome`
- `tipo`
- `localizacao`
- `criticidade`
- `status`
- `ultima_manutencao`
- `proxima_manutencao`
- `created_at`
- `updated_at`

### ciclos_manutencao

O projeto ainda esta inconsistente aqui. Antes de consolidar o SQL, vale escolher um unico modelo:

- usar `data_fim` ou `data_conclusao`
- usar `Concluido` ou `Concluida`

### registros_manutencao

Tambem precisa unificacao:

- o codigo atual usa `data_execucao`
- scripts antigos usam `data_manutencao`

## Minha leitura pratica

Hoje o caminho mais seguro e tratar `database/setup.sql` como instalacao limpa e `scripts/010_consolidacao_schema_ti.sql` como migracao de unificacao.

Se voce quiser deixar o banco realmente atualizado com o codigo atual, o ideal e fazer:

1. Aplicar `scripts/010_consolidacao_schema_ti.sql` nos ambientes antigos
2. Usar `database/setup.sql` como base padrao para novos ambientes
3. Parar de depender de criacao de tabela/coluna em runtime
4. Evoluir a tela de manutencao para ler `itens_checklist` reais do banco

## Arquivos-chave para entender o projeto

- `lib/db.ts`: conexao com PostgreSQL e `search_path`
- `app/api/auth/route.ts`: login
- `app/api/chamados/route.ts`: listagem e criacao de chamados
- `app/api/chamados/[id]/route.ts`: atualizacao e exclusao de chamados
- `app/api/chamados/[id]/comentarios/route.ts`: andamento dos chamados
- `app/api/usuarios/route.ts`: criacao e listagem de usuarios
- `app/api/ativos/route.ts`: listagem e criacao de ativos
- `app/api/ativos/[id]/route.ts`: ciclo de vida da manutencao do ativo
- `app/api/ciclos/route.ts`: manipulacao de ciclos e checklist
- `lib/maintenance-utils.ts`: regras de criticidade e calculo da proxima manutencao

## Conclusao

O sistema continua carregando historico antigo nos scripts legados, mas agora existe um caminho consolidado para alinhar banco e aplicacao.

O fluxo recomendado e simples:

1. ambiente novo: `database/setup.sql`
2. ambiente antigo: `scripts/010_consolidacao_schema_ti.sql`
