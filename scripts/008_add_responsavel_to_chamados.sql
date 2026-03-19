-- Garante coluna de técnico responsável nos chamados
ALTER TABLE IF EXISTS public.chamados
ADD COLUMN IF NOT EXISTS responsavel TEXT;

-- Opcional: índice para filtros por responsável
CREATE INDEX IF NOT EXISTS idx_chamados_responsavel ON public.chamados(responsavel);
