-- Criar tabela de usuários personalizados (não confundir com auth.users)
CREATE TABLE IF NOT EXISTS public.usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  nome TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'usuario')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Criar tabela de chamados
CREATE TABLE IF NOT EXISTS public.chamados (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  solicitante TEXT NOT NULL,
  prioridade TEXT NOT NULL CHECK (prioridade IN ('Baixa', 'Média', 'Alta')),
  status TEXT NOT NULL CHECK (status IN ('Aberto', 'Em andamento', 'Fechado')),
  solucao TEXT,
  data_abertura TIMESTAMPTZ DEFAULT NOW(),
  data_fechamento TIMESTAMPTZ,
  anexo_nome TEXT,
  anexo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inserir usuário admin padrão
INSERT INTO public.usuarios (username, password, nome, role)
VALUES ('admin', '!@Vela1996', 'Administrador', 'admin')
ON CONFLICT (username) DO NOTHING;

-- Habilitar RLS
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chamados ENABLE ROW LEVEL SECURITY;

-- Políticas para tabela usuarios (somente admin pode ver/gerenciar)
CREATE POLICY "Todos podem ler usuários" ON public.usuarios FOR SELECT USING (true);
CREATE POLICY "Apenas admin pode inserir usuários" ON public.usuarios FOR INSERT WITH CHECK (true);
CREATE POLICY "Apenas admin pode atualizar usuários" ON public.usuarios FOR UPDATE USING (true);
CREATE POLICY "Apenas admin pode deletar usuários" ON public.usuarios FOR DELETE USING (true);

-- Políticas para tabela chamados (todos podem ler e criar, atualizar e deletar)
CREATE POLICY "Todos podem ler chamados" ON public.chamados FOR SELECT USING (true);
CREATE POLICY "Todos podem criar chamados" ON public.chamados FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem atualizar chamados" ON public.chamados FOR UPDATE USING (true);
CREATE POLICY "Todos podem deletar chamados" ON public.chamados FOR DELETE USING (true);
