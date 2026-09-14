import { NextRequest, NextResponse } from 'next/server'
import { query, insert } from '@/lib/db'

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

// GET /api/estoque - Lista itens de estoque (controlados por quantidade)
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const categoriaId = searchParams.get('categoria_id')

    let sql =
      'SELECT id, categoria_id, nome, descricao, quantidade_total, quantidade_em_uso, quantidade_disponivel, estoque_minimo, localizacao FROM estoque_itens'
    const params: any[] = []

    if (categoriaId) {
      sql += ' WHERE categoria_id = $1'
      params.push(categoriaId)
    }

    sql += ' ORDER BY nome ASC'

    const itens = await query<EstoqueItem>(sql, params)
    return NextResponse.json(itens)
  } catch (error) {
    console.error('Erro ao listar estoque:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/estoque - Cria item de estoque
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    if (!data.nome) {
      return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 })
    }

    const total = Number.parseInt(data.quantidade_total, 10) || 0
    const emUso = Number.parseInt(data.quantidade_em_uso, 10) || 0

    if (emUso > total) {
      return NextResponse.json(
        { error: 'Quantidade em uso não pode ser maior que o total' },
        { status: 400 }
      )
    }

    const item = await insert<EstoqueItem>('estoque_itens', {
      categoria_id: data.categoria_id || null,
      nome: data.nome,
      descricao: data.descricao || null,
      quantidade_total: total,
      quantidade_em_uso: emUso,
      estoque_minimo: Number.parseInt(data.estoque_minimo, 10) || 0,
      localizacao: data.localizacao || null,
    })

    return NextResponse.json(item, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar item de estoque:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
