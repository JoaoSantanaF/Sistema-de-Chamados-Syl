import { type NextRequest, NextResponse } from "next/server"
import { query, queryOne, insert } from "@/lib/db"
import { calculateNextMaintenanceDate, type Criticality } from "@/lib/maintenance-utils"

// Checklist padrão conforme TI-01 Rev.10
const CHECKLIST_PADRAO = [
  "Limpeza física do equipamento",
  "Troca de teclado e mouse (se necessário)",
  "Verificação de cabos e conexões",
  "Desfragmentação (se necessário)",
  "Atualização de antivírus e Windows Update",
  "Atualizar campo 'Última Preventiva'",
]

interface Ativo {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: Criticality
  status: string
}

export async function POST(request: NextRequest) {
  try {
    const { ativoId } = await request.json()

    if (!ativoId) {
      return NextResponse.json({ error: "ID do ativo é obrigatório" }, { status: 400 })
    }

    // Buscar ativo
    const ativo = await queryOne<Ativo>(
      "SELECT * FROM ativos WHERE id = $1",
      [ativoId]
    )

    if (!ativo) {
      return NextResponse.json({ error: "Ativo não encontrado" }, { status: 404 })
    }

    // Calcular próxima data de manutenção baseada na criticidade
    const dataProximaManutencao = calculateNextMaintenanceDate(ativo.criticidade)

    // Criar ciclo de manutenção
    const ciclo = await insert<{ id: string }>("ciclos_manutencao", {
      ativo_id: ativoId,
      data_proxima_manutencao: dataProximaManutencao.toISOString().split("T")[0],
      status: "Pendente",
    })

    if (!ciclo) {
      return NextResponse.json({ error: "Erro ao criar ciclo de manutenção" }, { status: 500 })
    }

    // Criar itens do checklist
    for (const descricao of CHECKLIST_PADRAO) {
      await insert("itens_checklist", {
        ciclo_id: ciclo.id,
        descricao,
        concluido: false,
      })
    }

    // Atualizar próxima manutenção no ativo
    await query(
      "UPDATE ativos SET proxima_manutencao = $1, updated_at = NOW() WHERE id = $2",
      [dataProximaManutencao.toISOString().split("T")[0], ativoId]
    )

    return NextResponse.json({
      success: true,
      cycleId: ciclo.id,
      proximaManutencao: dataProximaManutencao.toISOString().split("T")[0]
    })
  } catch (error) {
    console.error("Erro ao gerar ciclo de manutenção:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
