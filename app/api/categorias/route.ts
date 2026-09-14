import { NextRequest, NextResponse } from 'next/server'
import { query, insert } from '@/lib/db'

export const runtime = 'nodejs'

interface Categoria {
  id: string
  nome: string
  controle: string
  icone?: string | null
  ordem: number
}

// GET /api/categorias - Lista as categorias de ativo (dirige as abas do inventário)
export async function GET() {
  try {
    const categorias = await query<Categoria>(
      'SELECT id, nome, controle, icone, ordem FROM categorias_ativo ORDER BY ordem ASC, nome ASC'
    )
    return NextResponse.json(categorias)
  } catch (error) {
    console.error('Erro ao listar categorias:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/categorias - Cria uma categoria
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    if (!data.nome) {
      return NextResponse.json({ error: 'Nome é obrigatório' }, { status: 400 })
    }

    const controle = data.controle === 'quantidade' ? 'quantidade' : 'individual'

    const categoria = await insert<Categoria>('categorias_ativo', {
      nome: data.nome,
      controle,
      icone: data.icone || null,
      ordem: Number.isFinite(data.ordem) ? data.ordem : 0,
    })

    return NextResponse.json(categoria, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar categoria:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
