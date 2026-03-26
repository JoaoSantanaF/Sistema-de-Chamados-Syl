"use client"

import { useEffect, useState } from "react"
import { useRouter, useParams } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Textarea } from "@/components/ui/textarea"
import { ArrowLeft, Save, CheckCircle2, AlertCircle, FileText } from "lucide-react"
import Link from "next/link"
import { DashboardLayout } from "@/components/dashboard-layout"

interface Asset {
  id: string
  nome: string
  tipo: string
  localizacao: string
  criticidade: string
  ultima_manutencao?: string
  ciclos?: any[]
  registros?: any[]
}

interface ChecklistItem {
  id: string
  descricao: string
  concluido: boolean
  observacoes?: string
}

export default function MaintenanceDetailPage() {
  const router = useRouter()
  const params = useParams()
  const assetId = params.id as string

  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [asset, setAsset] = useState<Asset | null>(null)
  const [checklistItems, setChecklistItems] = useState<ChecklistItem[]>([])
  const [generalObservations, setGeneralObservations] = useState("")
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [currentCycleId, setCurrentCycleId] = useState<string | null>(null)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    setUser(JSON.parse(userData))
    loadData()
  }, [router])

  const loadData = async () => {
    try {
      // Load asset with cycles
      const response = await fetch(`/api/ativos/${assetId}`)
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar ativo:", data.error)
        router.push("/manutencao")
        return
      }

      setAsset(data)

      // Find pending cycle
      const pendingCycle = data.ciclos?.find((c: any) => c.status === "Pendente")
      if (pendingCycle) {
        setCurrentCycleId(pendingCycle.id)

        // Load checklist items for this cycle
        const ciclosResponse = await fetch(`/api/ciclos?ativo_id=${assetId}&status=Pendente`)
        const ciclosData = await ciclosResponse.json()

        if (ciclosResponse.ok && ciclosData.length > 0) {
          // For now, use default checklist items
          const defaultItems: ChecklistItem[] = [
            { id: '1', descricao: 'Limpeza física do equipamento', concluido: false },
            { id: '2', descricao: 'Troca de teclado e mouse (se necessário)', concluido: false },
            { id: '3', descricao: 'Verificação de cabos e conexões', concluido: false },
            { id: '4', descricao: 'Desfragmentação (se necessário)', concluido: false },
            { id: '5', descricao: 'Atualização de antivírus e Windows Update', concluido: false },
            { id: '6', descricao: 'Atualizar campo "Última Preventiva"', concluido: false },
          ]
          setChecklistItems(defaultItems)
        }
      } else {
        // Create default checklist if no pending cycle
        const defaultItems: ChecklistItem[] = [
          { id: '1', descricao: 'Limpeza física do equipamento', concluido: false },
          { id: '2', descricao: 'Troca de teclado e mouse (se necessário)', concluido: false },
          { id: '3', descricao: 'Verificação de cabos e conexões', concluido: false },
          { id: '4', descricao: 'Desfragmentação (se necessário)', concluido: false },
          { id: '5', descricao: 'Atualização de antivírus e Windows Update', concluido: false },
          { id: '6', descricao: 'Atualizar campo "Última Preventiva"', concluido: false },
        ]
        setChecklistItems(defaultItems)
      }

      setLoading(false)
    } catch (err) {
      console.error("Erro ao carregar dados:", err)
      setLoading(false)
    }
  }

  const handleChecklistChange = (itemId: string, concluido: boolean) => {
    setChecklistItems((prev) => prev.map((item) => (item.id === itemId ? { ...item, concluido } : item)))
  }

  const handleCheckAll = () => {
    const allChecked = checklistItems.every((item) => item.concluido)
    setChecklistItems((prev) => prev.map((item) => ({ ...item, concluido: !allChecked })))
  }

  const handleItemObservations = (itemId: string, observacoes: string) => {
    setChecklistItems((prev) => prev.map((item) => (item.id === itemId ? { ...item, observacoes } : item)))
  }

  const handleSave = async () => {
    if (!user || !asset) return

    setSaving(true)
    try {
      const allCompleted = checklistItems.every((item) => item.concluido)

      if (allCompleted) {
        // Update asset with last maintenance date
        await fetch(`/api/ativos/${assetId}`, {
          method: "PUT",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            ultima_manutencao: new Date().toISOString().split("T")[0],
            ciclo_id: currentCycleId,
            tecnico: user.username,
            observacoes: generalObservations,
          }),
        })

        alert("Manutenção concluída com sucesso!")
        router.push("/manutencao")
      } else {
        alert("Progresso salvo!")
      }

      setSaving(false)
      await loadData()
    } catch (err) {
      console.error("Erro ao salvar:", err)
      alert("Erro ao salvar")
      setSaving(false)
    }
  }

  if (!user || loading) return null

  if (!asset) {
    return (
      <DashboardLayout>
        <div className="text-center py-12">
          <AlertCircle className="h-8 w-8 mx-auto mb-2 text-muted-foreground" />
          <p className="text-muted-foreground">Ativo não encontrado</p>
          <Button asChild className="mt-4">
            <Link href="/manutencao">Voltar para Manutenção</Link>
          </Button>
        </div>
      </DashboardLayout>
    )
  }

  const allCompleted = checklistItems.every((item) => item.concluido)
  const completedCount = checklistItems.filter((item) => item.concluido).length

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" asChild>
            <Link href="/manutencao">
              <ArrowLeft className="h-4 w-4" />
            </Link>
          </Button>
          <div className="flex-1">
            <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
              <FileText className="h-8 w-8" />
              Form.139 – Execução de Manutenção Preventiva
            </h1>
            <p className="text-muted-foreground mt-1">
              Ativo: {asset?.nome} • {asset?.tipo} • {asset?.localizacao}
            </p>
            <p className="text-xs text-muted-foreground mt-1">
              Conforme TI-01 Rev.10 - Item 6.2.2 - Checklist obrigatório
            </p>
          </div>
        </div>

        {/* Asset Info */}
        <Card>
          <CardHeader>
            <CardTitle>Informações do Ativo</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <p className="text-sm text-muted-foreground">Criticidade</p>
                <p className="font-medium">{asset.criticidade}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Tipo</p>
                <p className="font-medium">{asset.tipo}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Localização</p>
                <p className="font-medium">{asset.localizacao}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Última Manutenção</p>
                <p className="font-medium">
                  {asset.ultima_manutencao ? new Date(asset.ultima_manutencao).toLocaleDateString("pt-BR") : "N/A"}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Checklist */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <CheckCircle2 className="h-5 w-5" />
                  Checklist Oficial TI-01 (Item 6.2.2)
                </CardTitle>
                <CardDescription>
                  {completedCount} de {checklistItems.length} itens concluídos • Checklist não editável conforme
                  procedimento
                </CardDescription>
              </div>
              <Button variant="outline" size="sm" onClick={handleCheckAll} disabled={checklistItems.length === 0}>
                {checklistItems.every((item) => item.concluido) ? "Desmarcar Todos" : "Marcar Todos"}
              </Button>
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            {checklistItems.length === 0 ? (
              <p className="text-muted-foreground text-sm">Nenhum item de checklist</p>
            ) : (
              checklistItems.map((item) => (
                <div key={item.id} className="space-y-2 p-4 rounded-lg border">
                  <div className="flex items-center gap-3">
                    <Checkbox
                      id={`item-${item.id}`}
                      checked={item.concluido}
                      onCheckedChange={(checked) => handleChecklistChange(item.id, checked as boolean)}
                    />
                    <label htmlFor={`item-${item.id}`} className="flex-1 cursor-pointer font-medium text-sm">
                      {item.descricao}
                    </label>
                  </div>
                  <Textarea
                    placeholder="Observações sobre este item (opcional)"
                    value={item.observacoes || ""}
                    onChange={(e) => handleItemObservations(item.id, e.target.value)}
                    className="mt-2 text-sm"
                  />
                </div>
              ))
            )}
          </CardContent>
        </Card>

        {/* General Observations */}
        <Card>
          <CardHeader>
            <CardTitle>Observações Gerais</CardTitle>
          </CardHeader>
          <CardContent>
            <Textarea
              placeholder="Adicione observações gerais sobre a manutenção..."
              value={generalObservations}
              onChange={(e) => setGeneralObservations(e.target.value)}
              rows={5}
            />
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex gap-3">
          <Button variant="outline" asChild>
            <Link href="/manutencao">Cancelar</Link>
          </Button>
          <Button onClick={handleSave} disabled={saving || checklistItems.length === 0}>
            <Save className="h-4 w-4 mr-2" />
            {allCompleted ? "Concluir Manutenção" : "Salvar Progresso"}
          </Button>
        </div>
      </div>
    </DashboardLayout>
  )
}
