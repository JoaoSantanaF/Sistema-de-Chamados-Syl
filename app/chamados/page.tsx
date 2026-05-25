"use client"

import { useEffect, useRef, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Plus, Search, Filter, Trash2, Eye, FileText } from "lucide-react"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

/**
 * Interface para estrutura de dados de um chamado (ticket)
 * Representa todos os campos disponíveis para um registro de chamado
 */
interface Ticket {
  id: string
  titulo: string
  descricao: string
  solicitante: string
  prioridade: "Baixa" | "Média" | "Alta"
  status: "Aberto" | "Em andamento" | "Fechado"
  responsavel?: string
  solucao?: string
  created_at: string
  updated_at: string
}

/**
 * Interface para dados básicos da sessão do usuário
 * Armazenados no localStorage durante o login
 */
interface UserSession {
  username: string
  role: string
}

/**
 * Interface para dados de usuário administrador
 * Usado para popular dropdowns de seleção de técnicos responsáveis
 */
interface AdminUser {
  id: string
  username: string
  nome: string
}

// Intervalo em milissegundos entre verificações automáticas de novos chamados para admins
// Reduz uso de recursos enquanto mantém informações relativamente atualizadas
const POLLING_INTERVAL_MS = 5000

/**
 * Função utilitária para extrair o timestamp mais recente de atualização de um array de tickets
 * Usada para otimização de cache e detecção de alterações
 * @param items - Array de chamados a processar
 * @returns Timestamp em formato string do chamado mais recentemente atualizado, ou null se array vazio
 */
function getLatestUpdatedAt(items: Ticket[]): string | null {
  return items.reduce<string | null>((latest, item) => {
    if (!latest) return item.updated_at
    return new Date(item.updated_at).getTime() > new Date(latest).getTime() ? item.updated_at : latest
  }, null)
}

/**
 * Página principal para visualização e gerenciamento de chamados (tickets)
 * 
 * Funcionalidades:
 * - Listar chamados com visibilidade filtrada por role (admins veem todos, usuários veem seus chamados)
 * - Filtrar por status, prioridade, técnico responsável e período
 * - Busca full-text por título, descrição, solicitante ou responsável
 * - Polling automático para admins (refresh a cada 5 segundos)
 * - Exclusão de chamados (apenas admins)
 * 
 * Comportamento por role:
 * - Admin: vê TODOS os chamados, pode deletar, pode atribuir técnicos
 * - Usuário normal: vê apenas seus próprios chamados (onde solicitante = seu username)
 */
