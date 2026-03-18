import { NextResponse } from 'next/server'
import { query } from '@/lib/db'

interface UsuarioAdmin {
  id: string
  username: string
  nome: string
}

// GET /api/usuarios/admins - Lista técnicos disponíveis (admins)
export async function GET() {
  try {
    const admins = await query<UsuarioAdmin>(
      'SELECT id, username, nome FROM usuarios WHERE role = $1 ORDER BY nome ASC',
      ['admin']
    )

    return NextResponse.json(admins)
  } catch (error) {
    console.error('Erro ao listar administradores:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
