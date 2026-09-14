"use client"

import { useEffect, useMemo, useState } from "react"
import { useRouter } from "next/navigation"
import { DashboardLayout } from "@/components/dashboard-layout"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import {
  Boxes, Search, Package, AlertTriangle, Monitor, Laptop, Phone, Network,
  Mouse, Cable, Plug, Tag, MapPin, User, Server, Wifi, Plus, Edit2,
  Trash2, PlusCircle, MinusCircle, Info, HardDrive
} from "lucide-react"

// -------- Tipos --------
interface Categoria {
  id: string
  nome: string
  controle: "individual" | "quantidade"
  icone?: string | null
  ordem: number
}

interface Ativo {
  id: string
  nome: string
  tipo: string
  localizacao: string
  status: string
  criticidade?: string
  categoria_id?: string | null
  patrimonio?: string | null
  numero_serie?: string | null
  fabricante?: string | null
  modelo?: string | null
  data_aquisicao?: string | null
  valor_aquisicao?: number | null
  garantia_ate?: string | null
  responsavel?: string | null
  setor?: string | null
  observacoes?: string | null
}

interface EstoqueItem {
  id: string
  categoria_id?: string | null
  nome: string
  descricao?: string | null
  quantidade_total: number
  quantidade_em_uso: number
  quantidade_disponivel: number
  estoque_minimo: number
  localizacao?: string | null
}

// Mapa de ícones
const ICONS: Record<string, any> = {
  monitor: Monitor,
  laptop: Laptop,
  phone: Phone,
  network: Network,
  mouse: Mouse,
  cable: Cable,
  plug: Plug,
  server: Server,
  wifi: Wifi,
}

const SEM_CATEGORIA = "__sem_categoria__"

function statusColor(status: string): string {
  const s = (status || "").toLowerCase()
  if (s.includes("uso") || s === "operacional") return "bg-emerald-500/10 text-emerald-500 border border-emerald-500/20"
  if (s.includes("manuten")) return "bg-amber-500/10 text-amber-500 border border-amber-500/20"
  if (s.includes("estoque")) return "bg-blue-500/10 text-blue-500 border border-blue-500/20"
  if (s.includes("emprest")) return "bg-yellow-500/10 text-yellow-500 border border-yellow-500/20"
  if (s.includes("descart") || s === "inativo") return "bg-rose-500/10 text-rose-500 border border-rose-500/20"
  return "bg-muted text-muted-foreground border border-muted"
}

