/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
  // Headers de Segurança Globais
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on'
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          },
          {
            key: 'Permissions-Policy',
            value: 'geolocation=(), microphone=(), camera=(), payment=()'
          }
          // Strict-Transport-Security removido temporariamente: o sistema está
          // rodando em HTTP com certificado autoassinado não confiável.
          // Quando o HTTPS com CA interna confiável for reativado, reintroduzir:
          //   key: 'Strict-Transport-Security',
          //   value: 'max-age=31536000; includeSubDomains'
        ],
      },
      // Headers para API
      {
        source: '/api/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'no-store, no-cache, must-revalidate, max-age=0'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          }
        ],
      }
    ]
  }
}

export default nextConfig
