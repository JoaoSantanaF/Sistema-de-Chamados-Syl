-- =============================================================================
-- HelpDesk TI + Manutenção Preventiva - Script de Setup do Banco de Dados
-- Schema: ti
-- Usuário: ti_user
-- =============================================================================

-- Criar schema se não existir
CREATE SCHEMA IF NOT EXISTS ti;

-- Definir search_path para o schema ti
SET search_path TO ti;

-- =============================================================================
-- TABELA: usuarios
-- Armazena os usuários do sistema (admin e usuarios comuns)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'usuario' CHECK (role IN ('admin', 'usuario')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir usuário admin padrão (se não existir)
INSERT INTO ti.usuarios (username, nome, password, role)
VALUES ('admin', 'Administrador', 'admin123', 'admin')
ON CONFLICT (username) DO NOTHING;

-- =============================================================================
-- TABELA: chamados
-- Armazena os chamados de helpdesk
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.chamados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,
    solicitante VARCHAR(255) NOT NULL,
    prioridade VARCHAR(20) NOT NULL DEFAULT 'Média' CHECK (prioridade IN ('Alta', 'Média', 'Baixa')),
    status VARCHAR(30) NOT NULL DEFAULT 'Aberto' CHECK (status IN ('Aberto', 'Em Andamento', 'Resolvido', 'Fechado')),
    responsavel VARCHAR(255),
    solucao TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: ativos
-- Armazena os ativos de TI para manutenção preventiva
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.ativos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    localizacao VARCHAR(255) NOT NULL,
    criticidade VARCHAR(20) NOT NULL DEFAULT 'Média' CHECK (criticidade IN ('Alta', 'Média', 'Baixa')),
    status VARCHAR(30) NOT NULL DEFAULT 'Operacional' CHECK (status IN ('Operacional', 'Em Manutenção', 'Inativo')),
    ultima_manutencao DATE,
    proxima_manutencao DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: ciclos_manutencao
-- Armazena os ciclos de manutenção preventiva
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.ciclos_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ativo_id UUID NOT NULL REFERENCES ti.ativos(id) ON DELETE CASCADE,
    data_inicio DATE,
    data_fim DATE,
    data_proxima_manutencao DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Em Progresso', 'Concluído', 'Cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: itens_checklist
-- Armazena os itens do checklist de manutenção
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.itens_checklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ciclo_id UUID NOT NULL REFERENCES ti.ciclos_manutencao(id) ON DELETE CASCADE,
    descricao VARCHAR(500) NOT NULL,
    concluido BOOLEAN NOT NULL DEFAULT FALSE,
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: registros_manutencao
-- Armazena o histórico de manutenções realizadas
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.registros_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ativo_id UUID NOT NULL REFERENCES ti.ativos(id) ON DELETE CASCADE,
    ciclo_id UUID REFERENCES ti.ciclos_manutencao(id) ON DELETE SET NULL,
    tecnico VARCHAR(255) NOT NULL,
    chamado_id UUID REFERENCES ti.chamados(id) ON DELETE SET NULL,
    data_execucao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(30) NOT NULL DEFAULT 'Concluída' CHECK (status IN ('Concluída', 'Parcial', 'Cancelada')),
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- ÍNDICES para melhor performance
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_chamados_status ON ti.chamados(status);
CREATE INDEX IF NOT EXISTS idx_chamados_prioridade ON ti.chamados(prioridade);
CREATE INDEX IF NOT EXISTS idx_chamados_solicitante ON ti.chamados(solicitante);
CREATE INDEX IF NOT EXISTS idx_chamados_created_at ON ti.chamados(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ativos_criticidade ON ti.ativos(criticidade);
CREATE INDEX IF NOT EXISTS idx_ativos_status ON ti.ativos(status);
CREATE INDEX IF NOT EXISTS idx_ativos_proxima_manutencao ON ti.ativos(proxima_manutencao);

CREATE INDEX IF NOT EXISTS idx_ciclos_ativo_id ON ti.ciclos_manutencao(ativo_id);
CREATE INDEX IF NOT EXISTS idx_ciclos_status ON ti.ciclos_manutencao(status);

CREATE INDEX IF NOT EXISTS idx_itens_ciclo_id ON ti.itens_checklist(ciclo_id);

CREATE INDEX IF NOT EXISTS idx_registros_ativo_id ON ti.registros_manutencao(ativo_id);

-- =============================================================================
-- PERMISSÕES para ti_user
-- Essas permissões são aplicadas APÓS a criação das tabelas
-- Isso resolve o problema de perda de permissões após DROP/CREATE
-- =============================================================================

-- Permissões no schema
GRANT USAGE ON SCHEMA ti TO ti_user;

-- Permissões em todas as tabelas do schema ti
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ti TO ti_user;

-- Permissões em sequências (para auto-increment/serial)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ti TO ti_user;

-- Definir permissões padrão para tabelas futuras criadas no schema ti
ALTER DEFAULT PRIVILEGES IN SCHEMA ti GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ti_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA ti GRANT USAGE, SELECT ON SEQUENCES TO ti_user;

-- =============================================================================
-- VERIFICAÇÃO - Lista as permissões atuais
-- =============================================================================
-- Para verificar as permissões, execute:
-- SELECT grantee, privilege_type, table_name
-- FROM information_schema.table_privileges
-- WHERE table_schema = 'ti' AND grantee = 'ti_user';

-- =============================================================================
-- FIM DO SCRIPT
-- =============================================================================