export default function ChamadosPage() {
  const router = useRouter()

  // Estado: Dados do usuário autenticado
  const [user, setUser] = useState<UserSession | null>(null)
  // Estado: Array completo de chamados carregados
  const [tickets, setTickets] = useState<Ticket[]>([])
  // Estado: Chamados após aplicação de filtros (o que é exibido na tela)
  const [filteredTickets, setFilteredTickets] = useState<Ticket[]>([])
  // Estado: Lista de administradores do sistema (para dropdown de técnicos)
  const [adminUsers, setAdminUsers] = useState<AdminUser[]>([])

  // Filtros aplicáveis
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("todos")
  const [priorityFilter, setPriorityFilter] = useState<string>("todos")
  const [responsibleFilter, setResponsibleFilter] = useState<string>("todos")
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")

  // Estado: Timestamp da última sincronização bem-sucedida com servidor
  const [lastSyncAt, setLastSyncAt] = useState<string | null>(null)

  // Ref: Previne requisições simultâneas enquanto uma já está em andamento
  const isFetchingRef = useRef(false)
  // Ref: Estado do polling - rastreia quantos tickets há e quando foram atualizados
  // Usado para otimização com resposta HTTP 304 (Not Modified)
  const pollingStateRef = useRef<{ count: number; lastUpdated: string | null }>({
    count: 0,
    lastUpdated: null,
  })

  /**
   * Efeito: Inicialização do componente (executado uma única vez no mount)
   * 1. Verifica autenticação do usuário via localStorage
   * 2. Se não autenticado, redireciona para login
   * 3. Carrega dados do usuário e lista inicial de chamados
   * 4. Carrega lista de administradores (para seletor de técnicos)
   */
  useEffect(() => {
    // Recupera dados de autenticação do localStorage (armazenados após login bem-sucedido)
    const userData = localStorage.getItem("user")
    if (!userData) {
      // Usuário não autenticado - redireciona para tela de login
      router.push("/login")
      return
    }

    // Parse dos dados do usuário autenticado
    const parsedUser = JSON.parse(userData) as UserSession
    setUser(parsedUser)

    // Carrega lista inicial de técnicos e chamados
    void loadAdminUsers()
    void loadTickets(parsedUser)
  }, [router])

  /**
   * Efeito: Reaplica filtros quando dados mudam
   * Garante que lista exibida sempre reflete os filtros ativos
   * Dependências: tickets (dados), todos os filtros (termos de busca, datas, status, etc)
   */
  useEffect(() => {
    filterTickets()
  }, [tickets, searchTerm, statusFilter, priorityFilter, responsibleFilter, startDate, endDate])

  /**
   * Efeito: Configura polling automático para admins
   * 
   * Comportamento:
   * - Admins: polling a cada 5 segundos
   * - Usuários normais: nenhum polling (não afeta performance)
   * - Ativação: listener de visibilidade da aba (só atualiza se aba está focada)
   * 
   * Otimizações:
   * - Usa `useKnownState` para enviar HTTP 304 se dados não mudaram
   * - Para ao desmontar componente ou quando user muda
   */
  useEffect(() => {
    if (!user) return
    if (user.role !== "admin") return

    // Função de refresh: verifica se aba está visível antes de fazer requisição
    const refreshTickets = () => {
      if (document.visibilityState !== "visible") return
      void loadTickets(user, { useKnownState: true })
    }

    // Configura intervalo de polling a cada 5 segundos
    const intervalId = window.setInterval(refreshTickets, POLLING_INTERVAL_MS)

    // Handler de mudança de visibilidade: atualiza imediatamente quando aba fica visível
    const handleVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        void loadTickets(user, { useKnownState: true })
      }
    }

    // Registra listener de mudança de visibilidade
    document.addEventListener("visibilitychange", handleVisibilityChange)

    // Cleanup: remove listeners e cancela intervalo ao desmontar
    return () => {
      window.clearInterval(intervalId)
      document.removeEventListener("visibilitychange", handleVisibilityChange)
    }
  }, [user])

  /**
   * Sincroniza estado de chamados com servidor
   * Atualiza o estado local e o estado de polling para tracking de cache
   * @param nextTickets - Array novo de chamados a sincronizar
   */
  const syncTicketsState = (nextTickets: Ticket[]) => {
    // Atualiza lista de chamados
    setTickets(nextTickets)
    // Nota: filtros são replicados automaticamente via useEffect de filtros
    setFilteredTickets(nextTickets)

    // Atualiza estado de polling para otimização em próxima requisição
    pollingStateRef.current = {
      count: nextTickets.length,
      lastUpdated: getLatestUpdatedAt(nextTickets),
    }

    // Registra timestamp da última sincronização bem-sucedida
    setLastSyncAt(new Date().toISOString())
  }

  /**
   * Carrega chamados do servidor com filtros baseados no role do usuário
   * 
   * Filtros aplicados por role:
   * - Admins: recebem TODOS os chamados
   * - Usuários normais: recebem apenas seus próprios chamados (WHERE solicitante = username)
   * 
   * Otimizações:
   * - Impede requisições simultâneas (isFetchingRef)
   * - Suporta caching com HTTP 304 via `useKnownState` (compara count e lastUpdated)
   * - HTTP 304 = dados não mudaram desde última sincronização
   * 
   * @param currentUser - Dados do usuário para filtros
   * @param options - Opções adicionais
   * @param options.useKnownState - Se true, envia última sincronização conhecida para cache
   */
  const loadTickets = async (
    currentUser: UserSession,
    options?: {
      useKnownState?: boolean
    },
  ) => {
    // Previne requisições simultâneas
    if (isFetchingRef.current) return

    isFetchingRef.current = true

    try {
      // Constrói parâmetros de query
      const params = new URLSearchParams({
        role: currentUser.role,
        solicitante: currentUser.username,
      })

      // Se usando caching inteligente, envia estado conhecido para comparação
      if (options?.useKnownState) {
        params.set("knownCount", String(pollingStateRef.current.count))

        if (pollingStateRef.current.lastUpdated) {
          params.set("knownLastUpdated", pollingStateRef.current.lastUpdated)
        }
      }

      // Faz requisição para servidor
      const response = await fetch(`/api/chamados?${params.toString()}`, {
        cache: "no-store",
      })

      // Se 304: dados não mudaram, não precisa fazer mais nada
      if (response.status === 304) {
        setLastSyncAt(new Date().toISOString())
        return
      }

      // Parse dos dados retornados
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar chamados:", data.error)
        return
      }

      // Sincroniza novo estado com o servidor
      syncTicketsState(data || [])
    } catch (err) {
      console.error("Erro ao carregar tickets:", err)
    } finally {
      isFetchingRef.current = false
    }
  }

  /**
   * Carrega lista de administradores do sistema
   * Usada para popular dropdown de seleção de técnicos responsáveis
   */
  const loadAdminUsers = async () => {
    try {
      const response = await fetch("/api/usuarios/admins", {
        cache: "no-store",
      })
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar técnicos:", data.error)
        return
      }

      setAdminUsers(data || [])
    } catch (err) {
      console.error("Erro ao carregar técnicos:", err)
    }
  }

  /**
   * Monta lista de opções de técnicos responsáveis para o dropdown de filtro
   * Combina lista de admins com técnicos já atribuídos a chamados existentes
   * Mantém ordem alfabética e evita duplicatas com Set
   */
  const responsibleOptions = Array.from(
    new Set([
      ...adminUsers.map((admin) => admin.username),
      ...tickets
        .map((ticket) => ticket.responsavel)
        .filter((responsavel): responsavel is string => Boolean(responsavel)),
    ]),
  ).sort((a, b) => a.localeCompare(b, "pt-BR"))

  /**
   * Obtém nome formatado do técnico responsável para exibição
   * Se encontrado na lista de admins, retorna nome + username
   * Se não encontrado, retorna apenas o username
   * @param username - Username do técnico responsável
   * @returns String formatada para exibição
   */
  const getResponsibleLabel = (username: string) => {
    const admin = adminUsers.find((item) => item.username === username)
    return admin ? `${admin.nome} (@${admin.username})` : username
  }

  /**
   * Aplica filtros à lista de chamados baseado nas seleções do usuário
   * 
   * Filtros aplicáveis:
   * 1. Status: Aberto, Em andamento, Fechado
   * 2. Prioridade: Alta, Média, Baixa
   * 3. Técnico responsável: nome específico ou sem atribuição
   * 4. Período: data inicial e data final
   * 5. Busca full-text: título, descrição, solicitante, responsável
   * 
   * Todos os filtros são combinados com AND (devem satisfazer TODOS)
   */
  const filterTickets = () => {
    // Começa com lista completa de chamados
    let filtered = tickets

    // Filtro de status: exclui chamados com status diferente do selecionado
    if (statusFilter !== "todos") {
      filtered = filtered.filter((t) => t.status === statusFilter)
    }

    // Filtro de prioridade: exclui chamados com prioridade diferente da selecionada
    if (priorityFilter !== "todos") {
      filtered = filtered.filter((t) => t.prioridade === priorityFilter)
    }

    // Filtro de técnico responsável
    if (responsibleFilter === "sem-responsavel") {
      // Se selecionado "não atribuídos": mantém apenas chamados sem responsável
      filtered = filtered.filter((t) => !t.responsavel)
    } else if (responsibleFilter !== "todos") {
      // Se técnico específico selecionado: mantém apenas seus chamados
      filtered = filtered.filter((t) => t.responsavel === responsibleFilter)
    }

    // Filtro de data inicial: exclui chamados anteriores a essa data
    if (startDate) {
      filtered = filtered.filter((t) => {
        const ticketDate = new Date(t.created_at).toISOString().split("T")[0]
        return ticketDate >= startDate
      })
    }

    // Filtro de data final: exclui chamados posteriores a essa data
    if (endDate) {
      filtered = filtered.filter((t) => {
        const ticketDate = new Date(t.created_at).toISOString().split("T")[0]
        return ticketDate <= endDate
      })
    }

    // Filtro de busca: procura termo em múltiplos campos (case-insensitive)
    if (searchTerm) {
      filtered = filtered.filter(
        (t) =>
          t.titulo.toLowerCase().includes(searchTerm.toLowerCase()) ||
          t.descricao.toLowerCase().includes(searchTerm.toLowerCase()) ||
          t.solicitante.toLowerCase().includes(searchTerm.toLowerCase()) ||
          (t.responsavel || "").toLowerCase().includes(searchTerm.toLowerCase()),
      )
    }

    // Atualiza estado de chamados filtrados
    setFilteredTickets(filtered)
  }

  /**
   * Handler para exclusão de chamado
   * Apenas administradores podem deletar chamados
   * 
   * Fluxo:
   * 1. Valida que usuário é admin
   * 2. Pede confirmação ao usuário
   * 3. Envia requisição DELETE para API
   * 4. Atualiza lista local removendo o chamado
   * 5. Mostra mensagem de sucesso
   * 
   * @param id - ID do chamado a deletar
   */
  const handleDelete = async (id: string) => {
    // Validação: apenas admins podem deletar
    if (!user || user.role !== "admin") {
      alert("Somente administradores podem excluir chamados")
      return
    }

    // Pede confirmação do usuário antes de deletar
    if (!confirm("Tem certeza que deseja excluir este chamado?")) return

    try {
      // Prepara parâmetros para identificar quem está fazendo a exclusão
      const params = new URLSearchParams({ actorUsername: user.username })

      // Faz requisição DELETE para servidor
      const response = await fetch(`/api/chamados/${id}?${params.toString()}`, {
        method: "DELETE",
      })

      if (!response.ok) {
        const data = await response.json()
        console.error("Erro ao deletar:", data.error)
        alert("Erro ao excluir chamado")
        return
      }

      // Remove chamado deletado da lista local
      const nextTickets = tickets.filter((t) => t.id !== id)
      syncTicketsState(nextTickets)

      alert("Chamado excluído com sucesso!")
    } catch (err) {
      console.error("Erro ao deletar:", err)
      alert("Erro ao excluir chamado")
    }
  }

  // Não renderiza componente enquanto aguarda dados de autenticação
  if (!user) return null

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Cabeçalho da página */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
              <FileText className="h-8 w-8" />
              Form.147 - Chamado Suporte TI
            </h1>
            <p className="text-muted-foreground mt-1">
              Conforme procedimento TI-01 Rev.10 - Sistema informatizado de registro de ocorrências
            </p>
          </div>
          {/* Botão para criar novo chamado */}
          <Button asChild>
            <Link href="/chamados/novo">
              <Plus className="h-4 w-4 mr-2" />
              Novo Chamado
            </Link>
          </Button>
        </div>

        {/* Card de filtros de busca e seleção */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col gap-4">
              {/* Primeira linha de filtros */}
              <div className="flex flex-col md:flex-row gap-4">
                {/* Busca full-text */}
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Buscar por título, descrição, solicitante ou responsável..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-9"
                  />
                </div>

                {/* Filtro de status */}
                <Select value={statusFilter} onValueChange={setStatusFilter}>
                  <SelectTrigger className="w-full md:w-[200px]">
                    <Filter className="h-4 w-4 mr-2" />
                    <SelectValue placeholder="Filtrar por status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todos">Todos os status</SelectItem>
                    <SelectItem value="Aberto">Aberto</SelectItem>
                    <SelectItem value="Em andamento">Em andamento</SelectItem>
                    <SelectItem value="Fechado">Fechado</SelectItem>
                  </SelectContent>
                </Select>

                {/* Filtro de prioridade */}
                <Select value={priorityFilter} onValueChange={setPriorityFilter}>
                  <SelectTrigger className="w-full md:w-[200px]">
                    <Filter className="h-4 w-4 mr-2" />
                    <SelectValue placeholder="Filtrar por prioridade" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todos">Todas as prioridades</SelectItem>
                    <SelectItem value="Alta">Alta</SelectItem>
                    <SelectItem value="Média">Média</SelectItem>
                    <SelectItem value="Baixa">Baixa</SelectItem>
                  </SelectContent>
                </Select>

                {/* Filtro de técnico responsável */}
                <Select value={responsibleFilter} onValueChange={setResponsibleFilter}>
                  <SelectTrigger className="w-full md:w-[240px]">
                    <Filter className="h-4 w-4 mr-2" />
                    <SelectValue placeholder="Filtrar por técnico" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="todos">Todos os técnicos</SelectItem>
                    <SelectItem value="sem-responsavel">Não atribuídos</SelectItem>
                    {responsibleOptions.map((responsavel) => (
                      <SelectItem key={responsavel} value={responsavel}>
                        {getResponsibleLabel(responsavel)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Segunda linha: filtros de data */}
              <div className="flex flex-col md:flex-row gap-4">
                {/* Data inicial */}
                <div className="flex-1">
                  <label className="text-sm text-muted-foreground mb-1.5 block">Data Inicial</label>
                  <Input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    placeholder="Data inicial"
                  />
                </div>

                {/* Data final */}
                <div className="flex-1">
                  <label className="text-sm text-muted-foreground mb-1.5 block">Data Final</label>
                  <Input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    placeholder="Data final"
                  />
                </div>

                {/* Botão de limpar datas (aparece apenas se há filtro de data ativo) */}
                {(startDate || endDate) && (
                  <div className="flex items-end">
                    <Button
                      variant="outline"
                      onClick={() => {
                        setStartDate("")
                        setEndDate("")
                      }}
                    >
                      Limpar Datas
                    </Button>
                  </div>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Card contendo lista de chamados */}
        <Card>
          <CardHeader>
            <CardTitle>Lista de Chamados ({filteredTickets.length})</CardTitle>
            <CardDescription>
              {statusFilter !== "todos" || priorityFilter !== "todos" || responsibleFilter !== "todos"
                ? "Mostrando chamados filtrados"
                : "Todos os chamados do sistema"}
              {user.role === "admin" &&
                lastSyncAt &&
                ` • última verificação às ${new Date(lastSyncAt).toLocaleTimeString("pt-BR")}`}
            </CardDescription>
          </CardHeader>

          <CardContent>
            {/* Mensagem quando não há chamados (lista vazia) */}
            {filteredTickets.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                <p className="text-lg font-medium mb-1">Nenhum chamado encontrado</p>
                <p className="text-sm">Ajuste os filtros ou crie um novo chamado</p>
              </div>
            ) : (
              // Lista de chamados
              <div className="space-y-3">
                {filteredTickets.map((ticket) => (
                  <div
                    key={ticket.id}
                    className="flex items-center justify-between p-4 rounded-lg border hover:bg-accent/5 transition-colors"
                  >
                    {/* Informações do chamado (lado esquerdo) */}
                    <div className="flex-1 min-w-0 space-y-1">
                      {/* Título + ID + Status */}
                      <div className="flex items-center gap-2 flex-wrap">
                        <p className="font-medium text-foreground">{ticket.titulo}</p>
                        <span className="text-xs text-muted-foreground">#{String(ticket.id).slice(0, 8)}</span>
                        {/* Badge de status com cores: vermelho (aberto), amarelo (em andamento), verde (fechado) */}
                        <span
                          className={`text-xs px-2.5 py-0.5 rounded-full font-medium whitespace-nowrap ${
                            ticket.status === "Aberto"
                              ? "bg-destructive/15 text-destructive border border-destructive/30"
                              : ticket.status === "Em andamento"
                                ? "bg-warning/15 text-warning border border-warning/30"
                                : "bg-success/15 text-success border border-success/30"
                          }`}
                        >
                          {ticket.status}
                        </span>
                      </div>

                      {/* Solicitante */}
                      <p className="text-sm text-muted-foreground">Solicitante: {ticket.solicitante}</p>

                      {/* Técnico responsável */}
                      <p className="text-sm text-muted-foreground">
                        Técnico responsável: {ticket.responsavel || "Não atribuído"}
                      </p>

                      {/* Data de criação */}
                      <p className="text-xs text-muted-foreground">
                        Aberto em: {new Date(ticket.created_at).toLocaleString("pt-BR")}
                      </p>

                      {/* Data de fechamento (apenas se status for Fechado) */}
                      {ticket.status === "Fechado" && (
                        <p className="text-xs text-success">
                          Fechado em: {new Date(ticket.updated_at).toLocaleString("pt-BR")}
                        </p>
                      )}
                    </div>

                    {/* Ações do chamado (lado direito) */}
                    <div className="flex items-center gap-3 ml-4">
                      {/* Badge de prioridade com cores: vermelho (alta), amarelo (média), verde (baixa) */}
                      <span
                        className={`text-xs px-3 py-1 rounded-full font-medium whitespace-nowrap ${
                          ticket.prioridade === "Alta"
                            ? "bg-destructive/10 text-destructive"
                            : ticket.prioridade === "Média"
                              ? "bg-warning/10 text-warning"
                              : "bg-success/10 text-success"
                        }`}
                      >
                        {ticket.prioridade}
                      </span>

                      {/* Botões de ação */}
                      <div className="flex gap-2">
                        {/* Botão de visualizar detalhes */}
                        <Button variant="outline" size="sm" asChild>
                          <Link href={`/chamados/${ticket.id}`}>
                            <Eye className="h-4 w-4" />
                          </Link>
                        </Button>

                        {/* Botão de deletar (apenas para admins) */}
                        {user.role === "admin" && (
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleDelete(ticket.id)}
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
