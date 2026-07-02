import { NextRequest, NextResponse } from 'next/server'
import { query, queryOne, insert } from '@/lib/db'
import { sendNewChamadoNotification } from '@/lib/email'

export const runtime = 'nodejs'

/**
 * Interface que representa um chamado (ticket) no sistema
 * Contém todos os campos principais de um registro de chamado
 */
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

/**
 * Interface para dados de um usuário com informação de role (papel)
 * Usado para verificar se usuário tem permissões de admin
 */
interface UsuarioRole {
  role: string
}

/**
 * Interface para metadados de chamados
 * Usado para otimização de cache e polling
 */
interface ChamadosMeta {
  total: number
  last_updated: string | null
}

/**
 * Verifica se um usuário é administrador do sistema
 * @param username - Nome de usuário a verificar
 * @returns true se o usuário tem role 'admin', false caso contrário
 */
async function isAdminUser(username: string): Promise<boolean> {
  const user = await queryOne<UsuarioRole>('SELECT role FROM usuarios WHERE username = $1', [username])
  return user?.role === 'admin'
}

/**
 * Verifica se um usuário é admin válido e pode ser atribuído como técnico responsável
 * @param username - Nome de usuário a verificar
 * @returns true se usuário existe e tem role 'admin', false caso contrário
 */
async function isValidAdminResponsible(username: string): Promise<boolean> {
  const admin = await queryOne<{ username: string }>(
    'SELECT username FROM usuarios WHERE username = $1 AND role = $2',
    [username, 'admin']
  )

  return Boolean(admin)
}

/**
 * Verifica se um usuário existe no sistema
 * Esta é uma validação essencial para garantir que apenas usuários válidos possam criar ou ser solicitantes de chamados
 * @param username - Nome de usuário a verificar
 * @returns true se o usuário existe na tabela usuarios, false caso contrário
 */
async function isValidUser(username: string): Promise<boolean> {
  const user = await queryOne<{ username: string }>(
    'SELECT username FROM usuarios WHERE username = $1',
    [username]
  )
  return Boolean(user)
}

/**
 * Monta a URL base (protocolo + host) a partir da requisicao real, usando os
 * headers definidos pelo reverse proxy (x-forwarded-proto / x-forwarded-host)
 * com fallback para o header Host. Garante que o link do email aponte para o
 * mesmo endereco por onde o sistema foi acessado, evitando esquema errado.
 */
function resolveRequestBaseUrl(request: NextRequest): string | null {
  const host = request.headers.get('x-forwarded-host') || request.headers.get('host')
  if (!host) return null
  const proto =
    request.headers.get('x-forwarded-proto') ||
    request.nextUrl.protocol.replace(':', '') ||
    'http'
  return `${proto}://${host}`
}


