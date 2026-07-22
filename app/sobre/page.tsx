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
      {/* Layout compacto: cabe em uma tela sem rolagem em telas de altura padrão. */}
      <div className="mx-auto max-w-6xl space-y-4">
        {/* Cabeçalho */}
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
            <Info className="h-5 w-5 text-primary-foreground" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Sobre o Sistema</h1>
            <p className="text-sm text-muted-foreground">{SISTEMA.descricao}</p>
          </div>
        </div>

        {/* Informações gerais */}
        <Card className="py-4 gap-3">
          <CardHeader>
            <CardTitle className="text-base">Informações Gerais</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <p className="text-xs text-muted-foreground">Sistema</p>
                <p className="font-medium text-sm">{SISTEMA.nome}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Versão</p>
                <p className="font-medium text-sm">v{SISTEMA.versao}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Atualizado em</p>
                <p className="font-medium text-sm">{SISTEMA.atualizadoEm}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Procedimento</p>
                <p className="font-medium text-sm">{SISTEMA.procedimento}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Duas colunas: módulos à esquerda, suporte + tecnologias à direita */}
        <div className="grid gap-4 md:grid-cols-2">
          <Card className="py-4 gap-3">
            <CardHeader>
              <CardTitle className="text-base">Módulos</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {MODULOS.map((modulo) => {
                const Icon = modulo.icon
                return (
                  <div key={modulo.titulo} className="flex gap-3 p-3 rounded-lg border">
                    <Icon className="h-4 w-4 mt-0.5 flex-shrink-0 text-primary" />
                    <div>
                      <p className="font-medium text-sm">{modulo.titulo}</p>
                      <p className="text-xs text-muted-foreground mt-1 leading-relaxed">
                        {modulo.descricao}
                      </p>
                    </div>
                  </div>
                )
              })}
            </CardContent>
          </Card>

          <div className="space-y-4">
            {/* Suporte */}
            <Card className="py-4 gap-3">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <Mail className="h-4 w-4" />
                  Suporte
                </CardTitle>
                <CardDescription className="text-xs">
                  Abra um chamado pelo sistema ou fale com a equipe responsável.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <p className="text-xs text-muted-foreground">E-mail</p>
                    <a
                      href={`mailto:${SUPORTE.email}`}
                      className="font-medium text-sm text-primary hover:underline break-all"
                    >
                      {SUPORTE.email}
                    </a>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">Responsável</p>
                    <p className="font-medium text-sm">{SUPORTE.setor}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Tecnologias */}
            <Card className="py-4 gap-3">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <Code2 className="h-4 w-4" />
                  Tecnologias
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="flex flex-wrap gap-2">
                  {TECNOLOGIAS.map((tech) => (
                    <span
                      key={tech}
                      className="px-2.5 py-0.5 rounded-full border bg-muted/50 text-xs text-muted-foreground"
                    >
                      {tech}
                    </span>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Créditos */}
        <Card className="py-3">
          <CardContent>
            <div className="flex items-center gap-3">
              <ShieldCheck className="h-4 w-4 text-muted-foreground flex-shrink-0" />
              <p className="text-xs text-muted-foreground">
                Sistema desenvolvido e mantido internamente por{" "}
                <span className="font-medium text-foreground">{CREDITOS.autor}</span> — {CREDITOS.area},
                Grupo SYL.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  )
}
