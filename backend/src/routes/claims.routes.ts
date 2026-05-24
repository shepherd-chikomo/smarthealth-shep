import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { adminListQuerySchema } from '../lib/admin-query.js';
import { getRequestContext } from '../lib/request-context.js';
import { requireAdminAuth, requireStaffAuth } from '../plugins/admin-guard.js';
import { requireAuth } from '../plugins/auth-guard.js';
import * as claims from '../services/claims.service.js';
import * as practitionerClaim from '../services/practitioner-claim.service.js';
import * as invitations from '../services/invitations.service.js';

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

  app.get(
    '/claims/me/registry-email-match',
    {
      preHandler: requireAuth,
      schema: { tags: ['Claims'], security: [{ bearerAuth: [] }] },
    },
    async (request) =>
      practitionerClaim.checkRegistryEmailMatch(request.user!.id, request.user!.email),
  );

  app.get(
    '/claims/lookup/provider',
    {
      schema: {
        tags: ['Claims'],
        querystring: z.object({ email: z.string().email() }),
      },
    },
    async (request) => practitionerClaim.lookupProviderByEmail(request.query.email),
  );

  app.get(
    '/claims/me/onboarding-status',
    {
      preHandler: requireAuth,
      schema: { tags: ['Claims'], security: [{ bearerAuth: [] }] },
    },
    async (request) => practitionerClaim.getPractitionerOnboardingStatus(request.user!.id),
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
    '/claims/facility/:id/instant-claim',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
      },
    },
    async (request) =>
      claims.instantClaimFacilityForRoleHolder(request.user!.id, request.params.id),
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
    '/claims/me/primary-facilities',
    {
      preHandler: requireAuth,
      schema: { tags: ['Claims'], security: [{ bearerAuth: [] }] },
    },
    async (request) => practitionerClaim.getMyPrimaryFacilities(request.user!.id),
  );

  app.post(
    '/claims/practitioner/validate',
    {
      schema: {
        tags: ['Claims'],
        body: z.object({
          registrationNumber: z.string().min(1),
          email: z.string().email(),
          specialty: z.string().min(1),
        }),
      },
    },
    async (request) => practitionerClaim.validatePractitionerClaimCredentials(request.body),
  );

  app.post(
    '/claims/practitioner/otp/send',
    {
      schema: {
        tags: ['Claims'],
        body: z.object({
          registrationNumber: z.string().min(1),
          email: z.string().email(),
          specialty: z.string().min(1),
        }),
      },
      config: { rateLimit: { max: 5, timeWindow: '1 minute' } },
    },
    async (request) => practitionerClaim.initiatePractitionerClaimOtp(request.body),
  );

  app.post(
    '/claims/practitioner/otp/verify',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        body: z.object({
          sessionId: z.string().uuid(),
          otp: z.string().min(4),
        }),
      },
    },
    async (request) =>
      practitionerClaim.completePractitionerClaimOtp({
        ...request.body,
        userId: request.user!.id,
      }),
  );

  app.post(
    '/claims/practitioner/manual-validation',
    {
      schema: {
        tags: ['Claims'],
        body: z.object({
          registrationNumber: z.string().min(1),
          specialty: z.string().min(1),
          submitterName: z.string().optional(),
          submitterEmail: z.string().email().optional(),
          submitterPhone: z.string().optional(),
          evidence: evidenceSchema,
        }),
      },
    },
    async (request, reply) => {
      const result = await practitionerClaim.submitManualValidationTicket(request.body);
      return reply.status(201).send(result);
    },
  );

  app.get(
    '/claims/invitations',
    {
      preHandler: requireAuth,
      schema: { tags: ['Claims'], security: [{ bearerAuth: [] }] },
    },
    async (request) => invitations.listMyInvitations(request.user!.id),
  );

  app.post(
    '/claims/invitations/:id/respond',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ action: z.enum(['accept', 'decline']) }),
      },
    },
    async (request) =>
      invitations.respondToPractitionerInvitation(
        request.user!.id,
        request.params.id,
        request.body.action,
      ),
  );

  app.get(
    '/claims/admin-invitations',
    {
      preHandler: requireAuth,
      schema: { tags: ['Claims'], security: [{ bearerAuth: [] }] },
    },
    async (request) => invitations.listPendingAdminInvitations(request.user!.id),
  );

  app.post(
    '/claims/admin-invitations/:id/accept',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Claims'],
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
      },
    },
    async (request) =>
      invitations.acceptFacilityAdminInvitation(request.user!.id, request.params.id),
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
