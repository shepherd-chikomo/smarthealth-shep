import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { adminListQuerySchema } from '../lib/admin-query.js';
import { getRequestContext } from '../lib/request-context.js';
import { requireAdminAuth, requireStaffAuth } from '../plugins/admin-guard.js';
import { requireAuth } from '../plugins/auth-guard.js';
import * as claims from '../services/claims.service.js';

const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
  q: z.string().optional(),
});

const evidenceSchema = z.record(z.unknown()).optional();

export const claimsRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/claims/search/facilities',
    {
      schema: {
        tags: ['Claims'],
        querystring: paginationSchema,
      },
    },
    async (request) => claims.searchClaimableFacilities(request.query),
  );

  app.get(
    '/claims/search/providers',
    {
      schema: {
        tags: ['Claims'],
        querystring: paginationSchema,
      },
    },
    async (request) => claims.searchClaimableProviders(request.query),
  );

  app.get(
    '/claims/me',
    {
      preHandler: requireAuth,
      schema: { tags: ['Claims'], security: [{ bearerAuth: [] }] },
    },
    async (request) => claims.listMyClaims(request.user!.id),
  );

  app.post(
    '/claims/facility',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        body: z.object({
          facilityId: z.string().uuid(),
          businessRegistrationNumber: z.string().optional(),
          notes: z.string().optional(),
          evidence: evidenceSchema,
        }),
      },
    },
    async (request, reply) => {
      const result = await claims.createFacilityClaim(request.user!.id, request.body);
      return reply.status(201).send({ claim: result });
    },
  );

  app.post(
    '/claims/provider',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        body: z.object({
          providerId: z.string().uuid(),
          mdpczNumber: z.string().optional(),
          notes: z.string().optional(),
          evidence: evidenceSchema,
        }),
      },
    },
    async (request, reply) => {
      const result = await claims.createProviderClaim(request.user!.id, request.body);
      return reply.status(201).send({ claim: result });
    },
  );

  app.patch(
    '/claims/facility/:id',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({
          businessRegistrationNumber: z.string().optional(),
          notes: z.string().optional(),
          evidence: evidenceSchema,
        }),
      },
    },
    async (request) =>
      claims.updateFacilityClaim(request.user!.id, request.params.id, request.body),
  );

  app.post(
    '/claims/facility/:id/submit',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
      },
    },
    async (request) => ({
      claim: await claims.submitFacilityClaim(request.user!.id, request.params.id),
    }),
  );

  app.post(
    '/claims/provider/:id/submit',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
      },
    },
    async (request) => ({
      claim: await claims.submitProviderClaim(request.user!.id, request.params.id),
    }),
  );

  app.get(
    '/admin/claims',
    {
      preHandler: requireStaffAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        security: [{ bearerAuth: [] }],
        querystring: adminListQuerySchema,
      },
    },
    async (request) => claims.listClaimsForAdmin(request.user!, request.query),
  );

  app.post(
    '/admin/claims/:type/:id/review',
    {
      preHandler: requireAdminAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({
          type: z.enum(['facility', 'provider']),
          id: z.string().uuid(),
        }),
        body: z.object({
          action: z.enum(['approve', 'reject']),
          reviewNotes: z.string().optional(),
        }),
      },
    },
    async (request) =>
      claims.reviewClaim(
        request.user!,
        request.params.id,
        request.params.type,
        request.body.action,
        request.body.reviewNotes,
        getRequestContext(request),
      ),
  );

  app.get(
    '/admin/claims/:type/:entityId/history',
    {
      preHandler: requireStaffAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({
          type: z.enum(['facility', 'provider']),
          entityId: z.string().uuid(),
        }),
      },
    },
    async (request) => claims.getClaimHistory(request.params.entityId, request.params.type),
  );

  app.get(
    '/admin/claims/:type/:entityId/duplicates',
    {
      preHandler: requireStaffAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({
          type: z.enum(['facility', 'provider']),
          entityId: z.string().uuid(),
        }),
      },
    },
    async (request) =>
      claims.detectDuplicateClaims(request.params.entityId, request.params.type),
  );
};
