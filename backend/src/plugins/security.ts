import type { FastifyInstance } from 'fastify';

export async function registerSecurityPlugin(app: FastifyInstance): Promise<void> {
  app.addHook('onSend', async (_request, reply, payload) => {
    reply.header('X-Content-Type-Options', 'nosniff');
    reply.header('X-Frame-Options', 'DENY');
    reply.header('Referrer-Policy', 'strict-origin-when-cross-origin');
    reply.header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    reply.header('X-XSS-Protection', '0');
    return payload;
  });

  app.addHook('preHandler', async (request, reply) => {
    const method = request.method.toUpperCase();
    if (!['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) return;

    const authHeader = request.headers.authorization;
    if (authHeader?.startsWith('Bearer ')) return;

    if (request.url.startsWith('/v1/auth/') || request.url === '/health') return;

    const origin = request.headers.origin;
    const requestedWith = request.headers['x-requested-with'];
    if (origin && requestedWith !== 'XMLHttpRequest') {
      return reply.status(403).send({
        error: {
          code: 'CSRF_VALIDATION_FAILED',
          message: 'Cross-origin request blocked without CSRF protection',
          requestId: request.id,
        },
      });
    }
  });
}
