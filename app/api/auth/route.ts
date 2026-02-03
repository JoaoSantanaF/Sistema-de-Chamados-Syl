import { NextRequest, NextResponse } from 'next/server'
import { query, queryOne } from '@/lib/db'

interface Usuario {
  id: string
  username: string
  password: string
  nome: string
  role: string
  mustChangePassword: boolean
}

// POST /api/auth - Login
export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json()

    if (!username || !password) {
      return NextResponse.json({ error: 'Username e password são obrigatórios' }, { status: 400 })
    }

    const user = await queryOne<Usuario>(
      'SELECT id, username, nome, role, must_change_password AS "mustChangePassword" FROM usuarios WHERE username = $1 AND password = $2',
      [username, password]
    )

    if (!user) {
      return NextResponse.json({ error: 'Credenciais inválidas' }, { status: 401 })
    }

    return NextResponse.json({
      id: user.id,
      username: user.username,
      nome: user.nome,
      role: user.role,
      mustChangePassword: user.mustChangePassword,
    })
  } catch (error) {
    console.error('Erro no login:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
