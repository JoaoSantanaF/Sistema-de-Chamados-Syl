import { query } from '@/lib/db'

// Garante que a coluna de justificativa exista em registros_manutencao.
// Necessario para ambientes onde o script 011 ainda nao foi aplicado, evitando
// erro 500 ao concluir manutencao. Memoriza o resultado para nao rodar DDL a cada chamada.
let ensured: Promise<void> | null = null

export function ensureJustificativaColumn(): Promise<void> {
  if (!ensured) {
    ensured = query(`
      ALTER TABLE registros_manutencao
      ADD COLUMN IF NOT EXISTS justificativa TEXT
    `)
      .then(() => undefined)
      .catch((error) => {
        // Reseta o cache para tentar de novo na proxima chamada em caso de falha.
        ensured = null
        throw error
      })
  }
  return ensured
}
