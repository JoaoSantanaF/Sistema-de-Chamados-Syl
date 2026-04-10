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

interface UserSession {
  username: string
  role: string
}

const POLLING_INTERVAL_MS = 5000

function getLatestUpdatedAt(items: Ticket[]) {
  return items.reduce<string | null>((latest, item) => {
    if (!latest) return item.updated_at
    return new Date(item.updated_at).getTime() > new Date(latest).getTime() ? item.updated_at : latest
  }, null)
}

export default function ChamadosPage() {
  const router = useRouter()
  const [user, setUser] = useState<UserSession | null>(null)
  const [tickets, setTickets] = useState<Ticket[]>([])
  const [filteredTickets, setFilteredTickets] = useState<Ticket[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("todos")
  const [priorityFilter, setPriorityFilter] = useState<string>("todos")
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")
  const [lastSyncAt, setLastSyncAt] = useState<string | null>(null)
  const isFetchingRef = useRef(false)
  const pollingStateRef = useRef<{ count: number; lastUpdated: string | null }>({ count: 0, lastUpdated: null })

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }

    const parsedUser = JSON.parse(userData) as UserSession
    setUser(parsedUser)
    void loadTickets(parsedUser)
  }, [router])

  useEffect(() => {
    filterTickets()
  }, [tickets, searchTerm, statusFilter, priorityFilter, startDate, endDate])

  useEffect(() => {
    if (!user) return
    if (user.role !== "admin") return

    const refreshTickets = () => {
      if (document.visibilityState !== "visible") return
      void loadTickets(user, { useKnownState: true })
    }

    const intervalId = window.setInterval(refreshTickets, POLLING_INTERVAL_MS)
    const handleVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        void loadTickets(user, { useKnownState: true })
      }
    }

    document.addEventListener("visibilitychange", handleVisibilityChange)

    return () => {
      window.clearInterval(intervalId)
      document.removeEventListener("visibilitychange", handleVisibilityChange)
    }
  }, [user])

  const syncTicketsState = (nextTickets: Ticket[]) => {
    setTickets(nextTickets)
    setFilteredTickets(nextTickets)
    pollingStateRef.current = {
      count: nextTickets.length,
      lastUpdated: getLatestUpdatedAt(nextTickets),
    }
    setLastSyncAt(new Date().toISOString())
  }

  const loadTickets = async (
    currentUser: UserSession,
    options?: {
      useKnownState?: boolean
    },
  ) => {
    if (isFetchingRef.current) return

    isFetchingRef.current = true

    try {
      const params = new URLSearchParams({
        role: currentUser.role,
        solicitante: currentUser.username,
      })

      if (options?.useKnownState) {
        params.set("knownCount", String(pollingStateRef.current.count))

        if (pollingStateRef.current.lastUpdated) {
          params.set("knownLastUpdated", pollingStateRef.current.lastUpdated)
        }
      }

      const response = await fetch(`/api/chamados?${params.toString()}`, {
        cache: "no-store",
      })

      if (response.status === 304) {
        setLastSyncAt(new Date().toISOString())
        return
      }

      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar chamados:", data.error)
        return
      }

      syncTicketsState(data || [])
    } catch (err) {
      console.error("Erro ao carregar tickets:", err)
    } finally {
      isFetchingRef.current = false
    }
  }

  const filterTickets = () => {
    let filtered = tickets

    if (statusFilter !== "todos") {
      filtered = filtered.filter((t) => t.status === statusFilter)
    }

    if (priorityFilter !== "todos") {
      filtered = filtered.filter((t) => t.prioridade === priorityFilter)
    }

    if (startDate) {
      filtered = filtered.filter((t) => {
        const ticketDate = new Date(t.created_at).toISOString().split("T")[0]
        return ticketDate >= startDate
      })
    }

    if (endDate) {
      filtered = filtered.filter((t) => {
        const ticketDate = new Date(t.created_at).toISOString().split("T")[0]
        return ticketDate <= endDate
      })
    }

    if (searchTerm) {
      filtered = filtered.filter(
        (t) =>
          t.titulo.toLowerCase().includes(searchTerm.toLowerCase()) ||
          t.descricao.toLowerCase().includes(searchTerm.toLowerCase()) ||
          t.solicitante.toLowerCase().includes(searchTerm.toLowerCase()) ||
          (t.responsavel || "").toLowerCase().includes(searchTerm.toLowerCase()),
      )
    }

    setFilteredTickets(filtered)
  }

  const handleDelete = async (id: string) => {
    if (!user || user.role !== "admin") {
      alert("Somente administradores podem excluir chamados")
      return
    }

    if (!confirm("Tem certeza que deseja excluir este chamado?")) return

    try {
      const params = new URLSearchParams({ actorUsername: user.username })
      const response = await fetch(`/api/chamados/${id}?${params.toString()}`, {
        method: "DELETE",
      })

      if (!response.ok) {
        const data = await response.json()
        console.error("Erro ao deletar:", data.error)
        alert("Erro ao excluir chamado")
        return
      }

      const nextTickets = tickets.filter((t) => t.id !== id)
      syncTicketsState(nextTickets)
      alert("Chamado excluído com sucesso!")
    } catch (err) {
      console.error("Erro ao deletar:", err)
      alert("Erro ao excluir chamado")
    }
  }

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="space-y-6">
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
          <Button asChild>
            <Link href="/chamados/novo">
              <Plus className="h-4 w-4 mr-2" />
              Novo Chamado
            </Link>
          </Button>
        </div>

        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col gap-4">
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Buscar por título, descrição, solicitante ou responsável..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-9"
                  />
                </div>
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
              </div>
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1">
                  <label className="text-sm text-muted-foreground mb-1.5 block">Data Inicial</label>
                  <Input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    placeholder="Data inicial"
                  />
                </div>
                <div className="flex-1">
                  <label className="text-sm text-muted-foreground mb-1.5 block">Data Final</label>
                  <Input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    placeholder="Data final"
                  />
                </div>
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

        <Card>
          <CardHeader>
            <CardTitle>Lista de Chamados ({filteredTickets.length})</CardTitle>
            <CardDescription>
              {statusFilter !== "todos" || priorityFilter !== "todos"
                ? "Mostrando chamados filtrados"
                : "Todos os chamados do sistema"}
              {user.role === "admin" &&
                lastSyncAt &&
                ` • última verificação às ${new Date(lastSyncAt).toLocaleTimeString("pt-BR")}`}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {filteredTickets.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                <p className="text-lg font-medium mb-1">Nenhum chamado encontrado</p>
                <p className="text-sm">Ajuste os filtros ou crie um novo chamado</p>
              </div>
            ) : (
              <div className="space-y-3">
                {filteredTickets.map((ticket) => (
                  <div
                    key={ticket.id}
                    className="flex items-center justify-between p-4 rounded-lg border hover:bg-accent/5 transition-colors"
                  >
                    <div className="flex-1 min-w-0 space-y-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <p className="font-medium text-foreground">{ticket.titulo}</p>
                        <span className="text-xs text-muted-foreground">#{String(ticket.id).slice(0, 8)}</span>
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
                      <p className="text-sm text-muted-foreground">Solicitante: {ticket.solicitante}</p>
                      <p className="text-sm text-muted-foreground">
                        Técnico responsável: {ticket.responsavel || "Não atribuído"}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        Aberto em: {new Date(ticket.created_at).toLocaleString("pt-BR")}
                      </p>
                      {ticket.status === "Fechado" && (
                        <p className="text-xs text-success">
                          Fechado em: {new Date(ticket.updated_at).toLocaleString("pt-BR")}
                        </p>
                      )}
                    </div>
                    <div className="flex items-center gap-3 ml-4">
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
                      <div className="flex gap-2">
                        <Button variant="outline" size="sm" asChild>
                          <Link href={`/chamados/${ticket.id}`}>
                            <Eye className="h-4 w-4" />
                          </Link>
                        </Button>
                        {user.role === "admin" && (
                          <Button variant="outline" size="sm" onClick={() => handleDelete(ticket.id)}>
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
