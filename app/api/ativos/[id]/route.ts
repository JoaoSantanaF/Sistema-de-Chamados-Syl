import { NextRequest, NextResponse } from 'next/server'
import { queryOne, update, remove, query, insert } from '@/lib/db'
import { calculateNextMaintenanceDate, type Criticality } from '@/lib/maintenance-utils'

interface Ativo {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  status: string
  ultima_manutencao?: string | null
  proxima_manutencao?: string | null
}

interface AtivoResponse extends Ativo {
  ultima_manutencao?: string | null
  proxima_manutencao?: string | null
  ciclos: CicloManutencao[]
  registros: any[]
}

interface CicloManutencao {
  id: string
  ativo_id: string
  data_proxima_manutencao: string
  data_fim?: string
  status: string
  observacoes?: string
}

const CHECKLIST_PADRAO = [
  'Limpeza fisica do equipamento',
  'Troca de teclado e mouse (se necessario)',
  'Verificacao de cabos e conexoes',
  'Desfragmentacao (se necessario)',
  'Atualizacao de antivirus e Windows Update',
  'Atualizar campo "Ultima Preventiva"',
]

// GET /api/ativos/[id] - Buscar ativo por ID (com ciclos de manutencao)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const ativo = await queryOne<Ativo>('SELECT * FROM ativos WHERE id = $1', [id])

    if (!ativo) {
      return NextResponse.json({ error: 'Ativo nÃ£o encontrado' }, { status: 404 })
    }

    const ciclos = await query<CicloManutencao>(
      'SELECT * FROM ciclos_manutencao WHERE ativo_id = $1 ORDER BY data_proxima_manutencao DESC',
      [id]
    )

    const registros = await query(
      'SELECT * FROM registros_manutencao WHERE ativo_id = $1 ORDER BY data_execucao DESC',
      [id]
    )

    const ultimoRegistro = registros[0]?.data_execucao ?? ativo.ultima_manutencao ?? null
    const proximoCiclo = ciclos.find((ciclo) => ciclo.status === 'Pendente')?.data_proxima_manutencao ?? ativo.proxima_manutencao ?? null

    const response: AtivoResponse = {
      ...ativo,
      ultima_manutencao: ultimoRegistro,
      proxima_manutencao: proximoCiclo,
      ciclos,
      registros,
    }

    return NextResponse.json(response)
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
    const ativoAtual = await queryOne<Ativo>('SELECT * FROM ativos WHERE id = $1', [id])

    if (!ativoAtual) {
      return NextResponse.json({ error: 'Ativo nÃ£o encontrado' }, { status: 404 })
    }

    const updateData: Record<string, any> = {}

    if (data.nome !== undefined) updateData.nome = data.nome
    if (data.tipo !== undefined) updateData.tipo = data.tipo
    if (data.localizacao !== undefined) updateData.localizacao = data.localizacao
    if (data.criticidade !== undefined) updateData.criticidade = data.criticidade
    if (data.status !== undefined) updateData.status = data.status
    if (data.ultima_manutencao !== undefined) updateData.ultima_manutencao = data.ultima_manutencao
    if (data.proxima_manutencao !== undefined) updateData.proxima_manutencao = data.proxima_manutencao

    const isMaintenanceCompletion = data.ultima_manutencao !== undefined

    if (isMaintenanceCompletion) {
      const executionDate = new Date(`${data.ultima_manutencao}T00:00:00`)
      const criticidade = (data.criticidade ?? ativoAtual.criticidade) as Criticality
      const proximaManutencao =
        data.proxima_manutencao ?? calculateNextMaintenanceDate(criticidade, executionDate).toISOString().split('T')[0]

      updateData.ultima_manutencao = data.ultima_manutencao
      updateData.proxima_manutencao = proximaManutencao
      updateData.status = data.status ?? 'Operacional'

      const cicloPendente = data.ciclo_id
        ? await queryOne<CicloManutencao>('SELECT * FROM ciclos_manutencao WHERE id = $1 AND ativo_id = $2', [data.ciclo_id, id])
        : await queryOne<CicloManutencao>(
            "SELECT * FROM ciclos_manutencao WHERE ativo_id = $1 AND status = 'Pendente' ORDER BY data_proxima_manutencao ASC LIMIT 1",
            [id]
          )

      if (cicloPendente) {
        await update<CicloManutencao>(
          'ciclos_manutencao',
          {
            status: 'Concluído',
            data_fim: data.ultima_manutencao,
            observacoes: data.observacoes ?? cicloPendente.observacoes ?? null,
          },
          'id',
          cicloPendente.id
        )
      }

      await insert('registros_manutencao', {
        ativo_id: id,
        ciclo_id: cicloPendente?.id ?? null,
        tecnico: data.tecnico || 'Sistema',
        data_execucao: `${data.ultima_manutencao}T00:00:00.000Z`,
        status: 'Concluída',
        observacoes: data.observacoes || null,
      })

      const novoCiclo = await insert<CicloManutencao>('ciclos_manutencao', {
        ativo_id: id,
        data_proxima_manutencao: proximaManutencao,
        status: 'Pendente',
        observacoes: null,
      })

      if (novoCiclo) {
        for (const descricao of CHECKLIST_PADRAO) {
          await insert('itens_checklist', {
            ciclo_id: novoCiclo.id,
            descricao,
            concluido: false,
          })
        }
      }
    }

    if (Object.keys(updateData).length === 0) {
      return NextResponse.json({ error: 'Nenhum campo para atualizar' }, { status: 400 })
    }

    const ativo = await update<Ativo>('ativos', updateData, 'id', id)
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

    await remove('registros_manutencao', 'ativo_id', id)
    await remove('ciclos_manutencao', 'ativo_id', id)

    const deleted = await remove('ativos', 'id', id)

    if (!deleted) {
      return NextResponse.json({ error: 'Ativo nÃ£o encontrado' }, { status: 404 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Erro ao excluir ativo:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
