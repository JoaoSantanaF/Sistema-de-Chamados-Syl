"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Plus, Search, Calendar, AlertCircle, CheckCircle, Clock, FileText, Edit2, Trash2 } from "lucide-react"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

interface Asset {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  proxima_manutencao: string
  status: string
}

export default function ManutencaoPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [assets, setAssets] = useState<Asset[]>([])
  const [filteredAssets, setFilteredAssets] = useState<Asset[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [criticalityFilter, setcriticalityFilter] = useState<string>("Todas")
  const [statusFilter, setStatusFilter] = useState<string>("Todos")
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsedUser = JSON.parse(userData)

    if (parsedUser.role !== "admin") {
      router.push("/chamados")
      return
    }

    setUser(parsedUser)
    loadAssets()
  }, [router])

  useEffect(() => {
    filterAssets()
  }, [assets, searchTerm, criticalityFilter, statusFilter, startDate, endDate])

  const loadAssets = async () => {
    try {
      setLoading(true)
      setError(null)

      const response = await fetch("/api/ativos")
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar ativos:", data.error)
        setError("Erro ao carregar ativos. Verifique se as tabelas foram criadas no banco de dados.")
        setLoading(false)
        return
      }

      setAssets(data || [])
      setFilteredAssets(data || [])
    } catch (err) {
      console.error("Erro ao carregar ativos:", err)
      setError("Erro ao carregar dados de manutenção")
    } finally {
      setLoading(false)
    }
  }

  const filterAssets = () => {
    let filtered = [...assets]

    if (criticalityFilter !== "Todas") {
      filtered = filtered.filter((asset) => asset.criticidade === criticalityFilter)
    }

    if (statusFilter !== "Todos") {
      filtered = filtered.filter((asset) => asset.status === statusFilter)
    }

    if (startDate) {
      filtered = filtered.filter((asset) => asset.proxima_manutencao && asset.proxima_manutencao >= startDate)
    }

    if (endDate) {
      filtered = filtered.filter((asset) => asset.proxima_manutencao && asset.proxima_manutencao <= endDate)
    }

    if (searchTerm) {
      filtered = filtered.filter(
        (asset) =>
          asset.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
          asset.tipo.toLowerCase().includes(searchTerm.toLowerCase()) ||
          asset.localizacao.toLowerCase().includes(searchTerm.toLowerCase()),
      )
    }

    setFilteredAssets(filtered)
  }

  const getCriticalityLabel = (criticidade: string) => {
    const labels: Record<string, string> = {
      Alta: "Alta (30 dias)",
      Média: "Média (60 dias)",
      Baixa: "Baixa (180 dias)",
    }
    return labels[criticidade] || "Desconhecida"
  }

  const getCriticalityColor = (criticidade: string) => {
    const colors: Record<string, string> = {
      Alta: "bg-destructive/10 text-destructive",
      Média: "bg-warning/10 text-warning",
      Baixa: "bg-success/10 text-success",
    }
    return colors[criticidade] || "bg-muted text-muted-foreground"
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "Operacional":
        return <CheckCircle className="h-4 w-4 text-success" />
      case "Em Manutenção":
        return <Clock className="h-4 w-4 text-warning" />
      case "Inativo":
        return <AlertCircle className="h-4 w-4 text-destructive" />
      default:
        return null
    }
  }

  const handleDeleteAsset = async (assetId: string, assetName: string) => {
    if (!window.confirm(`Tem certeza que deseja excluir o ativo "${assetName}"? Esta ação não pode ser desfeita.`)) {
      return
    }

    try {
      const response = await fetch(`/api/ativos/${assetId}`, {
        method: "DELETE",
      })

      if (!response.ok) {
        const data = await response.json()
        console.error("Erro ao excluir ativo:", data.error)
        alert("Erro ao excluir ativo")
        return
      }

      alert("Ativo excluído com sucesso!")
      await loadAssets()
    } catch (err) {
      console.error("Erro ao excluir:", err)
      alert("Erro ao excluir ativo")
    }
  }

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
              <FileText className="h-8 w-8" />
              Form.139 – Plano de Manutenção Preventiva de Computadores
            </h1>
            <p className="text-muted-foreground mt-1">
              Conforme procedimento TI-01 Rev.10 - Sistema informatizado de manutenção preventiva
            </p>
          </div>
          {user.role === "admin" && (
            <Button asChild>
              <Link href="/manutencao/novo-ativo">
                <Plus className="h-4 w-4 mr-2" />
                Novo Ativo
              </Link>
            </Button>
          )}
        </div>

        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-3">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total de Ativos</CardTitle>
              <CheckCircle className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{assets.length}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Manutenções Pendentes</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {assets.filter((a) => a.proxima_manutencao && new Date(a.proxima_manutencao) <= new Date()).length}
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Alta Criticidade</CardTitle>
              <AlertCircle className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{assets.filter((a) => a.criticidade === "Alta").length}</div>
            </CardContent>
          </Card>
        </div>

        {/* Filters */}
        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col gap-4">
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Buscar por nome, tipo ou localização..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-9"
                  />
                </div>
                <Select value={criticalityFilter} onValueChange={setcriticalityFilter}>
                  <SelectTrigger className="w-full md:w-[200px]">
                    <SelectValue placeholder="Criticidade" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Todas">Todas</SelectItem>
                    <SelectItem value="Alta">Alta (30 dias)</SelectItem>
                    <SelectItem value="Média">Média (60 dias)</SelectItem>
                    <SelectItem value="Baixa">Baixa (180 dias)</SelectItem>
                  </SelectContent>
                </Select>
                <Select value={statusFilter} onValueChange={setStatusFilter}>
                  <SelectTrigger className="w-full md:w-[200px]">
                    <SelectValue placeholder="Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Todos">Todos</SelectItem>
                    <SelectItem value="Operacional">Operacional</SelectItem>
                    <SelectItem value="Em Manutenção">Em Manutenção</SelectItem>
                    <SelectItem value="Inativo">Inativo</SelectItem>
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
                {(startDate || endDate || searchTerm || criticalityFilter !== "Todas" || statusFilter !== "Todos") && (
                  <div className="flex items-end">
                    <Button
                      variant="outline"
                      onClick={() => {
                        setStartDate("")
                        setEndDate("")
                        setSearchTerm("")
                        setcriticalityFilter("Todas")
                        setStatusFilter("Todos")
                      }}
                    >
                      Limpar Filtros
                    </Button>
                  </div>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Asset List */}
        <Card>
          <CardHeader>
            <CardTitle>Ativos ({filteredAssets.length})</CardTitle>
            <CardDescription>Lista de todos os ativos cadastrados no sistema</CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="text-center py-12">
                <p className="text-muted-foreground">Carregando ativos...</p>
              </div>
            ) : error ? (
              <div className="text-center py-12">
                <AlertCircle className="h-12 w-12 text-destructive mx-auto mb-4" />
                <p className="text-destructive font-medium mb-2">{error}</p>
                <p className="text-sm text-muted-foreground">
                  Execute os scripts de migração no PostgreSQL
                </p>
              </div>
            ) : filteredAssets.length === 0 ? (
              <div className="text-center py-12 text-muted-foreground">
                <p className="text-lg font-medium mb-1">Nenhum ativo encontrado</p>
                <p className="text-sm">Ajuste os filtros ou cadastre um novo ativo</p>
              </div>
            ) : (
              <div className="space-y-3">
                {filteredAssets.map((asset) => (
                  <div
                    key={asset.id}
                    className="flex items-center justify-between p-4 rounded-lg border hover:bg-accent transition-colors"
                  >
                    <div className="flex-1 min-w-0 space-y-1">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(asset.status)}
                        <p className="font-medium">{asset.nome}</p>
                      </div>
                      <p className="text-sm text-muted-foreground">
                        {asset.tipo} • {asset.localizacao}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        <Calendar className="h-3 w-3 inline mr-1" />
                        Próxima manutenção:{" "}
                        {asset.proxima_manutencao
                          ? new Date(asset.proxima_manutencao).toLocaleDateString("pt-BR")
                          : "Não agendada"}
                      </p>
                    </div>
                    <div className="flex items-center gap-3 ml-4">
                      <span
                        className={`text-xs px-3 py-1 rounded-full font-medium whitespace-nowrap ${getCriticalityColor(asset.criticidade)}`}
                      >
                        {getCriticalityLabel(asset.criticidade)}
                      </span>
                      <Button variant="outline" size="sm" asChild>
                        <Link href={`/manutencao/${asset.id}`}>Ver Detalhes</Link>
                      </Button>
                      <Button variant="outline" size="sm" asChild>
                        <Link href={`/manutencao/${asset.id}/editar`}>
                          <Edit2 className="h-4 w-4" />
                        </Link>
                      </Button>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => handleDeleteAsset(asset.id, asset.nome)}
                        className="hover:bg-destructive/10 hover:text-destructive"
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Legend */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Legenda de Criticidade</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col sm:flex-row gap-4">
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-destructive" />
              <span className="text-sm text-muted-foreground">Alta - Manutenção a cada 30 dias</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-warning" />
              <span className="text-sm text-muted-foreground">Média - Manutenção a cada 60 dias</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-success" />
              <span className="text-sm text-muted-foreground">Baixa - Manutenção a cada 180 dias</span>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
