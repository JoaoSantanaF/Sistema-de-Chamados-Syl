# HELP DESK SYL
Este software interno do grupo SYL consiste em um sistema de manutenção continua para a equipe de suporte de TI.

A arquitetura deste software consiste basicamente em Next.js e o consumo de um armazém de dados para análise em postgres (datawarehouse em postgres).

## Estrutura de arquivos

```
helpdesksystem/
├── app/                            # Next.js App Router
│   ├── api/                        # Endpoints REST
│   │   ├── auth/route.ts           # POST - Login de usuários
│   │   ├── chamados/
│   │   │   ├── route.ts            # GET/POST - Listar e criar chamados
│   │   │   └── [id]/route.ts       # GET/PUT/DELETE - Chamado específico
│   │   ├── ativos/
│   │   │   ├── route.ts            # GET/POST - Listar e criar ativos
│   │   │   └── [id]/route.ts       # GET/PUT/DELETE - Ativo específico
│   │   ├── ciclos/route.ts         # GET/POST/PUT - Ciclos de manutenção
│   │   ├── usuarios/
│   │   │   ├── route.ts            # GET/POST - Listar e criar usuários
│   │   │   └── [id]/route.ts       # GET/PUT/DELETE - Usuário específico
│   │   └── manutencao/
│   │       └── gerar-ciclo/route.ts # POST - Gerar ciclo de manutenção
│   │
│   ├── chamados/                   # Páginas de chamados
│   │   ├── page.tsx                # Lista de chamados
│   │   ├── novo/page.tsx           # Criar novo chamado
│   │   └── [id]/page.tsx           # Detalhes do chamado
│   │
│   ├── manutencao/                 # Páginas de manutenção preventiva
│   │   ├── page.tsx                # Lista de ativos
│   │   ├── novo-ativo/page.tsx     # Criar novo ativo
│   │   └── [id]/
│   │       ├── page.tsx            # Detalhes do ativo
│   │       └── editar/page.tsx     # Editar ativo
│   │
│   ├── dashboard/page.tsx          # Dashboard principal
│   ├── login/page.tsx              # Página de login
│   ├── usuarios/page.tsx           # Gestão de usuários (admin)
│   ├── layout.tsx                  # Layout raiz
│   └── page.tsx                    # Redireciona para /login
│
├── components/                     # Componentes React
│   ├── ui/                         # Componentes shadcn/ui (50+)
│   ├── dashboard-layout.tsx        # Layout com sidebar e navegação
│   └── theme-provider.tsx          # Provider de tema dark/light
│
├── lib/                            # Utilitários
│   ├── db.ts                       # Pool de conexão PostgreSQL
│   ├── maintenance-utils.ts        # Cálculos de manutenção e dias úteis
│   └── utils.ts                    # Utilitários gerais (cn, etc)
│
├── database/                       # Scripts de banco de dados
│   ├── setup.sql                   # Schema completo PostgreSQL
│   └── grant-permissions.sql       # Permissões para ti_user
│
├── scripts/                        # Scripts de migração
│   ├── 004_create_preventive_maintenance_tables.sql
│   ├── 005_seed_equipment_list.sql
│   ├── 006_generate_first_maintenance_cycles.sql
│   └── 007_update_ti01_compliance.sql
│
├── hooks/                          # React hooks customizados
├── styles/                         # Arquivos CSS
├── public/                         # Assets estáticos
│
├── .env                            # Variáveis de ambiente
├── .env.example                    # Exemplo de variáveis
├── Dockerfile                      # Build da imagem Docker
├── entrypoint.sh                   # Script de inicialização Docker
├── package.json                    # Dependências
├── tsconfig.json                   # Configuração TypeScript
└── next.config.mjs                 # Configuração Next.js
```

