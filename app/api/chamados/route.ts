import { NextRequest, NextResponse } from 'next/server'
import { query, insert } from '@/lib/db'

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

// GET /api/chamados - Listar chamados
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const solicitante = searchParams.get('solicitante')
    const role = searchParams.get('role')

    let sql = 'SELECT * FROM chamados'
    const params: any[] = []

    // Se não for admin, filtra por solicitante
    if (role !== 'admin' && solicitante) {
      sql += ' WHERE solicitante = $1'
      params.push(solicitante)
    }

    sql += ' ORDER BY created_at DESC'

    const chamados = await query<Chamado>(sql, params)
    return NextResponse.json(chamados)
  } catch (error) {
    console.error('Erro ao listar chamados:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/chamados - Criar chamado
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    const chamado = await insert<Chamado>('chamados', {
      titulo: data.titulo,
      descricao: data.descricao,
      solicitante: data.solicitante,
      prioridade: data.prioridade || 'Média',
      status: 'Aberto'
    })

    return NextResponse.json(chamado, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
