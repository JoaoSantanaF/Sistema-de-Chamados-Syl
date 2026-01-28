-- Script para gerar os primeiros ciclos de manutenção para todos os ativos existentes
-- Isso garante que todos os ativos tenham um ciclo de manutenção ativo

-- Para cada ativo, criar um ciclo de manutenção se não existir
INSERT INTO public.ciclos_manutencao (ativo_id, data_proxima_manutencao, status)
SELECT 
  a.id,
  a.proxima_manutencao,
  'Pendente'
FROM public.ativos a
WHERE NOT EXISTS (
  SELECT 1 FROM public.ciclos_manutencao c 
  WHERE c.ativo_id = a.id AND c.status IN ('Pendente', 'Em Progresso')
)
ON CONFLICT (ativo_id, data_proxima_manutencao) DO NOTHING;

-- Adicionar itens de checklist padrão para cada ciclo criado
-- Computadores
INSERT INTO public.itens_checklist (ciclo_id, descricao)
SELECT 
  c.id,
  item.descricao
FROM public.ciclos_manutencao c
JOIN public.ativos a ON a.id = c.ativo_id
CROSS JOIN (
  VALUES 
    ('Limpeza física externa'),
    ('Limpeza física interna (ventiladores, dissipadores)'),
    ('Verificação de cabos e conexões'),
    ('Atualização de sistema operacional'),
    ('Verificação de antivírus'),
    ('Teste de performance'),
    ('Backup de dados importantes')
) AS item(descricao)
WHERE a.tipo = 'Computador' 
  AND NOT EXISTS (SELECT 1 FROM public.itens_checklist WHERE ciclo_id = c.id);

-- Impressoras
INSERT INTO public.itens_checklist (ciclo_id, descricao)
SELECT 
  c.id,
  item.descricao
FROM public.ciclos_manutencao c
JOIN public.ativos a ON a.id = c.ativo_id
CROSS JOIN (
  VALUES 
    ('Limpeza de cabeças de impressão'),
    ('Verificação de níveis de tinta/toner'),
    ('Limpeza de rolos'),
    ('Teste de impressão'),
    ('Verificação de conexão de rede'),
    ('Atualização de firmware')
) AS item(descricao)
WHERE a.tipo = 'Impressora' 
  AND NOT EXISTS (SELECT 1 FROM public.itens_checklist WHERE ciclo_id = c.id);

-- Equipamentos
INSERT INTO public.itens_checklist (ciclo_id, descricao)
SELECT 
  c.id,
  item.descricao
FROM public.ciclos_manutencao c
JOIN public.ativos a ON a.id = c.ativo_id
CROSS JOIN (
  VALUES 
    ('Inspeção visual geral'),
    ('Lubrificação de partes móveis'),
    ('Verificação de sensores'),
    ('Teste de funcionamento'),
    ('Limpeza geral'),
    ('Ajuste de calibração')
) AS item(descricao)
WHERE a.tipo = 'Equipamento' 
  AND NOT EXISTS (SELECT 1 FROM public.itens_checklist WHERE ciclo_id = c.id);
