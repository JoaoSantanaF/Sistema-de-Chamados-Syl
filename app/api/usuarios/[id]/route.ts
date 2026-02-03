import { NextRequest, NextResponse } from 'next/server'
import { queryOne, update, remove } from '@/lib/db'

interface Usuario {
  id: string
  username: string
  password: string
  nome: string
  role: string
  mustChangePassword: boolean
}

// GET /api/usuarios/[id] - Buscar usuário por ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const usuario = await queryOne<Usuario>(
      'SELECT id, username, nome, role, must_change_password AS "mustChangePassword" FROM usuarios WHERE id = $1',
      [id]
    )

    if (!usuario) {
      return NextResponse.json({ error: 'Usuário não encontrado' }, { status: 404 })
    }

    return NextResponse.json(usuario)
  } catch (error) {
    console.error('Erro ao buscar usuário:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// PUT /api/usuarios/[id] - Atualizar usuário
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const data = await request.json()

    const updateData: Record<string, any> = {}
    if (data.username !== undefined) updateData.username = data.username
    if (data.password !== undefined) updateData.password = data.password
    if (data.nome !== undefined) updateData.nome = data.nome
    if (data.role !== undefined) updateData.role = data.role
    if (data.mustChangePassword !== undefined) updateData.must_change_password = data.mustChangePassword

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json({ error: 'Nenhum campo para atualizar' }, { status: 400 })
    }

    const usuario = await update<Usuario>('usuarios', updateData, 'id', id)

    if (!usuario) {
      return NextResponse.json({ error: 'Usuário não encontrado' }, { status: 404 })
    }

    // Retorna sem a senha
    const { password, must_change_password, ...userWithoutPassword } = usuario as unknown as Record<string, any>
    return NextResponse.json({ ...userWithoutPassword, mustChangePassword: must_change_password })
  } catch (error) {
    console.error('Erro ao atualizar usuário:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// DELETE /api/usuarios/[id] - Excluir usuário
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const deleted = await remove('usuarios', 'id', id)

    if (!deleted) {
      return NextResponse.json({ error: 'Usuário não encontrado' }, { status: 404 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Erro ao excluir usuário:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
