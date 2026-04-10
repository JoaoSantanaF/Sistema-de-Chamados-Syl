BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS ti;
SET search_path TO ti;

-- =============================================================================
-- USUARIOS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'usuario',
    setor VARCHAR(100),
    must_change_password BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT usuarios_role_check CHECK (role IN ('admin', 'usuario'))
);

ALTER TABLE ti.usuarios
    ADD COLUMN IF NOT EXISTS nome VARCHAR(255),
    ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'usuario',
    ADD COLUMN IF NOT EXISTS setor VARCHAR(100),
    ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

UPDATE ti.usuarios
SET nome = COALESCE(NULLIF(nome, ''), username),
    role = CASE WHEN role = 'user' THEN 'usuario' ELSE COALESCE(NULLIF(role, ''), 'usuario') END,
    must_change_password = COALESCE(must_change_password, TRUE),
    created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, NOW());

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'usuarios'
    ) THEN
        INSERT INTO ti.usuarios (id, username, nome, password, role, setor, must_change_password, created_at, updated_at)
        SELECT
            id,
            username,
            COALESCE(NULLIF(nome, ''), username),
            password,
            CASE WHEN role = 'user' THEN 'usuario' ELSE COALESCE(NULLIF(role, ''), 'usuario') END,
            NULL,
            TRUE,
            COALESCE(created_at, NOW()),
            COALESCE(created_at, NOW())
        FROM public.usuarios
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

ALTER TABLE ti.usuarios
    ALTER COLUMN nome SET NOT NULL,
    ALTER COLUMN role SET NOT NULL,
    ALTER COLUMN must_change_password SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

INSERT INTO ti.usuarios (username, nome, password, role, must_change_password)
VALUES ('admin', 'Administrador', 'admin123', 'admin', FALSE)
ON CONFLICT (username) DO NOTHING;

-- =============================================================================
-- CHAMADOS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.chamados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,
    solicitante VARCHAR(255) NOT NULL,
    prioridade VARCHAR(20) NOT NULL DEFAULT 'Média',
    status VARCHAR(30) NOT NULL DEFAULT 'Aberto',
    responsavel VARCHAR(255),
    solucao TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chamados_prioridade_check CHECK (prioridade IN ('Alta', 'Média', 'Baixa')),
    CONSTRAINT chamados_status_check CHECK (status IN ('Aberto', 'Em andamento', 'Fechado'))
);

ALTER TABLE ti.chamados
    ADD COLUMN IF NOT EXISTS titulo VARCHAR(255),
    ADD COLUMN IF NOT EXISTS descricao TEXT,
    ADD COLUMN IF NOT EXISTS solicitante VARCHAR(255),
    ADD COLUMN IF NOT EXISTS prioridade VARCHAR(20) DEFAULT 'Média',
    ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'Aberto',
    ADD COLUMN IF NOT EXISTS responsavel VARCHAR(255),
    ADD COLUMN IF NOT EXISTS solucao TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

UPDATE ti.chamados
SET prioridade = CASE
        WHEN prioridade IN ('Alta', 'Média', 'Baixa') THEN prioridade
        WHEN prioridade ILIKE 'media' THEN 'Média'
        WHEN prioridade ILIKE 'média' THEN 'Média'
        WHEN prioridade ILIKE 'baixa' THEN 'Baixa'
        WHEN prioridade ILIKE 'alta' THEN 'Alta'
        ELSE 'Média'
    END,
    status = CASE
        WHEN status = 'Aberto' THEN 'Aberto'
        WHEN status ILIKE 'em andamento' THEN 'Em andamento'
        WHEN status ILIKE 'em_andamento' THEN 'Em andamento'
        WHEN status ILIKE 'em andamento%' THEN 'Em andamento'
        WHEN status ILIKE 'resolvido' THEN 'Fechado'
        WHEN status ILIKE 'fechado' THEN 'Fechado'
        WHEN status ILIKE 'concluido' THEN 'Fechado'
        WHEN status ILIKE 'concluida' THEN 'Fechado'
        ELSE 'Aberto'
    END,
    created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, NOW());

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'chamados'
    ) THEN
        INSERT INTO ti.chamados (
            id,
            titulo,
            descricao,
            solicitante,
            prioridade,
            status,
            responsavel,
            solucao,
            created_at,
            updated_at
        )
        SELECT
            id,
            titulo,
            descricao,
            solicitante,
            CASE
                WHEN prioridade IN ('Alta', 'Média', 'Baixa') THEN prioridade
                WHEN prioridade ILIKE 'media' THEN 'Média'
                WHEN prioridade ILIKE 'média' THEN 'Média'
                WHEN prioridade ILIKE 'baixa' THEN 'Baixa'
                WHEN prioridade ILIKE 'alta' THEN 'Alta'
                ELSE 'Média'
            END,
            CASE
                WHEN status = 'Aberto' THEN 'Aberto'
                WHEN status ILIKE 'em andamento' THEN 'Em andamento'
                WHEN status ILIKE 'resolvido' THEN 'Fechado'
                WHEN status ILIKE 'fechado' THEN 'Fechado'
                WHEN status ILIKE 'concluido' THEN 'Fechado'
                WHEN status ILIKE 'concluida' THEN 'Fechado'
                ELSE 'Aberto'
            END,
            responsavel,
            solucao,
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, COALESCE(created_at, NOW()))
        FROM public.chamados
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

