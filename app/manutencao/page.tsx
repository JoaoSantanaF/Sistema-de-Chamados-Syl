"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import Link from "next/link"
import {
  AlertCircle,
  Calendar,
  CheckCircle,
  ChevronRight,
  Clock,
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
import { Input } from "@/components/ui/input"
import { Progress } from "@/components/ui/progress"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from "@/components/ui/sheet"

interface Asset {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  proxima_manutencao?: string
  status: string
  created_at?: string
}

interface MaintenanceCycle {
  id: string
  ativo_id: string
  ativo_nome: string
  data_proxima_manutencao: string
  data_fim?: string | null
  status: string
}

interface MonthlyHistoryItem {
  monthKey: string
  monthLabel: string
  requiredCount: number
  completedCount: number
  completionRate: number
  goalReached: boolean
}

const MONTHLY_GOAL = 90

export default function ManutencaoPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [assets, setAssets] = useState<Asset[]>([])
  const [cycles, setCycles] = useState<MaintenanceCycle[]>([])
  const [filteredAssets, setFilteredAssets] = useState<Asset[]>([])
  const [searchTerm, setSearchTerm] = useState("")
  const [criticalityFilter, setCriticalityFilter] = useState<string>("Todas")
  const [statusFilter, setStatusFilter] = useState<string>("Todos")
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")
  const [isPendingSheetOpen, setIsPendingSheetOpen] = useState(false)
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
    loadMaintenanceData()
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

  const normalizeText = (value: string) =>
    value
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/Ã/g, "a")
      .replace(/Â/g, "")
      .toLowerCase()
      .trim()

  const normalizeCriticality = (value: string) => {
    const normalized = normalizeText(value)

    if (normalized.includes("alta")) return "Alta"
    if (normalized.includes("media")) return "Media"
    if (normalized.includes("baixa")) return "Baixa"

    return value
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

  const today = new Date()
  const currentMonth = today.getMonth()
  const currentYear = today.getFullYear()
  const currentMonthKey = `${currentYear}-${String(currentMonth + 1).padStart(2, "0")}`
  const monthLabel = today.toLocaleDateString("pt-BR", { month: "long", year: "numeric" })

  const parseDate = (dateValue?: string | null) => {
    if (!dateValue) return null
    const normalized = dateValue.includes("T") ? dateValue : `${dateValue}T00:00:00`
    const parsed = new Date(normalized)
    return Number.isNaN(parsed.getTime()) ? null : parsed
  }

  const isDateInCurrentMonth = (dateValue?: string | null) => {
    const parsedDate = parseDate(dateValue)
    if (!parsedDate) return false

    return parsedDate.getMonth() === currentMonth && parsedDate.getFullYear() === currentYear
  }

  const isSameMonth = (referenceDate: Date, dateValue?: string | null) => {
    const parsedDate = parseDate(dateValue)
    if (!parsedDate) return false

    return (
      parsedDate.getMonth() === referenceDate.getMonth() &&
      parsedDate.getFullYear() === referenceDate.getFullYear()
    )
  }

  const isAssetActiveInMonth = (asset: Asset, referenceDate: Date) => {
    const createdAt = parseDate(asset.created_at)
    if (!createdAt) return true

    return createdAt <= referenceDate
  }

  const completedCyclesThisMonth = cycles.filter((cycle) => {
    const normalizedStatus = normalizeText(cycle.status)
    return normalizedStatus.includes("conclu") && isDateInCurrentMonth(cycle.data_fim)
  })

  const completedCurrentMonthAssetIds = new Set(completedCyclesThisMonth.map((cycle) => cycle.ativo_id))
  const cycleRequiredCurrentMonthAssetIds = new Set(
    cycles.filter((cycle) => isDateInCurrentMonth(cycle.data_proxima_manutencao)).map((cycle) => cycle.ativo_id),
  )
  const highPriorityCurrentMonthAssetIds = new Set(
    assets
      .filter((asset) => normalizeCriticality(asset.criticidade) === "Alta" && isAssetActiveInMonth(asset, today))
      .map((asset) => asset.id),
  )
  const requiredCurrentMonthAssetIds = new Set([...cycleRequiredCurrentMonthAssetIds, ...highPriorityCurrentMonthAssetIds])
  const currentMonthCompletedCount = [...completedCurrentMonthAssetIds].filter((assetId) =>
    requiredCurrentMonthAssetIds.has(assetId),
  ).length
  const monthlyCompletionRate =
    requiredCurrentMonthAssetIds.size > 0
      ? Math.round((currentMonthCompletedCount / requiredCurrentMonthAssetIds.size) * 100)
      : 0
  const goalReached = requiredCurrentMonthAssetIds.size > 0 && monthlyCompletionRate >= MONTHLY_GOAL
  const remainingForGoal =
    requiredCurrentMonthAssetIds.size > 0
      ? Math.max(Math.ceil((MONTHLY_GOAL / 100) * requiredCurrentMonthAssetIds.size) - currentMonthCompletedCount, 0)
      : 0

  const pendingAssets = assets
    .filter((asset) => {
      if (normalizeCriticality(asset.criticidade) === "Alta") {
        return isAssetActiveInMonth(asset, today) && !completedCurrentMonthAssetIds.has(asset.id)
      }

      const nextMaintenanceDate = parseDate(asset.proxima_manutencao)
      return nextMaintenanceDate ? nextMaintenanceDate <= today : false
    })
    .sort((a, b) => {
      const isHighA = normalizeCriticality(a.criticidade) === "Alta"
      const isHighB = normalizeCriticality(b.criticidade) === "Alta"
      if (isHighA !== isHighB) return isHighA ? -1 : 1

      const dateA = parseDate(a.proxima_manutencao)?.getTime() ?? Number.MAX_SAFE_INTEGER
      const dateB = parseDate(b.proxima_manutencao)?.getTime() ?? Number.MAX_SAFE_INTEGER
      return dateA - dateB
    })

  const monthlyHistoryMap = new Map<string, MonthlyHistoryItem>()

  cycles.forEach((cycle) => {
    const dueDate = parseDate(cycle.data_proxima_manutencao)
    if (!dueDate) return

    const monthKey = `${dueDate.getFullYear()}-${String(dueDate.getMonth() + 1).padStart(2, "0")}`
    const normalizedStatus = normalizeText(cycle.status)
    const completedInSameMonth = normalizedStatus.includes("conclu") && isSameMonth(dueDate, cycle.data_fim)
    const existingMonth = monthlyHistoryMap.get(monthKey)

    if (existingMonth) {
      existingMonth.requiredCount += 1
      if (completedInSameMonth) existingMonth.completedCount += 1
      return
    }

    monthlyHistoryMap.set(monthKey, {
      monthKey,
      monthLabel: dueDate.toLocaleDateString("pt-BR", { month: "long", year: "numeric" }),
      requiredCount: 1,
      completedCount: completedInSameMonth ? 1 : 0,
      completionRate: 0,
      goalReached: false,
    })
  })

  assets
    .filter((asset) => normalizeCriticality(asset.criticidade) === "Alta")
    .forEach((asset) => {
      const createdAt = parseDate(asset.created_at) ?? today
      const startMonth = new Date(createdAt.getFullYear(), createdAt.getMonth(), 1)
      const endMonth = new Date(currentYear, currentMonth, 1)

      for (let monthCursor = new Date(startMonth); monthCursor <= endMonth; monthCursor.setMonth(monthCursor.getMonth() + 1)) {
        const monthKey = `${monthCursor.getFullYear()}-${String(monthCursor.getMonth() + 1).padStart(2, "0")}`
        const monthDate = new Date(monthCursor.getFullYear(), monthCursor.getMonth(), 1)
        const completedInMonth = cycles.some((cycle) => {
          const normalizedStatus = normalizeText(cycle.status)
          return cycle.ativo_id === asset.id && normalizedStatus.includes("conclu") && isSameMonth(monthDate, cycle.data_fim)
        })

        const existingMonth = monthlyHistoryMap.get(monthKey)

        if (existingMonth) {
          existingMonth.requiredCount += 1
          if (completedInMonth) existingMonth.completedCount += 1
        } else {
          monthlyHistoryMap.set(monthKey, {
            monthKey,
            monthLabel: monthDate.toLocaleDateString("pt-BR", { month: "long", year: "numeric" }),
            requiredCount: 1,
            completedCount: completedInMonth ? 1 : 0,
            completionRate: 0,
            goalReached: false,
          })
        }
      }
    })

  if (requiredCurrentMonthAssetIds.size > 0) {
    monthlyHistoryMap.set(currentMonthKey, {
      monthKey: currentMonthKey,
      monthLabel,
      requiredCount: requiredCurrentMonthAssetIds.size,
      completedCount: currentMonthCompletedCount,
      completionRate: 0,
      goalReached: false,
    })
  }

  const monthlyHistory = [...monthlyHistoryMap.values()]
    .map((item) => {
      const completionRate =
        item.requiredCount > 0 ? Math.round((item.completedCount / item.requiredCount) * 100) : 0

      return {
        ...item,
        completionRate,
        goalReached: item.requiredCount > 0 && completionRate >= MONTHLY_GOAL,
      }
    })
    .sort((a, b) => b.monthKey.localeCompare(a.monthKey))

  if (!user) return null

  return (
    <DashboardLayout>
      <div className="space-y-6">
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

          <Card className={goalReached ? "border-success/40 bg-success/5" : "border-warning/40 bg-warning/5"}>
            <CardHeader className="space-y-3 pb-2">
              <div className="flex items-center justify-between gap-3">
                <div>
                  <CardTitle className="text-sm font-medium">Meta mensal</CardTitle>
                  <CardDescription className="capitalize">{monthLabel}</CardDescription>
                </div>
                <Target className={goalReached ? "h-4 w-4 text-success" : "h-4 w-4 text-warning"} />
              </div>
              <Progress value={monthlyCompletionRate} className="h-3" />
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex items-end justify-between gap-3">
                <div className="text-2xl font-bold">{monthlyCompletionRate}%</div>
                <span className="text-xs font-medium text-muted-foreground">Meta {MONTHLY_GOAL}%</span>
              </div>
              <p className="text-sm text-muted-foreground">
                {currentMonthCompletedCount} de {requiredCurrentMonthAssetIds.size} maquinas necessarias concluidas neste mes.
              </p>
              <p className={`text-xs font-medium ${goalReached ? "text-success" : "text-warning"}`}>
                {requiredCurrentMonthAssetIds.size === 0
                  ? "Nenhuma manutencao prevista para este mes."
                  : goalReached
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
                  <label className="mb-1.5 block text-sm text-muted-foreground">Data Inicial</label>
                  <Input
                    type="date"
                    value={startDate}
                    onChange={(event) => setStartDate(event.target.value)}
                    placeholder="Data inicial"
                  />
                </div>
                <div className="flex-1">
                  <label className="mb-1.5 block text-sm text-muted-foreground">Data Final</label>
                  <Input
                    type="date"
                    value={endDate}
                    onChange={(event) => setEndDate(event.target.value)}
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
                          ? parseDate(asset.proxima_manutencao)?.toLocaleDateString("pt-BR")
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
            <CardTitle>Historico mensal de manutencao</CardTitle>
            <CardDescription>
              Registro por competencia, considerando apenas as maquinas que realmente precisavam de manutencao em cada mes.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {monthlyHistory.length === 0 ? (
              <div className="rounded-lg border border-dashed p-6 text-sm text-muted-foreground">
                Ainda nao ha ciclos suficientes para montar o historico mensal.
              </div>
            ) : (
              <div className="space-y-3">
                {monthlyHistory.map((item) => (
                  <div key={item.monthKey} className="rounded-lg border p-4">
                    <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                      <div>
                        <p className="text-base font-semibold capitalize">{item.monthLabel}</p>
                        <p className="text-sm text-muted-foreground">
                          {item.completedCount} de {item.requiredCount} manutencoes necessarias concluidas
                        </p>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-2xl font-bold">{item.completionRate}%</span>
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-medium ${
                            item.goalReached ? "bg-success/10 text-success" : "bg-warning/10 text-warning"
                          }`}
                        >
                          {item.goalReached ? "Meta batida" : "Abaixo da meta"}
                        </span>
                      </div>
                    </div>
                    <div className="mt-3">
                      <Progress value={item.completionRate} className="h-2.5" />
                    </div>
                  </div>
                ))}
              </div>
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
              <SheetDescription>
                {pendingAssets.length} maquina(s) com manutencao obrigatoria no mes ou vencida.
              </SheetDescription>
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
                            ? `Prevista para ${parseDate(asset.proxima_manutencao)?.toLocaleDateString("pt-BR")}`
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
