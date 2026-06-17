-- ============================================================================
-- 011_import_planilha_2026.sql
-- Importacao da planilha 'Form 139' (manutencao preventiva) - ano 2026.
-- Gerado por scripts/gen_import_planilha.py. NAO editar a mao.
-- Ativos: 45 | Ciclos: 335
-- Idempotente: pode ser reexecutado sem duplicar (casa ativo por nome).
-- ============================================================================

BEGIN;
SET search_path TO ti;

-- Coluna de justificativa do registro de execucao (data feita + justificativa).
ALTER TABLE ti.registros_manutencao ADD COLUMN IF NOT EXISTS justificativa TEXT;

-- Garante que nao haja ciclos duplicados (mesmo ativo + mesma data planejada).
CREATE UNIQUE INDEX IF NOT EXISTS uq_ciclos_ativo_data
    ON ti.ciclos_manutencao(ativo_id, data_proxima_manutencao);

DO $$
DECLARE
    v_ativo_id UUID;
    v_ciclo_id UUID;
    v_item TEXT;
    v_checklist TEXT[] := ARRAY[
        'Limpeza fisica do equipamento',
        'Troca de teclado e mouse (se necessario)',
        'Verificacao de cabos e conexoes',
        'Desfragmentacao (se necessario)',
        'Atualizacao de antivirus e Windows Update',
        'Atualizar campo "Ultima Preventiva"'
    ];
