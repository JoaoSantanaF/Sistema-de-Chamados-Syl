import { NextRequest, NextResponse } from 'next/server'
import { query, queryOne, insert, update } from '@/lib/db'

interface CicloManutencao {
  id: string
  ativo_id: string
  modelo_id: string
  data_proxima_manutencao: string
  data_conclusao?: string
  status: string
  observacoes?: string
}

interface ItemChecklist {
  id: string
  ciclo_id: string
  descricao: string
  concluido: boolean
  observacoes?: string
}

// GET /api/ciclos - Listar ciclos de manutenção
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const ativoId = searchParams.get('ativo_id')
    const status = searchParams.get('status')

    let sql = `
      SELECT c.*, a.nome as ativo_nome, a.criticidade
      FROM ciclos_manutencao c
      JOIN ativos a ON c.ativo_id = a.id
    `
    const conditions: string[] = []
    const params: any[] = []
    let paramIndex = 1

    if (ativoId) {
      conditions.push(`c.ativo_id = $${paramIndex++}`)
      params.push(ativoId)
    }

    if (status) {
      conditions.push(`c.status = $${paramIndex++}`)
      params.push(status)
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ')
    }

    sql += ' ORDER BY c.data_proxima_manutencao ASC'

    const ciclos = await query<CicloManutencao>(sql, params)
    return NextResponse.json(ciclos)
  } catch (error) {
    console.error('Erro ao listar ciclos:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/ciclos - Criar ciclo de manutenção
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    // Criar o ciclo
    const ciclo = await insert<CicloManutencao>('ciclos_manutencao', {
      ativo_id: data.ativo_id,
      modelo_id: data.modelo_id || null,
      data_proxima_manutencao: data.data_proxima_manutencao,
      status: 'Pendente',
      observacoes: data.observacoes || null
    })

    if (!ciclo) {
      return NextResponse.json({ error: 'Erro ao criar ciclo' }, { status: 500 })
    }

    // Criar itens do checklist padrão TI-01
    const checklistItems = [
      'Limpeza física do equipamento',
      'Troca de teclado e mouse (se necessário)',
      'Verificação de cabos e conexões',
      'Desfragmentação (se necessário)',
      'Atualização de antivírus e Windows Update',
      'Atualizar campo "Última Preventiva"'
    ]

    for (const descricao of checklistItems) {
      await insert('itens_checklist', {
        ciclo_id: ciclo.id,
        descricao,
        concluido: false
      })
    }

    // Buscar itens criados
    const itens = await query<ItemChecklist>(
      'SELECT * FROM itens_checklist WHERE ciclo_id = $1',
      [ciclo.id]
    )

    return NextResponse.json({ ...ciclo, itens }, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar ciclo:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// PUT /api/ciclos - Atualizar item do checklist ou ciclo
export async function PUT(request: NextRequest) {
  try {
    const data = await request.json()

    // Atualizar item do checklist
    if (data.item_id) {
      const item = await update<ItemChecklist>(
        'itens_checklist',
        { concluido: data.concluido, observacoes: data.observacoes },
        'id',
        data.item_id
      )
      return NextResponse.json(item)
    }

    // Atualizar ciclo
    if (data.ciclo_id) {
      const updateData: Record<string, any> = {}
      if (data.status !== undefined) updateData.status = data.status
      if (data.data_conclusao !== undefined) updateData.data_conclusao = data.data_conclusao
      if (data.observacoes !== undefined) updateData.observacoes = data.observacoes

      const ciclo = await update<CicloManutencao>(
        'ciclos_manutencao',
        updateData,
        'id',
        data.ciclo_id
      )
      return NextResponse.json(ciclo)
    }

    return NextResponse.json({ error: 'item_id ou ciclo_id é obrigatório' }, { status: 400 })
  } catch (error) {
    console.error('Erro ao atualizar:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
