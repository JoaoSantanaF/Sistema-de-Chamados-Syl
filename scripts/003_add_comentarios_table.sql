-- Criar tabela de comentários dos chamados
CREATE TABLE IF NOT EXISTS public.comentarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chamado_id UUID NOT NULL REFERENCES public.chamados(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  comentario TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.comentarios ENABLE ROW LEVEL SECURITY;

-- Políticas para tabela comentarios
CREATE POLICY "Todos podem ler comentários" ON public.comentarios FOR SELECT USING (true);
CREATE POLICY "Todos podem criar comentários" ON public.comentarios FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem deletar comentários" ON public.comentarios FOR DELETE USING (true);

-- Índice para buscar comentários por chamado
CREATE INDEX IF NOT EXISTS idx_comentarios_chamado_id ON public.comentarios(chamado_id);