export default function AtivosPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [categorias, setCategorias] = useState<Categoria[]>([])
  const [ativos, setAtivos] = useState<Ativo[]>([])
  const [estoque, setEstoque] = useState<EstoqueItem[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState("")

  // Modais
  const [isAssetModalOpen, setIsAssetModalOpen] = useState(false)
  const [isStockModalOpen, setIsStockModalOpen] = useState(false)
  const [editingAsset, setEditingAsset] = useState<Ativo | null>(null)
  const [editingStock, setEditingStock] = useState<EstoqueItem | null>(null)
  const [submitting, setSubmitting] = useState(false)

  // Forms
  const [assetForm, setAssetForm] = useState({
    nome: "",
    categoria_id: "",
    tipo: "Computador",
    localizacao: "TI",
    criticidade: "Média",
    status: "Operacional",
    patrimonio: "",
    numero_serie: "",
    fabricante: "",
    modelo: "",
    responsavel: "",
    setor: "",
    observacoes: "",
  })

  const [stockForm, setStockForm] = useState({
    nome: "",
    categoria_id: "",
    quantidade_total: 0,
    quantidade_em_uso: 0,
    estoque_minimo: 2,
    localizacao: "Armário TI",
    descricao: "",
  })

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsed = JSON.parse(userData)
    if (parsed.role !== "admin") {
      router.push("/dashboard")
      return
    }
    setUser(parsed)
    loadData()
  }, [router])

  const loadData = async () => {
    try {
      const [cat, ati, est] = await Promise.all([
        fetch("/api/categorias").then((r) => (r.ok ? r.json() : [])),
        fetch("/api/ativos").then((r) => (r.ok ? r.json() : [])),
        fetch("/api/estoque").then((r) => (r.ok ? r.json() : [])),
      ])
      setCategorias(cat)
      setAtivos(ati)
      setEstoque(est)
    } catch (err) {
      console.error("Erro ao carregar inventário:", err)
    } finally {
      setLoading(false)
    }
  }

  // Abertura de Modal de Ativo (Novo ou Edição)
  const openNewAssetModal = (defaultCatId?: string) => {
    setEditingAsset(null)
    const firstIndivCat = defaultCatId || categorias.find((c) => c.controle === "individual")?.id || ""
    setAssetForm({
      nome: "",
      categoria_id: firstIndivCat,
      tipo: "Computador",
      localizacao: "TI",
      criticidade: "Média",
      status: "Operacional",
      patrimonio: "",
      numero_serie: "",
      fabricante: "",
      modelo: "",
      responsavel: "",
      setor: "",
      observacoes: "",
    })
    setIsAssetModalOpen(true)
  }

  const openEditAssetModal = (ativo: Ativo) => {
    setEditingAsset(ativo)
    setAssetForm({
      nome: ativo.nome || "",
      categoria_id: ativo.categoria_id || "",
      tipo: ativo.tipo || "Computador",
      localizacao: ativo.localizacao || "TI",
      criticidade: ativo.criticidade || "Média",
      status: ativo.status || "Operacional",
      patrimonio: ativo.patrimonio || "",
      numero_serie: ativo.numero_serie || "",
      fabricante: ativo.fabricante || "",
      modelo: ativo.modelo || "",
      responsavel: ativo.responsavel || "",
      setor: ativo.setor || "",
      observacoes: ativo.observacoes || "",
    })
    setIsAssetModalOpen(true)
  }

  const handleSaveAsset = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!assetForm.nome.trim()) {
      alert("O nome/hostname do ativo é obrigatório.")
      return
    }

    setSubmitting(true)
    try {
      const url = editingAsset ? `/api/ativos/${editingAsset.id}` : "/api/ativos"
      const method = editingAsset ? "PUT" : "POST"

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(assetForm),
      })

      if (!res.ok) {
        const error = await res.json()
        throw new Error(error.error || "Erro ao salvar ativo")
      }

      await loadData()
      setIsAssetModalOpen(false)
    } catch (err: any) {
      alert(err.message)
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteAsset = async (id: string, nome: string) => {
    if (!confirm(`Tem certeza que deseja remover o ativo "${nome}"? Esta ação removerá o item do inventário.`)) {
      return
    }
    try {
      const res = await fetch(`/api/ativos/${id}`, { method: "DELETE" })
      if (!res.ok) throw new Error("Falha ao excluir ativo")
      await loadData()
    } catch (err: any) {
      alert(err.message)
    }
  }

  // Abertura de Modal de Estoque
  const openNewStockModal = (defaultCatId?: string) => {
    setEditingStock(null)
    const firstQtdCat = defaultCatId || categorias.find((c) => c.controle === "quantidade")?.id || ""
    setStockForm({
      nome: "",
      categoria_id: firstQtdCat,
      quantidade_total: 1,
      quantidade_em_uso: 0,
      estoque_minimo: 2,
      localizacao: "Armário TI",
      descricao: "",
    })
    setIsStockModalOpen(true)
  }

  const openEditStockModal = (item: EstoqueItem) => {
    setEditingStock(item)
    setStockForm({
      nome: item.nome || "",
      categoria_id: item.categoria_id || "",
      quantidade_total: item.quantidade_total || 0,
      quantidade_em_uso: item.quantidade_em_uso || 0,
      estoque_minimo: item.estoque_minimo || 0,
      localizacao: item.localizacao || "",
      descricao: item.descricao || "",
    })
    setIsStockModalOpen(true)
  }

  const handleSaveStock = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!stockForm.nome.trim()) {
      alert("O nome do item é obrigatório.")
      return
    }

    setSubmitting(true)
    try {
      const url = editingStock ? `/api/estoque/${editingStock.id}` : "/api/estoque"
      const method = editingStock ? "PUT" : "POST"

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(stockForm),
      })

      if (!res.ok) {
        const error = await res.json()
        throw new Error(error.error || "Erro ao salvar item de estoque")
      }

      await loadData()
      setIsStockModalOpen(false)
    } catch (err: any) {
      alert(err.message)
    } finally {
      setSubmitting(false)
    }
  }

  const handleDeleteStock = async (id: string, nome: string) => {
    if (!confirm(`Deseja remover "${nome}" do controle de estoque?`)) return
    try {
      const res = await fetch(`/api/estoque/${id}`, { method: "DELETE" })
      if (!res.ok) throw new Error("Erro ao excluir item")
      await loadData()
    } catch (err: any) {
      alert(err.message)
    }
  }

  // Ajuste rápido de quantidade em uso (+1 ou -1)
  const handleQuickStockChange = async (item: EstoqueItem, delta: number) => {
    const novoEmUso = item.quantidade_em_uso + delta
    if (novoEmUso < 0 || novoEmUso > item.quantidade_total) return

    try {
      const res = await fetch(`/api/estoque/${item.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ quantidade_em_uso: novoEmUso }),
      })
      if (res.ok) {
        setEstoque((prev) =>
          prev.map((e) =>
            e.id === item.id
              ? { ...e, quantidade_em_uso: novoEmUso, quantidade_disponivel: e.quantidade_total - novoEmUso }
              : e
          )
        )
      }
    } catch (err) {
      console.error(err)
    }
  }

  const termo = search.trim().toLowerCase()

  const ativosFiltrados = useMemo(
    () =>
      ativos.filter(
        (a) =>
          !termo ||
          [a.nome, a.patrimonio, a.responsavel, a.localizacao, a.fabricante, a.modelo, a.numero_serie]
            .filter(Boolean)
            .some((v) => String(v).toLowerCase().includes(termo))
      ),
    [ativos, termo]
  )

  const estoqueFiltrado = useMemo(
    () =>
      estoque.filter(
        (e) =>
          !termo ||
          [e.nome, e.localizacao, e.descricao]
            .filter(Boolean)
            .some((v) => String(v).toLowerCase().includes(termo))
      ),
    [estoque, termo]
  )

  const ativosPorCat = (catId: string) => ativosFiltrados.filter((a) => a.categoria_id === catId)
  const estoquePorCat = (catId: string) => estoqueFiltrado.filter((e) => e.categoria_id === catId)
  const ativosSemCat = ativosFiltrados.filter((a) => !a.categoria_id)

  const totalItens = ativos.length + estoque.reduce((s, e) => s + e.quantidade_total, 0)
  const estoqueBaixo = estoque.filter((e) => e.quantidade_disponivel <= e.estoque_minimo).length
  const servidoresCount = ativos.filter((a) => {
    const c = categorias.find((cat) => cat.id === a.categoria_id)
    return c?.nome.toLowerCase().includes("servidor")
  }).length
  const apCount = ativos.filter((a) => {
    const c = categorias.find((cat) => cat.id === a.categoria_id)
    return c?.nome.toLowerCase().includes("point") || c?.nome.toLowerCase().includes("wifi")
  }).length

  if (!user || loading) return null

  const stats = [
    { label: "Equipamentos Totais", value: ativos.length, icon: Package },
    { label: "Servidores & APs", value: servidoresCount + apCount, icon: Server },
    { label: "Tipos em Estoque", value: estoque.length, icon: Mouse },
    { label: "Estoque Baixo", value: estoqueBaixo, icon: AlertTriangle, alerta: estoqueBaixo > 0 },
  ]

  const individualCategories = categorias.filter((c) => c.controle === "individual")
  const quantityCategories = categorias.filter((c) => c.controle === "quantidade")

  return (
    <DashboardLayout>
      <div className="mx-auto max-w-6xl space-y-6">
        {/* Cabeçalho */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-lg bg-primary flex items-center justify-center flex-shrink-0 shadow-sm">
              <Boxes className="h-5 w-5 text-primary-foreground" />
            </div>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">Inventário de Ativos de TI</h1>
              <p className="text-sm text-muted-foreground">
                Controle de servidores, computadores, APs, estoque de periféricos e infraestrutura
              </p>
            </div>
          </div>

          {/* Botões de Ação */}
          <div className="flex items-center gap-2">
            <Button onClick={() => openNewAssetModal()} className="flex items-center gap-2">
              <Plus className="h-4 w-4" /> Novo Ativo
            </Button>
            <Button onClick={() => openNewStockModal()} variant="outline" className="flex items-center gap-2">
              <Plus className="h-4 w-4" /> Item de Estoque
            </Button>
          </div>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {stats.map((s) => {
            const Icon = s.icon
            return (
              <Card key={s.label} className="py-4">
                <CardContent className="flex items-center gap-3">
                  <div
                    className={`h-9 w-9 rounded-lg flex items-center justify-center ${
                      s.alerta ? "bg-amber-500/10" : "bg-muted"
                    }`}
                  >
                    <Icon className={`h-4 w-4 ${s.alerta ? "text-amber-500" : "text-muted-foreground"}`} />
                  </div>
                  <div>
                    <p className="text-xl font-bold leading-none">{s.value}</p>
                    <p className="text-xs text-muted-foreground mt-1">{s.label}</p>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Busca */}
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Buscar por nome, patrimônio, local, responsável, fabricante..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9"
          />
        </div>

        {/* Abas expansíveis por categoria */}
        <Accordion
          type="multiple"
          defaultValue={categorias.map((c) => c.id)}
          className="space-y-3"
        >
          {categorias.map((cat) => {
            const Icon = ICONS[cat.icone ?? ""] ?? Package
            const itensAtivos = cat.controle === "individual" ? ativosPorCat(cat.id) : []
            const itensEstoque = cat.controle === "quantidade" ? estoquePorCat(cat.id) : []
            const count = cat.controle === "individual" ? itensAtivos.length : itensEstoque.length

            return (
              <Card key={cat.id} className="py-0 overflow-hidden border shadow-sm">
                <AccordionItem value={cat.id} className="border-b-0">
                  <AccordionTrigger className="px-5 hover:no-underline">
                    <div className="flex items-center gap-3">
                      <div className="p-1.5 rounded-md bg-muted/60">
                        <Icon className="h-4 w-4 text-primary" />
                      </div>
                      <span className="font-semibold text-base">{cat.nome}</span>
                      <span className="text-xs text-muted-foreground rounded-full bg-muted px-2.5 py-0.5">
                        {count} {cat.controle === "quantidade" ? "tipo(s)" : "equipamento(s)"}
                      </span>
                    </div>
                  </AccordionTrigger>
                  <AccordionContent className="px-5 pt-1 pb-4">
                    {count === 0 ? (
                      <div className="flex items-center justify-between py-3 px-3 rounded-lg bg-muted/20 text-sm text-muted-foreground">
                        <span>Nenhum item cadastrado nesta categoria.</span>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() =>
                            cat.controle === "individual"
                              ? openNewAssetModal(cat.id)
                              : openNewStockModal(cat.id)
                          }
                          className="h-8 text-xs flex items-center gap-1"
                        >
                          <Plus className="h-3.5 w-3.5" /> Adicionar
                        </Button>
                      </div>
                    ) : cat.controle === "individual" ? (
                      <ListaIndividual
                        itens={itensAtivos}
                        onEdit={openEditAssetModal}
                        onDelete={handleDeleteAsset}
                      />
                    ) : (
                      <ListaEstoque
                        itens={itensEstoque}
                        onEdit={openEditStockModal}
                        onDelete={handleDeleteStock}
                        onQuickChange={handleQuickStockChange}
                      />
                    )}
                  </AccordionContent>
                </AccordionItem>
              </Card>
            )
          })}

          {/* Ativos sem categoria (se houver) */}
          {ativosSemCat.length > 0 && (
            <Card className="py-0 overflow-hidden border-dashed">
              <AccordionItem value={SEM_CATEGORIA} className="border-b-0">
                <AccordionTrigger className="px-5 hover:no-underline">
                  <div className="flex items-center gap-3">
                    <Package className="h-5 w-5 text-muted-foreground" />
                    <span className="font-semibold">Sem categoria</span>
                    <span className="text-xs text-muted-foreground rounded-full bg-muted px-2 py-0.5">
                      {ativosSemCat.length} item(ns)
                    </span>
                  </div>
                </AccordionTrigger>
                <AccordionContent className="px-5">
                  <ListaIndividual
                    itens={ativosSemCat}
                    onEdit={openEditAssetModal}
                    onDelete={handleDeleteAsset}
                  />
                </AccordionContent>
              </AccordionItem>
            </Card>
          )}
        </Accordion>

        {/* Modal: Novo / Editar Ativo Individual */}
        <Dialog open={isAssetModalOpen} onOpenChange={setIsAssetModalOpen}>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>{editingAsset ? "Editar Ativo" : "Novo Ativo de TI"}</DialogTitle>
              <DialogDescription>
                Cadastre servidores, computadores, APs e equipamentos de rede para rastreabilidade e localização.
              </DialogDescription>
            </DialogHeader>

            <form onSubmit={handleSaveAsset} className="space-y-4 py-2">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Nome / Hostname *</label>
                  <Input
                    required
                    placeholder="Ex: SRV-AD01, AP-PRODUCAO-01, DESK-ALMOX"
                    value={assetForm.nome}
                    onChange={(e) => setAssetForm({ ...assetForm, nome: e.target.value })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Categoria *</label>
                  <select
                    className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs mt-1"
                    value={assetForm.categoria_id}
                    onChange={(e) => setAssetForm({ ...assetForm, categoria_id: e.target.value })}
                  >
                    {individualCategories.map((c) => (
                      <option key={c.id} value={c.id} className="bg-background text-foreground">
                        {c.nome}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Localização / Setor Físico *</label>
                  <Input
                    required
                    placeholder="Ex: CPD, Sala Servidores, Galpão A, Almoxarifado"
                    value={assetForm.localizacao}
                    onChange={(e) => setAssetForm({ ...assetForm, localizacao: e.target.value })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Patrimônio (Tombo / Etiqueta)</label>
                  <Input
                    placeholder="Ex: PAT-0142, SYL-2026-09"
                    value={assetForm.patrimonio}
                    onChange={(e) => setAssetForm({ ...assetForm, patrimonio: e.target.value })}
                    className="mt-1"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Fabricante</label>
                  <Input
                    placeholder="Ex: Dell, Ubiquiti, Lenovo, Cisco"
                    value={assetForm.fabricante}
                    onChange={(e) => setAssetForm({ ...assetForm, fabricante: e.target.value })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Modelo</label>
                  <Input
                    placeholder="Ex: PowerEdge R440, U6-Pro"
                    value={assetForm.modelo}
                    onChange={(e) => setAssetForm({ ...assetForm, modelo: e.target.value })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Número de Série</label>
                  <Input
                    placeholder="Ex: 8XF29A3, CN012948"
                    value={assetForm.numero_serie}
                    onChange={(e) => setAssetForm({ ...assetForm, numero_serie: e.target.value })}
                    className="mt-1"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Responsável</label>
                  <Input
                    placeholder="Ex: João Vitor, Equipe TI"
                    value={assetForm.responsavel}
                    onChange={(e) => setAssetForm({ ...assetForm, responsavel: e.target.value })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Setor</label>
                  <Input
                    placeholder="Ex: TI, Produção, RH"
                    value={assetForm.setor}
                    onChange={(e) => setAssetForm({ ...assetForm, setor: e.target.value })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Status</label>
                  <select
                    className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs mt-1"
                    value={assetForm.status}
                    onChange={(e) => setAssetForm({ ...assetForm, status: e.target.value })}
                  >
                    <option value="Operacional" className="bg-background text-foreground">Operacional</option>
                    <option value="Em uso" className="bg-background text-foreground">Em uso</option>
                    <option value="Em estoque" className="bg-background text-foreground">Em estoque</option>
                    <option value="Em Manutenção" className="bg-background text-foreground">Em Manutenção</option>
                    <option value="Inativo" className="bg-background text-foreground">Inativo</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-muted-foreground">Observações / IP / Portas</label>
                <textarea
                  className="flex min-h-[70px] w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-xs mt-1 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                  placeholder="Ex: IP fixo 10.1.135.20, VLAN 10, Conectado no Switch 02 Porta 14"
                  value={assetForm.observacoes}
                  onChange={(e) => setAssetForm({ ...assetForm, observacoes: e.target.value })}
                />
              </div>

              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setIsAssetModalOpen(false)}>
                  Cancelar
                </Button>
                <Button type="submit" disabled={submitting}>
                  {submitting ? "Salvando..." : "Salvar Ativo"}
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>

        {/* Modal: Novo / Editar Item de Estoque */}
        <Dialog open={isStockModalOpen} onOpenChange={setIsStockModalOpen}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>{editingStock ? "Editar Estoque" : "Novo Item de Estoque"}</DialogTitle>
              <DialogDescription>
                Controle periféricos, cabos e peças por quantidade (disponíveis vs em uso).
              </DialogDescription>
            </DialogHeader>

            <form onSubmit={handleSaveStock} className="space-y-4 py-2">
              <div>
                <label className="text-xs font-semibold text-muted-foreground">Nome do Item *</label>
                <Input
                  required
                  placeholder="Ex: Mouse USB Dell, Teclado ABNT2, Cabo HDMI 2m"
                  value={stockForm.nome}
                  onChange={(e) => setStockForm({ ...stockForm, nome: e.target.value })}
                  className="mt-1"
                />
              </div>

              <div>
                <label className="text-xs font-semibold text-muted-foreground">Categoria *</label>
                <select
                  className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs mt-1"
                  value={stockForm.categoria_id}
                  onChange={(e) => setStockForm({ ...stockForm, categoria_id: e.target.value })}
                >
                  {quantityCategories.map((c) => (
                    <option key={c.id} value={c.id} className="bg-background text-foreground">
                      {c.nome}
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Total Geral</label>
                  <Input
                    type="number"
                    min="0"
                    required
                    value={stockForm.quantidade_total}
                    onChange={(e) => setStockForm({ ...stockForm, quantidade_total: parseInt(e.target.value) || 0 })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Em Uso</label>
                  <Input
                    type="number"
                    min="0"
                    max={stockForm.quantidade_total}
                    required
                    value={stockForm.quantidade_em_uso}
                    onChange={(e) => setStockForm({ ...stockForm, quantidade_em_uso: parseInt(e.target.value) || 0 })}
                    className="mt-1"
                  />
                </div>

                <div>
                  <label className="text-xs font-semibold text-muted-foreground">Estoque Mínimo</label>
                  <Input
                    type="number"
                    min="0"
                    required
                    value={stockForm.estoque_minimo}
                    onChange={(e) => setStockForm({ ...stockForm, estoque_minimo: parseInt(e.target.value) || 0 })}
                    className="mt-1"
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-muted-foreground">Local de Armazenamento</label>
                <Input
                  placeholder="Ex: Armário TI Prateleira 2, Gaveta 3"
                  value={stockForm.localizacao}
                  onChange={(e) => setStockForm({ ...stockForm, localizacao: e.target.value })}
                  className="mt-1"
                />
              </div>

              <div>
                <label className="text-xs font-semibold text-muted-foreground">Descrição / Detalhes</label>
                <Input
                  placeholder="Ex: Conexão USB-A, óptico 1000 DPI"
                  value={stockForm.descricao}
                  onChange={(e) => setStockForm({ ...stockForm, descricao: e.target.value })}
                  className="mt-1"
                />
              </div>

              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setIsStockModalOpen(false)}>
                  Cancelar
                </Button>
                <Button type="submit" disabled={submitting}>
                  {submitting ? "Salvando..." : "Salvar Estoque"}
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>
    </DashboardLayout>
  )
}

// -------- Listagem de Itens Individuais --------
function ListaIndividual({
  itens,
  onEdit,
  onDelete,
}: {
  itens: Ativo[]
  onEdit: (ativo: Ativo) => void
  onDelete: (id: string, nome: string) => void
}) {
  return (
    <div className="divide-y divide-border/50">
      {itens.map((a) => (
        <div
          key={a.id}
          className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 py-3 text-sm hover:bg-muted/30 px-2 rounded-md transition-colors"
        >
          <div className="flex flex-col gap-1 min-w-[12rem] flex-1">
            <div className="flex items-center gap-2">
              <span className="font-semibold text-foreground">{a.nome}</span>
              <span className={`text-[11px] px-2 py-0.5 rounded-full font-medium ${statusColor(a.status)}`}>
                {a.status}
              </span>
            </div>

            <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-muted-foreground">
              {a.localizacao && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-3 w-3 text-primary/70" /> {a.localizacao}
                </span>
              )}
              {a.responsavel && (
                <span className="flex items-center gap-1">
                  <User className="h-3 w-3 text-primary/70" /> {a.responsavel}
                </span>
              )}
              {a.patrimonio && (
                <span className="flex items-center gap-1">
                  <Tag className="h-3 w-3 text-primary/70" /> Tombo: {a.patrimonio}
                </span>
              )}
              {(a.fabricante || a.modelo) && (
                <span className="flex items-center gap-1">
                  <HardDrive className="h-3 w-3 text-primary/70" /> {[a.fabricante, a.modelo].filter(Boolean).join(" ")}
                </span>
              )}
            </div>
          </div>

          <div className="flex items-center gap-1 self-end sm:self-center">
            <Button
              size="sm"
              variant="ghost"
              onClick={() => onEdit(a)}
              className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground"
              title="Editar ativo"
            >
              <Edit2 className="h-3.5 w-3.5" />
            </Button>
            <Button
              size="sm"
              variant="ghost"
              onClick={() => onDelete(a.id, a.nome)}
              className="h-8 w-8 p-0 text-muted-foreground hover:text-destructive"
              title="Excluir ativo"
            >
              <Trash2 className="h-3.5 w-3.5" />
            </Button>
          </div>
        </div>
      ))}
    </div>
  )
}

// -------- Listagem de Itens de Estoque --------
function ListaEstoque({
  itens,
  onEdit,
  onDelete,
  onQuickChange,
}: {
  itens: EstoqueItem[]
  onEdit: (item: EstoqueItem) => void
  onDelete: (id: string, nome: string) => void
  onQuickChange: (item: EstoqueItem, delta: number) => void
}) {
  return (
    <div className="divide-y divide-border/50">
      {itens.map((e) => {
        const baixo = e.quantidade_disponivel <= e.estoque_minimo
        return (
          <div
            key={e.id}
            className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 py-3 text-sm hover:bg-muted/30 px-2 rounded-md transition-colors"
          >
            <div className="flex flex-col gap-1 min-w-[12rem] flex-1">
              <div className="flex items-center gap-2">
                <span className="font-semibold text-foreground">{e.nome}</span>
                {baixo && (
                  <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-500 border border-amber-500/20 flex items-center gap-1">
                    <AlertTriangle className="h-3 w-3" /> Repor estoque
                  </span>
                )}
              </div>

              <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-muted-foreground">
                {e.localizacao && (
                  <span className="flex items-center gap-1">
                    <MapPin className="h-3 w-3 text-primary/70" /> {e.localizacao}
                  </span>
                )}
                {e.descricao && <span>{e.descricao}</span>}
                <span>Mínimo: {e.estoque_minimo} un</span>
              </div>
            </div>

            {/* Contadores e Ações Rápidas */}
            <div className="flex items-center gap-3 self-end sm:self-center">
              <div className="flex items-center gap-2 bg-muted/40 px-2.5 py-1 rounded-lg border border-border/60">
                <div className="text-right">
                  <p className="text-xs font-semibold leading-tight text-foreground">
                    {e.quantidade_disponivel} / {e.quantidade_total}
                  </p>
                  <p className="text-[10px] text-muted-foreground leading-tight">disponíveis ({e.quantidade_em_uso} em uso)</p>
                </div>

                <div className="flex items-center gap-0.5 border-l border-border/60 pl-1.5 ml-1">
                  <button
                    type="button"
                    title="Devolver 1 ao estoque (diminui em uso)"
                    disabled={e.quantidade_em_uso <= 0}
                    onClick={() => onQuickChange(e, -1)}
                    className="p-1 rounded hover:bg-muted text-muted-foreground hover:text-foreground disabled:opacity-30 disabled:pointer-events-none"
                  >
                    <MinusCircle className="h-3.5 w-3.5" />
                  </button>
                  <button
                    type="button"
                    title="Entregar 1 para uso (aumenta em uso)"
                    disabled={e.quantidade_disponivel <= 0}
                    onClick={() => onQuickChange(e, 1)}
                    className="p-1 rounded hover:bg-muted text-muted-foreground hover:text-foreground disabled:opacity-30 disabled:pointer-events-none"
                  >
                    <PlusCircle className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>

              <div className="flex items-center gap-1">
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => onEdit(e)}
                  className="h-8 w-8 p-0 text-muted-foreground hover:text-foreground"
                  title="Editar item"
                >
                  <Edit2 className="h-3.5 w-3.5" />
                </Button>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => onDelete(e.id, e.nome)}
                  className="h-8 w-8 p-0 text-muted-foreground hover:text-destructive"
                  title="Excluir item"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </Button>
              </div>
            </div>
          </div>
        )
      })}
    </div>
  )
}