ALTER TABLE ti.chamados
    ALTER COLUMN titulo SET NOT NULL,
    ALTER COLUMN descricao SET NOT NULL,
    ALTER COLUMN solicitante SET NOT NULL,
    ALTER COLUMN prioridade SET NOT NULL,
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

-- =============================================================================
-- COMENTARIOS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.comentarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chamado_id UUID NOT NULL REFERENCES ti.chamados(id) ON DELETE CASCADE,
    user_id VARCHAR(100) NOT NULL,
    comentario TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comentarios_chamado_id ON ti.comentarios(chamado_id);
CREATE INDEX IF NOT EXISTS idx_comentarios_user_id ON ti.comentarios(user_id);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'comentarios'
    ) THEN
        INSERT INTO ti.comentarios (id, chamado_id, user_id, comentario, created_at)
        SELECT
            id,
            chamado_id,
            user_id,
            comentario,
            COALESCE(created_at, NOW())
        FROM public.comentarios
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- =============================================================================
-- ATIVOS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.ativos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    localizacao VARCHAR(255) NOT NULL,
    criticidade VARCHAR(20) NOT NULL DEFAULT 'Média',
    status VARCHAR(30) NOT NULL DEFAULT 'Operacional',
    ultima_manutencao DATE,
    proxima_manutencao DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ativos_criticidade_check CHECK (criticidade IN ('Alta', 'Média', 'Baixa')),
    CONSTRAINT ativos_status_check CHECK (status IN ('Operacional', 'Em Manutenção', 'Inativo'))
);

ALTER TABLE ti.ativos
    ADD COLUMN IF NOT EXISTS nome VARCHAR(255),
    ADD COLUMN IF NOT EXISTS tipo VARCHAR(100),
    ADD COLUMN IF NOT EXISTS localizacao VARCHAR(255),
    ADD COLUMN IF NOT EXISTS criticidade VARCHAR(20) DEFAULT 'Média',
    ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'Operacional',
    ADD COLUMN IF NOT EXISTS ultima_manutencao DATE,
    ADD COLUMN IF NOT EXISTS proxima_manutencao DATE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

UPDATE ti.ativos
SET criticidade = CASE
        WHEN criticidade IN ('Alta', 'Média', 'Baixa') THEN criticidade
        WHEN criticidade ILIKE 'media' THEN 'Média'
        WHEN criticidade ILIKE 'média' THEN 'Média'
        WHEN criticidade ILIKE 'baixa' THEN 'Baixa'
        WHEN criticidade ILIKE 'alta' THEN 'Alta'
        ELSE 'Média'
    END,
    status = CASE
        WHEN status = 'Operacional' THEN 'Operacional'
        WHEN status ILIKE 'em manutencao' THEN 'Em Manutenção'
        WHEN status ILIKE 'em manutenção' THEN 'Em Manutenção'
        WHEN status ILIKE 'inativo' THEN 'Inativo'
        ELSE 'Operacional'
    END,
    created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, NOW());

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'ativos'
    ) THEN
        INSERT INTO ti.ativos (
            id,
            nome,
            tipo,
            localizacao,
            criticidade,
            status,
            ultima_manutencao,
            proxima_manutencao,
            created_at,
            updated_at
        )
        SELECT
            id,
            nome,
            COALESCE(tipo, 'Equipamento'),
            COALESCE(localizacao, 'Nao informado'),
            CASE
                WHEN criticidade IN ('Alta', 'Média', 'Baixa') THEN criticidade
                WHEN criticidade ILIKE 'media' THEN 'Média'
                WHEN criticidade ILIKE 'média' THEN 'Média'
                WHEN criticidade ILIKE 'baixa' THEN 'Baixa'
                WHEN criticidade ILIKE 'alta' THEN 'Alta'
                ELSE 'Média'
            END,
            CASE
                WHEN status = 'Operacional' THEN 'Operacional'
                WHEN status ILIKE 'em manutencao' THEN 'Em Manutenção'
                WHEN status ILIKE 'em manutenção' THEN 'Em Manutenção'
                WHEN status ILIKE 'inativo' THEN 'Inativo'
                ELSE 'Operacional'
            END,
            ultima_manutencao,
            proxima_manutencao,
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, COALESCE(created_at, NOW()))
        FROM public.ativos
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

