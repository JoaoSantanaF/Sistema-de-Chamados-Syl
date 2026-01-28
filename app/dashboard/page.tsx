"use client"

import { useEffect, useState } from "react"
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

export default function DashboardPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ username: string; role: string; nome: string } | null>(null)
  const [tickets, setTickets] = useState<Ticket[]>([])
  const [stats, setStats] = useState({
    total: 0,
    abertos: 0,
    emAndamento: 0,
    fechados: 0,
  })

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsedUser = JSON.parse(userData)
    setUser(parsedUser)

    loadTickets(parsedUser)
  }, [router])

  const loadTickets = async (currentUser: { username: string; role: string }) => {
    try {
      const params = new URLSearchParams({
        role: currentUser.role,
        solicitante: currentUser.username,
      })

      const response = await fetch(`/api/chamados?${params}`)
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar chamados:", data.error)
        return
      }

      const allTickets = data || []
      setTickets(allTickets)

      // Calcular estatísticas
      const abertos = allTickets.filter((t: Ticket) => t.status === "Aberto").length
      const emAndamento = allTickets.filter((t: Ticket) => t.status === "Em andamento").length
      const fechados = allTickets.filter((t: Ticket) => t.status === "Fechado").length

      setStats({
        total: allTickets.length,
        abertos,
        emAndamento,
        fechados,
      })
    } catch (err) {
      console.error("Erro ao carregar tickets:", err)
    }
  }

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="space-y-8">
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
                        <p className="text-sm text-muted-foreground truncate">{ticket.solicitante}</p>
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
