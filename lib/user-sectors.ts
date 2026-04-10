export const USER_SECTORS = [
  'Comercial',
  'Compras',
  'Comunicacao',
  'Diretoria',
  'Financeiro',
  'Fiscal',
  'General IT',
  'Juridico',
  'Logistica',
  'Manutencao',
  'PCP',
  'PeD',
  'Processos',
  'Producao',
  'Qualidade',
  'RH',
  'Seguranca',
  'SGQ',
  'Teste',
  'TI',
] as const

export type UserSector = (typeof USER_SECTORS)[number]
