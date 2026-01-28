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

// GET /api/chamados/[id] - Buscar chamado por ID
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const chamado = await queryOne<Chamado>('SELECT * FROM chamados WHERE id = $1', [id])

    if (!chamado) {
      return NextResponse.json({ error: 'Chamado não encontrado' }, { status: 404 })
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

    // Remove campos undefined/null
    const updateData: Record<string, any> = {}
    if (data.titulo !== undefined) updateData.titulo = data.titulo
    if (data.descricao !== undefined) updateData.descricao = data.descricao
    if (data.prioridade !== undefined) updateData.prioridade = data.prioridade
    if (data.status !== undefined) updateData.status = data.status
    if (data.responsavel !== undefined) updateData.responsavel = data.responsavel
    if (data.solucao !== undefined) updateData.solucao = data.solucao
    updateData.updated_at = new Date().toISOString()

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json({ error: 'Nenhum campo para atualizar' }, { status: 400 })
    }

    const chamado = await update<Chamado>('chamados', updateData, 'id', id)

    if (!chamado) {
      return NextResponse.json({ error: 'Chamado não encontrado' }, { status: 404 })
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
    const deleted = await remove('chamados', 'id', id)

    if (!deleted) {
      return NextResponse.json({ error: 'Chamado não encontrado' }, { status: 404 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Erro ao excluir chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
