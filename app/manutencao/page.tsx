"use client"

import { useEffect, useState } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import {
  AlertCircle,
  Calendar,
  CheckCircle,
  ChevronRight,
  Clock,
  Download,
  Edit2,
  FileText,
  Plus,
  Search,
  Target,
  Trash2,
} from "lucide-react"

import { DashboardLayout } from "@/components/dashboard-layout"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"
import { Progress } from "@/components/ui/progress"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import {
  buildMonthlyMetrics,
  formatMaintenanceDate,
  formatMonthLabel,
  normalizeCriticality,
  normalizeText,
  parseMaintenanceDate,
  type MaintenanceAsset,
  type MaintenanceCycle,
} from "@/lib/maintenance-report"

interface Asset extends MaintenanceAsset {
  status: string
}

interface MaintenanceCycleWithAsset extends MaintenanceCycle {
  ativo_nome: string
}

const MONTHLY_GOAL = 90

function escapeHtml(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")
}

export default function ManutencaoPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [assets, setAssets] = useState<Asset[]>([])
  const [cycles, setCycles] = useState<MaintenanceCycleWithAsset[]>([])
  const [filteredAssets, setFilteredAssets] = useState<Asset[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [criticalityFilter, setCriticalityFilter] = useState<string>("Todas")
  const [statusFilter, setStatusFilter] = useState<string>("Todos")
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")
  const [isPendingSheetOpen, setIsPendingSheetOpen] = useState(false)
  const [selectedReportMonths, setSelectedReportMonths] = useState<string[]>([])
  const [isExportingReport, setIsExportingReport] = useState(false)
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
    void loadMaintenanceData()
  }, [router])

  useEffect(() => {
    filterAssets()
  }, [assets, searchTerm, criticalityFilter, statusFilter, startDate, endDate])

  const loadMaintenanceData = async () => {
    try {
      setLoading(true)
      setError(null)

      const [assetsResponse, cyclesResponse] = await Promise.all([fetch("/api/ativos"), fetch("/api/ciclos")])
      const [assetsData, cyclesData] = await Promise.all([assetsResponse.json(), cyclesResponse.json()])

      if (!assetsResponse.ok) {
        console.error("Erro ao carregar ativos:", assetsData.error)
        setError("Erro ao carregar ativos. Verifique se as tabelas foram criadas no banco de dados.")
        return
      }

      if (!cyclesResponse.ok) {
        console.error("Erro ao carregar ciclos:", cyclesData.error)
        setError("Erro ao carregar ciclos de manutencao.")
        return
      }

      setAssets(assetsData || [])
      setCycles(cyclesData || [])
      setFilteredAssets(assetsData || [])
    } catch (err) {
      console.error("Erro ao carregar manutencao:", err)
      setError("Erro ao carregar dados de manutencao")
    } finally {
      setLoading(false)
    }
  }

  const filterAssets = () => {
    let filtered = [...assets]

    if (criticalityFilter !== "Todas") {
      filtered = filtered.filter((asset) => normalizeCriticality(asset.criticidade) === normalizeCriticality(criticalityFilter))
    }

    if (statusFilter !== "Todos") {
      filtered = filtered.filter((asset) => asset.status === statusFilter)
    }

    if (startDate) {
      filtered = filtered.filter((asset) => {
        if (!asset.proxima_manutencao) return false
        const assetMonth = asset.proxima_manutencao.substring(0, 7)
        return assetMonth >= startDate
      })
    }

    if (endDate) {
      filtered = filtered.filter((asset) => {
        if (!asset.proxima_manutencao) return false
        const assetMonth = asset.proxima_manutencao.substring(0, 7)
        return assetMonth <= endDate
      })
    }

    if (searchTerm) {
      filtered = filtered.filter(
        (asset) =>
          asset.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
          asset.tipo.toLowerCase().includes(searchTerm.toLowerCase()) ||
          asset.localizacao.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    setFilteredAssets(filtered)
  }

  const getCriticalityLabel = (criticidade: string) => {
    const labels: Record<string, string> = {
      Alta: "Alta (30 dias)",
      Media: "Media (60 dias)",
      Baixa: "Baixa (180 dias)",
    }

    return labels[normalizeCriticality(criticidade)] || "Desconhecida"
  }

  const getCriticalityColor = (criticidade: string) => {
    const colors: Record<string, string> = {
      Alta: "bg-destructive/10 text-destructive",
      Media: "bg-warning/10 text-warning",
      Baixa: "bg-success/10 text-success",
    }

    return colors[normalizeCriticality(criticidade)] || "bg-muted text-muted-foreground"
  }

  const getStatusIcon = (status: string) => {
    const normalizedStatus = normalizeText(status)

    switch (normalizedStatus) {
      case "operacional":
        return <CheckCircle className="h-4 w-4 text-success" />
      case "em manutencao":
        return <Clock className="h-4 w-4 text-warning" />
      case "inativo":
        return <AlertCircle className="h-4 w-4 text-destructive" />
      default:
        return null
    }
  }

  const handleDeleteAsset = async (assetId: string, assetName: string) => {
    if (!window.confirm(`Tem certeza que deseja excluir o ativo "${assetName}"? Esta acao nao pode ser desfeita.`)) {
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

      alert("Ativo excluido com sucesso!")
      await loadMaintenanceData()
    } catch (err) {
      console.error("Erro ao excluir:", err)
      alert("Erro ao excluir ativo")
    }
  }

  const monthlyMetrics = buildMonthlyMetrics(assets, cycles)
  const currentMonthKey = `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, "0")}`
  const currentMonthMetrics = monthlyMetrics.find((item) => item.monthKey === currentMonthKey) ?? {
    monthLabel: new Date().toLocaleDateString("pt-BR", { month: "long", year: "numeric" }),
    requiredCount: 0,
    completedCount: 0,
    pendingCount: 0,
    completionRate: 0,
    goalReached: false,
    assets: [],
  }
  const remainingForGoal =
    currentMonthMetrics.requiredCount > 0
      ? Math.max(Math.ceil((MONTHLY_GOAL / 100) * currentMonthMetrics.requiredCount) - currentMonthMetrics.completedCount, 0)
      : 0

  const pendingAssets = currentMonthMetrics.assets
    .filter((asset) => !asset.completed)
    .map((metricAsset) => assets.find((asset) => asset.id === metricAsset.assetId))
    .filter((asset): asset is Asset => Boolean(asset))
    .sort((a, b) => {
      const isHighA = normalizeCriticality(a.criticidade) === "Alta"
      const isHighB = normalizeCriticality(b.criticidade) === "Alta"
      if (isHighA !== isHighB) return isHighA ? -1 : 1

      const dateA = parseMaintenanceDate(a.proxima_manutencao)?.getTime() ?? Number.MAX_SAFE_INTEGER
      const dateB = parseMaintenanceDate(b.proxima_manutencao)?.getTime() ?? Number.MAX_SAFE_INTEGER
      return dateA - dateB
    })

  const reportMonthOptions = monthlyMetrics.slice(0, 12)

  useEffect(() => {
    if (reportMonthOptions.length > 0 && selectedReportMonths.length === 0) {
      const defaultMonth =
        reportMonthOptions.find((item) => item.monthKey === currentMonthKey)?.monthKey ?? reportMonthOptions[0].monthKey

      setSelectedReportMonths([defaultMonth])
    }
  }, [currentMonthKey, reportMonthOptions, selectedReportMonths.length])

  const toggleReportMonth = (monthKey: string, checked: boolean) => {
    setSelectedReportMonths((current) => {
      if (checked) {
        return current.includes(monthKey) ? current : [...current, monthKey]
      }

      return current.filter((item) => item !== monthKey)
    })
  }

  const handleExportReport = async () => {
    if (selectedReportMonths.length === 0) {
      alert("Selecione pelo menos um mes para exportar o relatorio.")
      return
    }

    try {
      setIsExportingReport(true)
      const selectedMetrics = buildMonthlyMetrics(assets, cycles, {
        monthKeys: [...selectedReportMonths].sort(),
      })

      const sections = selectedMetrics
        .map((item) => {
          const rows = item.assets
            .map(
              (asset) => `
                <tr>
                  <td>${escapeHtml(asset.assetName)}</td>
                  <td>${escapeHtml(asset.assetType)}</td>
                  <td>${escapeHtml(asset.location)}</td>
                  <td>${escapeHtml(asset.criticality)}</td>
                  <td>${escapeHtml(asset.dueDateLabel)}</td>
                  <td>${asset.completed ? "Realizada" : "Pendente"}</td>
                  <td>${asset.completionDate ? escapeHtml(formatMaintenanceDate(asset.completionDate) ?? "-") : "-"}</td>
                </tr>
              `
            )
            .join("")

          return `
            <section class="month-section">
              <div class="month-header">
                <div>
                  <h2>${escapeHtml(item.monthLabel)}</h2>
                  <p>${item.completedCount} realizada(s) de ${item.requiredCount} prevista(s)</p>
                </div>
                <div class="summary">
                  <span>Taxa: ${item.completionRate}%</span>
                  <span>Pendentes: ${item.pendingCount}</span>
                </div>
              </div>
              <div class="stats-grid">
                <div class="stat-card">
                  <strong>${item.requiredCount}</strong>
                  <span>Previstas</span>
                </div>
                <div class="stat-card">
                  <strong>${item.completedCount}</strong>
                  <span>Realizadas</span>
                </div>
                <div class="stat-card">
                  <strong>${item.pendingCount}</strong>
                  <span>Pendentes</span>
                </div>
              </div>
              <table>
                <thead>
                  <tr>
                    <th>Maquina</th>
                    <th>Tipo</th>
                    <th>Localizacao</th>
                    <th>Criticidade</th>
                    <th>Referencia</th>
                    <th>Status no mes</th>
                    <th>Data de conclusao</th>
                  </tr>
                </thead>
                <tbody>${rows}</tbody>
              </table>
            </section>
          `
        })
        .join("")

      const html = `
        <!DOCTYPE html>
        <html lang="pt-BR">
          <head>
            <meta charset="UTF-8" />
            <title>Relatorio de manutencao preventiva</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 32px; color: #1f2937; background: #f8fafc; }
              h1 { margin-bottom: 8px; }
              .subtitle { margin-bottom: 24px; color: #475569; }
              .month-section { background: #ffffff; border: 1px solid #dbe4ee; border-radius: 16px; padding: 20px; margin-bottom: 20px; }
              .month-header { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 16px; }
              .month-header h2 { margin: 0 0 4px; text-transform: capitalize; }
              .month-header p, .summary span { margin: 0; color: #475569; }
              .summary { display: flex; flex-direction: column; gap: 6px; text-align: right; }
              .stats-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin-bottom: 16px; }
              .stat-card { background: #eff6ff; border-radius: 12px; padding: 12px; }
              .stat-card strong { display: block; font-size: 24px; }
              .stat-card span { color: #475569; }
              table { width: 100%; border-collapse: collapse; font-size: 14px; }
              th, td { padding: 10px 12px; border-bottom: 1px solid #e2e8f0; text-align: left; }
              th { background: #f1f5f9; }
            </style>
          </head>
          <body>
            <h1>Relatorio de manutencao preventiva</h1>
            <p class="subtitle">
              Gerado em ${new Date().toLocaleString("pt-BR")} para os meses:
              ${selectedReportMonths.map((monthKey) => formatMonthLabel(monthKey)).join(", ")}
            </p>
            ${sections}
          </body>
        </html>
      `

      const blob = new Blob([html], { type: "text/html;charset=utf-8" })
      const fileName = `relatorio-manutencao-${[...selectedReportMonths].sort().join("_")}.html`

      const objectUrl = window.URL.createObjectURL(blob)
      const link = document.createElement("a")
      link.href = objectUrl
      link.download = fileName
      document.body.appendChild(link)
      link.click()
      link.remove()
      window.URL.revokeObjectURL(objectUrl)
    } catch (error) {
      console.error("Erro ao exportar relatorio:", error)
      alert("Nao foi possivel exportar o relatorio.")
    } finally {
      setIsExportingReport(false)
    }
  }

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="mx-auto max-w-6xl space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="flex items-center gap-2 text-3xl font-bold tracking-tight">
              <FileText className="h-8 w-8" />
              Form.139 - Plano de Manutencao Preventiva de Computadores
            </h1>
            <p className="mt-1 text-muted-foreground">
              Conforme procedimento TI-01 Rev.10 - Sistema informatizado de manutencao preventiva
            </p>
          </div>
          {user.role === "admin" && (
            <Button asChild>
              <Link href="/manutencao/novo-ativo">
                <Plus className="mr-2 h-4 w-4" />
                Novo Ativo
              </Link>
            </Button>
          )}
        </div>

        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total de Ativos</CardTitle>
              <CheckCircle className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{assets.length}</div>
            </CardContent>
          </Card>

          <Card
            className="cursor-pointer transition-colors hover:bg-accent/40"
            onClick={() => setIsPendingSheetOpen(true)}
            onKeyDown={(event) => {
              if (event.key === "Enter" || event.key === " ") {
                event.preventDefault()
                setIsPendingSheetOpen(true)
              }
            }}
            role="button"
            tabIndex={0}
          >
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Manutencoes Pendentes</CardTitle>
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="flex items-end justify-between gap-3">
                <div className="text-2xl font-bold">{pendingAssets.length}</div>
                <span className="text-xs text-muted-foreground">Clique para abrir</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Alta Criticidade</CardTitle>
              <AlertCircle className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {assets.filter((asset) => normalizeCriticality(asset.criticidade) === "Alta").length}
              </div>
            </CardContent>
          </Card>

          <Card className={currentMonthMetrics.goalReached ? "border-success/40 bg-success/5" : "border-warning/40 bg-warning/5"}>
            <CardHeader className="space-y-3 pb-2">
              <div className="flex items-center justify-between gap-3">
                <div>
                  <CardTitle className="text-sm font-medium">Meta mensal</CardTitle>
                  <CardDescription className="capitalize">{currentMonthMetrics.monthLabel}</CardDescription>
                </div>
                <Target className={currentMonthMetrics.goalReached ? "h-4 w-4 text-success" : "h-4 w-4 text-warning"} />
              </div>
              <Progress value={currentMonthMetrics.completionRate} className="h-3" />
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex items-end justify-between gap-3">
                <div className="text-2xl font-bold">{currentMonthMetrics.completionRate}%</div>
                <span className="text-xs font-medium text-muted-foreground">Meta {MONTHLY_GOAL}%</span>
              </div>
              <p className="text-sm text-muted-foreground">
                {currentMonthMetrics.completedCount} de {currentMonthMetrics.requiredCount} maquinas necessarias concluidas neste mes.
              </p>
              <p className={`text-xs font-medium ${currentMonthMetrics.goalReached ? "text-success" : "text-warning"}`}>
                {currentMonthMetrics.requiredCount === 0
                  ? "Nenhuma manutencao prevista para este mes."
                  : currentMonthMetrics.goalReached
                    ? "Meta atingida no periodo."
                    : `Faltam ${remainingForGoal} manutencao(oes) para bater a meta.`}
              </p>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardContent className="pt-6">
            <div className="flex flex-col gap-4">
              <div className="flex flex-col gap-4 md:flex-row">
                <div className="relative flex-1">
                  <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    placeholder="Buscar por nome, tipo ou localizacao..."
                    value={searchTerm}
                    onChange={(event) => setSearchTerm(event.target.value)}
                    className="pl-9"
                  />
                </div>
                <Select value={criticalityFilter} onValueChange={setCriticalityFilter}>
                  <SelectTrigger className="w-full md:w-[200px]">
                    <SelectValue placeholder="Criticidade" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Todas">Todas</SelectItem>
                    <SelectItem value="Alta">Alta (30 dias)</SelectItem>
                    <SelectItem value="Media">Media (60 dias)</SelectItem>
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
                    <SelectItem value="Em Manutencao">Em manutencao</SelectItem>
                    <SelectItem value="Inativo">Inativo</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="flex flex-col gap-4 md:flex-row">
                <div className="flex-1">
                  <label className="mb-1.5 block text-sm text-muted-foreground">Mês Inicial</label>
                  <Input
                    type="month"
                    value={startDate}
                    onChange={(event) => setStartDate(event.target.value)}
                    placeholder="Mês inicial"
                  />
                </div>
                <div className="flex-1">
                  <label className="mb-1.5 block text-sm text-muted-foreground">Mês Final</label>
                  <Input
                    type="month"
                    value={endDate}
                    onChange={(event) => setEndDate(event.target.value)}
                    placeholder="Mês final"
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
                        setCriticalityFilter("Todas")
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

        <Card>
          <CardHeader>
            <CardTitle>Ativos ({filteredAssets.length})</CardTitle>
            <CardDescription>Lista de todos os ativos cadastrados no sistema</CardDescription>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="py-12 text-center">
                <p className="text-muted-foreground">Carregando ativos...</p>
              </div>
            ) : error ? (
              <div className="py-12 text-center">
                <AlertCircle className="mx-auto mb-4 h-12 w-12 text-destructive" />
                <p className="mb-2 font-medium text-destructive">{error}</p>
                <p className="text-sm text-muted-foreground">Execute os scripts de migracao no PostgreSQL</p>
              </div>
            ) : filteredAssets.length === 0 ? (
              <div className="py-12 text-center text-muted-foreground">
                <p className="mb-1 text-lg font-medium">Nenhum ativo encontrado</p>
                <p className="text-sm">Ajuste os filtros ou cadastre um novo ativo</p>
              </div>
            ) : (
              <div className="space-y-3">
                {filteredAssets.map((asset) => (
                  <div
                    key={asset.id}
                    className="flex items-center justify-between rounded-lg border p-4 transition-colors hover:bg-accent"
                  >
                    <div className="min-w-0 flex-1 space-y-1">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(asset.status)}
                        <p className="font-medium">{asset.nome}</p>
                      </div>
                      <p className="text-sm text-muted-foreground">
                        {asset.tipo} - {asset.localizacao}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        <Calendar className="mr-1 inline h-3 w-3" />
                        Proxima manutencao:{" "}
                        {asset.proxima_manutencao
                          ? formatMaintenanceDate(asset.proxima_manutencao)
                          : normalizeCriticality(asset.criticidade) === "Alta"
                            ? "Obrigatoria neste mes"
                            : "Nao agendada"}
                      </p>
                    </div>
                    <div className="ml-4 flex items-center gap-3">
                      <span
                        className={`whitespace-nowrap rounded-full px-3 py-1 text-xs font-medium ${getCriticalityColor(asset.criticidade)}`}
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

        <Card>
          <CardHeader>
            <CardTitle>Relatorio mensal de manutencao</CardTitle>
            <CardDescription>
              Selecione um ou mais meses para baixar um arquivo com pendencias e realizacoes por competencia.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {reportMonthOptions.length === 0 ? (
              <div className="rounded-lg border border-dashed p-6 text-sm text-muted-foreground">
                Ainda nao ha dados suficientes para gerar o relatorio.
              </div>
            ) : (
              <>
                <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
                  {reportMonthOptions.map((item) => (
                    <label
                      key={item.monthKey}
                      className="flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors hover:bg-accent"
                    >
                      <Checkbox
                        checked={selectedReportMonths.includes(item.monthKey)}
                        onCheckedChange={(checked) => toggleReportMonth(item.monthKey, Boolean(checked))}
                      />
                      <div className="space-y-1">
                        <p className="font-medium capitalize">{item.monthLabel}</p>
                        <p className="text-sm text-muted-foreground">
                          {item.completedCount} realizadas de {item.requiredCount} previstas
                        </p>
                        <p className="text-xs text-muted-foreground">{item.pendingCount} pendente(s)</p>
                      </div>
                    </label>
                  ))}
                </div>

                <div className="flex flex-col gap-3 rounded-lg border bg-muted/30 p-4 md:flex-row md:items-center md:justify-between">
                  <div>
                    <p className="font-medium">Exportacao selecionada</p>
                    <p className="text-sm text-muted-foreground">
                      {selectedReportMonths.length === 0
                        ? "Nenhum mes selecionado."
                        : `${selectedReportMonths.length} mes(es) selecionado(s) para baixar em HTML.`}
                    </p>
                  </div>
                  <Button onClick={handleExportReport} disabled={isExportingReport || selectedReportMonths.length === 0}>
                    <Download className="mr-2 h-4 w-4" />
                    {isExportingReport ? "Gerando..." : "Baixar Relatorio"}
                  </Button>
                </div>
              </>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Legenda de Criticidade</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-4 sm:flex-row">
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-destructive" />
              <span className="text-sm text-muted-foreground">Alta - Manutencao a cada 30 dias</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-warning" />
              <span className="text-sm text-muted-foreground">Media - Manutencao a cada 60 dias</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-3 w-3 rounded-full bg-success" />
              <span className="text-sm text-muted-foreground">Baixa - Manutencao a cada 180 dias</span>
            </div>
          </CardContent>
        </Card>

        <Sheet open={isPendingSheetOpen} onOpenChange={setIsPendingSheetOpen}>
          <SheetContent className="w-full sm:max-w-xl">
            <SheetHeader>
              <SheetTitle>Maquinas pendentes de manutencao</SheetTitle>
              <SheetDescription>{pendingAssets.length} maquina(s) pendente(s) no mes selecionado.</SheetDescription>
            </SheetHeader>
            <div className="flex-1 space-y-3 overflow-y-auto px-4 pb-4">
              {pendingAssets.length === 0 ? (
                <div className="rounded-lg border border-dashed p-6 text-sm text-muted-foreground">
                  Nenhuma maquina pendente no momento.
                </div>
              ) : (
                pendingAssets.map((asset) => (
                  <Link
                    key={asset.id}
                    href={`/manutencao/${asset.id}`}
                    onClick={() => setIsPendingSheetOpen(false)}
                    className="flex items-center justify-between gap-4 rounded-lg border p-4 transition-colors hover:bg-accent"
                  >
                    <div className="min-w-0 space-y-1">
                      <p className="font-medium">{asset.nome}</p>
                      <p className="text-sm text-muted-foreground">
                        {asset.tipo} - {asset.localizacao}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {normalizeCriticality(asset.criticidade) === "Alta"
                          ? "Obrigatoria neste mes"
                          : asset.proxima_manutencao
                            ? `Prevista para ${formatMaintenanceDate(asset.proxima_manutencao)}`
                            : "Data nao informada"}
                      </p>
                    </div>
                    <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground" />
                  </Link>
                ))
              )}
            </div>
          </SheetContent>
        </Sheet>
      </div>
    </DashboardLayout>
  )
}
