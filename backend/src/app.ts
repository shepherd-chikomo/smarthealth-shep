import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';
import {
  serializerCompiler,
  validatorCompiler,
  type ZodTypeProvider,
} from 'fastify-type-provider-zod';
import { env } from './config.js';
import { checkDatabaseConnection } from './lib/db.js';
import { registerErrorHandler } from './plugins/error-handler.js';
import { registerSecurityPlugin } from './plugins/security.js';
import { registerMetrics } from './plugins/metrics.js';
import { registerSwagger } from './plugins/swagger.js';
import { authRoutes } from './routes/auth.routes.js';
import { patientsRoutes } from './routes/patients.routes.js';
import { providersRoutes } from './routes/providers.routes.js';
import { facilitiesRoutes } from './routes/facilities.routes.js';
import { appointmentsRoutes } from './routes/appointments.routes.js';
import { reviewsRoutes } from './routes/reviews.routes.js';
import { emergencyRoutes } from './routes/emergency.routes.js';
import { notificationsRoutes } from './routes/notifications.routes.js';
import { paymentsRoutes } from './routes/payments.routes.js';
import { adminRoutes } from './routes/admin.routes.js';
import { analyticsRoutes } from './routes/analytics.routes.js';
import { searchRoutes } from './routes/search.routes.js';
import { facilityRoutes } from './routes/facility.routes.js';
import { claimsRoutes } from './routes/claims.routes.js';
import { z } from 'zod';

export async function buildApp() {
  const app = Fastify({
    logger: {
      level: env.LOG_LEVEL,
      transport:
        env.NODE_ENV === 'development'
          ? { target: 'pino-pretty', options: { colorize: true } }
          : undefined,
    },
    requestIdHeader: 'x-request-id',
    genReqId: () => crypto.randomUUID(),
  }).withTypeProvider<ZodTypeProvider>();

  app.setValidatorCompiler(validatorCompiler);
  app.setSerializerCompiler(serializerCompiler);

  await app.register(helmet, {
    contentSecurityPolicy: env.NODE_ENV === 'production'
      ? {
          directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", 'data:', 'https:'],
            connectSrc: ["'self'", 'https://smarthealth.co.zw'],
            frameSrc: ["'none'"],
            objectSrc: ["'none'"],
          },
        }
      : false,
    crossOriginEmbedderPolicy: false,
  });
  await app.register(cors, {
    origin: env.NODE_ENV === 'production' ? ['https://smarthealth.co.zw'] : true,
    credentials: true,
  });

  await app.register(rateLimit, {
    global: true,
    max: env.RATE_LIMIT_MAX,
    timeWindow: env.RATE_LIMIT_WINDOW_MS,
    addHeaders: {
      'x-ratelimit-limit': true,
      'x-ratelimit-remaining': true,
      'x-ratelimit-reset': true,
    },
  });

  await registerSwagger(app);
  await registerErrorHandler(app);
  await registerSecurityPlugin(app);
  await registerMetrics(app);

  app.addHook('onRequest', async (request) => {
    request.log.info({ method: request.method, url: request.url }, 'Incoming request');
  });

  app.addHook('onResponse', async (request, reply) => {
    request.log.info(
      { method: request.method, url: request.url, statusCode: reply.statusCode },
      'Request completed',
    );
  });

  app.get('/health', {
    schema: {
      tags: ['Health'],
      summary: 'Health check',
      response: {
        200: z.object({
          status: z.string(),
          database: z.string(),
          timestamp: z.string(),
        }),
      },
    },
  }, async () => {
    const dbOk = await checkDatabaseConnection();
    return {
      status: dbOk ? 'ok' : 'degraded',
      database: dbOk ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString(),
    };
  });

  await app.register(async (api) => {
    await api.register(authRoutes);
    await api.register(patientsRoutes);
    await api.register(providersRoutes);
    await api.register(facilitiesRoutes);
    await api.register(appointmentsRoutes);
    await api.register(reviewsRoutes);
    await api.register(emergencyRoutes);
    await api.register(notificationsRoutes);
    await api.register(paymentsRoutes);
    await api.register(adminRoutes);
    await api.register(analyticsRoutes);
    await api.register(facilityRoutes);
    await api.register(claimsRoutes);
    await api.register(searchRoutes);
  }, { prefix: env.API_PREFIX });

  return app;
}
