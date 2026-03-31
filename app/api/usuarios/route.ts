import { NextRequest, NextResponse } from 'next/server'
import { query, insert } from '@/lib/db'
import { USER_SECTORS } from '@/lib/user-sectors'
import { ensureUserSectorColumn } from '@/lib/user-sectors.server'

interface Usuario {
  id: string
  username: string
  password: string
  nome: string
  role: string
  setor?: string | null
  mustChangePassword: boolean
  created_at: string
}

// GET /api/usuarios - Listar usuários
export async function GET() {
  try {
    await ensureUserSectorColumn()

    const usuarios = await query<Usuario>(
      'SELECT id, username, nome, role, setor, created_at, must_change_password AS "mustChangePassword" FROM usuarios ORDER BY created_at DESC'
    )
    return NextResponse.json(usuarios)
  } catch (error) {
    console.error('Erro ao listar usuários:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/usuarios - Criar usuário
export async function POST(request: NextRequest) {
  try {
    await ensureUserSectorColumn()

    const data = await request.json()

    if (!data.username || !data.password) {
      return NextResponse.json({ error: 'Username e password são obrigatórios' }, { status: 400 })
    }

    const role = data.role || 'usuario'
    const setor = typeof data.setor === 'string' ? data.setor.trim() : ''
    const mustChangePassword =
      typeof data.mustChangePassword === 'boolean' ? data.mustChangePassword : role === 'usuario'

    if (!setor) {
      return NextResponse.json({ error: 'Setor e obrigatorio' }, { status: 400 })
    }

    if (!USER_SECTORS.includes(setor as (typeof USER_SECTORS)[number])) {
      return NextResponse.json({ error: 'Setor invalido' }, { status: 400 })
    }

    const usuario = await insert<Usuario>('usuarios', {
      username: data.username,
      password: data.password,
      nome: data.nome || data.username,
      role,
      setor,
      must_change_password: mustChangePassword,
      created_at: new Date().toISOString()
    })

    // Retorna sem a senha
    if (usuario) {
      const { password, must_change_password, ...userWithoutPassword } = usuario as unknown as Record<string, any>
      return NextResponse.json(
        { ...userWithoutPassword, mustChangePassword: must_change_password },
        { status: 201 }
      )
    }

    return NextResponse.json({ error: 'Erro ao criar usuário' }, { status: 500 })
  } catch (error) {
    console.error('Erro ao criar usuário:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
