"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ArrowLeft, FileText } from "lucide-react"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"

/**
 * Interface para dados de usuário administrador
 * Usado ao listar admins disponíveis para atribuição como técnico responsável
 */
interface AdminUser {
  id: string
  username: string
  nome: string
}

/**
 * Interface para dados do formulário de novo chamado
 * Centraliza todos os campos que podem ser editados
 */
interface FormData {
  titulo: string
  descricao: string
  solicitante: string
  prioridade: "Baixa" | "Média" | "Alta"
  responsavel: string
}

/**
 * Página para criação de novo chamado (ticket)
 * Segue o padrão Form.147 conforme procedimento TI-01
 * 
 * Comportamento por tipo de usuário:
 * - Usuários normais: campo "solicitante" é bloqueado (mostra apenas seu username)
 * - Admins: campo "solicitante" é editável + acesso a seletor de técnico responsável
 */
export default function NovoChamadoPage() {
  const router = useRouter()
  // Estado do usuário atual logado
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  // Lista de administradores disponíveis para atribuição como técnico responsável
  const [adminUsers, setAdminUsers] = useState<AdminUser[]>([])
  // Dados do formulário sendo editados
  const [formData, setFormData] = useState<FormData>({
    titulo: "",
    descricao: "",
    solicitante: "",
    prioridade: "Média",
    responsavel: "",
  })
  // Indica se requisição de criação está em progresso
  const [loading, setLoading] = useState(false)

  /**
   * Efeito: Inicialização do componente
   * 1. Verifica se usuário está autenticado (via localStorage)
   * 2. Se não estiver autenticado, redireciona para login
   * 3. Carrega dados do usuário (nome, role)
   * 4. Pré-carrega lista de administradores (se for admin)
   */
  useEffect(() => {
    // Recupera dados de autenticação do localStorage
    const userData = localStorage.getItem("user")
    if (!userData) {
      // Usuário não autenticado - redireciona para login
      router.push("/login")
      return
    }

    // Parse dos dados do usuário autenticado
    const parsedUser = JSON.parse(userData)
    setUser(parsedUser)

    // Pré-popula campo de solicitante com username do usuário logado
    // Este valor será: bloqueado para usuários normais, editável para admins
    setFormData((prev) => ({ ...prev, solicitante: parsedUser.username }))

    // Se usuário é admin, carrega lista de administradores para seleção de responsável
    if (parsedUser.role === "admin") {
      loadAdminUsers()
    }
  }, [router])

  /**
   * Carrega lista de administradores do sistema
   * Usada para popular o seletor de "Técnico responsável"
   * Apenas admins veem este campo
   */
  const loadAdminUsers = async () => {
    try {
      const response = await fetch("/api/usuarios/admins")
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar administradores:", data.error)
        return
      }

      setAdminUsers(data || [])
    } catch (error) {
      console.error("Erro ao carregar administradores:", error)
    }
  }

  /**
   * Handler de submissão do formulário
   * 
   * Fluxo:
   * 1. Valida que usuário está autenticado
   * 2. Prepara payload de envio
   * 3. Se admin: adiciona informações extras (actorUsername e responsável)
   * 4. Envia para API /api/chamados
   * 5. Em caso de erro: mostra mensagem e permanece na página
   * 6. Em caso de sucesso: redireciona para lista de chamados
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    // Validação de segurança: garante que usuário está autenticado
    if (!user) return

    // Ativa indicador de carregamento
    setLoading(true)

    try {
      // Prepara dados básicos do chamado a enviar
      const payload: Record<string, any> = {
        titulo: formData.titulo,
        descricao: formData.descricao,
        solicitante: formData.solicitante,
        prioridade: formData.prioridade,
        anexo_url: null,
      }

      // Se usuário é admin, adiciona dados extras
      if (user.role === "admin") {
        // actorUsername identifica quem (admin) está criando o chamado
        payload.actorUsername = user.username
        // Técnico responsável para este chamado (preenchimento opcional)
        payload.responsavel = formData.responsavel || null
      }

      // Envia requisição para criar chamado
      const response = await fetch("/api/chamados", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      })

      // Parse da resposta
      const data = await response.json()

      // Verifica status da resposta
      if (!response.ok) {
        console.error("Erro ao criar chamado:", data.error)
        alert("Erro ao criar chamado: " + data.error)
        return
      }

      // Sucesso: redireciona para lista de chamados
      router.push("/chamados")
    } catch (error) {
      console.error("Erro ao criar chamado:", error)
      alert("Erro ao criar chamado")
    } finally {
      // Desativa indicador de carregamento
      setLoading(false)
    }
  }

  // Não renderiza enquanto aguarda carregamento de dados de autenticação
  if (!user) return null

  return (
    <DashboardLayout>
      <div className="mx-auto max-w-3xl">
        <div className="space-y-6">
          {/* Cabeçalho da página com título e navegação */}
          <div className="flex items-center gap-4">
            {/* Botão de voltar para lista de chamados */}
            <Button variant="outline" size="icon" asChild>
              <Link href="/chamados">
                <ArrowLeft className="h-4 w-4" />
              </Link>
            </Button>

            {/* Informações da página */}
            <div>
              <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
                <FileText className="h-8 w-8" />
                Form.147 – Chamado Suporte TI
              </h1>
              <p className="text-muted-foreground mt-1">
                Abertura de novo chamado • Conforme TI-01 Rev.10 - Item 6.3.1
              </p>
            </div>
          </div>

          {/* Card contendo o formulário */}
          <Card>
            <CardHeader>
              <CardTitle>Informações do Chamado</CardTitle>
              <CardDescription>
                Todos os campos marcados com * são obrigatórios • Campos: Data, Setor, Usuário, Descrição do problema
              </CardDescription>
            </CardHeader>

            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Campo: Título do chamado (obrigatório) */}
                <div className="space-y-2">
                  <Label htmlFor="titulo">Título *</Label>
                  <Input
                    id="titulo"
                    placeholder="Ex: Problema com impressora"
                    value={formData.titulo}
                    onChange={(e) => setFormData({ ...formData, titulo: e.target.value })}
                    required
                  />
                </div>

                {/* Campo: Descrição detalhada do problema (obrigatório) */}
                <div className="space-y-2">
                  <Label htmlFor="descricao">Descrição do Problema *</Label>
                  <Textarea
                    id="descricao"
                    placeholder="Descreva o problema em detalhes..."
                    value={formData.descricao}
                    onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                    rows={5}
                    required
                  />
                </div>

                {/* Campo: Usuário/Solicitante (obrigatório)
                    - Usuários normais: BLOQUEADO (somente leitura)
                    - Admins: EDITÁVEL (podem criar chamado em nome de outro usuário)
                    
                    Importante: O backend valida que este usuário existe no sistema
                    antes de permitir a criação do chamado */}
                <div className="space-y-2">
                  <Label htmlFor="solicitante">Usuário/Solicitante *</Label>
                  <Input
                    id="solicitante"
                    value={formData.solicitante}
                    onChange={(e) => setFormData({ ...formData, solicitante: e.target.value })}
                    // Se não for admin, campo é somente leitura
                    disabled={user.role !== "admin"}
                    required
                  />
                  {/* Dica para usuários normais explicando o campo bloqueado */}
                  {user.role !== "admin" && (
                    <p className="text-xs text-muted-foreground">
                      Campo bloqueado: chamados são registrados em seu nome
                    </p>
                  )}
                </div>

                {/* Campo: Técnico responsável (opcional, apenas para admins)
                    Permite atribuir um administrador para técnico responsável
                    Este campo só aparece se usuário logado é admin */}
                {user.role === "admin" && (
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
                        {/* Opção padrão: sem técnico atribuído */}
                        <SelectItem value="sem-responsavel">Não atribuído</SelectItem>
                        {/* Lista de administradores disponíveis */}
                        {adminUsers.map((admin) => (
                          <SelectItem key={admin.id} value={admin.username}>
                            {admin.nome} (@{admin.username})
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                )}

                {/* Campo: Prioridade do chamado (obrigatório)
                    Define urgência: Baixa, Média ou Alta
                    Valor padrão é Média */}
                <div className="space-y-2">
                  <Label htmlFor="prioridade">Prioridade *</Label>
                  <Select
                    value={formData.prioridade}
                    onValueChange={(value: "Baixa" | "Média" | "Alta") =>
                      setFormData({ ...formData, prioridade: value })
                    }
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

                {/* Botões de ação: Criar ou Cancelar */}
                <div className="flex gap-3 pt-4">
                  {/* Botão para enviar formulário */}
                  <Button type="submit" className="flex-1" disabled={loading}>
                    {loading ? "Criando..." : "Criar Chamado"}
                  </Button>
                  {/* Botão para cancelar e voltar */}
                  <Button type="button" variant="outline" asChild className="flex-1 bg-transparent">
                    <Link href="/chamados">Cancelar</Link>
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  )
}
