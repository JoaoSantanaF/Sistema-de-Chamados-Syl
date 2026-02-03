"use client"

import type React from "react"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

type SessionUser = {
  id: string
  username: string
  nome: string
  role: "admin" | "usuario"
  mustChangePassword?: boolean
}

export default function AlterarSenhaPage() {
  const router = useRouter()
  const [user, setUser] = useState<SessionUser | null>(null)
  const [password, setPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  const [error, setError] = useState("")
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }

    const parsedUser = JSON.parse(userData) as SessionUser
    if (parsedUser.role === "admin") {
      router.push("/dashboard")
      return
    }

    if (!parsedUser.mustChangePassword) {
      router.push("/dashboard")
      return
    }

    setUser(parsedUser)
  }, [router])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")

    if (!password || !confirmPassword) {
      setError("Preencha a nova senha e a confirmacao.")
      return
    }

    if (password !== confirmPassword) {
      setError("As senhas nao conferem.")
      return
    }

    if (!user) return

    setIsLoading(true)
    try {
      const response = await fetch(`/api/usuarios/${user.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          password,
          mustChangePassword: false,
        }),
      })

      const data = await response.json()
      if (!response.ok) {
        setError(data.error || "Erro ao atualizar senha.")
        setIsLoading(false)
        return
      }

      localStorage.setItem(
        "user",
        JSON.stringify({
          ...user,
          mustChangePassword: false,
        }),
      )

      router.push("/dashboard")
    } catch (err) {
      setError("Erro ao atualizar senha.")
    } finally {
      setIsLoading(false)
    }
  }

  if (!user) return null

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-muted/20 to-background p-4">
      <Card className="w-full max-w-md shadow-lg">
        <CardHeader className="space-y-2 text-center">
          <CardTitle className="text-2xl font-bold">Alterar senha</CardTitle>
          <CardDescription>Defina uma nova senha para continuar</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="password">Nova senha</Label>
              <Input
                id="password"
                type="password"
                placeholder="Digite a nova senha"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                disabled={isLoading}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirmPassword">Confirmar senha</Label>
              <Input
                id="confirmPassword"
                type="password"
                placeholder="Confirme a nova senha"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                disabled={isLoading}
              />
            </div>
            {error && <div className="text-sm text-destructive text-center p-2 bg-destructive/10 rounded-md">{error}</div>}
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? "Salvando..." : "Atualizar senha"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
