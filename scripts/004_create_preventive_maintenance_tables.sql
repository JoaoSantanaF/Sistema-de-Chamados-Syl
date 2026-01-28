-- Drop existing tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS public.registros_manutencao CASCADE;
DROP TABLE IF EXISTS public.itens_checklist CASCADE;
DROP TABLE IF EXISTS public.ciclos_manutencao CASCADE;
DROP TABLE IF EXISTS public.modelos_checklist CASCADE;
DROP TABLE IF EXISTS public.ativos CASCADE;

-- Create ativos (assets) table
CREATE TABLE public.ativos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  tipo VARCHAR(100) NOT NULL,
  localizacao VARCHAR(255),
  criticidade VARCHAR(10) CHECK (criticidade IN ('Alta', 'Média', 'Baixa')) DEFAULT 'Média',
  status VARCHAR(50) CHECK (status IN ('Operacional', 'Em Manutenção', 'Inativo')) DEFAULT 'Operacional',
  ultima_manutencao DATE,
  proxima_manutencao DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create modelos_checklist (checklist templates) table
CREATE TABLE public.modelos_checklist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  descricao TEXT,
  tipo_ativo VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create ciclos_manutencao (maintenance cycles) table
CREATE TABLE public.ciclos_manutencao (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ativo_id UUID NOT NULL REFERENCES public.ativos(id) ON DELETE CASCADE,
  modelo_id UUID REFERENCES public.modelos_checklist(id),
  data_proxima_manutencao DATE NOT NULL,
  data_conclusao DATE,
  status VARCHAR(20) CHECK (status IN ('Pendente', 'Em Progresso', 'Concluída', 'Vencida')) DEFAULT 'Pendente',
  observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(ativo_id, data_proxima_manutencao)
);

-- Create itens_checklist (checklist items) table
CREATE TABLE public.itens_checklist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ciclo_id UUID NOT NULL REFERENCES public.ciclos_manutencao(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  concluido BOOLEAN DEFAULT FALSE,
  observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create registros_manutencao (maintenance records) table
CREATE TABLE public.registros_manutencao (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ativo_id UUID NOT NULL REFERENCES public.ativos(id) ON DELETE CASCADE,
  ciclo_id UUID NOT NULL REFERENCES public.ciclos_manutencao(id) ON DELETE CASCADE,
  data_manutencao DATE NOT NULL,
  tecnico VARCHAR(255),
  observacoes TEXT,
  status VARCHAR(20) CHECK (status IN ('Concluída', 'Parcial', 'Falhou')) DEFAULT 'Concluída',
  chamado_id UUID,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS for all tables
ALTER TABLE public.ativos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modelos_checklist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ciclos_manutencao ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_checklist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registros_manutencao ENABLE ROW LEVEL SECURITY;

-- Policies for ativos (everyone can read and write)
CREATE POLICY "Todos podem ler ativos" ON public.ativos FOR SELECT USING (true);
CREATE POLICY "Todos podem inserir ativos" ON public.ativos FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem atualizar ativos" ON public.ativos FOR UPDATE USING (true);
CREATE POLICY "Todos podem deletar ativos" ON public.ativos FOR DELETE USING (true);

-- Policies for modelos_checklist (everyone can read and write)
CREATE POLICY "Todos podem ler modelos" ON public.modelos_checklist FOR SELECT USING (true);
CREATE POLICY "Todos podem gerenciar modelos" ON public.modelos_checklist FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem atualizar modelos" ON public.modelos_checklist FOR UPDATE USING (true);
CREATE POLICY "Todos podem deletar modelos" ON public.modelos_checklist FOR DELETE USING (true);

-- Policies for ciclos_manutencao (everyone can read and write)
CREATE POLICY "Todos podem ler ciclos" ON public.ciclos_manutencao FOR SELECT USING (true);
CREATE POLICY "Todos podem criar ciclos" ON public.ciclos_manutencao FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem atualizar ciclos" ON public.ciclos_manutencao FOR UPDATE USING (true);
CREATE POLICY "Todos podem deletar ciclos" ON public.ciclos_manutencao FOR DELETE USING (true);

-- Policies for itens_checklist (everyone can read and write)
CREATE POLICY "Todos podem ler itens" ON public.itens_checklist FOR SELECT USING (true);
CREATE POLICY "Todos podem criar itens" ON public.itens_checklist FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem atualizar itens" ON public.itens_checklist FOR UPDATE USING (true);
CREATE POLICY "Todos podem deletar itens" ON public.itens_checklist FOR DELETE USING (true);

-- Policies for registros_manutencao (everyone can read and write)
CREATE POLICY "Todos podem ler registros" ON public.registros_manutencao FOR SELECT USING (true);
CREATE POLICY "Todos podem criar registros" ON public.registros_manutencao FOR INSERT WITH CHECK (true);
CREATE POLICY "Todos podem atualizar registros" ON public.registros_manutencao FOR UPDATE USING (true);
CREATE POLICY "Todos podem deletar registros" ON public.registros_manutencao FOR DELETE USING (true);

-- Create indexes for performance
CREATE INDEX idx_ativos_criticidade ON public.ativos(criticidade);
CREATE INDEX idx_ativos_status ON public.ativos(status);
CREATE INDEX idx_ativos_proxima_manutencao ON public.ativos(proxima_manutencao);
CREATE INDEX idx_ciclos_ativo_id ON public.ciclos_manutencao(ativo_id);
CREATE INDEX idx_ciclos_status ON public.ciclos_manutencao(status);
CREATE INDEX idx_ciclos_data ON public.ciclos_manutencao(data_proxima_manutencao);
CREATE INDEX idx_itens_ciclo_id ON public.itens_checklist(ciclo_id);
CREATE INDEX idx_registros_ativo_id ON public.registros_manutencao(ativo_id);
CREATE INDEX idx_registros_ciclo_id ON public.registros_manutencao(ciclo_id);
