-- =============================================================================
-- Script para conceder permissões ao ti_user
-- Execute este script se o ti_user perdeu permissões após DROP/CREATE
-- ou se as tabelas foram criadas por outro usuário
-- =============================================================================

-- Definir search_path
SET search_path TO ti;

-- Permissões no schema
GRANT USAGE ON SCHEMA ti TO ti_user;

-- Permissões em TODAS as tabelas existentes no schema ti
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ti TO ti_user;

-- Permissões em TODAS as sequências existentes no schema ti
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ti TO ti_user;

-- Definir permissões padrão para tabelas FUTURAS criadas no schema ti
-- Isso garante que qualquer nova tabela criada automaticamente terá as permissões
ALTER DEFAULT PRIVILEGES IN SCHEMA ti GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ti_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA ti GRANT USAGE, SELECT ON SEQUENCES TO ti_user;

-- =============================================================================
-- VERIFICAÇÃO - Listar permissões atuais do ti_user
-- =============================================================================
SELECT
    table_schema,
    table_name,
    privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'ti'
  AND grantee = 'ti_user'
ORDER BY table_name, privilege_type;

-- =============================================================================
-- Se você ainda tiver problemas de permissão, execute como superusuário:
-- ALTER TABLE ti.usuarios OWNER TO ti_user;
-- ALTER TABLE ti.chamados OWNER TO ti_user;
-- ALTER TABLE ti.ativos OWNER TO ti_user;
-- ALTER TABLE ti.ciclos_manutencao OWNER TO ti_user;
-- ALTER TABLE ti.itens_checklist OWNER TO ti_user;
-- ALTER TABLE ti.registros_manutencao OWNER TO ti_user;
-- =============================================================================