ALTER TABLE ti.ativos
    ALTER COLUMN nome SET NOT NULL,
    ALTER COLUMN tipo SET NOT NULL,
    ALTER COLUMN localizacao SET NOT NULL,
    ALTER COLUMN criticidade SET NOT NULL,
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

-- =============================================================================
-- CICLOS DE MANUTENCAO
-- Padronizacao escolhida: data_proxima_manutencao + data_fim
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.ciclos_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ativo_id UUID NOT NULL REFERENCES ti.ativos(id) ON DELETE CASCADE,
    data_inicio DATE,
    data_fim DATE,
    data_proxima_manutencao DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'Pendente',
    observacoes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ciclos_status_check CHECK (status IN ('Pendente', 'Em Progresso', 'Concluído', 'Cancelado'))
);

ALTER TABLE ti.ciclos_manutencao
    ADD COLUMN IF NOT EXISTS ativo_id UUID,
    ADD COLUMN IF NOT EXISTS data_inicio DATE,
    ADD COLUMN IF NOT EXISTS data_fim DATE,
    ADD COLUMN IF NOT EXISTS data_proxima_manutencao DATE,
    ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'Pendente',
    ADD COLUMN IF NOT EXISTS observacoes TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$
BEGIN
    IF (SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'ti'
          AND table_name = 'ciclos_manutencao'
          AND column_name = 'data_conclusao'
    )) THEN
        EXECUTE '
            UPDATE ti.ciclos_manutencao
            SET data_fim = data_conclusao
            WHERE data_fim IS NULL
              AND data_conclusao IS NOT NULL
        ';
    END IF;

    IF (SELECT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'ti'
          AND table_name = 'ciclos_manutencao'
          AND column_name = 'data_prevista'
    )) THEN
        EXECUTE '
            UPDATE ti.ciclos_manutencao
            SET data_proxima_manutencao = data_prevista
            WHERE data_proxima_manutencao IS NULL
              AND data_prevista IS NOT NULL
        ';
    END IF;
END $$;

UPDATE ti.ciclos_manutencao
SET status = CASE
        WHEN status ILIKE 'pendente' THEN 'Pendente'
        WHEN status ILIKE 'em progresso' THEN 'Em Progresso'
        WHEN status ILIKE 'concluido' THEN 'Concluído'
        WHEN status ILIKE 'concluída' THEN 'Concluído'
        WHEN status ILIKE 'concluida' THEN 'Concluído'
        WHEN status ILIKE 'cancelado' THEN 'Cancelado'
        WHEN status ILIKE 'cancelada' THEN 'Cancelado'
        WHEN status ILIKE 'vencida' THEN 'Cancelado'
        WHEN status ILIKE 'vencido' THEN 'Cancelado'
        ELSE 'Pendente'
    END,
    created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, NOW());

ALTER TABLE ti.ciclos_manutencao
    ALTER COLUMN ativo_id SET NOT NULL,
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ciclos_ativo_id ON ti.ciclos_manutencao(ativo_id);
CREATE INDEX IF NOT EXISTS idx_ciclos_status ON ti.ciclos_manutencao(status);
CREATE INDEX IF NOT EXISTS idx_ciclos_data_proxima ON ti.ciclos_manutencao(data_proxima_manutencao);

-- =============================================================================
-- ITENS DE CHECKLIST
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.itens_checklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ciclo_id UUID NOT NULL REFERENCES ti.ciclos_manutencao(id) ON DELETE CASCADE,
    descricao VARCHAR(500) NOT NULL,
    concluido BOOLEAN NOT NULL DEFAULT FALSE,
    observacoes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE ti.itens_checklist
    ADD COLUMN IF NOT EXISTS ciclo_id UUID,
    ADD COLUMN IF NOT EXISTS descricao VARCHAR(500),
    ADD COLUMN IF NOT EXISTS concluido BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS observacoes TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE ti.itens_checklist
    ALTER COLUMN ciclo_id SET NOT NULL,
    ALTER COLUMN descricao SET NOT NULL,
    ALTER COLUMN concluido SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_itens_ciclo_id ON ti.itens_checklist(ciclo_id);

