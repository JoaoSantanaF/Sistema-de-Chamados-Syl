import { NextRequest, NextResponse } from 'next/server'
import { query, queryOne } from '@/lib/db'
import { ensureUserSectorColumn } from '@/lib/user-sectors.server'

/**
 * Interface para dados de um usuário no banco de dados
 * Contém todas as informações necessárias para autenticação e sessão
 */
interface Usuario {
  id: string                    // ID único do usuário no banco de dados
  username: string              // Nome de usuário (identificador único)
  password: string              // Senha (idealmente seria hasheada em produção)
  nome: string                  // Nome completo do usuário para exibição
  role: string                  // Papel/permissão: 'admin' ou 'usuario'
  setor?: string | null         // Departamento/setor do usuário (opcional)
  mustChangePassword: boolean   // Flag indicando se usuário deve trocar senha no próximo login
}

/**
 * Handler POST para autenticação de usuários (Login)
 * 
 * Fluxo de autenticação:
 * 1. Recebe credenciais (username e password) no corpo da requisição
 * 2. Valida que ambos os campos foram fornecidos
 * 3. Busca usuário no banco com username e password
 * 4. Se encontrado: retorna dados do usuário (para armazenar em localStorage)
 * 5. Se não encontrado: retorna erro 401 (não autorizado)
 * 
 * Resposta de sucesso (200):
 *   - id: ID do usuário
 *   - username: Nome de usuário
 *   - nome: Nome completo
 *   - role: 'admin' ou 'usuario'
 *   - setor: Departamento do usuário
 *   - mustChangePassword: Flag para força mudança de senha
 * 
 * Erros possíveis:
 *   - 400: Username ou password faltando
 *   - 401: Credenciais inválidas (usuário não encontrado ou password errada)
 *   - 500: Erro interno do servidor
 */
export async function POST(request: NextRequest) {
  try {
    // Parse do corpo da requisição para extrair credenciais
    const { username, password } = await request.json()

    // Validação: ambos username e password são obrigatórios
    if (!username || !password) {
      return NextResponse.json(
        { error: 'Username e password são obrigatórios' },
        { status: 400 }
      )
    }

    // Busca usuário no banco de dados com as credenciais fornecidas
    // Usa prepared statement (parametrizado) para prevenir SQL injection
    const user = await queryOne<Usuario>(
      'SELECT id, username, nome, role, setor, must_change_password AS "mustChangePassword" FROM usuarios WHERE username = $1 AND password = $2',
      [username, password]
    )

    // Se usuário não encontrado, retorna erro de autenticação
    if (!user) {
      return NextResponse.json(
        { error: 'Credenciais inválidas' },
        { status: 401 }
      )
    }

    // Autenticação bem-sucedida: retorna dados do usuário para armazenagem em localStorage
    // Estes dados serão usados para validar requisições e filtrar dados no frontend
    return NextResponse.json({
      id: user.id,
      username: user.username,
      nome: user.nome,
      role: user.role,
      setor: user.setor,
      mustChangePassword: user.mustChangePassword,
    })
  } catch (error) {
    // Log de erro para debugging
    console.error('Erro no login:', error)
    // Retorna erro genérico 500 para não expor detalhes internos
    return NextResponse.json(
      { error: 'Erro interno do servidor' },
      { status: 500 }
    )
  }
}
