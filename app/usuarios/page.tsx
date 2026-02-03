"use client"

import type React from "react"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Plus, Trash2, Shield, UserIcon, Pencil } from "lucide-react"
import { DashboardLayout } from "@/components/dashboard-layout"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"

interface User {
  id?: string
  username: string
  nome: string
  password?: string
  role: "admin" | "usuario"
  mustChangePassword?: boolean
}


export default function UsuariosPage() {
  const router = useRouter()
  const [currentUser, setCurrentUser] = useState<{ username: string; role: string } | null>(null)
  const [users, setUsers] = useState<User[]>([])
  const [showForm, setShowForm] = useState(false)
  const [editingUser, setEditingUser] = useState<string | null>(null)
  const [formData, setFormData] = useState({
    username: "",
    nome: "",
    password: "",
    role: "usuario" as "admin" | "usuario",
    mustChangePassword: true,
  })

  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    const parsedUser = JSON.parse(userData)
    if (parsedUser.role !== "admin") {
      router.push("/dashboard")
      return
    }
    setCurrentUser(parsedUser)
    loadUsers()
  }, [router])

  const loadUsers = async () => {
    try {
      const response = await fetch("/api/usuarios")
      const data = await response.json()

      if (!response.ok) {
        console.error("Erro ao carregar usuários:", data.error)
        return
      }

      setUsers(data)
    } catch (error) {
      console.error("Erro ao carregar usuários:", error)
    }
  }

  const handleEdit = (user: User) => {
    setEditingUser(user.username)
    setFormData({
      username: user.username,
      nome: user.nome,
      password: "",
      role: user.role,
      mustChangePassword: user.mustChangePassword ?? true,
    })
    setShowForm(true)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    try {
      if (editingUser) {
        // Editando usuário existente
        const userToUpdate = users.find((u) => u.username === editingUser)
        if (!userToUpdate) return

        const payload: Record<string, any> = {
          username: formData.username,
          nome: formData.nome,
          role: formData.role,
          mustChangePassword:
            formData.role === "usuario" ? formData.mustChangePassword : false,
        }
        if (formData.password) {
          payload.password = formData.password
        }

        const response = await fetch(`/api/usuarios/${userToUpdate.id}`, {
          method: "PUT",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload),
        })

        if (!response.ok) {
          const data = await response.json()
          alert("Erro ao atualizar usuário: " + data.error)
          setIsLoading(false)
          return
        }

        // Se editou o próprio usuário, atualizar sessão
        if (editingUser === currentUser?.username) {
          localStorage.setItem(
            "user",
            JSON.stringify({
              id: userToUpdate.id,
              username: formData.username,
              nome: formData.nome,
              role: formData.role,
              mustChangePassword:
                formData.role === "usuario" ? formData.mustChangePassword : false,
            }),
          )
        }
      } else {
        // Criando novo usuário
        const response = await fetch("/api/usuarios", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            username: formData.username,
            nome: formData.nome,
            password: formData.password,
            role: formData.role,
            mustChangePassword:
              formData.role === "usuario" ? formData.mustChangePassword : false,
          }),
        })

        if (!response.ok) {
          const data = await response.json()
          if (data.error?.includes("duplicate") || data.error?.includes("23505")) {
            alert("Usuário já existe!")
          } else {
            alert("Erro ao criar usuário: " + data.error)
          }
          setIsLoading(false)
          return
        }
      }

      // Recarregar lista de usuários
      await loadUsers()

      // Resetar form
      setFormData({ username: "", nome: "", password: "", role: "usuario", mustChangePassword: true })
      setShowForm(false)
      setEditingUser(null)
    } catch (err) {
      console.error("Erro ao salvar usuário:", err)
      alert("Erro ao salvar usuário")
    } finally {
      setIsLoading(false)
    }
  }

  const handleDelete = async (username: string) => {
    if (username === "admin") {
      alert("Não é possível excluir o usuário admin padrão!")
      return
    }

    if (username === currentUser?.username) {
      alert("Você não pode excluir seu próprio usuário!")
      return
    }

    if (confirm(`Tem certeza que deseja excluir o usuário "${username}"?`)) {
      const userToDelete = users.find((u) => u.username === username)
      if (!userToDelete) return

      try {
        const response = await fetch(`/api/usuarios/${userToDelete.id}`, {
          method: "DELETE",
        })

        if (!response.ok) {
          const data = await response.json()
          alert("Erro ao excluir usuário: " + data.error)
          return
        }

        await loadUsers()
      } catch (error) {
        console.error("Erro ao excluir usuário:", error)
        alert("Erro ao excluir usuário")
      }
    }
  }

  const handleCancel = () => {
    setFormData({ username: "", nome: "", password: "", role: "usuario", mustChangePassword: true })
    setShowForm(false)
    setEditingUser(null)
  }

  if (!currentUser) return null

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Gerenciar Usuários</h1>
            <p className="text-muted-foreground mt-1">Adicione e gerencie usuários do sistema</p>
          </div>
          <Button
            onClick={() => {
              setShowForm(!showForm)
              setEditingUser(null)
              setFormData({ username: "", nome: "", password: "", role: "usuario", mustChangePassword: true })
            }}
          >
            <Plus className="h-4 w-4 mr-2" />
            {showForm && !editingUser ? "Cancelar" : "Novo Usuário"}
          </Button>
        </div>

        {/* Form */}
        {showForm && (
          <Card>
            <CardHeader>
              <CardTitle>{editingUser ? "Editar Usuário" : "Criar Novo Usuário"}</CardTitle>
              <CardDescription>
                {editingUser ? "Atualize os dados do usuário" : "Preencha os dados do novo usuário"}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="username">Nome de usuário</Label>
                  <Input
                    id="username"
                    placeholder="Digite o nome de usuário"
                    value={formData.username}
                    onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                    disabled={editingUser === "admin" || isLoading}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="nome">Nome completo</Label>
                  <Input
                    id="nome"
                    placeholder="Digite o nome completo"
                    value={formData.nome}
                    onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                    disabled={isLoading}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password">Senha</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="Digite a senha"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    disabled={isLoading}
                    required={!editingUser}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="role">Tipo de usuário</Label>
                  <Select
                    value={formData.role}
                    onValueChange={(value: "admin" | "usuario") =>
                      setFormData({
                        ...formData,
                        role: value,
                        mustChangePassword: value === "admin" ? false : formData.mustChangePassword,
                      })
                    }
                    disabled={isLoading}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="usuario">Usuário</SelectItem>
                      <SelectItem value="admin">Administrador</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              {formData.role === "usuario" && (
                <div className="flex items-center justify-between rounded-lg border p-3">
                  <div className="space-y-1">
                    <Label htmlFor="mustChangePassword">Trocar senha no primeiro login</Label>
                    <p className="text-xs text-muted-foreground">
                      ObrigatÃ³rio para usuÃ¡rios comuns no primeiro acesso.
                    </p>
                  </div>
                  <Switch
                    id="mustChangePassword"
                    checked={formData.mustChangePassword}
                    onCheckedChange={(checked) => setFormData({ ...formData, mustChangePassword: checked })}
                    disabled={isLoading}
                  />
                </div>
              )}

                <div className="flex gap-2">
                  <Button type="submit" className="flex-1" disabled={isLoading}>
                    {isLoading ? "Salvando..." : editingUser ? "Salvar Alterações" : "Criar Usuário"}
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleCancel}
                    className="flex-1 bg-transparent"
                    disabled={isLoading}
                  >
                    Cancelar
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        )}

        {/* Users List */}
        <Card>
          <CardHeader>
            <CardTitle>Usuários do Sistema ({users.length})</CardTitle>
            <CardDescription>Lista de todos os usuários cadastrados</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {users.map((user) => (
                <div
                  key={user.id}
                  className="flex items-center justify-between p-4 rounded-lg border hover:bg-accent transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <div
                      className={`h-10 w-10 rounded-full flex items-center justify-center ${
                        user.role === "admin" ? "bg-primary" : "bg-muted"
                      }`}
                    >
                      {user.role === "admin" ? (
                        <Shield className="h-5 w-5 text-primary-foreground" />
                      ) : (
                        <UserIcon className="h-5 w-5 text-muted-foreground" />
                      )}
                    </div>
                    <div>
                      <p className="font-medium">{user.nome}</p>
                      <p className="text-sm text-muted-foreground">@{user.username}</p>
                      <p className="text-xs text-muted-foreground">
                        {user.role === "admin" ? "Administrador" : "Usuário"}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {user.username === "admin" && (
                      <span className="text-xs px-3 py-1 rounded-full bg-primary/10 text-primary font-medium">
                        Padrão
                      </span>
                    )}
                    <Button variant="outline" size="sm" onClick={() => handleEdit(user)}>
                      <Pencil className="h-4 w-4" />
                    </Button>
                    {user.username !== "admin" && (
                      <Button variant="outline" size="sm" onClick={() => handleDelete(user.username)}>
                        <Trash2 className="h-4 w-4 text-destructive" />
                      </Button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