// GET /api/chamados - Listar chamados
/**
 * Handler GET para listar chamados com filtros inteligentes
 * 
 * Comportamento:
 * - Admins: veem TODOS os chamados
 * - Usuários normais: veem apenas seus próprios chamados (onde solicitante = username)
 * 
 * Suporta polling otimizado com HTTP 304 (Not Modified) quando dados não mudaram
 * 
 * Query Parameters:
 * - solicitante: nome do usuário (do localStorage)
 * - role: papel do usuário (admin ou usuario)
 * - knownCount: quantidade de chamados conhecida na última sync
 * - knownLastUpdated: timestamp da última atualização conhecida
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const solicitante = searchParams.get('solicitante')
    const role = searchParams.get('role')
    const knownCount = searchParams.get('knownCount')
    const knownLastUpdated = searchParams.get('knownLastUpdated')
    const params: string[] = []
    let whereClause = ''

    // Filtro de visibilidade: usuários normais só veem seus próprios chamados
    // Admins veem todos os chamados do sistema
    if (role !== 'admin' && solicitante) {
      whereClause = ' WHERE solicitante = $1'
      params.push(solicitante)
    }

    // Busca metadados para otimização de cache
    const meta = await queryOne<ChamadosMeta>(
      `SELECT COUNT(*)::int AS total, MAX(updated_at)::text AS last_updated FROM chamados${whereClause}`,
      params
    )

    // Converte timestamps para comparação
    const parsedKnownCount = knownCount ? Number.parseInt(knownCount, 10) : Number.NaN
    const currentLastUpdated = meta?.last_updated ? new Date(meta.last_updated).getTime() : null
    const parsedKnownLastUpdated = knownLastUpdated ? new Date(knownLastUpdated).getTime() : null

    // Verifica se dados não mudaram desde última sincronização
    const hasUnchangedEmptyList =
      meta?.total === 0 && Number.isFinite(parsedKnownCount) && parsedKnownCount === 0 && !knownLastUpdated
    const hasUnchangedDataset =
      Number.isFinite(parsedKnownCount) &&
      meta?.total === parsedKnownCount &&
      currentLastUpdated !== null &&
      parsedKnownLastUpdated !== null &&
      currentLastUpdated <= parsedKnownLastUpdated

    // Retorna 304 Not Modified se cliente já tem dados atuais
    if (hasUnchangedEmptyList || hasUnchangedDataset) {
      return new NextResponse(null, { status: 304 })
    }

    // Busca e retorna lista completa de chamados
    const sql = `SELECT * FROM chamados${whereClause} ORDER BY created_at DESC`
    const chamados = await query<Chamado>(sql, params)
    return NextResponse.json(chamados)
  } catch (error) {
    console.error('Erro ao listar chamados:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}

// POST /api/chamados - Criar chamado
/**
 * Handler POST para criação de novo chamado
 * 
 * Validações executadas:
 * 1. O campo 'solicitante' deve ser um usuário válido existente no sistema
 * 2. Se definir 'responsavel', apenas admins podem fazer isso
 * 3. O 'responsavel' (se definido) deve ser um admin válido
 * 
 * Fluxo:
 * 1. Recebe dados do chamado no corpo da requisição
 * 2. Valida existência do usuário solicitante
 * 3. Se admin, valida permissões e responsável
 * 4. Insere na tabela chamados
 * 5. Envia notificação de novo chamado por email
 * 
 * @returns Objeto do chamado criado com ID gerado
 */
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()
    const actorUsername = data.actorUsername

    // VALIDAÇÃO 1: Verifica se o usuário solicitante existe no sistema
    // Isso garante que apenas usuários válidos podem ser solicitantes
    const isValidSolicitante = await isValidUser(data.solicitante)
    if (!isValidSolicitante) {
      return NextResponse.json(
        { error: `Usuário solicitante '${data.solicitante}' não existe no sistema` },
        { status: 400 }
      )
    }

    // Prepara dados para inserção no banco
    const insertData: Record<string, any> = {
      titulo: data.titulo,
      descricao: data.descricao,
      solicitante: data.solicitante,
      prioridade: data.prioridade || 'Média',
      status: 'Aberto'
    }

    // VALIDAÇÃO 2: Verifica permissões para atribuição de técnico responsável
    // Apenas admins podem definir quem é o técnico responsável de um chamado
    if (data.responsavel !== undefined) {
      if (!actorUsername || !(await isAdminUser(actorUsername))) {
        return NextResponse.json(
          { error: 'Somente administradores podem definir técnico responsável' },
          { status: 403 }
        )
      }

      // VALIDAÇÃO 3: Valida se o técnico responsável é um admin válido
      if (data.responsavel) {
        const isAdminResponsible = await isValidAdminResponsible(data.responsavel)
        if (!isAdminResponsible) {
          return NextResponse.json({ error: 'Técnico responsável inválido' }, { status: 400 })
        }
      }

      insertData.responsavel = data.responsavel || null
    }

    // Insere o chamado no banco de dados
    const chamado = await insert<Chamado>('chamados', insertData)

    // Envia notificação por email para administradores.
    // Passa a URL base derivada da requisição para o link apontar para o
    // endereço/protocolo reais por onde o sistema foi acessado.
    if (chamado) {
      const baseUrl = resolveRequestBaseUrl(request)
      sendNewChamadoNotification(chamado, baseUrl).catch((error) => {
        console.error('Erro ao enviar aviso de novo chamado:', error)
      })
    }

    // Retorna o chamado criado com status 201 (Created)
    return NextResponse.json(chamado, { status: 201 })
  } catch (error) {
    console.error('Erro ao criar chamado:', error)
    return NextResponse.json({ error: 'Erro interno do servidor' }, { status: 500 })
  }
}
