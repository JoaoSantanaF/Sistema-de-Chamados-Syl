import nodemailer from 'nodemailer'

interface ChamadoNotification {
  id: string
  titulo: string
  descricao: string
  solicitante: string
  prioridade: string
  status: string
  responsavel?: string | null
  created_at?: string
}

function getRequiredEmailConfig() {
  const recipients = (process.env.CHAMADO_NOTIFICATION_RECIPIENTS || '')
    .split(',')
    .map((email) => email.trim())
    .filter(Boolean)

  if (
    !process.env.SMTP_HOST ||
    !process.env.SMTP_USER ||
    !process.env.SMTP_PASSWORD ||
    !process.env.SMTP_FROM ||
    recipients.length === 0
  ) {
    return null
  }

  return {
    host: process.env.SMTP_HOST,
    port: Number.parseInt(process.env.SMTP_PORT || '587', 10),
    secure: process.env.SMTP_SECURE === 'true',
    user: process.env.SMTP_USER,
    password: process.env.SMTP_PASSWORD,
    from: process.env.SMTP_FROM,
    recipients,
  }
}

function escapeHtml(value: string | null | undefined): string {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

// Monta a URL do chamado. Prioriza a base derivada da requisicao (host/protocolo
// reais por onde o app foi acessado) e so cai para APP_BASE_URL/NEXT_PUBLIC_API_URL
// como fallback. Evita links quebrados quando APP_BASE_URL aponta para um esquema
// (ex.: https) diferente do que realmente serve a aplicacao (ex.: http).
function getChamadoUrl(chamadoId: string, baseUrlOverride?: string | null): string | null {
  const raw = baseUrlOverride || process.env.APP_BASE_URL || process.env.NEXT_PUBLIC_API_URL
  const baseUrl = raw?.replace(/\/$/, '')
  return baseUrl ? `${baseUrl}/chamados/${chamadoId}` : null
}

export async function sendNewChamadoNotification(
  chamado: ChamadoNotification,
  baseUrlOverride?: string | null,
): Promise<void> {
  const config = getRequiredEmailConfig()

  if (!config) {
    console.warn('Aviso de chamado nao enviado: configuracao SMTP incompleta.')
    return
  }

  const chamadoUrl = getChamadoUrl(chamado.id, baseUrlOverride)
  const transporter = nodemailer.createTransport({
    host: config.host,
    port: config.port,
    secure: config.secure,
    auth: {
      user: config.user,
      pass: config.password,
    },
  })

  const subject = `[Helpdesk SYL] Novo chamado aberto: ${chamado.titulo}`
  const textLines = [
    'Um novo chamado foi aberto no Helpdesk SYL.',
    '',
    `Titulo: ${chamado.titulo}`,
    `Solicitante: ${chamado.solicitante}`,
    `Prioridade: ${chamado.prioridade}`,
    `Status: ${chamado.status}`,
    chamado.responsavel ? `Responsavel: ${chamado.responsavel}` : null,
    '',
    'Descricao:',
    chamado.descricao,
    '',
    chamadoUrl ? `Acessar chamado: ${chamadoUrl}` : null,
  ].filter(Boolean)

  const html = `
    <div style="font-family: Arial, sans-serif; color: #111827; line-height: 1.5;">
      <h2 style="margin: 0 0 16px;">Novo chamado aberto</h2>
      <p>Um novo chamado foi aberto no Helpdesk SYL.</p>
      <table style="border-collapse: collapse; margin: 16px 0;">
        <tr><td style="padding: 4px 12px 4px 0;"><strong>Titulo</strong></td><td>${escapeHtml(chamado.titulo)}</td></tr>
        <tr><td style="padding: 4px 12px 4px 0;"><strong>Solicitante</strong></td><td>${escapeHtml(chamado.solicitante)}</td></tr>
        <tr><td style="padding: 4px 12px 4px 0;"><strong>Prioridade</strong></td><td>${escapeHtml(chamado.prioridade)}</td></tr>
        <tr><td style="padding: 4px 12px 4px 0;"><strong>Status</strong></td><td>${escapeHtml(chamado.status)}</td></tr>
        ${
          chamado.responsavel
            ? `<tr><td style="padding: 4px 12px 4px 0;"><strong>Responsavel</strong></td><td>${escapeHtml(chamado.responsavel)}</td></tr>`
            : ''
        }
      </table>
      <p><strong>Descricao</strong></p>
      <p style="white-space: pre-wrap;">${escapeHtml(chamado.descricao)}</p>
      ${
        chamadoUrl
          ? `<p><a href="${escapeHtml(chamadoUrl)}" style="color: #2563eb;">Acessar chamado</a></p>`
          : ''
      }
    </div>
  `

  await transporter.sendMail({
    from: config.from,
    to: config.recipients,
    subject,
    text: textLines.join('\n'),
    html,
  })
}
