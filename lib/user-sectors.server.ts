import { query } from '@/lib/db'

export async function ensureUserSectorColumn() {
  await query(`
    ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS setor VARCHAR(100)
  `)
}
