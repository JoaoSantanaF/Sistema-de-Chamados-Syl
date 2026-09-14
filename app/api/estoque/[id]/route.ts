import { NextRequest, NextResponse } from 'next/server'
import { queryOne, update, remove } from '@/lib/db'

export const runtime = 'nodejs'

interface EstoqueItem {
  id: string
  categoria_id: string | null
  nome: string
  descricao?: string | null
  quantidade_total: number
  quantidade_em_uso: number
  quantidade_disponivel: number
  estoque_minimo: number
  localizacao?: string | null
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const item = await queryOne<EstoqueItem>('SELECT * FROM estoque_itens WHERE id = $1', [id])
    if (!item) {
      return NextResponse.json({ error: 'Item não encontrado' }, { status: 404 })
    }
    return NextResponse.json(item)
  } catch (error) {
    console.error('Erro ao buscar item de estoque:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const data = await request.json()

    const itemAtual = await queryOne<EstoqueItem>('SELECT * FROM estoque_itens WHERE id = $1', [id])
    if (!itemAtual) {
      return NextResponse.json({ error: 'Item não encontrado' }, { status: 404 })
    }

    const updateData: Record<string, any> = {}

    if (data.nome !== undefined) updateData.nome = data.nome
    if (data.categoria_id !== undefined) updateData.categoria_id = data.categoria_id || null
    if (data.descricao !== undefined) updateData.descricao = data.descricao || null
    if (data.localizacao !== undefined) updateData.localizacao = data.localizacao || null
    if (data.estoque_minimo !== undefined) updateData.estoque_minimo = Number.parseInt(data.estoque_minimo, 10) || 0

    const total = data.quantidade_total !== undefined ? Number.parseInt(data.quantidade_total, 10) : itemAtual.quantidade_total
    const emUso = data.quantidade_em_uso !== undefined ? Number.parseInt(data.quantidade_em_uso, 10) : itemAtual.quantidade_em_uso

    if (emUso > total) {
      return NextResponse.json(
        { error: 'Quantidade em uso não pode ser maior que o total' },
        { status: 400 }
      )
    }

    if (data.quantidade_total !== undefined) updateData.quantidade_total = total
    if (data.quantidade_em_uso !== undefined) updateData.quantidade_em_uso = emUso

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json({ error: 'Nenhum campo para atualizar' }, { status: 400 })
    }

    const item = await update<EstoqueItem>('estoque_itens', updateData, 'id', id)
    return NextResponse.json(item)
  } catch (error) {
    console.error('Erro ao atualizar item de estoque:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const deleted = await remove('estoque_itens', 'id', id)
    if (!deleted) {
      return NextResponse.json({ error: 'Item não encontrado' }, { status: 404 })
    }
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Erro ao excluir item de estoque:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
