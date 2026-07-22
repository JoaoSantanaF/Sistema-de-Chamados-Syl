"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { LayoutDashboard, Ticket, LogOut, Menu, X, Users, Moon, Sun, Wrench, Info } from "lucide-react"
import Link from "next/link"
import { usePathname } from "next/navigation"

export function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()
  const [user, setUser] = useState<{ username: string; role: string } | null>(null)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [isDark, setIsDark] = useState(true)

  useEffect(() => {
    const userData = localStorage.getItem("user")
    if (!userData) {
      router.push("/login")
      return
    }
    setUser(JSON.parse(userData))

    const savedTheme = localStorage.getItem("theme")
    const prefersDark =
      savedTheme === "dark" || (!savedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)
    setIsDark(prefersDark)
    document.documentElement.classList.toggle("dark", prefersDark)
  }, [router])

  const toggleTheme = () => {
    const newTheme = !isDark
    setIsDark(newTheme)
    localStorage.setItem("theme", newTheme ? "dark" : "light")
    document.documentElement.classList.toggle("dark", newTheme)
  }

  const handleLogout = () => {
    localStorage.removeItem("user")
    router.push("/login")
  }

  const navItems = [
    { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
    { href: "/chamados", label: "Chamados", icon: Ticket },
    ...(user?.role === "admin"
      ? [
          { href: "/manutencao", label: "Manutenção", icon: Wrench },
          { href: "/usuarios", label: "Usuários", icon: Users },
        ]
      : []),
    { href: "/sobre", label: "Sobre", icon: Info },
  ]

  if (!user) return null

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/80 backdrop-blur-md">
        <div className="container flex h-16 items-center gap-4">
          <div className="flex items-center gap-3 flex-shrink-0">
            <img src="/logo-syl.png" alt="SYL Logo" className="h-8 w-8 object-contain" />
            <span className="font-semibold text-lg tracking-tight hidden sm:inline-block text-primary">SYL</span>
          </div>

          <nav className="hidden md:flex items-center gap-1 flex-1">
            {navItems.map((item) => {
              const Icon = item.icon
              const isActive = pathname === item.href
              return (
                <Button
                  key={item.href}
                  variant={isActive ? "secondary" : "ghost"}
                  asChild
                  className="gap-2 font-medium"
                >
                  <Link href={item.href}>
                    <Icon className="h-4 w-4" />
                    {item.label}
                  </Link>
                </Button>
              )
            })}
          </nav>

          <div className="flex items-center gap-3 ml-auto">
            <div className="hidden sm:flex flex-col items-end text-sm">
              <span className="font-medium text-foreground">{user.username}</span>
              <span className="text-xs text-muted-foreground">
                {user.role === "admin" ? "Administrador" : "Usuário"}
              </span>
            </div>
            <Button variant="ghost" size="icon" onClick={toggleTheme} className="rounded-lg">
              {isDark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
            </Button>
            <Button variant="ghost" size="icon" onClick={handleLogout} className="rounded-lg">
              <LogOut className="h-4 w-4" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className="md:hidden rounded-lg"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? <X className="h-4 w-4" /> : <Menu className="h-4 w-4" />}
            </Button>
          </div>
        </div>
      </header>

      {mobileMenuOpen && (
        <div className="md:hidden border-b bg-card">
          <nav className="container py-4 flex flex-col gap-2">
            {navItems.map((item) => {
              const Icon = item.icon
              const isActive = pathname === item.href
              return (
                <Button
                  key={item.href}
                  variant={isActive ? "secondary" : "ghost"}
                  asChild
                  className="justify-start gap-2"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <Link href={item.href}>
                    <Icon className="h-4 w-4" />
                    {item.label}
                  </Link>
                </Button>
              )
            })}
          </nav>
        </div>
      )}

      <main className="container py-10 max-w-7xl">{children}</main>
    </div>
  )
}
