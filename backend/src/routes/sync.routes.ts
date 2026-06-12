import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { requireFacilityStaffAuth, facilityIdQuerySchema } from '../plugins/facility-guard.js';
import * as sync from '../services/sync.service.js';

export const syncRoutes: FastifyPluginAsyncZod = async (app) => {
  app.addHook('preHandler', requireFacilityStaffAuth);

  app.get(
    '/sync/bootstrap',
    {
      schema: {
        tags: ['Sync'],
        security: [{ bearerAuth: [] }],
        querystring: facilityIdQuerySchema,
      },
    },
    async (request) =>
      sync.bootstrap(request.user!, request.facilityId!),
  );

  app.get(
    '/sync/delta',
    {
      schema: {
        tags: ['Sync'],
        querystring: facilityIdQuerySchema.extend({
          since: z.string().datetime(),
        }),
      },
    },
    async (request) =>
      sync.delta(
        request.user!,
        request.facilityId!,
        new Date(request.query.since),
      ),
  );

  app.post(
    '/sync/mutations',
    {
      schema: {
        tags: ['Sync'],
        body: z.object({
          facilityId: z.string().uuid(),
          mutations: z.array(
            z.object({
              entityType: z.string(),
              entityId: z.string(),
              operation: z.string(),
              payload: z.record(z.unknown()),
            }),
          ),
        }),
      },
    },
    async (request) => {
      request.facilityId = request.body.facilityId;
      return sync.applyMutations(
        request.user!,
        request.body.facilityId,
        request.body.mutations,
      );
    },
  );
};
