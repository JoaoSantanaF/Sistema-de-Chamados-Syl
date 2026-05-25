// Maintenance intervals by criticality (in days)
export const CRITICALITY_INTERVALS = {
  Alta: 30, // Criticidade 1
  Media: 60, // Criticidade 2
  Baixa: 180, // Criticidade 3
} as const

export type Criticality = keyof typeof CRITICALITY_INTERVALS

function normalizeCriticality(criticality: string): Criticality {
  const normalized = criticality
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim()

  if (normalized.includes("alta")) return "Alta"
  if (normalized.includes("baixa")) return "Baixa"
  return "Media"
}

const BRAZILIAN_HOLIDAYS_2025_2026 = [
  "2025-01-01", // Ano Novo
  "2025-02-24", // Carnaval
  "2025-02-25", // Carnaval
  "2025-04-18", // Sexta-feira Santa
  "2025-04-21", // Tiradentes
  "2025-05-01", // Dia do Trabalho
  "2025-06-19", // Corpus Christi
  "2025-09-07", // Independência
  "2025-10-12", // Nossa Senhora Aparecida
  "2025-11-02", // Finados
  "2025-11-15", // Proclamação da República
  "2025-12-25", // Natal
  "2026-01-01", // Ano Novo
  "2026-02-16", // Carnaval
  "2026-02-17", // Carnaval
  "2026-04-03", // Sexta-feira Santa
  "2026-04-21", // Tiradentes
  "2026-05-01", // Dia do Trabalho
  "2026-06-04", // Corpus Christi
  "2026-09-07", // Independência
  "2026-10-12", // Nossa Senhora Aparecida
  "2026-11-02", // Finados
  "2026-11-15", // Proclamação da República
  "2026-12-25", // Natal
]

/**
 * Check if a date is a business day (not weekend or holiday)
 */
export function isBusinessDay(date: Date): boolean {
  const dayOfWeek = date.getDay()
  // Sunday = 0, Saturday = 6
  if (dayOfWeek === 0 || dayOfWeek === 6) {
    return false
  }

  const dateString = date.toISOString().split("T")[0]
  return !BRAZILIAN_HOLIDAYS_2025_2026.includes(dateString)
}

/**
 * Get the next business day from a given date
 */
export function getNextBusinessDay(date: Date): Date {
  const nextDay = new Date(date)
  nextDay.setDate(nextDay.getDate() + 1)

  while (!isBusinessDay(nextDay)) {
    nextDay.setDate(nextDay.getDate() + 1)
  }

  return nextDay
}

/**
 * Add business days to a date (skipping weekends and holidays)
 */
export function addBusinessDays(startDate: Date, days: number): Date {
  let currentDate = new Date(startDate)
  let remainingDays = days

  while (remainingDays > 0) {
    currentDate = getNextBusinessDay(currentDate)
    remainingDays--
  }

  return currentDate
}

/**
 * Calculate the next maintenance date based on criticality (business days only)
 */
export function calculateNextMaintenanceDate(criticality: string, fromDate: Date = new Date()): Date {
  const days = CRITICALITY_INTERVALS[normalizeCriticality(criticality)]
  return addBusinessDays(fromDate, days)
}

/**
 * Format a date to Brazilian locale string
 */
export function formatDateBR(date: Date | string): string {
  if (typeof date === 'string') {
    const isoDate = date.match(/^(\d{4})-(\d{2})-(\d{2})/)
    if (isoDate) {
      const [, year, month, day] = isoDate
      return `${day}/${month}/${year}`
    }
  }

  const d = typeof date === 'string' ? new Date(date) : date
  return new Intl.DateTimeFormat('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(d)
}

/**
 * Get criticality label with interval
 */
export function getCriticalityLabel(criticidade: string): string {
  const labels: Record<string, string> = {
    Alta: "Alta (30 dias)",
    Media: "Media (60 dias)",
    Baixa: "Baixa (180 dias)",
  }
  return labels[normalizeCriticality(criticidade)] || "Desconhecida"
}

/**
 * Get criticality color classes
 */
export function getCriticalityColor(criticidade: string): string {
  const colors: Record<string, string> = {
    Alta: "bg-destructive/10 text-destructive",
    Media: "bg-warning/10 text-warning",
    Baixa: "bg-success/10 text-success",
  }
  return colors[normalizeCriticality(criticidade)] || "bg-muted text-muted-foreground"
}
