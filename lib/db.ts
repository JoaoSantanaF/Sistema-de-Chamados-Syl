import { Pool } from 'pg'

// Pool de conexões PostgreSQL
// Configurado via variáveis de ambiente
const pool = new Pool({
  host: process.env.DATABASE_HOST,
  port: parseInt(process.env.DATABASE_PORT || '5432'),
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME,
})

// Schema do banco de dados
const SCHEMA = process.env.DATABASE_SCHEMA || 'ti'

// Helper para executar queries com schema ti
export async function query<T = any>(text: string, params?: any[]): Promise<T[]> {
  const client = await pool.connect()
  try {
    // Define o search_path para o schema configurado
    await client.query(`SET search_path TO ${SCHEMA}`)
    const result = await client.query(text, params)
    return result.rows as T[]
  } finally {
    client.release()
  }
}

// Helper para executar query que retorna um único resultado
export async function queryOne<T = any>(text: string, params?: any[]): Promise<T | null> {
  const rows = await query<T>(text, params)
  return rows[0] || null
}

// Helper para INSERT que retorna o registro inserido
export async function insert<T = any>(table: string, data: Record<string, any>): Promise<T | null> {
  const keys = Object.keys(data)
  const values = Object.values(data)
  const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ')
  const columns = keys.join(', ')

  const text = `INSERT INTO ${table} (${columns}) VALUES (${placeholders}) RETURNING *`
  return queryOne<T>(text, values)
}

// Helper para UPDATE
export async function update<T = any>(
  table: string,
  data: Record<string, any>,
  whereColumn: string,
  whereValue: any
): Promise<T | null> {
  const keys = Object.keys(data)
  const values = Object.values(data)
  const setClause = keys.map((key, i) => `${key} = $${i + 1}`).join(', ')

  const text = `UPDATE ${table} SET ${setClause} WHERE ${whereColumn} = $${keys.length + 1} RETURNING *`
  return queryOne<T>(text, [...values, whereValue])
}

// Helper para DELETE
export async function remove(table: string, whereColumn: string, whereValue: any): Promise<boolean> {
  const text = `DELETE FROM ${table} WHERE ${whereColumn} = $1`
  const client = await pool.connect()
  try {
    await client.query(`SET search_path TO ${SCHEMA}`)
    const result = await client.query(text, [whereValue])
    return (result.rowCount ?? 0) > 0
  } finally {
    client.release()
  }
}

export default pool
