# Documentação Técnica — Helpdesk SYL

> Sistema interno de gestão de chamados de TI e manutenção preventiva do Grupo SYL.
> Última revisão desta documentação: 2026-07-20 · Versão da aplicação: v1.0

Esta é a documentação de referência do sistema, cobrindo **arquitetura, implantação,
configuração, operação e manutenção**. Complementa (e consolida) os documentos
[`README.md`](README.md) e [`REQUISITOS_TECNICOS.md`](REQUISITOS_TECNICOS.md).

---

## Índice

1. [Visão geral](#1-visão-geral)
2. [Arquitetura](#2-arquitetura)
3. [Estrutura de pastas](#3-estrutura-de-pastas)
4. [Modelo de dados](#4-modelo-de-dados)
5. [Módulos funcionais](#5-módulos-funcionais)
6. [Referência da API](#6-referência-da-api)
7. [Implantação (deploy)](#7-implantação-deploy)
8. [Configuração](#8-configuração)
9. [Banco de dados: setup e migrações](#9-banco-de-dados-setup-e-migrações)
10. [Importação da planilha de manutenção](#10-importação-da-planilha-de-manutenção)
11. [Operação e manutenção](#11-operação-e-manutenção)
12. [Troubleshooting](#12-troubleshooting)
13. [Segurança](#13-segurança)
14. [Glossário](#14-glossário)

---

## 1. Visão geral

O **Helpdesk SYL** é uma aplicação web interna que atende a equipe de suporte de TI
em duas frentes:

| Módulo | O que faz |
|--------|-----------|
| **Chamados** (tickets) | Abertura, acompanhamento, atribuição de responsável, comentários de andamento e fechamento com solução. Usuários comuns veem só os próprios chamados; administradores veem todos. |
| **Manutenção preventiva** | Cadastro de ativos (máquinas/equipamentos), ciclos de manutenção com **datas fixas**, checklist oficial TI‑01 Rev.10, registro de execução (data realizada + justificativa) e relatórios mensais. |

Público-alvo: colaboradores internos do Grupo SYL. Não é um sistema exposto à internet
pública — roda na rede interna, acessado por um domínio interno.

Referência normativa: os formulários e o checklist seguem o procedimento interno
**TI‑01 Rev.10** (Form.139 = execução de manutenção; Form.147 = chamado de suporte).

---

## 2. Arquitetura

### 2.1 Stack

| Camada | Tecnologia |
|--------|-----------|
| Framework | **Next.js 16** (App Router) — front-end e back-end no mesmo projeto |
| UI | **React 19**, **Tailwind CSS 4**, **shadcn/ui** (componentes em `components/ui`) |
| Back-end | **Route Handlers** do Next.js (`app/api/**/route.ts`), runtime **Node.js** |
| Banco de dados | **PostgreSQL 14+**, acessado com o driver **`pg`** (pool de conexões) |
| E-mail | **nodemailer** (SMTP Office 365) |
| Empacotamento | **Docker** (build `standalone`) |

> ⚠️ **Atenção — divergência de documentação:** o `REQUISITOS_TECNICOS.md` menciona
> Supabase. O código **não usa Supabase**: a conexão é feita diretamente via `pg`
> ([`lib/db.ts`](lib/db.ts)) com variáveis `DATABASE_*`. Considere esta documentação
> como a fonte correta.

### 2.2 Diagrama de camadas

```
┌─────────────────────────────────────────────────────────────┐
│  Navegador (rede interna)                                    │
│  Páginas React (client components) — sessão em localStorage  │
└───────────────┬─────────────────────────────────────────────┘
                │ fetch() HTTP
┌───────────────▼─────────────────────────────────────────────┐
│  Next.js (server) — porta 3000                               │
│  ├─ Route Handlers  app/api/**/route.ts                      │
│  ├─ middleware.ts   (headers de segurança)                   │
│  └─ lib/db.ts       (pool pg, helpers query/insert/update)   │
└───────────────┬─────────────────────────────────────────────┘
                │ SQL (schema "ti")
┌───────────────▼─────────────────────────────────────────────┐
│  PostgreSQL — banco "analysis", schema "ti"                  │
└─────────────────────────────────────────────────────────────┘
                │ SMTP
┌───────────────▼─────────────────────────────────────────────┐
│  Office 365 (envio de avisos de novo chamado)               │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Camada de acesso a dados

Toda query passa por [`lib/db.ts`](lib/db.ts), que expõe helpers reutilizáveis:

- `query<T>(sql, params)` — executa e retorna linhas; define `SET search_path` para o schema configurado a cada chamada.
- `queryOne<T>(sql, params)` — retorna a primeira linha ou `null`.
- `insert<T>(table, data)` — `INSERT ... RETURNING *`.
- `update<T>(table, data, whereColumn, whereValue)` — `UPDATE ... RETURNING *`.
- `remove(table, whereColumn, whereValue)` — `DELETE`.

Todas as queries de dados usam **prepared statements parametrizados** (`$1, $2, …`),
protegendo contra SQL injection.

---

## 3. Estrutura de pastas

```
Helpdesk_SYL/
├── app/                                # Next.js App Router
│   ├── api/                            # Endpoints (Route Handlers)
│   │   ├── auth/route.ts               # POST  — login
│   │   ├── chamados/
│   │   │   ├── route.ts                # GET/POST
│   │   │   └── [id]/
│   │   │       ├── route.ts            # GET/PUT/DELETE
│   │   │       └── comentarios/route.ts# GET/POST comentários
│   │   ├── ativos/
│   │   │   ├── route.ts                # GET/POST
│   │   │   └── [id]/route.ts           # GET/PUT/DELETE (+ conclusão de manutenção)
│   │   ├── ciclos/route.ts             # GET/POST/PUT ciclos de manutenção
│   │   ├── manutencao/
│   │   │   ├── gerar-ciclo/route.ts    # POST — gera ciclo + checklist
│   │   │   └── relatorio/route.ts      # GET  — relatório HTML mensal
│   │   ├── usuarios/
│   │   │   ├── route.ts                # GET/POST
│   │   │   ├── [id]/route.ts           # GET/PUT/DELETE
│   │   │   └── admins/route.ts         # GET — lista de administradores
│   │   └── downloads/guias/route.ts    # GET — download seguro de PDFs
│   │
│   ├── login/page.tsx                  # Tela de login
│   ├── alterar-senha/page.tsx          # Troca de senha obrigatória
│   ├── dashboard/page.tsx              # Dashboard
│   ├── chamados/                       # Páginas de chamados (lista, novo, detalhe)
│   ├── manutencao/                     # Páginas de manutenção (lista, novo-ativo, detalhe, editar)
│   ├── usuarios/page.tsx               # Gestão de usuários (admin)
│   ├── layout.tsx                      # Layout raiz
│   └── page.tsx                        # Redireciona "/" → "/login"
│
├── components/
│   ├── ui/                             # Componentes shadcn/ui
│   ├── dashboard-layout.tsx            # Layout com sidebar
│   └── theme-provider.tsx              # Tema claro/escuro
│
├── lib/
│   ├── db.ts                           # Pool PostgreSQL + helpers
│   ├── email.ts                        # Envio de avisos por e-mail
│   ├── maintenance-utils.ts            # Criticidade, dias úteis, feriados
│   ├── maintenance-report.ts           # Métricas mensais do relatório
│   ├── maintenance-schema.server.ts    # ensureJustificativaColumn()
│   ├── user-sectors.ts / .server.ts    # Lista de setores + ensureUserSectorColumn()
│   └── utils.ts                        # cn() e utilitários
│
├── database/
│   ├── setup.sql                       # Schema (referência)
│   └── grant-permissions.sql           # Permissões do ti_user
│
├── scripts/                            # Migrações incrementais (001 → 011)
│   ├── 001_..._010_consolidacao_schema_ti.sql
│   ├── 011_import_planilha_2026.sql    # Import da planilha (gerado)
│   └── gen_import_planilha.py          # Gerador do script 011
│
├── public/guias/                       # PDFs de guias de uso
├── middleware.ts                       # Headers de segurança
├── next.config.mjs                     # Config Next.js (standalone, headers)
├── Dockerfile / entrypoint.sh          # Build e execução em container
└── .env                                # Variáveis de ambiente (NÃO versionado)
```

---

## 4. Modelo de dados

Schema **`ti`** no banco **`analysis`**. Definição canônica consolidada em
[`scripts/010_consolidacao_schema_ti.sql`](scripts/010_consolidacao_schema_ti.sql).

### 4.1 Tabelas

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| `usuarios` | Contas de acesso | `username` (único), `password`, `role` (`admin`\|`usuario`), `setor`, `must_change_password` |
| `chamados` | Tickets de suporte | `titulo`, `descricao`, `solicitante`, `prioridade` (`Alta`\|`Média`\|`Baixa`), `status` (`Aberto`\|`Em andamento`\|`Fechado`), `responsavel`, `solucao` |
| `comentarios` | Andamento dos chamados | `chamado_id` → chamados, `user_id`, `comentario` |
| `ativos` | Máquinas/equipamentos | `nome`, `tipo`, `localizacao`, `criticidade` (`Alta`\|`Média`\|`Baixa`), `status` (`Operacional`\|`Em Manutenção`\|`Inativo`), `ultima_manutencao`, `proxima_manutencao` |
| `ciclos_manutencao` | Ocorrências agendadas de manutenção | `ativo_id` → ativos, `data_proxima_manutencao` (data planejada fixa), `data_fim`, `status` (`Pendente`\|`Em Progresso`\|`Concluído`\|`Cancelado`) |
| `itens_checklist` | Itens do checklist TI‑01 por ciclo | `ciclo_id` → ciclos, `descricao`, `concluido` |
| `registros_manutencao` | Histórico de execuções | `ativo_id`, `ciclo_id`, `tecnico`, `data_execucao`, `status`, `observacoes`, `justificativa` |

Todas as tabelas têm `id UUID` (default `gen_random_uuid()`), `created_at` e
`updated_at` (atualizado por trigger `set_updated_at`).

### 4.2 Relações

```
usuarios
chamados 1───N comentarios
ativos   1───N ciclos_manutencao 1───N itens_checklist
ativos   1───N registros_manutencao   N───1 ciclos_manutencao (opcional)
```

### 4.3 Criticidade e intervalos

O nível de criticidade define a frequência de manutenção (ver
[`lib/maintenance-utils.ts`](lib/maintenance-utils.ts)):

| Criticidade | Planilha | Intervalo |
|-------------|----------|-----------|
| Alta | 1 | 30 dias (mensal) |
| Média | 2 | 60 dias (bimestral) |
| Baixa | 3 | 180 dias (semestral) |

---

## 5. Módulos funcionais

### 5.1 Autenticação e sessão

- Login em `POST /api/auth`: valida `username`+`password` no banco.
- Em caso de sucesso, os dados do usuário são armazenados no **`localStorage`** do
  navegador (`user`), usados pelo front para identificar o usuário e filtrar dados.
- Se `must_change_password` estiver marcado, o usuário é levado a `/alterar-senha`.
- Não há sessão server-side (cookie/JWT) — ver [Segurança](#13-segurança).

### 5.2 Chamados

- Usuário comum: cria chamados e vê **apenas os seus** (`solicitante = username`).
- Admin: vê todos, atribui técnico responsável (que deve ser um admin válido),
  altera status (`Aberto` → `Em andamento` → `Fechado`), registra solução e exclui.
- Comentários de andamento: somente admins adicionam.
- Ao criar um chamado, é disparado um **e-mail de aviso** aos destinatários
  configurados, com link direto para o chamado.

### 5.3 Manutenção preventiva

- Cadastro de ativos com criticidade.
- **Ciclos com datas fixas**: cada ativo tem ocorrências agendadas (importadas da
  planilha ou geradas), com data planejada que **não é recalculada** enquanto houver
  ciclo futuro agendado.
- **Execução** (`app/manutencao/[id]/page.tsx`): preenche o checklist TI‑01, informa
  a **data em que a manutenção foi realizada** (editável) e uma **justificativa
  opcional**; ao concluir, grava em `registros_manutencao` e marca o ciclo como
  `Concluído`.
- **Relatório** (`GET /api/manutencao/relatorio?months=YYYY-MM`): gera um HTML
  imprimível com previstas × realizadas por mês e taxa de conclusão (meta 90%).

### 5.4 E-mail de avisos

[`lib/email.ts`](lib/email.ts) envia o aviso de novo chamado. O link do chamado é
montado a partir do **host/protocolo reais da requisição** (headers
`x-forwarded-proto` / `x-forwarded-host`), com fallback para `APP_BASE_URL`.

### 5.5 Download de guias

`GET /api/downloads/guias?file=<nome>.pdf` serve PDFs de `public/guias/` com proteção
anti *path traversal* (rejeita `/`, `..`, `\`, exige extensão `.pdf` e revalida o
caminho resolvido).

---

## 6. Referência da API

Todas as rotas retornam JSON (exceto relatório e download). Erros seguem
`{ "error": "mensagem" }` com o status HTTP apropriado.

### Autenticação
| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/api/auth` | Login. Body: `{ username, password }` |

### Chamados
| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/chamados?solicitante=&role=` | Lista (admin vê todos; usuário vê os seus). Suporta HTTP 304 via `knownCount`/`knownLastUpdated`. |
| POST | `/api/chamados` | Cria. Body: `{ titulo, descricao, solicitante, prioridade, responsavel?, actorUsername? }` |
| GET | `/api/chamados/[id]` | Detalhe |
| PUT | `/api/chamados/[id]` | Atualiza (admin). Envie `actorUsername`. |
| DELETE | `/api/chamados/[id]?actorUsername=` | Exclui (admin) |
| GET/POST | `/api/chamados/[id]/comentarios` | Lista / adiciona comentário |

### Ativos e manutenção
| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/ativos?criticidade=&status=` | Lista ativos |
| POST | `/api/ativos` | Cria ativo |
| GET | `/api/ativos/[id]` | Ativo + ciclos + registros |
| PUT | `/api/ativos/[id]` | Atualiza ativo **ou conclui manutenção** (`{ ultima_manutencao, ciclo_id, tecnico, observacoes, justificativa }`) |
| DELETE | `/api/ativos/[id]` | Exclui ativo (e ciclos/registros) |
| GET | `/api/ciclos?ativo_id=&status=` | Lista ciclos |
| POST | `/api/ciclos` | Cria ciclo + checklist padrão |
| PUT | `/api/ciclos` | Atualiza item de checklist ou ciclo |
| POST | `/api/manutencao/gerar-ciclo` | Gera ciclo por criticidade. Body: `{ ativoId }` |
| GET | `/api/manutencao/relatorio?months=YYYY-MM&months=...` | Relatório HTML |

### Usuários
| Método | Rota | Descrição |
|--------|------|-----------|
| GET/POST | `/api/usuarios` | Lista / cria |
| GET/PUT/DELETE | `/api/usuarios/[id]` | Detalhe / atualiza / exclui |
| GET | `/api/usuarios/admins` | Lista de administradores |

### Downloads
| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/downloads/guias?file=<nome>.pdf` | Download de guia PDF |

---

## 7. Implantação (deploy)

### 7.1 Pré-requisitos

- **Node.js 20 LTS** (o Docker usa `node:20-alpine`).
- **PostgreSQL 14+** acessível pela aplicação, com banco e usuário criados.
- Servidor SMTP (Office 365) para os avisos por e-mail.
- (Opcional) Docker + reverse proxy (nginx/IIS) na frente.

### 7.2 Opção A — Docker (recomendado, é como está em produção)

O projeto tem [`Dockerfile`](Dockerfile) multi-stage que produz a saída
`standalone` do Next.js e roda `node server.js` via [`entrypoint.sh`](entrypoint.sh).

```bash
# 1. Garanta que o .env está preenchido (ver seção 8) — ele é copiado para a imagem.
# 2. Build
docker build -t helpdesk-syl .

# 3. Executar (porta 3000)
docker run -d --name helpdesk-syl -p 3000:3000 --restart unless-stopped helpdesk-syl
```

> O `Dockerfile` copia o `.env` para dentro da imagem. **Não** publique essa imagem em
> registries públicos (contém segredos). Prefira montar o `.env` como volume/secret se
> for usar um registry.

### 7.3 Opção B — Node.js direto (sem container)

```bash
npm ci --legacy-peer-deps
npm run build          # gera .next
npm start              # sobe em http://localhost:3000
```

### 7.4 Opção C — Vercel

Compatível (Next.js), mas exige que o PostgreSQL interno seja acessível pela Vercel
(rede/VPN) — normalmente **não** é o caso de um banco interno `10.x.x.x`. Para este
sistema, Docker on-premises é o cenário real.

### 7.5 Reverse proxy

Como a aplicação escuta em `:3000`, coloque um proxy (nginx/IIS) para expor o domínio
interno. **Configure o proxy para enviar os headers** `X-Forwarded-Proto` e
`X-Forwarded-Host` — o link do e-mail depende deles para apontar para o endereço certo.

---

## 8. Configuração

Variáveis em [`.env`](.env) (arquivo **não versionado** — mantenha um backup seguro).

| Variável | Exemplo | Descrição |
|----------|---------|-----------|
| `DATABASE_HOST` | `10.1.135.24` | Host do PostgreSQL |
| `DATABASE_PORT` | `5432` | Porta |
| `DATABASE_USER` | `ti_user` | Usuário do banco |
| `DATABASE_PASSWORD` | `••••••` | Senha do banco |
| `DATABASE_NAME` | `analysis` | Nome do banco |
| `DATABASE_SCHEMA` | `ti` | Schema usado (default `ti`) |
| `NODE_ENV` | `production` | Ambiente |
| `APP_BASE_URL` | `http://chamados-ti.sylpastilhas.com` | Base p/ links de e-mail (fallback) |
| `NEXT_PUBLIC_API_URL` | `http://chamados-ti.sylpastilhas.com` | Base pública |
| `CHAMADO_NOTIFICATION_RECIPIENTS` | `a@x.com,b@x.com` | Destinatários dos avisos (separados por vírgula) |
| `SMTP_HOST` | `smtp.office365.com` | Servidor SMTP |
| `SMTP_PORT` | `587` | Porta SMTP |
| `SMTP_SECURE` | `false` | `true` para TLS implícito (porta 465) |
| `SMTP_USER` | `chamados.ti@syl.com.br` | Usuário SMTP |
| `SMTP_PASSWORD` | `••••••` | Senha SMTP |
| `SMTP_FROM` | `Sistema de Chamados TI <...>` | Remetente |

> ⚠️ Se a aplicação é servida por **HTTP** (certificado autoassinado), use `http://` em
> `APP_BASE_URL`/`NEXT_PUBLIC_API_URL`. Um valor `https://` para um servidor que só
> responde em HTTP gera links de e-mail quebrados.

---

## 9. Banco de dados: setup e migrações

### 9.1 Criação inicial (banco novo)

1. Crie o banco e o usuário (como superusuário):
   ```sql
   CREATE DATABASE analysis;
   CREATE USER ti_user WITH PASSWORD 'sua-senha';
   ```
2. Aplique o schema consolidado (cria schema `ti` + todas as tabelas, triggers, índices
   e o usuário admin inicial):
   ```bash
   psql -h HOST -U postgres -d analysis -f scripts/010_consolidacao_schema_ti.sql
   ```
   > Cria o usuário `admin` / senha `admin123` (**troque imediatamente**).
3. Conceda permissões ao `ti_user`:
   ```bash
   psql -h HOST -U postgres -d analysis -f database/grant-permissions.sql
   ```

### 9.2 Ordem das migrações

Os scripts `001` a `009` são a evolução histórica; o **`010_consolidacao_schema_ti.sql`**
consolida tudo e é idempotente — para um banco novo, **basta o 010**. Em um banco que já
passou pelos scripts antigos, o 010 também roda com segurança (usa `IF NOT EXISTS` e
normaliza dados legados).

O **`011_import_planilha_2026.sql`** é opcional e importa os dados da planilha
(ver seção 10).

> A aplicação também se auto-corrige para colunas específicas em runtime:
> `ensureUserSectorColumn()` (setor) e `ensureJustificativaColumn()` (justificativa),
> executando `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` na primeira necessidade.

---

## 10. Importação da planilha de manutenção

A planilha interna **"Form 139"** (`checklist de manutenção preventiva TI.xls`) contém,
por ano, uma grade de máquinas × meses, com a data planejada de cada mês e um flag
**P** (Previsto) / **R** (Realizado). O script `011` traduz isso para o banco.

### 10.1 Gerar o script a partir da planilha

```bash
# Requer: pip install pandas xlrd
python scripts/gen_import_planilha.py "<caminho>/checklist de manutenção preventiva TI.xls" 2026 scripts/011_import_planilha_2026.sql
```

O gerador:
- Casa ativos **por nome** (cria os que faltam; atualiza os existentes).
- Mapeia criticidade `1/2/3` → `Alta/Média/Baixa`.
- Cria os ciclos com **datas fixas**, marcando `R = Concluído` e `P = Pendente`.
- É **idempotente** (índice único `ativo_id + data_proxima_manutencao`; pode reexecutar).

### 10.2 Aplicar

```bash
psql -h HOST -U ti_user -d analysis -f scripts/011_import_planilha_2026.sql
```

Para importar outro ano, gere com o ano desejado como parâmetro e aplique.

---

## 11. Operação e manutenção

### 11.1 Backup

- **Banco (crítico):** agende `pg_dump` diário do banco `analysis`.
  ```bash
  pg_dump -h HOST -U ti_user -Fc analysis > backup_analysis_$(date +%F).dump
  ```
- **`.env`:** guarde uma cópia segura (não está no git; contém segredos).
- **PDFs de guias:** versionados em `public/guias/`.

### 11.2 Atualização da aplicação

```bash
git pull
docker build -t helpdesk-syl . && docker rm -f helpdesk-syl && \
  docker run -d --name helpdesk-syl -p 3000:3000 --restart unless-stopped helpdesk-syl
```

### 11.3 Gestão de usuários

- Criação/edição pela tela `/usuarios` (admin) ou via `/api/usuarios`.
- Novos usuários entram com `must_change_password = true` e trocam a senha no 1º acesso.

### 11.4 Logs

- Container: `docker logs -f helpdesk-syl`.
- Erros de servidor são logados com `console.error` nas rotas (aparecem no stdout).

### 11.5 Rotina de manutenção preventiva (uso)

1. O ativo aparece com um ciclo `Pendente` na data planejada.
2. O técnico abre o ativo, marca os itens do checklist TI‑01.
3. Informa a **data realizada** e, se aplicável, a **justificativa**.
4. Conclui — o ciclo vira `Concluído` e o próximo ciclo agendado assume como próximo.
5. O relatório mensal reflete previstas × realizadas.

---

## 12. Troubleshooting

| Sintoma | Causa provável | Solução |
|---------|----------------|---------|
| **Link do e-mail dá erro de conexão/SSL** ("site não encontrado") | `APP_BASE_URL` com `https://` mas app servido por HTTP | O código já usa host/protocolo da requisição; garanta que o proxy envia `X-Forwarded-Proto`/`Host` e ajuste `APP_BASE_URL` para `http://`. |
| **"Erro interno do servidor" ao concluir manutenção** | Coluna `justificativa` ausente (script 011 não aplicado) | Resolvido em runtime por `ensureJustificativaColumn()`. Basta subir a versão atual; opcionalmente rode o `011`. |
| **Avisos de e-mail não chegam** | SMTP incompleto/incorreto | Verifique variáveis `SMTP_*` e `CHAMADO_NOTIFICATION_RECIPIENTS`; veja logs (`Aviso de chamado nao enviado`). |
| **Erros de permissão no banco** | `ti_user` sem grants | Rode `database/grant-permissions.sql`. |
| **Usuário admin não loga** | Senha alterada/esquecida | Atualize direto no banco (`UPDATE ti.usuarios SET password=... WHERE username='admin'`). |
| **Login "cai" com HTTPS** | Certificado autoassinado não confiável | Sistema roda em HTTP por isso; ver comentários em `next.config.mjs`/`middleware.ts`. |

---

## 13. Segurança

**Estado atual (uso interno).** O sistema foi desenhado para rede interna confiável.
Pontos que devem ser conhecidos e, idealmente, endereçados:

| Item | Situação | Recomendação |
|------|----------|--------------|
| Senhas | Armazenadas em **texto puro** (`usuarios.password`) | Migrar para hash (`pgcrypto`/`bcrypt`). O `pgcrypto` já é criado no schema. |
| Sessão | Dados do usuário em `localStorage`, sem cookie/JWT | Introduzir sessão server-side (cookie HttpOnly). |
| Autorização | Regras de admin dependem de parâmetros vindos do cliente (`role`, `actorUsername`) | Validar no servidor a partir de uma sessão autenticada. |
| Transporte | HTTP com certificado autoassinado | Emitir certificado por CA interna confiável e reativar HTTPS/HSTS (blocos comentados em `next.config.mjs`/`middleware.ts`). |
| Segredos | `.env` copiado para a imagem Docker; SMTP/DB em texto | Usar secrets/volumes; não publicar a imagem. |

Pontos **positivos** já implementados: prepared statements (anti SQL injection), headers
de segurança (CSP, X-Frame-Options, etc.), download com proteção anti path traversal e
escape de HTML nos e-mails/relatórios.

---

## 14. Glossário

| Termo | Significado |
|-------|-------------|
| **Ativo** | Máquina/equipamento sujeito a manutenção preventiva |
| **Ciclo de manutenção** | Uma ocorrência agendada de manutenção de um ativo, com data planejada |
| **Criticidade** | Nível (Alta/Média/Baixa) que define a frequência de manutenção |
| **P / R** | Na planilha: **P**revisto (pendente) / **R**ealizado (concluído) |
| **Form.139 / Form.147** | Formulários do procedimento TI‑01 Rev.10 (manutenção / chamado) |
| **Chamado** | Ticket de suporte de TI |
| **Solicitante** | Usuário que abre o chamado |
| **Responsável** | Administrador (técnico) designado para o chamado |

---

*Documento mantido junto ao código. Ao alterar comportamento do sistema, atualize a
seção correspondente aqui.*
