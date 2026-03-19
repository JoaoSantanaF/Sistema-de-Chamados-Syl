-- First, insert checklist templates
INSERT INTO ti.modelos_checklist (nome, descricao, tipo_ativo) VALUES
  ('Manutenção de Computador', 'Checklist padrão para manutenção preventiva de computadores e notebooks', 'Computador'),
  ('Manutenção de Impressora', 'Checklist padrão para manutenção preventiva de impressoras', 'Impressora'),
  ('Manutenção de Equipamento Industrial', 'Checklist padrão para manutenção preventiva de equipamentos industriais', 'Equipamento')
ON CONFLICT DO NOTHING;

-- Insert all equipment with their criticality levels
-- Criticidade Alta = 30 dias
INSERT INTO ti.ativos (nome, tipo, criticidade, localizacao, status, proxima_manutencao) VALUES
  ('CARIMBADEIRA', 'Equipamento', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('EMBALAGEM ZEBRA1', 'Impressora', 'Alta', 'Embalagem', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('EMBALAGEMZEBRA2', 'Impressora', 'Alta', 'Embalagem', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('EMBALAGEM990', 'Impressora', 'Alta', 'Embalagem', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('REBITADEIRA390', 'Equipamento', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('COLA', 'Equipamento', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('PREPRENSA', 'Equipamento', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('RETIFICA', 'Equipamento', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('ACESSORIOS', 'Equipamento', 'Alta', 'Almoxarifado', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('RECEBIMENTOTHINK', 'Computador', 'Alta', 'Recebimento', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('SAPATACARIM', 'Equipamento', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('ALMOXARIFADO', 'Computador', 'Alta', 'Almoxarifado', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('GABRIELLITHINK', 'Computador', 'Alta', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('MANUTENCAOPI', 'Computador', 'Alta', 'Manutenção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('MANUTENCAO02', 'Computador', 'Alta', 'Manutenção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('FERRAMENTASDELL', 'Computador', 'Alta', 'Ferramentaria', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('SAPATADELL790', 'Computador', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days'),
  ('SAPATA5070', 'Computador', 'Alta', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '30 days')
ON CONFLICT DO NOTHING;

-- Criticidade Média = 60 dias
INSERT INTO ti.ativos (nome, tipo, criticidade, localizacao, status, proxima_manutencao) VALUES
  ('SAPATA-RFID', 'Computador', 'Média', 'Produção', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('EXPEDICAO', 'Computador', 'Média', 'Expedição', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('ROGERIOTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('LOGISTICA03', 'Computador', 'Média', 'Logística', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('RICARDOTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('LOGISTICA-RECEB', 'Computador', 'Média', 'Logística', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('VALMIR', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('LEONARDOTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('ROCHATHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('OTAVIOTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('JONASTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('AMABILYTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('ENCARREGADOSTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('DRÁUSIOTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('CLAUDINEITHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('SILVIATHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('LUIZ-PROCESSOS', 'Computador', 'Média', 'Processos', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('DOUGLASTHINK', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days'),
  ('NICOLEDELL3050', 'Computador', 'Média', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '60 days')
ON CONFLICT DO NOTHING;

-- Criticidade Baixa = 180 dias
INSERT INTO ti.ativos (nome, tipo, criticidade, localizacao, status, proxima_manutencao) VALUES
  ('EDNATHINK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('ARIANITHINK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('ERICATHINK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('AMANDATHINK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('CAROLINETHINK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('LEONARDOTHINK_2', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('LETICIATHINK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('THAUANNYNOTE', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days'),
  ('FLAVIATHIMK', 'Computador', 'Baixa', 'Escritório', 'Operacional', CURRENT_DATE + INTERVAL '180 days')
ON CONFLICT DO NOTHING;
