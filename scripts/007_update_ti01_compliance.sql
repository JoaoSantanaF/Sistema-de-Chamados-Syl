-- Script para conformidade total com TI-01 Rev.10
-- OBRIGATÓRIO: Remove checklists genéricos e implementa checklist oficial

-- Limpar itens de checklist existentes
DELETE FROM public.itens_checklist;

-- Limpar modelos de checklist existentes
DELETE FROM public.modelos_checklist;

-- Adicionar campo form_number nas tabelas para rastreamento
ALTER TABLE public.ciclos_manutencao ADD COLUMN IF NOT EXISTS form_number VARCHAR(50) DEFAULT 'Form.139';
ALTER TABLE public.registros_manutencao ADD COLUMN IF NOT EXISTS form_number VARCHAR(50) DEFAULT 'Form.139';

-- Criar o ÚNICO modelo de checklist oficial conforme TI-01 item 6.2.2
INSERT INTO public.modelos_checklist (id, nome, descricao, tipo_ativo) VALUES
('00000000-0000-0000-0000-000000000001', 'Form.139 - Plano de Manutenção Preventiva de Computadores', 'Checklist oficial conforme procedimento TI-01 Rev.10 - item 6.2.2', 'Computador');

-- Atualizar todos os ciclos de manutenção para usar o modelo oficial
UPDATE public.ciclos_manutencao 
SET modelo_id = '00000000-0000-0000-0000-000000000001',
    form_number = 'Form.139';

-- Inserir os 6 itens OBRIGATÓRIOS do checklist conforme TI-01
-- ATENÇÃO: Estes são os ÚNICOS itens permitidos, não adicionar ou modificar

INSERT INTO public.itens_checklist (ciclo_id, descricao, concluido, observacoes)
SELECT 
  cm.id,
  item.descricao,
  false,
  NULL
FROM public.ciclos_manutencao cm
CROSS JOIN (
  VALUES 
    ('Limpeza física (se a máquina estiver na produção)'),
    ('Troca de teclado e mouse, se necessário'),
    ('Verificação de cabos de energia e estabilizador'),
    ('Se apresentar lentidão, desfragmentar e otimizar o disco'),
    ('Conferir atualização de antivírus e Windows Update'),
    ('Atualizar campo "Última Preventiva"')
) AS item(descricao)
WHERE NOT EXISTS (
  SELECT 1 FROM public.itens_checklist ic WHERE ic.ciclo_id = cm.id
);

-- Adicionar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_ciclos_form_number ON public.ciclos_manutencao(form_number);
CREATE INDEX IF NOT EXISTS idx_registros_form_number ON public.registros_manutencao(form_number);
