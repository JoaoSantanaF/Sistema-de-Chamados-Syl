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
import { ArrowLeft, Upload, FileText } from "lucide-react"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"

export default function NovoChamadoPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [formData, setFormData] = useState({
    titulo: "",
    descricao: "",
    solicitante: "",
    prioridade: "Média" as "Baixa" | "Média" | "Alta",
  })
  const [anexo, setAnexo] = useState<File | null>(null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsedUser = JSON.parse(userData)
    setUser(parsedUser)
    setFormData((prev) => ({ ...prev, solicitante: parsedUser.username }))
  }, [router])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!user) return

    setLoading(true)
    try {
      const response = await fetch("/api/chamados", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          titulo: formData.titulo,
          descricao: formData.descricao,
          solicitante: formData.solicitante,
          prioridade: formData.prioridade,
          anexo_nome: anexo ? anexo.name : null,
          anexo_url: null,
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao criar chamado:", data.error)
        alert("Erro ao criar chamado: " + data.error)
        return
      }

      console.log("Chamado criado com sucesso:", data)
      router.push("/chamados")
    } catch (error) {
      console.error("Erro ao criar chamado:", error)
      alert("Erro ao criar chamado")
    } finally {
      setLoading(false)
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      const validTypes = ["application/pdf", "image/png", "image/jpeg", "image/jpg"]
      if (!validTypes.includes(file.type)) {
        alert("Apenas arquivos PDF, PNG e JPG são permitidos")
        return
      }
      if (file.size > 16 * 1024 * 1024) {
        alert("O arquivo deve ter no máximo 16MB")
        return
      }
      setAnexo(file)
    }
  }

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="flex justify-center">
        <div className="space-y-6 max-w-3xl">
          {/* Header - Adicionado título Form.147 para conformidade TI-01 */}
          <div className="flex items-center gap-4">
            <Button variant="outline" size="icon" asChild>
              <Link href="/chamados">
                <ArrowLeft className="h-4 w-4" />
              </Link>
            </Button>
            <div>
              <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
                <FileText className="h-8 w-8" />
                Form.147 – Chamado Suporte TI
              </h1>
              <p className="text-muted-foreground mt-1">Abertura de novo chamado • Conforme TI-01 Rev.10 - Item 6.3.1</p>
            </div>
          </div>

          {/* Form */}
          <Card>
            <CardHeader>
              <CardTitle>Informações do Chamado</CardTitle>
              <CardDescription>
                Todos os campos marcados com * são obrigatórios • Campos: Data, Setor, Usuário, Descrição do problema
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
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

                <div className="space-y-2">
                  <Label htmlFor="solicitante">Usuário/Solicitante *</Label>
                  <Input
                    id="solicitante"
                    value={formData.solicitante}
                    onChange={(e) => setFormData({ ...formData, solicitante: e.target.value })}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="prioridade">Prioridade *</Label>
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
                  <Label htmlFor="anexo">Anexo (opcional)</Label>
                  <div className="flex items-center gap-2">
                    <Input
                      id="anexo"
                      type="file"
                      accept=".pdf,.png,.jpg,.jpeg"
                      onChange={handleFileChange}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      className="w-full bg-transparent"
                      onClick={() => document.getElementById("anexo")?.click()}
                    >
                      <Upload className="h-4 w-4 mr-2" />
                      {anexo ? anexo.name : "Escolher arquivo (PDF, PNG, JPG - máx 16MB)"}
                    </Button>
                  </div>
                </div>

                <div className="flex gap-3 pt-4">
                  <Button type="submit" className="flex-1" disabled={loading}>
                    {loading ? "Criando..." : "Criar Chamado"}
                  </Button>
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
