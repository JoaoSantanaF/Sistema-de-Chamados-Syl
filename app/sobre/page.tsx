"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { DashboardLayout } from "@/components/dashboard-layout"
import { Info, Ticket, Wrench, Mail, Code2, ShieldCheck } from "lucide-react"

/**
 * Página "Sobre o Sistema".
 *
 * Reúne informações institucionais do Helpdesk SYL: versão, módulos disponíveis,
 * contato de suporte e créditos de desenvolvimento.
 *
 * Para atualizar, edite as constantes abaixo — não é necessário mexer no JSX.
 */
const SISTEMA = {
  nome: "Helpdesk SYL",
  descricao: "Sistema interno de gestão de chamados de TI e manutenção preventiva.",
  versao: "1.0",
  atualizadoEm: "Julho de 2026",
  procedimento: "TI-01 Rev.10",
}

const SUPORTE = {
  email: "chamados.ti@syl.com.br",
  setor: "Equipe de TI — Grupo SYL",
}

const CREDITOS = {
  autor: "João Vitor",
  area: "Equipe de TI",
}

const MODULOS = [
  {
    icon: Ticket,
    titulo: "Chamados",
    descricao:
      "Abertura e acompanhamento de chamados de suporte, com atribuição de técnico responsável, histórico de andamento e registro da solução aplicada (Form.147).",
  },
  {
    icon: Wrench,
    titulo: "Manutenção Preventiva",
    descricao:
      "Controle de ativos e ciclos de manutenção com datas planejadas, checklist oficial, registro da data de execução com justificativa e relatórios mensais (Form.139).",
  },
]

const TECNOLOGIAS = ["Next.js", "React", "TypeScript", "Tailwind CSS", "PostgreSQL"]

export default function SobrePage() {
  return (
    <DashboardLayout>
      <div className="flex justify-center">
        <div className="space-y-6 max-w-3xl w-full">
          {/* Cabeçalho */}
          <div className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
              <Info className="h-6 w-6 text-primary-foreground" />
            </div>
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Sobre o Sistema</h1>
              <p className="text-muted-foreground mt-1">{SISTEMA.descricao}</p>
            </div>
          </div>

          {/* Informações gerais */}
          <Card>
            <CardHeader>
              <CardTitle>Informações Gerais</CardTitle>
              <CardDescription>Dados de identificação e versão da aplicação</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div>
                  <p className="text-sm text-muted-foreground">Sistema</p>
                  <p className="font-medium">{SISTEMA.nome}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Versão</p>
                  <p className="font-medium">v{SISTEMA.versao}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Atualizado em</p>
                  <p className="font-medium">{SISTEMA.atualizadoEm}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Procedimento</p>
                  <p className="font-medium">{SISTEMA.procedimento}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Módulos */}
          <Card>
            <CardHeader>
              <CardTitle>Módulos</CardTitle>
              <CardDescription>Funcionalidades disponíveis no sistema</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {MODULOS.map((modulo) => {
                const Icon = modulo.icon
                return (
                  <div key={modulo.titulo} className="flex gap-4 p-4 rounded-lg border">
                    <Icon className="h-5 w-5 mt-0.5 flex-shrink-0 text-primary" />
                    <div>
                      <p className="font-medium">{modulo.titulo}</p>
                      <p className="text-sm text-muted-foreground mt-1">{modulo.descricao}</p>
                    </div>
                  </div>
                )
              })}
            </CardContent>
          </Card>

          {/* Suporte */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Mail className="h-5 w-5" />
                Suporte
              </CardTitle>
              <CardDescription>Precisa de ajuda ou encontrou algum problema?</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              <p className="text-sm text-muted-foreground">
                Abra um chamado pelo próprio sistema ou entre em contato diretamente com a equipe
                responsável.
              </p>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <p className="text-sm text-muted-foreground">E-mail</p>
                  <a href={`mailto:${SUPORTE.email}`} className="font-medium text-primary hover:underline">
                    {SUPORTE.email}
                  </a>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Responsável</p>
                  <p className="font-medium">{SUPORTE.setor}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Tecnologias */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Code2 className="h-5 w-5" />
                Tecnologias
              </CardTitle>
              <CardDescription>Principais tecnologias utilizadas na construção do sistema</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                {TECNOLOGIAS.map((tech) => (
                  <span
                    key={tech}
                    className="px-3 py-1 rounded-full border bg-muted/50 text-sm text-muted-foreground"
                  >
                    {tech}
                  </span>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Créditos */}
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-3">
                <ShieldCheck className="h-5 w-5 text-muted-foreground flex-shrink-0" />
                <p className="text-sm text-muted-foreground">
                  Sistema desenvolvido internamente por{" "}
                  <span className="font-medium text-foreground">{CREDITOS.autor}</span> — {CREDITOS.area},
                  Grupo SYL.
                </p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  )
}
