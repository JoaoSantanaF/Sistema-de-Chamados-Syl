import { NextRequest, NextResponse } from 'next/server'
import { query, queryOne, insert } from '@/lib/db'
import { sendNewChamadoNotification } from '@/lib/email'

export const runtime = 'nodejs'

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

interface UsuarioRole {
  role: string
}

interface ChamadosMeta {
  total: number
  last_updated: string | null
}

async function isAdminUser(username: string): Promise<boolean> {
  const user = await queryOne<UsuarioRole>('SELECT role FROM usuarios WHERE username = $1', [username])
  return user?.role === 'admin'
}

async function isValidAdminResponsible(username: string): Promise<boolean> {
  const admin = await queryOne<{ username: string }>(
    'SELECT username FROM usuarios WHERE username = $1 AND role = $2',
    [username, 'admin']
  )

  return Boolean(admin)
}

// GET /api/chamados - Listar chamados
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const solicitante = searchParams.get('solicitante')
    const role = searchParams.get('role')
    const knownCount = searchParams.get('knownCount')
    const knownLastUpdated = searchParams.get('knownLastUpdated')
    const params: string[] = []
    let whereClause = ''

    // Se nao for admin, filtra por solicitante
    if (role !== 'admin' && solicitante) {
      whereClause = ' WHERE solicitante = $1'
      params.push(solicitante)
    }

    const meta = await queryOne<ChamadosMeta>(
      `SELECT COUNT(*)::int AS total, MAX(updated_at)::text AS last_updated FROM chamados${whereClause}`,
      params
    )

    const parsedKnownCount = knownCount ? Number.parseInt(knownCount, 10) : Number.NaN
    const currentLastUpdated = meta?.last_updated ? new Date(meta.last_updated).getTime() : null
    const parsedKnownLastUpdated = knownLastUpdated ? new Date(knownLastUpdated).getTime() : null

    const hasUnchangedEmptyList =
      meta?.total === 0 && Number.isFinite(parsedKnownCount) && parsedKnownCount === 0 && !knownLastUpdated
    const hasUnchangedDataset =
      Number.isFinite(parsedKnownCount) &&
      meta?.total === parsedKnownCount &&
      currentLastUpdated !== null &&
      parsedKnownLastUpdated !== null &&
      currentLastUpdated <= parsedKnownLastUpdated

    if (hasUnchangedEmptyList || hasUnchangedDataset) {
      return new NextResponse(null, { status: 304 })
    }

    const sql = `SELECT * FROM chamados${whereClause} ORDER BY created_at DESC`
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
    const actorUsername = data.actorUsername

    const insertData: Record<string, any> = {
      titulo: data.titulo,
      descricao: data.descricao,
      solicitante: data.solicitante,
      prioridade: data.prioridade || 'Média',
      status: 'Aberto'
    }

    if (data.responsavel !== undefined) {
      if (!actorUsername || !(await isAdminUser(actorUsername))) {
        return NextResponse.json(
          { error: 'Somente administradores podem definir técnico responsável' },
          { status: 403 }
        )
      }

      if (data.responsavel) {
        const isAdminResponsible = await isValidAdminResponsible(data.responsavel)
        if (!isAdminResponsible) {
          return NextResponse.json({ error: 'Técnico responsável inválido' }, { status: 400 })
        }
      }

      insertData.responsavel = data.responsavel || null
    }

    const chamado = await insert<Chamado>('chamados', insertData)

    if (chamado) {
      sendNewChamadoNotification(chamado).catch((error) => {
        console.error('Erro ao enviar aviso de novo chamado:', error)
      })
    }

    return NextResponse.json(chamado, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
