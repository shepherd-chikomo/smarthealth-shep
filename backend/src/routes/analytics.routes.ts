import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { env } from '../config.js';
import { requireAdminAuth, requireStaffAuth, requireSuperAdminAuth } from '../plugins/admin-guard.js';
import { requireFacilityStaffAuth } from '../plugins/facility-guard.js';
import * as analytics from '../services/analytics.service.js';

export const analyticsRoutes: FastifyPluginAsyncZod = async (app) => {
  // Internal refresh (scheduled job / super admin)
  app.post(
    '/analytics/refresh',
    {
      schema: {
        tags: ['Analytics'],
        body: z.object({ secret: z.string().optional() }),
      },
    },
    async (request, reply) => {
      const secret = (request.body as { secret?: string })?.secret;
      if (secret !== env.ANALYTICS_REFRESH_SECRET) {
        try {
          const { getAuthenticatedUser } = await import('../lib/auth.js');
          const { isSuperAdmin } = await import('../lib/rbac.js');
          request.user = getAuthenticatedUser(request);
          if (!isSuperAdmin(request.user)) {
            return reply.status(403).send({ error: { code: 'FORBIDDEN', message: 'Super admin required' } });
          }
        } catch {
          return reply.status(401).send({ error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } });
        }
      }
      await analytics.refreshAnalyticsAggregates();
      return { message: 'Analytics refreshed', timestamp: new Date().toISOString() };
    },
  );

  // Super admin platform dashboard
  app.get(
    '/analytics/platform',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Analytics'], security: [{ bearerAuth: [] }] },
    },
    async (request) => ({
      dashboard: await analytics.getPlatformDashboard(request.user!),
    }),
  );

  app.get(
    '/analytics/platform/export',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Analytics'],
        querystring: z.object({ type: z.enum(['dau', 'facilities']).default('dau') }),
      },
    },
    async (request, reply) => {
      const csv = await analytics.exportAnalyticsCsv(
        request.user!,
        'platform',
        request.query.type === 'facilities' ? 'facilities' : 'dau',
        {},
      );
      reply.header('Content-Type', 'text/csv');
      reply.header('Content-Disposition', `attachment; filename="platform-${request.query.type}.csv"`);
      return csv;
    },
  );

  // Facility admin dashboard
  app.get(
    '/analytics/facility',
    {
      preHandler: requireFacilityStaffAuth,
      schema: {
        tags: ['Analytics'],
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) => ({
      dashboard: await analytics.getFacilityDashboard(request.user!, request.facilityId!),
    }),
  );

  app.get(
    '/analytics/facility/export',
    {
      preHandler: requireFacilityStaffAuth,
      schema: {
        tags: ['Analytics'],
        querystring: z.object({
          facilityId: z.string().uuid(),
          type: z.enum(['daily', 'providers']).default('daily'),
        }),
      },
    },
    async (request, reply) => {
      const csv = await analytics.exportAnalyticsCsv(
        request.user!,
        'facility',
        request.query.type,
        { facilityId: request.facilityId! },
      );
      reply.header('Content-Type', 'text/csv');
      reply.header('Content-Disposition', `attachment; filename="facility-${request.query.type}.csv"`);
      return csv;
    },
  );

  // Provider dashboard
  app.get(
    '/analytics/provider',
    {
      preHandler: requireStaffAuth,
      schema: {
        tags: ['Analytics'],
        querystring: z.object({
          providerId: z.string().uuid(),
          facilityId: z.string().uuid().optional(),
        }),
      },
    },
    async (request) => ({
      dashboard: await analytics.getProviderDashboard(
        request.user!,
        request.query.providerId,
        request.query.facilityId,
      ),
    }),
  );

  app.get(
    '/analytics/provider/export',
    {
      preHandler: requireStaffAuth,
      schema: {
        tags: ['Analytics'],
        querystring: z.object({
          providerId: z.string().uuid(),
          facilityId: z.string().uuid().optional(),
        }),
      },
    },
    async (request, reply) => {
      const csv = await analytics.exportAnalyticsCsv(
        request.user!,
        'provider',
        'daily',
        { providerId: request.query.providerId, facilityId: request.query.facilityId },
      );
      reply.header('Content-Type', 'text/csv');
      reply.header('Content-Disposition', 'attachment; filename="provider-analytics.csv"');
      return csv;
    },
  );
};
