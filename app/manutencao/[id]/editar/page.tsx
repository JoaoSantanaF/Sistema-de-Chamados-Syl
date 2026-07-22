"use client"

import type React from "react"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import Link from "next/link"
import { ArrowLeft, Save } from "lucide-react"

import { DashboardLayout } from "@/components/dashboard-layout"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

function formatDateForDisplay(dateValue?: string | null) {
  if (!dateValue) return ""

  const isoDate = String(dateValue).match(/^(\d{4})-(\d{2})-(\d{2})/)
  if (isoDate) {
    const [, year, month, day] = isoDate
    return `${day}/${month}/${year}`
  }

  return String(dateValue)
}

function parseDisplayDate(dateValue: string) {
  const trimmed = dateValue.trim()
  if (!trimmed) return null

  const brDate = trimmed.match(/^(\d{2})\/(\d{2})\/(\d{4})$/)
  if (brDate) {
    const [, day, month, year] = brDate
    return `${year}-${month}-${day}`
  }

  if (/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) {
    return trimmed
  }

  return undefined
}

export default function EditAssetPage() {
  const router = useRouter()
  const params = useParams()
  const assetId = params.id as string

  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [formData, setFormData] = useState({
    nome: "",
    tipo: "",
    localizacao: "",
    criticidade: "Media",
    status: "Operacional",
    ultima_manutencao: "",
    proxima_manutencao: "",
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

    void loadAsset()
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
        nome: data.nome ?? "",
        tipo: data.tipo ?? "",
        localizacao: data.localizacao ?? "",
        criticidade: data.criticidade ?? "Media",
        status: data.status ?? "Operacional",
        ultima_manutencao: formatDateForDisplay(data.ultima_manutencao),
        proxima_manutencao: formatDateForDisplay(data.proxima_manutencao),
      })
    } catch (err) {
      console.error("Erro ao carregar ativo:", err)
      router.push("/manutencao")
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault()

    if (!formData.nome || !formData.tipo || !formData.localizacao) {
      alert("Por favor, preencha todos os campos obrigatorios")
      return
    }

    setSaving(true)

    try {
      const ultimaManutencao = parseDisplayDate(formData.ultima_manutencao)
      const proximaManutencao = parseDisplayDate(formData.proxima_manutencao)

      if (ultimaManutencao === undefined || proximaManutencao === undefined) {
        alert("Informe as datas no formato dia/mes/ano, por exemplo 18/05/2026.")
        return
      }

      const response = await fetch(`/api/ativos/${assetId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nome: formData.nome,
          tipo: formData.tipo,
          localizacao: formData.localizacao,
          criticidade: formData.criticidade,
          status: formData.status,
          ultima_manutencao: ultimaManutencao,
          proxima_manutencao: proximaManutencao,
          manual_date_edit: true,
        }),
      })

      if (!response.ok) {
        const data = await response.json()
        console.error("Erro ao atualizar ativo:", data.error)
        alert("Erro ao atualizar ativo")
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
      <div className="mx-auto max-w-3xl space-y-6">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" asChild>
            <Link href="/manutencao">
              <ArrowLeft className="h-4 w-4" />
            </Link>
          </Button>
          <h1 className="text-3xl font-bold tracking-tight">Editar Ativo</h1>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Informacoes do Ativo</CardTitle>
            <CardDescription>Atualize os dados do ativo e, se quiser, ajuste as datas de manutencao.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="text-sm font-medium">Nome do Ativo *</label>
                <Input
                  value={formData.nome}
                  onChange={(event) => setFormData({ ...formData, nome: event.target.value })}
                  placeholder="Ex: Servidor Web 01"
                />
              </div>

              <div>
                <label className="text-sm font-medium">Tipo *</label>
                <Input
                  value={formData.tipo}
                  onChange={(event) => setFormData({ ...formData, tipo: event.target.value })}
                  placeholder="Ex: Servidor, Switch, Firewall"
                />
              </div>

              <div>
                <label className="text-sm font-medium">Localizacao *</label>
                <Input
                  value={formData.localizacao}
                  onChange={(event) => setFormData({ ...formData, localizacao: event.target.value })}
                  placeholder="Ex: Data Center, Sala de Servidores"
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
                    <SelectItem value="Media">Media (60 dias)</SelectItem>
                    <SelectItem value="Média">Media (60 dias)</SelectItem>
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
                    <SelectItem value="Em Manutencao">Em manutencao</SelectItem>
                    <SelectItem value="Em Manutenção">Em manutencao</SelectItem>
                    <SelectItem value="Inativo">Inativo</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <label className="text-sm font-medium">Ultima manutencao</label>
                  <Input
                    inputMode="numeric"
                    placeholder="dd/mm/aaaa"
                    value={formData.ultima_manutencao}
                    onChange={(event) => setFormData({ ...formData, ultima_manutencao: event.target.value })}
                  />
                </div>

                <div>
                  <label className="text-sm font-medium">Proxima manutencao</label>
                  <Input
                    inputMode="numeric"
                    placeholder="dd/mm/aaaa"
                    value={formData.proxima_manutencao}
                    onChange={(event) => setFormData({ ...formData, proxima_manutencao: event.target.value })}
                  />
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <Button type="button" variant="outline" asChild>
                  <Link href="/manutencao">Cancelar</Link>
                </Button>
                <Button type="submit" disabled={saving}>
                  <Save className="mr-2 h-4 w-4" />
                  {saving ? "Salvando..." : "Salvar Alteracoes"}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
