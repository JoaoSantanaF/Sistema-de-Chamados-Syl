"use client"

import type React from "react"
import { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Ticket, Download } from "lucide-react"

/**
 * Página de login do sistema HelpDesk TI
 * 
 * Responsável por:
 * 1. Coletar credenciais do usuário (username e password)
 * 2. Enviar para autenticação no backend
 * 3. Armazenar dados da sessão em localStorage
 * 4. Redirecionar para página apropriada baseado em role e status
 * 
 * Fluxo:
 * - Usuário normal sem necessidade de trocar senha → /dashboard
 * - Usuário normal que deve trocar senha → /alterar-senha
 * - Admin → /dashboard
 */
export default function LoginPage() {
  const router = useRouter()

  // Estado: credenciais do formulário
  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")

  // Estado: mensagem de erro exibida ao usuário
  const [error, setError] = useState("")

  // Estado: indica se requisição de login está em progresso
  const [isLoading, setIsLoading] = useState(false)

  /**
   * Handler do formulário de login
   * 
   * Fluxo:
   * 1. Previne comportamento padrão do formulário (envio HTTP)
   * 2. Limpa erros anteriores
   * 3. Ativa indicador de carregamento
   * 4. Envia credenciais para API de autenticação
   * 5. Se sucesso: armazena dados de sessão e redireciona
   * 6. Se erro: exibe mensagem de erro ao usuário
   */
  const handleLogin = async (e: React.FormEvent) => {
    // Previne comportamento padrão do form (page reload)
    e.preventDefault()

    // Limpa erros de tentativas anteriores
    setError("")

    // Ativa indicador de carregamento
    setIsLoading(true)

    try {
      // Envia credenciais para API de autenticação
      const response = await fetch("/api/auth", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      })

      // Parse da resposta
      const data = await response.json()

      // Verifica status da requisição
      if (!response.ok) {
        // Autenticação falhou: exibe mensagem de erro
        setError(data.error || "Usuário ou senha inválidos")
        setIsLoading(false)
        return
      }

      // Autenticação bem-sucedida: armazena dados de sessão em localStorage
      // Estes dados serão usados pela aplicação para:
      // - Identificar o usuário logado
      // - Filtrar dados baseado em role (admin vs usuário)
      // - Validar permissões para ações específicas
      localStorage.setItem(
        "user",
        JSON.stringify({
          id: data.id,
          username: data.username,
          nome: data.nome,
          role: data.role,
          setor: data.setor,
          mustChangePassword: data.mustChangePassword,
        }),
      )

      // Redireciona baseado em status do usuário:
      // - Se usuário comum e deve trocar senha: vai para /alterar-senha
      // - Caso contrário: vai para /dashboard
      if (data.role === "usuario" && data.mustChangePassword) {
        router.push("/alterar-senha")
        return
      }

      // Redirecionamento padrão para dashboard
      router.push("/dashboard")
    } catch (err) {
      // Erro de rede ou parsing: exibe mensagem genérica
      setError("Erro ao fazer login")
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-muted/20 to-background p-4">
      {/* Card de login centralizado */}
      <Card className="w-full max-w-md shadow-lg">
        {/* Cabeçalho com logo e título */}
        <CardHeader className="space-y-2 text-center">
          {/* Logo do sistema */}
          <div className="flex justify-center mb-2">
            <div className="h-12 w-12 rounded-lg bg-primary flex items-center justify-center">
              <Ticket className="h-6 w-6 text-primary-foreground" />
            </div>
          </div>
          {/* Título do sistema */}
          <CardTitle className="text-2xl font-bold">HelpDesk TI</CardTitle>
          {/* Descrição */}
          <CardDescription>Sistema de gerenciamento de chamados</CardDescription>
        </CardHeader>

        {/* Conteúdo do card com formulário */}
        <CardContent>
          <form onSubmit={handleLogin} className="space-y-4">
            {/* Campo: Nome de usuário */}
            <div className="space-y-2">
              <Label htmlFor="username">Usuário</Label>
              <Input
                id="username"
                type="text"
                placeholder="Digite seu usuário"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                disabled={isLoading}
              />
            </div>

            {/* Campo: Senha */}
            <div className="space-y-2">
              <Label htmlFor="password">Senha</Label>
              <Input
                id="password"
                type="password"
                placeholder="Digite sua senha"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                disabled={isLoading}
              />
            </div>

            {/* Mensagem de erro (exibida apenas se houver erro) */}
            {error && (
              <div className="text-sm text-destructive text-center p-2 bg-destructive/10 rounded-md">
                {error}
              </div>
            )}

            {/* Botão de envio do formulário */}
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? "Entrando..." : "Entrar"}
            </Button>
          </form>

          {/* Link para download do guia de uso */}
          <div className="mt-6 pt-4 border-t">
            <a href="/api/downloads/guias?file=guia-completo-uso.pdf" className="flex items-center justify-center gap-2 text-sm text-muted-foreground hover:text-primary transition-colors">
              <Download className="h-4 w-4" />
              <span>Baixar Guia de Uso</span>
            </a>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