-- =============================================================================
-- REGISTROS DE MANUTENCAO
-- =============================================================================
CREATE TABLE IF NOT EXISTS ti.registros_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ativo_id UUID NOT NULL REFERENCES ti.ativos(id) ON DELETE CASCADE,
    ciclo_id UUID REFERENCES ti.ciclos_manutencao(id) ON DELETE SET NULL,
    tecnico VARCHAR(255) NOT NULL,
    chamado_id UUID REFERENCES ti.chamados(id) ON DELETE SET NULL,
    data_execucao TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(30) NOT NULL DEFAULT 'Concluída',
    observacoes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT registros_status_check CHECK (status IN ('Concluída', 'Parcial', 'Cancelada'))
);

ALTER TABLE ti.registros_manutencao
    ADD COLUMN IF NOT EXISTS ativo_id UUID,
    ADD COLUMN IF NOT EXISTS ciclo_id UUID,
    ADD COLUMN IF NOT EXISTS tecnico VARCHAR(255),
    ADD COLUMN IF NOT EXISTS chamado_id UUID,
    ADD COLUMN IF NOT EXISTS data_execucao TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'Concluída',
    ADD COLUMN IF NOT EXISTS observacoes TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'ti'
          AND table_name = 'registros_manutencao'
          AND column_name = 'data_manutencao'
    ) THEN
        EXECUTE '
            UPDATE ti.registros_manutencao
            SET data_execucao = data_manutencao::timestamptz
            WHERE data_execucao IS NULL
              AND data_manutencao IS NOT NULL
        ';
    END IF;
END $$;

UPDATE ti.registros_manutencao
SET status = CASE
        WHEN status ILIKE 'concluida' THEN 'Concluída'
        WHEN status ILIKE 'concluída' THEN 'Concluída'
        WHEN status ILIKE 'parcial' THEN 'Parcial'
        WHEN status ILIKE 'cancelada' THEN 'Cancelada'
        WHEN status ILIKE 'falhou' THEN 'Cancelada'
        ELSE 'Concluída'
    END,
    tecnico = COALESCE(NULLIF(tecnico, ''), 'Sistema'),
    data_execucao = COALESCE(data_execucao, NOW()),
    created_at = COALESCE(created_at, NOW()),
    updated_at = COALESCE(updated_at, NOW());

ALTER TABLE ti.registros_manutencao
    ALTER COLUMN ativo_id SET NOT NULL,
    ALTER COLUMN tecnico SET NOT NULL,
    ALTER COLUMN data_execucao SET NOT NULL,
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_registros_ativo_id ON ti.registros_manutencao(ativo_id);
CREATE INDEX IF NOT EXISTS idx_registros_ciclo_id ON ti.registros_manutencao(ciclo_id);
CREATE INDEX IF NOT EXISTS idx_registros_chamado_id ON ti.registros_manutencao(chamado_id);

-- =============================================================================
-- FUNCAO E TRIGGERS DE updated_at
-- =============================================================================
CREATE OR REPLACE FUNCTION ti.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_usuarios_updated_at ON ti.usuarios;
CREATE TRIGGER trg_usuarios_updated_at
BEFORE UPDATE ON ti.usuarios
FOR EACH ROW
EXECUTE FUNCTION ti.set_updated_at();

DROP TRIGGER IF EXISTS trg_chamados_updated_at ON ti.chamados;
CREATE TRIGGER trg_chamados_updated_at
BEFORE UPDATE ON ti.chamados
FOR EACH ROW
EXECUTE FUNCTION ti.set_updated_at();

DROP TRIGGER IF EXISTS trg_ativos_updated_at ON ti.ativos;
CREATE TRIGGER trg_ativos_updated_at
BEFORE UPDATE ON ti.ativos
FOR EACH ROW
EXECUTE FUNCTION ti.set_updated_at();

DROP TRIGGER IF EXISTS trg_ciclos_updated_at ON ti.ciclos_manutencao;
CREATE TRIGGER trg_ciclos_updated_at
BEFORE UPDATE ON ti.ciclos_manutencao
FOR EACH ROW
EXECUTE FUNCTION ti.set_updated_at();

DROP TRIGGER IF EXISTS trg_itens_checklist_updated_at ON ti.itens_checklist;
CREATE TRIGGER trg_itens_checklist_updated_at
BEFORE UPDATE ON ti.itens_checklist
FOR EACH ROW
EXECUTE FUNCTION ti.set_updated_at();

DROP TRIGGER IF EXISTS trg_registros_updated_at ON ti.registros_manutencao;
CREATE TRIGGER trg_registros_updated_at
BEFORE UPDATE ON ti.registros_manutencao
FOR EACH ROW
EXECUTE FUNCTION ti.set_updated_at();

COMMIT;
