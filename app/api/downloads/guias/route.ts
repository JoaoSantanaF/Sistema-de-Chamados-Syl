import { NextRequest, NextResponse } from 'next/server'
import { readFile, stat } from 'fs/promises'
import path from 'path'

/**
 * Rota de download seguro de guias em PDF.
 *
 * Parâmetros (query string):
 *   - file: nome do arquivo PDF (apenas nome simples, sem diretórios).
 *
 * Comportamento:
 *   - Resolve o arquivo a partir de /public/guias/<file>.
 *   - Garante que o caminho final continua dentro de /public/guias (anti path traversal).
 *   - Serve com Content-Type application/pdf e Content-Disposition attachment.
 *   - 404 se o arquivo não existir; 400 se o parâmetro for inválido.
 *
 * Middleware: os headers de segurança/cache para esta rota são aplicados
 * automaticamente pelo middleware.ts (matcher exclui apenas _next/static etc.).
 */
export async function GET(request: NextRequest) {
  const fileParam = request.nextUrl.searchParams.get('file')

  if (!fileParam) {
    return NextResponse.json(
      { error: 'Parâmetro "file" é obrigatório' },
      { status: 400 }
    )
  }

  // Bloqueia path traversal: só aceitamos um nome de arquivo simples (sem '/' ou '..').
  if (fileParam.includes('/') || fileParam.includes('..') || fileParam.includes('\\')) {
    return NextResponse.json(
      { error: 'Nome de arquivo inválido' },
      { status: 400 }
    )
  }

  // Garante extensão .pdf.
  if (!fileParam.toLowerCase().endsWith('.pdf')) {
    return NextResponse.json(
      { error: 'Apenas arquivos .pdf são permitidos' },
      { status: 400 }
    )
  }

  const baseDir = path.join(process.cwd(), 'public', 'guias')
  const filePath = path.join(baseDir, fileParam)

  // Defesa extra: garante que o caminho resolvido ainda está dentro de baseDir.
  const resolved = path.resolve(filePath)
  if (!resolved.startsWith(path.resolve(baseDir) + path.sep)) {
    return NextResponse.json(
      { error: 'Caminho inválido' },
      { status: 400 }
    )
  }

  try {
    await stat(resolved)
  } catch {
    return NextResponse.json(
      { error: 'Arquivo não encontrado' },
      { status: 404 }
    )
  }

  const buffer = await readFile(resolved)

  return new NextResponse(buffer, {
    status: 200,
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="${fileParam}"`,
      'Content-Length': String(buffer.length),
      'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0',
      'X-Content-Type-Options': 'nosniff',
    },
  })
}
