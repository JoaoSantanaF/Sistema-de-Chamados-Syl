import { NextRequest, NextResponse } from "next/server"

import { query } from "@/lib/db"
import {
  buildMonthlyMetrics,
  formatMaintenanceDate,
  type MaintenanceAsset,
  type MaintenanceCycle,
} from "@/lib/maintenance-report"

function escapeHtml(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const months = searchParams.getAll("months").filter(Boolean)

    if (months.length === 0) {
      return NextResponse.json({ error: "Informe ao menos um mes para gerar o relatorio." }, { status: 400 })
    }

    const [assets, cycles] = await Promise.all([
      query<MaintenanceAsset>("SELECT id, nome, tipo, localizacao, criticidade, proxima_manutencao, created_at FROM ativos ORDER BY nome ASC"),
      query<MaintenanceCycle>("SELECT id, ativo_id, data_proxima_manutencao, data_fim, status FROM ciclos_manutencao ORDER BY data_proxima_manutencao ASC"),
    ])

    const monthlyMetrics = buildMonthlyMetrics(assets, cycles, { monthKeys: months })

    const sections = monthlyMetrics
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
            body {
              font-family: Arial, sans-serif;
              margin: 32px;
              color: #1f2937;
              background: #f8fafc;
            }
            h1 {
              margin-bottom: 8px;
            }
            .subtitle {
              margin-bottom: 24px;
              color: #475569;
            }
            .month-section {
              background: #ffffff;
              border: 1px solid #dbe4ee;
              border-radius: 16px;
              padding: 20px;
              margin-bottom: 20px;
            }
            .month-header {
              display: flex;
              justify-content: space-between;
              gap: 16px;
              align-items: center;
              margin-bottom: 16px;
            }
            .month-header h2 {
              margin: 0 0 4px;
              text-transform: capitalize;
            }
            .month-header p,
            .summary span {
              margin: 0;
              color: #475569;
            }
            .summary {
              display: flex;
              flex-direction: column;
              gap: 6px;
              text-align: right;
            }
            .stats-grid {
              display: grid;
              grid-template-columns: repeat(3, minmax(0, 1fr));
              gap: 12px;
              margin-bottom: 16px;
            }
            .stat-card {
              background: #eff6ff;
              border-radius: 12px;
              padding: 12px;
            }
            .stat-card strong {
              display: block;
              font-size: 24px;
            }
            .stat-card span {
              color: #475569;
            }
            table {
              width: 100%;
              border-collapse: collapse;
              font-size: 14px;
            }
            th,
            td {
              padding: 10px 12px;
              border-bottom: 1px solid #e2e8f0;
              text-align: left;
            }
            th {
              background: #f1f5f9;
            }
            @media print {
              body {
                margin: 0;
                background: #ffffff;
              }
              .month-section {
                break-inside: avoid;
              }
            }
          </style>
        </head>
        <body>
          <h1>Relatorio de manutencao preventiva</h1>
          <p class="subtitle">Gerado em ${new Date().toLocaleString("pt-BR")} para os meses: ${months.join(", ")}</p>
          ${sections}
        </body>
      </html>
    `

    return new NextResponse(html, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Content-Disposition": `attachment; filename="relatorio-manutencao-${months.join("_")}.html"`,
      },
    })
  } catch (error) {
    console.error("Erro ao gerar relatorio de manutencao:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
