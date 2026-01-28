# Requisitos Técnicos - Sistema de Helpdesk SYL

## 🔧 Linguagens Utilizadas

### Frontend
- **TypeScript 5.x** - Tipagem estática para JavaScript
- **JavaScript ES6+** - Runtime
- **TSX/JSX** - React componentes com TypeScript

### Backend
- **TypeScript** - Server-side logic
- **Node.js** - Runtime do servidor

### Banco de Dados
- **SQL** - PostgreSQL via Supabase
- **PostgreSQL 14+** - DBMS

## 📦 Dependências Principais

### Framework e Runtime
- **Next.js 16.0.10** - Full-stack React framework
- **React 19.2.0** - UI library
- **React DOM 19.2.0** - React rendering

### UI Components e Styling
- **Radix UI** - Biblioteca de componentes primitivos (30+ pacotes)
- **Tailwind CSS 4.1.9** - Utility-first CSS framework
- **Tailwind Merge 2.5.5** - Merge classes helper
- **Tailwind Animate 1.0.7** - Animações CSS
- **Shadcn/ui** - Componentes React customizáveis

### Formulários e Validação
- **React Hook Form 7.60.0** - Gerenciamento de formulários
- **Zod 3.25.76** - Validação de schemas TypeScript
- **@hookform/resolvers 3.10.0** - Integração com validadores

### Banco de Dados
- **@supabase/supabase-js (latest)** - Client SDK do Supabase
- **@supabase/ssr (latest)** - Server-side rendering com Supabase

### Utilitários
- **date-fns 4.1.0** - Manipulação de datas
- **lucide-react 0.454.0** - Icon library (500+ icons)
- **clsx 2.1.1** - Utilidade para classes condicionais
- **cmdk 1.0.4** - Command menu
- **recharts 2.15.4** - React charts library
- **sonner 1.7.4** - Toast notifications
- **next-themes 0.4.6** - Dark mode
- **Vaul 1.1.2** - Drawer/modal
- **embla-carousel-react 8.5.1** - Carousel
- **react-resizable-panels 2.1.7** - Painéis redimensionáveis
- **input-otp 1.4.1** - OTP input
- **react-day-picker 9.8.0** - Date picker

### Analytics e Monitoring
- **@vercel/analytics 1.3.1** - Analytics do Vercel

### Desenvolvimento
- **TypeScript 5.x**
- **Tailwind CSS 4.1.9**
- **PostCSS 8.5**
- **Autoprefixer 10.4.20**
- **ESLint** - Linting

## 🖥️ Requisitos Mínimos de Servidor

### Ambiente de Desenvolvimento

**Node.js:**
- Versão mínima: **Node.js 18 LTS** ou superior
- Recomendado: **Node.js 20 LTS** ou **Node.js 22 LTS**

**npm/pnpm:**
- npm 10.x ou superior
- pnpm 8.x ou superior (recomendado para este projeto - usa pnpm-lock.yaml)

**Processador:**
- Mínimo: Dual-core 2GHz
- Recomendado: Quad-core 2.4GHz+

**Memória RAM:**
- Mínimo: 2GB
- Recomendado: 4GB ou mais

**Espaço em Disco:**
- Node_modules: ~800MB
- Build artifacts: ~200MB
- Total: ~1.5GB

### Ambiente de Produção (Servidor)

**Plataforma Recomendada:**
- **Vercel** (otimizado para Next.js)
- **AWS EC2** com Node.js
- **Digital Ocean** App Platform
- **Railway**
- **Render**
- **Heroku** (com limitações)

**Especificações de Servidor (Self-hosted):**

| Recurso | Mínimo | Recomendado | Alta Carga |
|---------|--------|-------------|-----------|
| **vCPU** | 1 | 2-4 | 4-8 |
| **RAM** | 1GB | 2-4GB | 8-16GB |
| **Storage** | 10GB | 20-50GB | 100GB+ |
| **Bandwidth** | 1Mbps | 10Mbps | 100Mbps+ |

**Requisitos de Sistema Operacional:**
- Linux (Ubuntu 20.04 LTS ou superior - Recomendado)
- macOS 12+
- Windows Server 2019+

### Banco de Dados (Supabase/PostgreSQL)

**Requisitos Supabase:**
- Plano: Free (desenvolvimento) ou Paid (produção)
- Storage: Depende do volume de dados
- Conexões: Máximo 100 simultâneas (plano Free)
- Bandwidth: 2GB/mês (Free)

**Alternativa Self-hosted PostgreSQL:**
- PostgreSQL 14+
- Mínimo: 256MB RAM
- Recomendado: 1-2GB RAM
- Storage: 5-50GB (depende do volume de dados)

## 📋 Processo de Setup e Deploy

### Desenvolvimento Local

```bash
# 1. Instalar dependências
pnpm install

# 2. Configurar variáveis de ambiente
cp .env.example .env.local
# Adicionar NEXT_PUBLIC_SUPABASE_URL e NEXT_PUBLIC_SUPABASE_ANON_KEY

# 3. Rodar servidor de desenvolvimento
pnpm dev
# Acesse http://localhost:3000
```

### Build para Produção

```bash
# 1. Build otimizado
pnpm build

# 2. Iniciar servidor de produção
pnpm start
```

### Deploy no Vercel (Recomendado)

```bash
# 1. Instalar Vercel CLI
npm install -g vercel

# 2. Deploy
vercel

# 3. Configurar variáveis de ambiente no Vercel Dashboard
```

## 🔐 Variáveis de Ambiente Necessárias

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-anonima
SUPABASE_SERVICE_ROLE_KEY=sua-chave-servico

# Optional - Development
NEXT_PUBLIC_DEV_SUPABASE_REDIRECT_URL=http://localhost:3000
```

## 📊 Performance e Escalabilidade

**Limites Típicos:**
- Usuários simultâneos: 100-500 (dependendo do servidor)
- Requisições por segundo: 50-200 RPS (com otimizações)
- Tempo de resposta: <200ms (média)

**Otimizações Implementadas:**
- Next.js 16 com Turbopack (bundler padrão)
- Image optimization desabilitada (imagens do Vercel Blob)
- Server Components para melhor performance
- Caching automático via Next.js

## 🛡️ Segurança

- HTTPS obrigatório em produção
- Environment variables isoladas
- Row Level Security (RLS) no PostgreSQL via Supabase
- TypeScript para type safety
- Validação com Zod em formulários

## 📝 Resumo Técnico

| Aspecto | Versão/Especificação |
|---------|---------------------|
| **Framework** | Next.js 16.0.10 |
| **UI Framework** | React 19.2.0 |
| **Linguagem** | TypeScript 5.x |
| **Styling** | Tailwind CSS 4.1.9 |
| **Banco de Dados** | PostgreSQL 14+ (Supabase) |
| **Deploy** | Vercel ou Self-hosted Node.js |
| **Node.js** | 18 LTS mínimo, 20+ recomendado |
| **Gerenciador Pacotes** | pnpm (recomendado) |

---

**Última atualização:** Janeiro 2026
**Versão da Aplicação:** v1.0
