import { NextRequest, NextResponse } from 'next/server'
import { queryOne, update, remove } from '@/lib/db'

interface Chamado {
  id: string
  titulo: string
  descricao: string
  solicitante: string
  prioridade: string
  status: string
  responsavel?: string
  solucao?: string
  created_at: string
  updated_at: string
}

interface UsuarioRole {
  role: string
}

async function isAdminUser(username: string): Promise<boolean> {
  const user = await queryOne<UsuarioRole>('SELECT role FROM usuarios WHERE username = $1', [username])
  return user?.role === 'admin'
}

async function isValidAdminResponsible(username: string): Promise<boolean> {
  const admin = await queryOne<{ username: string }>(
    'SELECT username FROM usuarios WHERE username = $1 AND role = $2',
    [username, 'admin']
  )

  return Boolean(admin)
}

// GET /api/chamados/[id] - Buscar chamado por ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const chamado = await queryOne<Chamado>('SELECT * FROM chamados WHERE id = $1', [id])

    if (!chamado) {
      return NextResponse.json({ error: 'Chamado nao encontrado' }, { status: 404 })
    }

    return NextResponse.json(chamado)
  } catch (error) {
    console.error('Erro ao buscar chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// PUT /api/chamados/[id] - Atualizar chamado
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const data = await request.json()
    const actorUsername = typeof data.actorUsername === 'string' ? data.actorUsername.trim() : ''

    if (!actorUsername) {
      return NextResponse.json({ error: 'Usuario executor e obrigatorio' }, { status: 400 })
    }

    if (!(await isAdminUser(actorUsername))) {
      return NextResponse.json(
        { error: 'Somente administradores podem alterar chamados apos a abertura' },
        { status: 403 }
      )
    }

    const updateData: Record<string, any> = {}
    if (data.titulo !== undefined) updateData.titulo = data.titulo
    if (data.descricao !== undefined) updateData.descricao = data.descricao
    if (data.prioridade !== undefined) updateData.prioridade = data.prioridade
    if (data.status !== undefined) updateData.status = data.status

    if (data.responsavel !== undefined) {
      if (data.responsavel) {
        const isAdminResponsible = await isValidAdminResponsible(data.responsavel)
        if (!isAdminResponsible) {
          return NextResponse.json({ error: 'Tecnico responsavel invalido' }, { status: 400 })
        }
      }

      updateData.responsavel = data.responsavel || null
    }

    if (data.solucao !== undefined) updateData.solucao = data.solucao
    updateData.updated_at = new Date().toISOString()

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json({ error: 'Nenhum campo para atualizar' }, { status: 400 })
    }

    const chamado = await update<Chamado>('chamados', updateData, 'id', id)

    if (!chamado) {
      return NextResponse.json({ error: 'Chamado nao encontrado' }, { status: 404 })
    }

    return NextResponse.json(chamado)
  } catch (error) {
    console.error('Erro ao atualizar chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// DELETE /api/chamados/[id] - Excluir chamado
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const actorUsername = request.nextUrl.searchParams.get('actorUsername')?.trim()

    if (!actorUsername) {
      return NextResponse.json({ error: 'Usuario executor e obrigatorio' }, { status: 400 })
    }

    if (!(await isAdminUser(actorUsername))) {
      return NextResponse.json({ error: 'Somente administradores podem excluir chamados' }, { status: 403 })
    }

    const deleted = await remove('chamados', 'id', id)

    if (!deleted) {
      return NextResponse.json({ error: 'Chamado nao encontrado' }, { status: 404 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Erro ao excluir chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
