import { NextRequest, NextResponse } from 'next/server'
import { query, insert } from '@/lib/db'

interface Ativo {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  status: string
  ultima_manutencao?: string
  proxima_manutencao?: string
  created_at: string
}

// GET /api/ativos - Listar ativos
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const criticidade = searchParams.get('criticidade')
    const status = searchParams.get('status')

    let sql = 'SELECT * FROM ativos'
    const conditions: string[] = []
    const params: any[] = []
    let paramIndex = 1

    if (criticidade && criticidade !== 'todos') {
      conditions.push(`criticidade = $${paramIndex++}`)
      params.push(criticidade)
    }

    if (status && status !== 'todos') {
      conditions.push(`status = $${paramIndex++}`)
      params.push(status)
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ')
    }

    sql += ' ORDER BY nome ASC'

    const ativos = await query<Ativo>(sql, params)
    return NextResponse.json(ativos)
  } catch (error) {
    console.error('Erro ao listar ativos:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/ativos - Criar ativo
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    const ativo = await insert<Ativo>('ativos', {
      nome: data.nome,
      tipo: data.tipo,
      localizacao: data.localizacao,
      criticidade: data.criticidade || 'Média',
      status: data.status || 'Operacional',
      ultima_manutencao: data.ultima_manutencao || null,
      proxima_manutencao: data.proxima_manutencao || null,
      created_at: new Date().toISOString()
    })

    return NextResponse.json(ativo, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar ativo:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
