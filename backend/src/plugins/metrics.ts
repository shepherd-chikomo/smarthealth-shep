import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { env } from '../config.js';

let httpRequestsTotal = 0;
let httpErrorsTotal = 0;
const startTime = Date.now();

function authorizeMetrics(request: FastifyRequest, reply: FastifyReply): boolean {
  const token = env.METRICS_TOKEN;
  if (!token) {
    return env.NODE_ENV !== 'production';
  }

  const authHeader = request.headers.authorization;
  if (authHeader === `Bearer ${token}`) return true;

  const queryToken = (request.query as { token?: string }).token;
  if (queryToken === token) return true;

  void reply.code(401).send({ error: { code: 'UNAUTHORIZED', message: 'Invalid metrics token' } });
  return false;
}

export function registerMetrics(app: FastifyInstance): void {
  app.addHook('onResponse', async (request, reply) => {
    if (request.url.startsWith('/metrics')) return;
    httpRequestsTotal++;
    if (reply.statusCode >= 500) httpErrorsTotal++;
  });

  app.get('/metrics', {
    schema: { hide: true },
  }, async (request, reply) => {
    if (!authorizeMetrics(request, reply)) return;

    const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);
    const lines = [
      '# HELP smarthealth_http_requests_total Total HTTP requests',
      '# TYPE smarthealth_http_requests_total counter',
      `smarthealth_http_requests_total ${httpRequestsTotal}`,
      '# HELP smarthealth_http_errors_total Total HTTP 5xx responses',
      '# TYPE smarthealth_http_errors_total counter',
      `smarthealth_http_errors_total ${httpErrorsTotal}`,
      '# HELP smarthealth_uptime_seconds Process uptime',
      '# TYPE smarthealth_uptime_seconds gauge',
      `smarthealth_uptime_seconds ${uptimeSeconds}`,
    ];
    return reply.type('text/plain; version=0.0.4').send(lines.join('\n') + '\n');
  });
}
