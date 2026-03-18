-- Cria tabela de comentários no schema ti (usado pela aplicação)
CREATE TABLE IF NOT EXISTS ti.comentarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chamado_id UUID NOT NULL REFERENCES ti.chamados(id) ON DELETE CASCADE,
  user_id VARCHAR(100) NOT NULL,
  comentario TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para consultas por chamado
CREATE INDEX IF NOT EXISTS idx_ti_comentarios_chamado_id ON ti.comentarios(chamado_id);
