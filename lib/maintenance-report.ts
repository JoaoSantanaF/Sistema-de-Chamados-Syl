export interface MaintenanceAsset {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  proxima_manutencao?: string | null
  created_at?: string | null
}

export interface MaintenanceCycle {
  id: string
  ativo_id: string
  ativo_nome?: string
  data_proxima_manutencao?: string | null
  data_fim?: string | null
  status: string
}

export interface MonthlyMetricAsset {
  assetId: string
  assetName: string
  assetType: string
  location: string
  criticality: string
  dueDateLabel: string
  completed: boolean
  completionDate?: string | null
}

export interface MonthlyMetricItem {
  monthKey: string
  monthLabel: string
  requiredCount: number
  completedCount: number
  pendingCount: number
  completionRate: number
  goalReached: boolean
  assets: MonthlyMetricAsset[]
}

const MONTHLY_GOAL = 90

export function normalizeText(value: string) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/Ãƒ/g, "a")
    .replace(/Ã‚/g, "")
    .toLowerCase()
    .trim()
}

export function normalizeCriticality(value: string) {
  const normalized = normalizeText(value)

  if (normalized.includes("alta")) return "Alta"
  if (normalized.includes("media")) return "Media"
  if (normalized.includes("baixa")) return "Baixa"

  return value
}

export function parseMaintenanceDate(dateValue?: string | null) {
  if (!dateValue) return null
  const normalized = dateValue.includes("T") ? dateValue : `${dateValue}T00:00:00`
  const parsed = new Date(normalized)
  return Number.isNaN(parsed.getTime()) ? null : parsed
}

export function getMonthKey(date: Date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`
}

export function formatMonthLabel(monthKey: string) {
  const [year, month] = monthKey.split("-").map(Number)
  return new Date(year, month - 1, 1).toLocaleDateString("pt-BR", { month: "long", year: "numeric" })
}

function isSameMonthKey(dateValue: string | null | undefined, monthKey: string) {
  const parsed = parseMaintenanceDate(dateValue)
  return parsed ? getMonthKey(parsed) === monthKey : false
}

function getMonthBounds(monthKey: string) {
  const [year, month] = monthKey.split("-").map(Number)
  const start = new Date(year, month - 1, 1)
  const end = new Date(year, month, 0, 23, 59, 59, 999)
  return { start, end }
}

function isAssetActiveInMonth(asset: MaintenanceAsset, monthKey: string) {
  const createdAt = parseMaintenanceDate(asset.created_at)
  if (!createdAt) return true

  const { end } = getMonthBounds(monthKey)
  return createdAt <= end
}

function collectAvailableMonthKeys(
  assets: MaintenanceAsset[],
  cycles: MaintenanceCycle[],
  monthKeys: string[] | undefined,
  currentDate: Date
) {
  if (monthKeys && monthKeys.length > 0) {
    return [...new Set(monthKeys)].sort((a, b) => b.localeCompare(a))
  }

  const keys = new Set(monthKeys ?? [])
  const currentMonthKey = getMonthKey(currentDate)

  cycles.forEach((cycle) => {
    const dueDate = parseMaintenanceDate(cycle.data_proxima_manutencao)
    if (dueDate) keys.add(getMonthKey(dueDate))
  })

  assets.forEach((asset) => {
    const nextDate = parseMaintenanceDate(asset.proxima_manutencao)
    if (nextDate) keys.add(getMonthKey(nextDate))

    if (normalizeCriticality(asset.criticidade) === "Alta") {
      const createdAt = parseMaintenanceDate(asset.created_at) ?? currentDate
      const cursor = new Date(createdAt.getFullYear(), createdAt.getMonth(), 1)
      const limit = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)

      while (cursor <= limit) {
        keys.add(getMonthKey(cursor))
        cursor.setMonth(cursor.getMonth() + 1)
      }
    }
  })

  keys.add(currentMonthKey)

  return [...keys].sort((a, b) => b.localeCompare(a))
}

export function buildMonthlyMetrics(
  assets: MaintenanceAsset[],
  cycles: MaintenanceCycle[],
  options?: { monthKeys?: string[]; currentDate?: Date }
): MonthlyMetricItem[] {
  const currentDate = options?.currentDate ?? new Date()
  const availableMonthKeys = collectAvailableMonthKeys(assets, cycles, options?.monthKeys, currentDate)

  return availableMonthKeys
    .map((monthKey) => {
      const requiredAssets = new Map<string, MonthlyMetricAsset>()

      assets.forEach((asset) => {
        if (normalizeCriticality(asset.criticidade) === "Alta" && isAssetActiveInMonth(asset, monthKey)) {
          requiredAssets.set(asset.id, {
            assetId: asset.id,
            assetName: asset.nome,
            assetType: asset.tipo,
            location: asset.localizacao,
            criticality: normalizeCriticality(asset.criticidade),
            dueDateLabel: "Obrigatoria no mes",
            completed: false,
          })
        }

        if (isSameMonthKey(asset.proxima_manutencao, monthKey)) {
          requiredAssets.set(asset.id, {
            assetId: asset.id,
            assetName: asset.nome,
            assetType: asset.tipo,
            location: asset.localizacao,
            criticality: normalizeCriticality(asset.criticidade),
            dueDateLabel: parseMaintenanceDate(asset.proxima_manutencao)?.toLocaleDateString("pt-BR") ?? "Agendada no mes",
            completed: false,
          })
        }
      })

      cycles.forEach((cycle) => {
        if (!isSameMonthKey(cycle.data_proxima_manutencao, monthKey)) return

        const asset = assets.find((item) => item.id === cycle.ativo_id)
        if (!asset) return

        requiredAssets.set(asset.id, {
          assetId: asset.id,
          assetName: asset.nome,
          assetType: asset.tipo,
          location: asset.localizacao,
          criticality: normalizeCriticality(asset.criticidade),
          dueDateLabel:
            parseMaintenanceDate(cycle.data_proxima_manutencao)?.toLocaleDateString("pt-BR") ?? "Agendada no mes",
          completed: false,
        })
      })

      const completedByAsset = new Map<string, string | null>()
      cycles.forEach((cycle) => {
        if (!requiredAssets.has(cycle.ativo_id)) return
        if (!normalizeText(cycle.status).includes("conclu")) return
        if (!isSameMonthKey(cycle.data_fim, monthKey)) return

        const previousCompletion = completedByAsset.get(cycle.ativo_id)
        const currentCompletion = cycle.data_fim ?? null

        if (!previousCompletion || (currentCompletion && previousCompletion > currentCompletion)) {
          completedByAsset.set(cycle.ativo_id, currentCompletion)
        }
      })

      const metricAssets = [...requiredAssets.values()]
        .map((asset) => ({
          ...asset,
          completed: completedByAsset.has(asset.assetId),
          completionDate: completedByAsset.get(asset.assetId) ?? null,
        }))
        .sort((a, b) => a.assetName.localeCompare(b.assetName))

      const requiredCount = metricAssets.length
      const completedCount = metricAssets.filter((asset) => asset.completed).length
      const pendingCount = Math.max(requiredCount - completedCount, 0)
      const completionRate = requiredCount > 0 ? Math.round((completedCount / requiredCount) * 100) : 0

      return {
        monthKey,
        monthLabel: formatMonthLabel(monthKey),
        requiredCount,
        completedCount,
        pendingCount,
        completionRate,
        goalReached: requiredCount > 0 && completionRate >= MONTHLY_GOAL,
        assets: metricAssets,
      }
    })
    .filter((item) => item.requiredCount > 0 || (options?.monthKeys ?? []).includes(item.monthKey))
}
