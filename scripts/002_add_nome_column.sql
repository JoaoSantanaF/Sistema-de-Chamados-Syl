-- Adicionar coluna nome caso não exista
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'usuarios' AND column_name = 'nome'
  ) THEN
    ALTER TABLE public.usuarios ADD COLUMN nome TEXT NOT NULL DEFAULT 'Nome do Usuário';
  END IF;
END $$;

-- Atualizar o admin com nome correto
UPDATE public.usuarios SET nome = 'Administrador' WHERE username = 'admin';
