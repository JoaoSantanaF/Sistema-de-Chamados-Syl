"use client"

import { useEffect, useState } from "react"
import { useRouter, useParams } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ArrowLeft, Save, Lock, LockOpen, Trash2, MessageSquare, FileText } from "lucide-react"
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

interface Comentario {
  id: string
  user_id: string
  comentario: string
  created_at: string
}

interface AdminUser {
  id: string
  username: string
  nome: string
}

export default function ChamadoDetalhePage() {
  const router = useRouter()
  const params = useParams()
  const id = params.id as string
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [ticket, setTicket] = useState<Ticket | null>(null)
  const [adminUsers, setAdminUsers] = useState<AdminUser[]>([])
  const [formData, setFormData] = useState({
    titulo: "",
    descricao: "",
    solicitante: "",
    prioridade: "Média" as "Baixa" | "Média" | "Alta",
    status: "Aberto" as "Aberto" | "Em andamento" | "Fechado",
    responsavel: "",
    solucao: "",
  })
  const [comentarios, setComentarios] = useState<Comentario[]>([])
  const [novoComentario, setNovoComentario] = useState("")
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (id === "novo") {
      router.push("/chamados/novo")
      return
    }
  }, [id, router])

  useEffect(() => {
    if (id === "novo") return

    const loadTicket = async () => {
      const userData = localStorage.getItem("user")
      if (!userData) {
        router.push("/login")
        return
      }

      const parsedUser = JSON.parse(userData)
      setUser(parsedUser)

      try {
        if (parsedUser.role === "admin") {
          const adminResponse = await fetch("/api/usuarios/admins")
          const adminData = await adminResponse.json()
          if (adminResponse.ok) {
            setAdminUsers(adminData || [])
          }
        }

        const response = await fetch(`/api/chamados/${id}`)
        const data = await response.json()

        if (!response.ok) {
          console.error("Erro ao buscar chamado:", data.error)
          alert("Chamado não encontrado")
          router.push("/chamados")
          return
        }

        if (parsedUser.role !== "admin" && data.solicitante !== parsedUser.username) {
          alert("Você não tem permissão para acessar este chamado")
          router.push("/chamados")
          return
        }

        setTicket(data)
        setFormData({
          titulo: data.titulo,
          descricao: data.descricao,
          solicitante: data.solicitante,
          prioridade: data.prioridade,
          status: data.status,
          responsavel: data.responsavel || "",
          solucao: data.solucao || "",
        })

        await loadComentarios(data.id)
      } catch (error) {
        console.error("Erro ao buscar chamado:", error)
        alert("Erro ao carregar chamado")
        router.push("/chamados")
      } finally {
        setLoading(false)
      }
    }

    loadTicket()
  }, [router, id])

  const loadComentarios = async (chamadoId: string) => {
    try {
      const response = await fetch(`/api/chamados/${chamadoId}/comentarios`)
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar comentarios:", data.error)
        return
      }

      setComentarios(data || [])
    } catch (error) {
      console.error("Erro ao carregar comentarios:", error)
    }
  }

  const handleAddComentario = async () => {
    if (!ticket || !user || !novoComentario.trim()) return

    if (user.role !== "admin") {
      alert("Somente administradores podem adicionar comentários de andamento")
      return
    }

    try {
      const response = await fetch(`/api/chamados/${ticket.id}/comentarios`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user_id: user.username,
          comentario: novoComentario,
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao adicionar comentario:", data.error)
        alert("Erro ao adicionar comentario: " + data.error)
        return
      }

      setComentarios((prev) => [...prev, data])
      setNovoComentario("")
    } catch (error) {
      console.error("Erro ao adicionar comentario:", error)
      alert("Erro ao adicionar comentario")
    }
  }

  const handleSave = async () => {
    if (!ticket || !user) return

    if (user.role !== "admin") {
      alert("Somente administradores podem alterar chamados")
      return
    }

    try {
      const updates: Record<string, unknown> = {
        titulo: formData.titulo,
        descricao: formData.descricao,
        prioridade: formData.prioridade,
        status: formData.status,
        responsavel: formData.responsavel || null,
        actorUsername: user.username,
      }

      if (formData.status === "Fechado") {
        updates.solucao = formData.solucao
      }

      const response = await fetch(`/api/chamados/${ticket.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(updates),
      })

      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao atualizar chamado:", data.error)
        alert("Erro ao atualizar chamado: " + data.error)
        return
      }

      alert("Chamado atualizado com sucesso!")
      setTicket(data)
      setFormData({
        titulo: data.titulo,
        descricao: data.descricao,
        solicitante: data.solicitante,
        prioridade: data.prioridade,
        status: data.status,
        responsavel: data.responsavel || "",
        solucao: data.solucao || "",
      })
    } catch (error) {
      console.error("Erro ao atualizar chamado:", error)
      alert("Erro ao atualizar chamado")
    }
  }

  const handleToggleStatus = async () => {
    if (!ticket || !user) return

    if (user.role !== "admin") {
      alert("Somente administradores podem alterar o status do chamado")
      return
    }

    const newStatus =
      ticket.status === "Fechado"
        ? "Aberto"
        : ticket.status === "Aberto"
          ? "Em andamento"
          : "Fechado"

    try {
      const updates = {
        status: newStatus,
        actorUsername: user.username,
      }

      const response = await fetch(`/api/chamados/${ticket.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(updates),
      })

      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao atualizar status:", data.error)
        alert("Erro ao atualizar status: " + data.error)
        return
      }

      setTicket(data)
      setFormData((prev) => ({
        ...prev,
        status: data.status,
        solucao: data.solucao || prev.solucao,
      }))
    } catch (error) {
      console.error("Erro ao atualizar status:", error)
      alert("Erro ao atualizar status")
    }
  }

  const handleDelete = async () => {
    if (!ticket || !user) return

    if (user.role !== "admin") {
      alert("Somente administradores podem excluir chamados")
      return
    }

    if (confirm("Tem certeza que deseja excluir este chamado?")) {
      try {
        const params = new URLSearchParams({ actorUsername: user.username })
        const response = await fetch(`/api/chamados/${ticket.id}?${params.toString()}`, {
          method: "DELETE",
        })

        if (!response.ok) {
          const data = await response.json()
          console.error("Erro ao excluir chamado:", data.error)
          alert("Erro ao excluir chamado: " + data.error)
          return
        }

        router.push("/chamados")
      } catch (error) {
        console.error("Erro ao excluir chamado:", error)
        alert("Erro ao excluir chamado")
      }
    }
  }

  if (loading) return null
  if (!user || !ticket) return null

  const isAdmin = user.role === "admin"

  return (
    <DashboardLayout>
      <div className="flex justify-center">
        <div className="space-y-6 max-w-3xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Button variant="outline" size="icon" asChild>
                <Link href="/chamados">
                  <ArrowLeft className="h-4 w-4" />
                </Link>
              </Button>
              <div>
                <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
                  <FileText className="h-8 w-8" />
                  Form.147 - Chamado Suporte TI
                </h1>
                <p className="text-muted-foreground mt-1">
                  ID: #{String(ticket.id).slice(0, 8)} • Conforme TI-01 Rev.10 - Item 6.3
                </p>
              </div>
            </div>
            <div className="flex gap-2 p-3">
              {isAdmin && (
                <Button variant="outline" onClick={handleToggleStatus}>
                  {ticket.status === "Fechado" ? (
                    <>
                      <LockOpen className="h-4 w-4 mr-2" />
                      Reabrir
                    </>
                  ) : ticket.status === "Aberto" ? (
                    <>
                      <MessageSquare className="h-4 w-4 mr-2" />
                      Marcar em andamento
                    </>
                  ) : (
                    <>
                      <Lock className="h-4 w-4 mr-2" />
                      Fechar
                    </>
                  )}
                </Button>
              )}
              {isAdmin && (
                <Button variant="destructive" onClick={handleDelete}>
                  <Trash2 className="h-4 w-4 mr-2" />
                  Excluir
                </Button>
              )}
            </div>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Informações do Chamado</CardTitle>
              <CardDescription>
                Criado em {new Date(ticket.created_at).toLocaleString("pt-BR")}
                {ticket.status === "Fechado" && ` • Fechado em ${new Date(ticket.updated_at).toLocaleString("pt-BR")}`}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="titulo">Título</Label>
                <Input
                  id="titulo"
                  value={formData.titulo}
                  onChange={(e) => setFormData({ ...formData, titulo: e.target.value })}
                  readOnly={!isAdmin}
                  disabled={!isAdmin}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="descricao">Descrição</Label>
                <Textarea
                  id="descricao"
                  value={formData.descricao}
                  onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                  rows={5}
                  readOnly={!isAdmin}
                  disabled={!isAdmin}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="solicitante">Solicitante</Label>
                <Input
                  id="solicitante"
                  value={formData.solicitante}
                  readOnly
                  disabled
                />
              </div>

              {isAdmin && (
                <div className="space-y-2">
                  <Label htmlFor="responsavel">Técnico responsável</Label>
                  <Select
                    value={formData.responsavel || "sem-responsavel"}
                    onValueChange={(value) =>
                      setFormData({ ...formData, responsavel: value === "sem-responsavel" ? "" : value })
                    }
                  >
                    <SelectTrigger id="responsavel">
                      <SelectValue placeholder="Selecione um administrador" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="sem-responsavel">Não atribuído</SelectItem>
                      {adminUsers.map((admin) => (
                        <SelectItem key={admin.id} value={admin.username}>
                          {admin.nome} (@{admin.username})
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              )}

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="prioridade">Prioridade</Label>
                  <Select
                    value={formData.prioridade}
                    onValueChange={(value: "Baixa" | "Média" | "Alta") => setFormData({ ...formData, prioridade: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Baixa">Baixa</SelectItem>
                      <SelectItem value="Média">Média</SelectItem>
                      <SelectItem value="Alta">Alta</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="status">Status</Label>
                  <Select
                    value={formData.status}
                    onValueChange={(value: "Aberto" | "Em andamento" | "Fechado") =>
                      setFormData({ ...formData, status: value })
                    }
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Aberto">Aberto</SelectItem>
                      <SelectItem value="Em andamento">Em andamento</SelectItem>
                      <SelectItem value="Fechado">Fechado</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {isAdmin && formData.status === "Fechado" && (
                <div className="space-y-2">
                  <Label htmlFor="solucao">Solução Final</Label>
                  <Textarea
                    id="solucao"
                    placeholder="Descreva a solução aplicada que resolveu o problema..."
                    value={formData.solucao}
                    onChange={(e) => setFormData({ ...formData, solucao: e.target.value })}
                    rows={4}
                    className="border-green-500/50 focus:border-green-500"
                  />
                  <p className="text-xs text-muted-foreground">Este campo será salvo como solução final do chamado</p>
                </div>
              )}

              <div className="flex gap-3 pt-4">
                {isAdmin && <Button onClick={handleSave} className="flex-1">
                  <Save className="h-4 w-4 mr-2" />
                  Salvar Alterações
                </Button>}
                <Button variant="outline" asChild className="flex-1 bg-transparent">
                  <Link href="/chamados">Voltar</Link>
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MessageSquare className="h-5 w-5" />
                Histórico de Andamento
              </CardTitle>
              <CardDescription>Documentação do que foi feito ou está sendo investigado</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {comentarios.length > 0 && (
                <div className="space-y-3">
                  {comentarios.map((comentario) => (
                    <div key={comentario.id} className="p-4 border rounded-lg bg-muted/50">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-sm font-medium text-foreground">{comentario.user_id}</span>
                        <span className="text-xs text-muted-foreground">
                          {new Date(comentario.created_at).toLocaleString("pt-BR")}
                        </span>
                      </div>
                      <p className="text-sm text-foreground whitespace-pre-wrap">{comentario.comentario}</p>
                    </div>
                  ))}
                </div>
              )}

              {comentarios.length === 0 && (
                <p className="text-sm text-muted-foreground text-center py-8">
                  Nenhum comentário ainda. Adicione o primeiro comentário sobre o andamento do chamado.
                </p>
              )}

              {isAdmin && formData.status !== "Fechado" && (
                <div className="space-y-3 pt-4 border-t">
                  <Label htmlFor="novo-comentario">Adicionar Comentário de Andamento</Label>
                  <Textarea
                    id="novo-comentario"
                    placeholder="Descreva o que está sendo feito, investigado ou atualizado..."
                    value={novoComentario}
                    onChange={(e) => setNovoComentario(e.target.value)}
                    rows={3}
                  />
                  <Button onClick={handleAddComentario} disabled={!novoComentario.trim()} className="w-full">
                    <MessageSquare className="h-4 w-4 mr-2" />
                    Adicionar Comentário
                  </Button>
                </div>
              )}

              {isAdmin && formData.status === "Fechado" && (
                <p className="text-sm text-muted-foreground text-center py-4 border-t">
                  Chamado fechado. Reabra o chamado para adicionar novos comentários.
                </p>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  )
}