BEGIN

    -- ----- CARIMBADEIRA (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('CARIMBADEIRA') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('CARIMBADEIRA', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- EMBALAGEM ZEBRA1 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('EMBALAGEM ZEBRA1') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('EMBALAGEM ZEBRA1', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- EMBALAGEMZEBRA2 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('EMBALAGEMZEBRA2') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('EMBALAGEMZEBRA2', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-04-06', '2026-05-06')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-04-06', ultima_manutencao),
               proxima_manutencao = '2026-05-06'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- EMBALAGEM990 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('EMBALAGEM990') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('EMBALAGEM990', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-04-06', '2026-05-06')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-04-06', ultima_manutencao),
               proxima_manutencao = '2026-05-06'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- REBITADEIRA390 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('REBITADEIRA390') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('REBITADEIRA390', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-06-05', '2026-07-06')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-06-05', ultima_manutencao),
               proxima_manutencao = '2026-07-06'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', '2026-06-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-06-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- COLA (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('COLA') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('COLA', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- PREPRENSA (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('PREPRENSA') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('PREPRENSA', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-06-05', '2026-07-06')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-06-05', ultima_manutencao),
               proxima_manutencao = '2026-07-06'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', '2026-06-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-06-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- RETIFICA (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('RETIFICA') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('RETIFICA', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-06-05', '2026-07-06')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-06-05', ultima_manutencao),
               proxima_manutencao = '2026-07-06'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', '2026-06-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-06-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- ACESSORIOS (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ACESSORIOS') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ACESSORIOS', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-04-06')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-04-06'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- RECEBIMENTOTHINK (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('RECEBIMENTOTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('RECEBIMENTOTHINK', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- SAPATACARIM (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('SAPATACARIM') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('SAPATACARIM', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- ALMOXARIFADO (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ALMOXARIFADO') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ALMOXARIFADO', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- GABRIELLITHINK (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('GABRIELLITHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('GABRIELLITHINK', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- MANUTENCAOPI (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('MANUTENCAOPI') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('MANUTENCAOPI', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- MANUTENCAO02 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('MANUTENCAO02') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('MANUTENCAO02', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- FERRAMENTASDELL (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('FERRAMENTASDELL') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('FERRAMENTASDELL', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- SAPATADELL790 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('SAPATADELL790') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('SAPATADELL790', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- SAPATA5070 (criticidade Alta) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('SAPATA5070') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('SAPATA5070', 'Equipamento', 'Nao informado', 'Alta', 'Operacional', '2026-05-06', '2026-06-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Alta',
               ultima_manutencao = COALESCE('2026-05-06', ultima_manutencao),
               proxima_manutencao = '2026-06-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-05', '2026-02-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', '2026-03-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-06', '2026-04-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-06', '2026-05-06', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-06'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-04', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- SAPATA-RFID (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('SAPATA-RFID') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('SAPATA-RFID', 'Equipamento', 'Nao informado', 'Média', 'Operacional', NULL, NULL)
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = NULL
         WHERE id = v_ativo_id;
    END IF;

    -- ----- EXPEDICAO (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('EXPEDICAO') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('EXPEDICAO', 'Equipamento', 'Nao informado', 'Média', 'Operacional', NULL, NULL)
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = NULL
         WHERE id = v_ativo_id;
    END IF;

    -- ----- ROGERIOTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ROGERIOTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ROGERIOTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-02-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-02-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- LOGISTICA03 (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('LOGISTICA03') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('LOGISTICA03', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-02-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-02-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- RICARDOTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('RICARDOTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('RICARDOTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-20', '2026-06-19')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-20', ultima_manutencao),
               proxima_manutencao = '2026-06-19'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-20', '2026-02-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-20', '2026-04-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- LOGISTICA-RECEB (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('LOGISTICA-RECEB') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('LOGISTICA-RECEB', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-20', '2026-06-19')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-20', ultima_manutencao),
               proxima_manutencao = '2026-06-19'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-20', '2026-02-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-20', '2026-04-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- VALMIR (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('VALMIR') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('VALMIR', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-20', '2026-06-19')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-20', ultima_manutencao),
               proxima_manutencao = '2026-06-19'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-20', '2026-04-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- LEONARDOTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('LEONARDOTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('LEONARDOTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-06-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-06-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-10', '2026-02-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- ROCHATHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ROCHATHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ROCHATHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-20', '2026-06-19')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-20', ultima_manutencao),
               proxima_manutencao = '2026-06-19'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-20', '2026-04-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- OTAVIOTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('OTAVIOTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('OTAVIOTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-05-19', '2026-07-17')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-05-19', ultima_manutencao),
               proxima_manutencao = '2026-07-17'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-19', '2026-01-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-19', '2026-03-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-19', '2026-05-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-17', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-17', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-17', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- JONASTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('JONASTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('JONASTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-05-19', '2026-07-17')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-05-19', ultima_manutencao),
               proxima_manutencao = '2026-07-17'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-19', '2026-01-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-19', '2026-03-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-03-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-19', '2026-05-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-17', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-17', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-17', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- AMABILYTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('AMABILYTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('AMABILYTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-05-22', '2026-07-20')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-05-22', ultima_manutencao),
               proxima_manutencao = '2026-07-20'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-23', '2026-01-23', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-23'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-23', '2026-04-23', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-23'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-22', '2026-05-22', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-22'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-20', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-21', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- ENCARREGADOSTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ENCARREGADOSTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ENCARREGADOSTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-06-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-06-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-10', '2026-02-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- DRAUSIOTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('DRAUSIOTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('DRAUSIOTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-06-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-06-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-10', '2026-02-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- CLAUDINEITHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('CLAUDINEITHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('CLAUDINEITHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-20', '2026-06-19')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-20', ultima_manutencao),
               proxima_manutencao = '2026-06-19'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-19', '2026-02-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-20', '2026-04-20', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-20'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-19', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- SILVIATHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('SILVIATHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('SILVIATHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-06-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-06-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-10', '2026-02-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- LUIZ-PROCESSOS (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('LUIZ-PROCESSOS') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('LUIZ-PROCESSOS', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-05-05', '2026-03-05')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-05-05', ultima_manutencao),
               proxima_manutencao = '2026-03-05'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-05', '2026-01-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-01-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-05', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-05', '2026-05-05', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-05'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-06', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-08', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-09', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-14', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- DOUGLASTHINK (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('DOUGLASTHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('DOUGLASTHINK', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-04-10', '2026-06-10')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-04-10', ultima_manutencao),
               proxima_manutencao = '2026-06-10'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-02-19', '2026-02-19', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-02-19'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-04-10', '2026-04-10', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-04-10'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-08-10', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-10-13', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- NICOLEDELL3050 (criticidade Média) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('NICOLEDELL3050') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('NICOLEDELL3050', 'Equipamento', 'Nao informado', 'Média', 'Operacional', '2026-05-22', '2026-01-21')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Média',
               ultima_manutencao = COALESCE('2026-05-22', ultima_manutencao),
               proxima_manutencao = '2026-01-21'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-01-21', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-03-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-05-22', '2026-05-22', 'Concluído')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, TRUE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.registros_manutencao (ativo_id, ciclo_id, tecnico, data_execucao, status)
    SELECT v_ativo_id, v_ciclo_id, 'Importado da planilha', '2026-05-22'::timestamptz, 'Concluída'
    WHERE NOT EXISTS (
        SELECT 1 FROM ti.registros_manutencao WHERE ciclo_id = v_ciclo_id
    );
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-07-20', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-09-21', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-11-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- EDNATHINK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('EDNATHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('EDNATHINK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- ARIANITHINK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ARIANITHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ARIANITHINK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- ERICATHINK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('ERICATHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('ERICATHINK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- AMANDATHINK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('AMANDATHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('AMANDATHINK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- CAROLINETHINK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('CAROLINETHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('CAROLINETHINK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- LETICIATHINK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('LETICIATHINK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('LETICIATHINK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- THAUANNYNOTE (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('THAUANNYNOTE') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('THAUANNYNOTE', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;

    -- ----- FLAVIATHIMK (criticidade Baixa) -----
    SELECT id INTO v_ativo_id FROM ti.ativos WHERE lower(nome) = lower('FLAVIATHIMK') LIMIT 1;
    IF v_ativo_id IS NULL THEN
        INSERT INTO ti.ativos (nome, tipo, localizacao, criticidade, status, ultima_manutencao, proxima_manutencao)
        VALUES ('FLAVIATHIMK', 'Equipamento', 'Nao informado', 'Baixa', 'Operacional', NULL, '2026-06-26')
        RETURNING id INTO v_ativo_id;
    ELSE
        UPDATE ti.ativos
           SET criticidade = 'Baixa',
               ultima_manutencao = COALESCE(NULL, ultima_manutencao),
               proxima_manutencao = '2026-06-26'
         WHERE id = v_ativo_id;
    END IF;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-06-26', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
    INSERT INTO ti.ciclos_manutencao (ativo_id, data_proxima_manutencao, data_fim, status)
    VALUES (v_ativo_id, '2026-12-23', NULL, 'Pendente')
    ON CONFLICT (ativo_id, data_proxima_manutencao) DO UPDATE
        SET status = EXCLUDED.status, data_fim = EXCLUDED.data_fim
    RETURNING id INTO v_ciclo_id;
    FOREACH v_item IN ARRAY v_checklist LOOP
        INSERT INTO ti.itens_checklist (ciclo_id, descricao, concluido)
        SELECT v_ciclo_id, v_item, FALSE
        WHERE NOT EXISTS (
            SELECT 1 FROM ti.itens_checklist WHERE ciclo_id = v_ciclo_id AND descricao = v_item
        );
    END LOOP;
END $$;

COMMIT;
