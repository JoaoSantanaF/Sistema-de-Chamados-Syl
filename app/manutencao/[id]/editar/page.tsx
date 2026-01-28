"use client"

import type React from "react"

import { useEffect, useState } from "react"
import { useRouter, useParams } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { ArrowLeft, Save } from "lucide-react"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"

export default function EditAssetPage() {
  const router = useRouter()
  const params = useParams()
  const assetId = params.id as string

  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [formData, setFormData] = useState({
    nome: "",
    tipo: "",
    localizacao: "",
    criticidade: "Média",
    status: "Operacional",
  })

  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsedUser = JSON.parse(userData)
    setUser(parsedUser)

    if (parsedUser.role !== "admin") {
      router.push("/manutencao")
      return
    }

    loadAsset()
  }, [router])

  const loadAsset = async () => {
    try {
      const response = await fetch(`/api/ativos/${assetId}`)
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar ativo:", data.error)
        router.push("/manutencao")
        return
      }

      setFormData({
        nome: data.nome,
        tipo: data.tipo,
        localizacao: data.localizacao,
        criticidade: data.criticidade,
        status: data.status,
      })

      setLoading(false)
    } catch (err) {
      console.error("Erro ao carregar ativo:", err)
      router.push("/manutencao")
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.nome || !formData.tipo || !formData.localizacao) {
      alert("Por favor, preencha todos os campos obrigatórios")
      return
    }

    setSaving(true)

    try {
      const response = await fetch(`/api/ativos/${assetId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nome: formData.nome,
          tipo: formData.tipo,
          localizacao: formData.localizacao,
          criticidade: formData.criticidade,
          status: formData.status,
        }),
      })

      if (!response.ok) {
        const data = await response.json()
        console.error("Erro ao atualizar ativo:", data.error)
        alert("Erro ao atualizar ativo")
        setSaving(false)
        return
      }

      alert("Ativo atualizado com sucesso!")
      router.push("/manutencao")
    } catch (err) {
      console.error("Erro ao atualizar ativo:", err)
      alert("Erro ao atualizar ativo")
    } finally {
      setSaving(false)
    }
  }

  if (!user || loading) return null

  return (
    <DashboardLayout>
      <div className="space-y-6 max-w-2xl">
        {/* Header */}
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" asChild>
            <Link href="/manutencao">
              <ArrowLeft className="h-4 w-4" />
            </Link>
          </Button>
          <h1 className="text-3xl font-bold tracking-tight">Editar Ativo</h1>
        </div>

        {/* Form */}
        <Card>
          <CardHeader>
            <CardTitle>Informações do Ativo</CardTitle>
            <CardDescription>Atualize as informações do ativo de TI</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="text-sm font-medium">Nome do Ativo *</label>
                <Input
                  value={formData.nome}
                  onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                  placeholder="Ex: Servidor Web 01"
                />
              </div>

              <div>
                <label className="text-sm font-medium">Tipo *</label>
                <Input
                  value={formData.tipo}
                  onChange={(e) => setFormData({ ...formData, tipo: e.target.value })}
                  placeholder="Ex: Servidor, Switch, Firewall, etc"
                />
              </div>

              <div>
                <label className="text-sm font-medium">Localização *</label>
                <Input
                  value={formData.localizacao}
                  onChange={(e) => setFormData({ ...formData, localizacao: e.target.value })}
                  placeholder="Ex: Data Center, Sala de Servidor, Andar 2"
                />
              </div>

              <div>
                <label className="text-sm font-medium">Criticidade *</label>
                <Select
                  value={formData.criticidade}
                  onValueChange={(value) => setFormData({ ...formData, criticidade: value })}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Alta">Alta (30 dias)</SelectItem>
                    <SelectItem value="Média">Média (60 dias)</SelectItem>
                    <SelectItem value="Baixa">Baixa (180 dias)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <label className="text-sm font-medium">Status *</label>
                <Select value={formData.status} onValueChange={(value) => setFormData({ ...formData, status: value })}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Operacional">Operacional</SelectItem>
                    <SelectItem value="Em Manutenção">Em Manutenção</SelectItem>
                    <SelectItem value="Inativo">Inativo</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="flex gap-3 pt-4">
                <Button type="button" variant="outline" asChild>
                  <Link href="/manutencao">Cancelar</Link>
                </Button>
                <Button type="submit" disabled={saving}>
                  <Save className="h-4 w-4 mr-2" />
                  {saving ? "Salvando..." : "Salvar Alterações"}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
