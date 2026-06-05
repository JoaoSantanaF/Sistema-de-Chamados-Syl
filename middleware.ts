import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Headers de Segurança
  // Previne ataques de clickjacking
  response.headers.set('X-Frame-Options', 'SAMEORIGIN')

  // Previne MIME type sniffing
  response.headers.set('X-Content-Type-Options', 'nosniff')

  // Content Security Policy
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'self';"
  )

  // Referrer Policy
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')

  // Permissions Policy
  response.headers.set(
    'Permissions-Policy',
    'geolocation=(), microphone=(), camera=(), payment=()'
  )

  // Headers para Downloads Seguros
  // Nota: redirect HTTP→HTTPS removido (certificado autoassinado quebrava o login).
  // Quando houver CA interna confiável, reintroduzir o redirect aqui.
  if (request.nextUrl.pathname.includes('/api/') || request.nextUrl.pathname.includes('/guias/')) {
    // Headers específicos para downloads
    if (request.nextUrl.pathname.match(/\.(pdf|doc|docx|xlsx|xls|csv|zip)$/i)) {
      response.headers.set('X-Content-Type-Options', 'nosniff')
      response.headers.set('Content-Disposition', 'attachment; filename*=UTF-8')
      response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
    }
  }

  return response
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|public).*)',
  ],
}
