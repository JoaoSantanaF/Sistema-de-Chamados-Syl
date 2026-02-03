import { NextRequest, NextResponse } from 'next/server'
import { queryOne, update, remove, query } from '@/lib/db'

interface Ativo {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  status: string
}

interface AtivoResponse extends Ativo {
  ultima_manutencao?: string
  proxima_manutencao?: string
  ciclos: CicloManutencao[]
  registros: any[]
}


interface CicloManutencao {
  id: string
  ativo_id: string
  data_proxima_manutencao: string
  data_conclusao?: string
  status: string
  observacoes?: string
}

// GET /api/ativos/[id] - Buscar ativo por ID (com ciclos de manutenção)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const ativo = await queryOne<Ativo>('SELECT * FROM ativos WHERE id = $1', [id])

    if (!ativo) {
      return NextResponse.json({ error: 'Ativo não encontrado' }, { status: 404 })
    }

    // Buscar ciclos de manutenção do ativo
    const ciclos = await query<CicloManutencao>(
      'SELECT * FROM ciclos_manutencao WHERE ativo_id = $1 ORDER BY data_proxima_manutencao DESC',
      [id]
    )

    // Buscar registros de manutenção
    const registros = await query(
      'SELECT * FROM registros_manutencao WHERE ativo_id = $1 ORDER BY data_execucao DESC',
      [id]
    )

    const ultimoRegistro = registros[0]?.data_execucao ?? null
    const proximoCiclo = ciclos[0]?.data_proxima_manutencao ?? null

    return NextResponse.json({
  ...ativo,
  ultima_manutencao: ultimoRegistro,
  proxima_manutencao: proximoCiclo,
  ciclos,
  registros
})
  } catch (error) {
    console.error('Erro ao buscar ativo:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// PUT /api/ativos/[id] - Atualizar ativo
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const data = await request.json()

    const updateData: Record<string, any> = {}

    if (data.nome !== undefined) updateData.nome = data.nome
    if (data.tipo !== undefined) updateData.tipo = data.tipo
    if (data.localizacao !== undefined) updateData.localizacao = data.localizacao
    if (data.criticidade !== undefined) updateData.criticidade = data.criticidade
    if (data.status !== undefined) updateData.status = data.status


    if (Object.keys(updateData).length === 0) {
      return NextResponse.json({ error: 'Nenhum campo para atualizar' }, { status: 400 })
    }

    const ativo = await update<Ativo>('ativos', updateData, 'id', id)

    if (!ativo) {
      return NextResponse.json({ error: 'Ativo não encontrado' }, { status: 404 })
    }

    return NextResponse.json(ativo)
  } catch (error) {
    console.error('Erro ao atualizar ativo:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// DELETE /api/ativos/[id] - Excluir ativo
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params

    // Primeiro remove registros relacionados
    await remove('registros_manutencao', 'ativo_id', id)
    await remove('ciclos_manutencao', 'ativo_id', id)

    const deleted = await remove('ativos', 'id', id)

    if (!deleted) {
      return NextResponse.json({ error: 'Ativo não encontrado' }, { status: 404 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Erro ao excluir ativo:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
