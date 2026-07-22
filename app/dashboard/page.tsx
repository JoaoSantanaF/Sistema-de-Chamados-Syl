"use client"

import { useCallback, useEffect, useRef, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { TicketIcon, CheckCircle2, Clock, AlertCircle, Plus } from "lucide-react"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"

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
  nome: string
}

const POLLING_INTERVAL_MS = 5000

function getLatestUpdatedAt(items: Ticket[]) {
  return items.reduce<string | null>((latest, item) => {
    if (!latest) return item.updated_at
    return new Date(item.updated_at).getTime() > new Date(latest).getTime() ? item.updated_at : latest
  }, null)
}

export default function DashboardPage() {
  const router = useRouter()
  const [user, setUser] = useState<UserSession | null>(null)
  const [tickets, setTickets] = useState<Ticket[]>([])
  const [stats, setStats] = useState({
    total: 0,
    abertos: 0,
    emAndamento: 0,
    fechados: 0,
  })
  const isFetchingRef = useRef(false)
  const pollingStateRef = useRef<{ count: number; lastUpdated: string | null }>({ count: 0, lastUpdated: null })

  const syncTicketsState = useCallback((nextTickets: Ticket[]) => {
    setTickets(nextTickets)

    const abertos = nextTickets.filter((t) => t.status === "Aberto").length
    const emAndamento = nextTickets.filter((t) => t.status === "Em andamento").length
    const fechados = nextTickets.filter((t) => t.status === "Fechado").length

    setStats({
      total: nextTickets.length,
      abertos,
      emAndamento,
      fechados,
    })

    pollingStateRef.current = {
      count: nextTickets.length,
      lastUpdated: getLatestUpdatedAt(nextTickets),
    }
  }, [])

  const loadTickets = useCallback(
    async (
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

        if (response.status === 304) return

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
    },
    [syncTicketsState],
  )

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsedUser = JSON.parse(userData) as UserSession
    setUser(parsedUser)

    void loadTickets(parsedUser)
  }, [loadTickets, router])

  useEffect(() => {
    if (!user) return

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
  }, [loadTickets, user])

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="mx-auto max-w-6xl space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
            <p className="text-muted-foreground mt-1">
              Bem-vindo, {user.nome} ({user.role === "admin" ? "Administrador" : "Usuário"})
            </p>
          </div>
          <Button asChild>
            <Link href="/chamados/novo">
              <Plus className="h-4 w-4 mr-2" />
              Novo Chamado
            </Link>
          </Button>
        </div>

        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card className="bg-card hover:shadow-md transition-shadow">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total de Chamados</CardTitle>
              <TicketIcon className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.total}</div>
              <p className="text-xs text-muted-foreground">Todos os chamados</p>
            </CardContent>
          </Card>

          <Card className="bg-card hover:shadow-md transition-shadow border-l-4 border-l-destructive">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Abertos</CardTitle>
              <AlertCircle className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-destructive">{stats.abertos}</div>
              <p className="text-xs text-muted-foreground">Aguardando atendimento</p>
            </CardContent>
          </Card>

          <Card className="bg-card hover:shadow-md transition-shadow border-l-4 border-l-warning">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Em Andamento</CardTitle>
              <Clock className="h-4 w-4 text-warning" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-warning">{stats.emAndamento}</div>
              <p className="text-xs text-muted-foreground">Sendo atendidos</p>
            </CardContent>
          </Card>

          <Card className="bg-card hover:shadow-md transition-shadow border-l-4 border-l-success">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Fechados</CardTitle>
              <CheckCircle2 className="h-4 w-4 text-success" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-success">{stats.fechados}</div>
              <p className="text-xs text-muted-foreground">Resolvidos</p>
            </CardContent>
          </Card>
        </div>

        {/* Recent Tickets */}
        <Card>
          <CardHeader>
            <CardTitle>Chamados Recentes</CardTitle>
            <CardDescription>Últimos chamados registrados no sistema</CardDescription>
          </CardHeader>
          <CardContent>
            {tickets.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                <TicketIcon className="h-12 w-12 mx-auto mb-4 opacity-50" />
                <p className="text-lg font-medium mb-1">Nenhum chamado encontrado</p>
                <p className="text-sm">Clique em "Novo Chamado" para criar o primeiro</p>
              </div>
            ) : (
              <div className="space-y-3">
                {tickets.slice(0, 5).map((ticket) => (
                  <Link key={ticket.id} href={`/chamados/${ticket.id}`}>
                    <div className="flex items-center justify-between p-4 rounded-lg border hover:bg-accent transition-colors cursor-pointer">
                      <div className="flex-1 min-w-0">
                        <p className="font-medium truncate">{ticket.titulo}</p>
                        <p className="text-sm text-muted-foreground truncate">Solicitante: {ticket.solicitante}</p>
                        <p className="text-sm text-muted-foreground truncate">
                          Técnico responsável: {ticket.responsavel || "Não atribuído"}
                        </p>
                      </div>
                      <div className="flex items-center gap-3 ml-4">
                        <span
                          className={`text-xs px-2 py-1 rounded-full font-medium ${
                            ticket.prioridade === "Alta"
                              ? "bg-destructive/10 text-destructive"
                              : ticket.prioridade === "Média"
                                ? "bg-warning/10 text-warning"
                                : "bg-success/10 text-success"
                          }`}
                        >
                          {ticket.prioridade}
                        </span>
                        <span
                          className={`text-xs px-2 py-1 rounded-full font-medium ${
                            ticket.status === "Aberto"
                              ? "bg-destructive/10 text-destructive"
                              : ticket.status === "Em andamento"
                                ? "bg-warning/10 text-warning"
                                : "bg-success/10 text-success"
                          }`}
                        >
                          {ticket.status}
                        </span>
                      </div>
                    </div>
                  </Link>
                ))}
                {tickets.length > 5 && (
                  <Button variant="outline" className="w-full bg-transparent" asChild>
                    <Link href="/chamados">Ver todos os chamados</Link>
                  </Button>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
