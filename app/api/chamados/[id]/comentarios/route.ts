import { NextRequest, NextResponse } from 'next/server'
import { query, queryOne, insert } from '@/lib/db'

interface Comentario {
  id: string
  chamado_id: string
  user_id: string
  comentario: string
  created_at: string
}

async function ensureComentariosTable() {
  await query(`
    CREATE TABLE IF NOT EXISTS comentarios (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      chamado_id UUID NOT NULL REFERENCES chamados(id) ON DELETE CASCADE,
      user_id VARCHAR(100) NOT NULL,
      comentario TEXT NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW()
    )
  `)

  await query(`
    CREATE INDEX IF NOT EXISTS idx_comentarios_chamado_id
    ON comentarios(chamado_id)
  `)
}

// GET /api/chamados/[id]/comentarios - Lista comentarios de um chamado
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    await ensureComentariosTable()

    const chamado = await queryOne<{ id: string }>('SELECT id FROM chamados WHERE id = $1', [id])
    if (!chamado) {
      return NextResponse.json({ error: 'Chamado nao encontrado' }, { status: 404 })
    }

    const comentarios = await query<Comentario>(
      'SELECT id, chamado_id, user_id, comentario, created_at FROM comentarios WHERE chamado_id = $1 ORDER BY created_at ASC',
      [id]
    )

    return NextResponse.json(comentarios)
  } catch (error) {
    console.error('Erro ao listar comentarios:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/chamados/[id]/comentarios - Adiciona comentario em um chamado
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const data = await request.json()
    await ensureComentariosTable()

    if (!data.user_id || !String(data.user_id).trim()) {
      return NextResponse.json({ error: 'Usuario e obrigatorio' }, { status: 400 })
    }

    if (!data.comentario || !String(data.comentario).trim()) {
      return NextResponse.json({ error: 'Comentario e obrigatorio' }, { status: 400 })
    }

    const chamado = await queryOne<{ id: string }>('SELECT id FROM chamados WHERE id = $1', [id])
    if (!chamado) {
      return NextResponse.json({ error: 'Chamado nao encontrado' }, { status: 404 })
    }

    const comentario = await insert<Comentario>('comentarios', {
      chamado_id: id,
      user_id: String(data.user_id).trim(),
      comentario: String(data.comentario).trim(),
      created_at: new Date().toISOString(),
    })

    return NextResponse.json(comentario, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar comentario:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
