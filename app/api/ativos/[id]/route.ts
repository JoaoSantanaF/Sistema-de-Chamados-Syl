import { NextRequest, NextResponse } from 'next/server'
import { queryOne, update, remove, query, insert } from '@/lib/db'
import { calculateNextMaintenanceDate } from '@/lib/maintenance-utils'

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

async function createPendingCycle(ativoId: string, dataProximaManutencao: string) {
  const novoCiclo = await insert<CicloManutencao>('ciclos_manutencao', {
    ativo_id: ativoId,
    data_proxima_manutencao: dataProximaManutencao,
    status: 'Pendente',
    observacoes: null,
  })

  if (!novoCiclo) return null

  for (const descricao of CHECKLIST_PADRAO) {
    await insert('itens_checklist', {
      ciclo_id: novoCiclo.id,
      descricao,
      concluido: false,
    })
  }

  return novoCiclo
}

function isPendingCycle(ciclo: CicloManutencao) {
  return ciclo.status.toLowerCase() === 'pendente'
}

// Normaliza uma data (Date que o pg retorna para colunas DATE, ou string) para
// 'YYYY-MM-DD' usando componentes locais, evitando deslocamento de fuso horario.
function toIsoDate(value: unknown): string | null {
  if (!value) return null
  if (value instanceof Date) {
    const y = value.getFullYear()
    const m = String(value.getMonth() + 1).padStart(2, '0')
    const d = String(value.getDate()).padStart(2, '0')
    return `${y}-${m}-${d}`
  }
  const match = String(value).match(/^\d{4}-\d{2}-\d{2}/)
  return match ? match[0] : null
}

async function findPendingCycle(ativoId: string, cicloId?: string | null) {
  if (cicloId) {
    const ciclo = await queryOne<CicloManutencao>(
      "SELECT * FROM ciclos_manutencao WHERE id = $1 AND ativo_id = $2 AND lower(status) = 'pendente'",
      [cicloId, ativoId]
    )

    if (ciclo) return ciclo
  }

  return queryOne<CicloManutencao>(
    "SELECT * FROM ciclos_manutencao WHERE ativo_id = $1 AND lower(status) = 'pendente' ORDER BY data_proxima_manutencao ASC LIMIT 1",
    [ativoId]
  )
}

async function completeCycle(ciclo: CicloManutencao, data: Record<string, any>) {
  const updateData = {
    status: 'Conclu\u00eddo',
    data_fim: data.ultima_manutencao,
    observacoes: data.observacoes ?? ciclo.observacoes ?? null,
  }

  try {
    return await update<CicloManutencao>('ciclos_manutencao', updateData, 'id', ciclo.id)
  } catch (error) {
    return update<CicloManutencao>(
      'ciclos_manutencao',
      { ...updateData, status: 'Conclu\u00edda' },
      'id',
      ciclo.id
    )
  }
}

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

    const ultimaManutencao = ativo.ultima_manutencao ?? registros[0]?.data_execucao ?? null
    const proximoCiclo = ciclos.find(isPendingCycle)?.data_proxima_manutencao ?? ativo.proxima_manutencao ?? null

    const response: AtivoResponse = {
      ...ativo,
      ultima_manutencao: ultimaManutencao,
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

    const isManualDateEdit = Boolean(data.manual_date_edit)
    const isMaintenanceCompletion = data.ultima_manutencao !== undefined && !isManualDateEdit

    if (isMaintenanceCompletion) {
      const executionDate = new Date(`${data.ultima_manutencao}T00:00:00`)
      const criticidade = data.criticidade ?? ativoAtual.criticidade

      const cicloPendente = await findPendingCycle(id, data.ciclo_id)

      if (cicloPendente) {
        await completeCycle(cicloPendente, data)
      }

      // Registra a execucao com a data informada e a justificativa (opcional).
      await insert('registros_manutencao', {
        ativo_id: id,
        ciclo_id: cicloPendente?.id ?? null,
        tecnico: data.tecnico || 'Sistema',
        data_execucao: `${data.ultima_manutencao}T00:00:00.000Z`,
        status: 'Conclu\u00edda',
        observacoes: data.observacoes || null,
        justificativa: data.justificativa || null,
      })

      // Datas fixas (cronograma da planilha): se ja existe um proximo ciclo
      // agendado, usa a data dele e NAO recalcula nem cria um novo ciclo.
      // Sem cronograma futuro, mantem o comportamento antigo (recalcula + cria ciclo).
      const proximoAgendado = await queryOne<CicloManutencao>(
        `SELECT * FROM ciclos_manutencao
         WHERE ativo_id = $1 AND lower(status) = 'pendente'${cicloPendente ? ' AND id <> $2' : ''}
         ORDER BY data_proxima_manutencao ASC LIMIT 1`,
        cicloPendente ? [id, cicloPendente.id] : [id]
      )

      let proximaManutencao: string | null
      if (proximoAgendado?.data_proxima_manutencao) {
        proximaManutencao = toIsoDate(proximoAgendado.data_proxima_manutencao)
      } else {
        const novaData: string =
          data.proxima_manutencao ??
          calculateNextMaintenanceDate(criticidade, executionDate).toISOString().split('T')[0]
        await createPendingCycle(id, novaData)
        proximaManutencao = novaData
      }

      updateData.ultima_manutencao = data.ultima_manutencao
      updateData.proxima_manutencao = proximaManutencao
      updateData.status = data.status ?? 'Operacional'
    }

    if (isManualDateEdit && data.proxima_manutencao !== undefined) {
      const cicloPendente = await findPendingCycle(id)

      if (cicloPendente) {
        await update<CicloManutencao>(
          'ciclos_manutencao',
          {
            data_proxima_manutencao: data.proxima_manutencao,
          },
          'id',
          cicloPendente.id
        )
      } else if (data.proxima_manutencao) {
        await createPendingCycle(id, data.proxima_manutencao)
      }
    }

    if (isManualDateEdit && data.ultima_manutencao) {
      await query(
        `UPDATE registros_manutencao
         SET data_execucao = $1
         WHERE id = (
           SELECT id
           FROM registros_manutencao
           WHERE ativo_id = $2
           ORDER BY data_execucao DESC
           LIMIT 1
         )`,
        [`${data.ultima_manutencao}T00:00:00.000Z`, id]
      )

      await query(
        `UPDATE ciclos_manutencao
         SET data_fim = $1
         WHERE id = (
           SELECT id
           FROM ciclos_manutencao
           WHERE ativo_id = $2
             AND lower(status) LIKE 'conclu%'
           ORDER BY data_fim DESC NULLS LAST, data_proxima_manutencao DESC
           LIMIT 1
         )`,
        [data.ultima_manutencao, id]
      )
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
