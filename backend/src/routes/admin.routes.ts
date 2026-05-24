import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { getRequestContext } from '../lib/request-context.js';
import { adminListQuerySchema } from '../lib/admin-query.js';
import { requireAdminAuth, requireStaffAuth, requireSuperAdminAuth } from '../plugins/admin-guard.js';
import * as admin from '../services/admin.service.js';
import * as audit from '../services/audit.service.js';
import * as importSvc from '../services/import.service.js';

const moderateBodySchema = z.object({
  action: z.enum(['cancel', 'flag', 'priority']),
  priority: z.number().int().min(0).max(5).optional(),
  reason: z.string().optional(),
});

export const adminRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/admin/me',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], security: [{ bearerAuth: [] }] } },
    async (request) => ({ profile: await admin.getAdminProfile(request.user!.id) }),
  );

  app.get(
    '/admin/dashboard/stats',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], security: [{ bearerAuth: [] }] } },
    async (request) => ({ stats: await admin.getDashboardStats(request.user!) }),
  );

  // Facility admins
  app.get(
    '/admin/facility-admins',
    { preHandler: requireSuperAdminAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listFacilityAdmins(request.user!, request.query),
  );

  app.post(
    '/admin/facility-admins',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin'],
        body: z.object({ userId: z.string().uuid(), facilityId: z.string().uuid() }),
      },
    },
    async (request, reply) => {
      const result = await admin.createFacilityAdmin(
        request.user!,
        request.body,
        getRequestContext(request),
      );
      return reply.status(201).send(result);
    },
  );

  app.delete(
    '/admin/facility-admins/:id',
    { preHandler: requireSuperAdminAuth, schema: { tags: ['Admin'], params: z.object({ id: z.string().uuid() }) } },
    async (request) => {
      await admin.removeFacilityAdmin(
        request.user!,
        request.params.id,
        getRequestContext(request),
      );
      return { message: 'Removed' };
    },
  );

  // Platform administrators (super admins)
  app.get(
    '/admin/platform-admins',
    { preHandler: requireSuperAdminAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listPlatformAdmins(request.user!, request.query),
  );

  app.post(
    '/admin/platform-admins',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin'],
        body: z
          .object({
            userId: z.string().uuid().optional(),
            phone: z.string().min(9).max(20).optional(),
            email: z.string().email().optional(),
            firstName: z.string().min(1).max(100).optional(),
            lastName: z.string().min(1).max(100).optional(),
          })
          .refine(
            (body) => Boolean(body.userId || body.phone || body.email),
            { message: 'Provide userId, phone, or email' },
          ),
      },
    },
    async (request, reply) => {
      const result = await admin.promotePlatformAdmin(
        request.user!,
        request.body,
        getRequestContext(request),
      );
      return reply.status(201).send(result);
    },
  );

  app.delete(
    '/admin/platform-admins/:userId',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin'], params: z.object({ userId: z.string().uuid() }) },
    },
    async (request) => {
      await admin.revokePlatformAdmin(
        request.user!,
        request.params.userId,
        getRequestContext(request),
      );
      return { message: 'Revoked' };
    },
  );

  // Queue
  app.get(
    '/admin/queue/live',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listLiveQueues(request.user!, request.query),
  );

  app.get(
    '/admin/queue/stats',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: z.object({ facilityId: z.string().uuid().optional() }) } },
    async (request) => ({ stats: await admin.getQueueStats(request.user!, request.query.facilityId) }),
  );

  app.post(
    '/admin/queue/:id/moderate',
    {
      preHandler: requireAdminAuth,
      schema: { tags: ['Admin'], params: z.object({ id: z.string().uuid() }), body: moderateBodySchema },
    },
    async (request) => {
      await admin.moderateQueueEntry(
        request.user!,
        request.params.id,
        request.body.action,
        request.body,
        getRequestContext(request),
      );
      return { message: 'Updated' };
    },
  );

  // Providers
  app.get(
    '/admin/providers',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listProvidersAdmin(request.user!, request.query),
  );

  app.patch(
    '/admin/providers/:id/verify',
    {
      preHandler: requireAdminAuth,
      schema: { tags: ['Admin'], params: z.object({ id: z.string().uuid() }), body: z.object({ verified: z.boolean() }) },
    },
    async (request) => {
      await admin.verifyProvider(
        request.user!,
        request.params.id,
        request.body.verified,
        getRequestContext(request),
      );
      return { message: 'Updated' };
    },
  );

  app.patch(
    '/admin/providers/:id/suspend',
    {
      preHandler: requireAdminAuth,
      schema: {
        tags: ['Admin'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ suspended: z.boolean(), reason: z.string().optional() }),
      },
    },
    async (request) => {
      await admin.suspendProvider(
        request.user!,
        request.params.id,
        request.body.suspended,
        request.body.reason,
        getRequestContext(request),
      );
      return { message: 'Updated' };
    },
  );

  app.get(
    '/admin/specialties',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listSpecialties(request.query),
  );

  // Appointments
  app.get(
    '/admin/appointments',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listAppointmentsAdmin(request.user!, request.query),
  );

  app.get(
    '/admin/appointments/analytics',
    {
      preHandler: requireStaffAuth,
      schema: { tags: ['Admin'], querystring: z.object({ facilityId: z.string().uuid().optional() }) },
    },
    async (request) => admin.getBookingAnalytics(request.user!, request.query.facilityId),
  );

  // Operating hours
  app.get(
    '/admin/hours',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listOperatingHours(request.user!, request.query),
  );

  app.put(
    '/admin/hours',
    {
      preHandler: requireAdminAuth,
      schema: {
        tags: ['Admin'],
        body: z.object({
          providerId: z.string().uuid(),
          dayOfWeek: z.number().int().min(0).max(6),
          opensAt: z.string().optional(),
          closesAt: z.string().optional(),
          isClosed: z.boolean().optional(),
        }),
      },
    },
    async (request) => {
      await admin.upsertOperatingHours(request.body);
      return { message: 'Saved' };
    },
  );

  // Content
  app.get(
    '/admin/content/emergency',
    { preHandler: requireStaffAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listEmergencyServicesAdmin(request.query),
  );

  app.get(
    '/admin/content/settings/:scope',
    {
      preHandler: requireAdminAuth,
      schema: {
        tags: ['Admin'],
        params: z.object({ scope: z.string() }),
        querystring: z.object({ tenantId: z.string().uuid().optional() }),
      },
    },
    async (request) => ({
      settings: await admin.listAppSettings(request.params.scope, request.query.tenantId),
    }),
  );

  app.put(
    '/admin/content/settings',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin'],
        body: z.object({
          scope: z.string(),
          key: z.string(),
          value: z.unknown(),
          description: z.string().optional(),
          isPublic: z.boolean().optional(),
          tenantId: z.string().uuid().nullable().optional(),
        }),
      },
    },
    async (request) => {
      await admin.upsertAppSetting(request.body);
      return { message: 'Saved' };
    },
  );

  // Reports
  app.get(
    '/admin/reports/revenue',
    { preHandler: requireAdminAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listRevenueReports(request.user!, request.query),
  );

  app.get(
    '/admin/reports/export/:type',
    {
      preHandler: requireAdminAuth,
      schema: { tags: ['Admin'], params: z.object({ type: z.enum(['revenue', 'appointments', 'usage']) }) },
    },
    async (request, reply) => {
      const csv = await admin.exportReportCsv(request.user!, request.params.type);
      reply.header('Content-Type', 'text/csv');
      reply.header('Content-Disposition', `attachment; filename="${request.params.type}-report.csv"`);
      return csv;
    },
  );

  app.get(
    '/admin/reports/export/:type/pdf',
    {
      preHandler: requireAdminAuth,
      schema: { tags: ['Admin'], params: z.object({ type: z.enum(['revenue', 'appointments', 'usage']) }) },
    },
    async (request, reply) => {
      const csv = await admin.exportReportCsv(request.user!, request.params.type);
      reply.header('Content-Type', 'application/pdf');
      reply.header('Content-Disposition', `attachment; filename="${request.params.type}-report.pdf"`);
      return `%PDF-1.4\n% SmartHealth Report\n${csv}`;
    },
  );

  // Security
  app.get(
    '/admin/security/audit-logs',
    { preHandler: requireAdminAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listAuditLogs(request.user!, request.query),
  );

  app.get(
    '/admin/security/events',
    { preHandler: requireAdminAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listSecurityEvents(request.user!, request.query),
  );

  app.get(
    '/admin/security/medical-access-logs',
    { preHandler: requireAdminAuth, schema: { tags: ['Admin'], querystring: adminListQuerySchema } },
    async (request) => admin.listMedicalAccessLogs(request.user!, request.query),
  );

  const auditQuerySchema = adminListQuerySchema.extend({
    category: z.string().optional(),
    actionType: z.string().optional(),
    userId: z.string().uuid().optional(),
    entityType: z.string().optional(),
    outcome: z.string().optional(),
  });

  app.get(
    '/admin/audit',
    {
      preHandler: requireAdminAuth,
      schema: { tags: ['Admin', 'Audit'], querystring: auditQuerySchema },
    },
    async (request) => audit.listComplianceLogs(request.user!, request.query),
  );

  app.get(
    '/admin/audit/summary',
    {
      preHandler: requireAdminAuth,
      schema: {
        tags: ['Admin', 'Audit'],
        querystring: z.object({ facilityId: z.string().uuid().optional() }),
      },
    },
    async (request) => audit.getAuditSummary(request.user!, request.query.facilityId),
  );

  app.get(
    '/admin/audit/export',
    {
      preHandler: requireAdminAuth,
      schema: { tags: ['Admin', 'Audit'], querystring: auditQuerySchema },
    },
    async (request, reply) => {
      const csv = await audit.exportComplianceLogs(request.user!, request.query);
      reply.header('Content-Type', 'text/csv');
      reply.header('Content-Disposition', 'attachment; filename="audit-export.csv"');
      return csv;
    },
  );

  // Data import moderation
  app.get(
    '/admin/import/batches',
    { preHandler: requireSuperAdminAuth, schema: { tags: ['Admin', 'Import'], querystring: adminListQuerySchema } },
    async (request) => importSvc.listImportBatches(request.user!, request.query),
  );

  app.get(
    '/admin/import/batches/:id',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin', 'Import'], params: z.object({ id: z.string().uuid() }) },
    },
    async (request) => importSvc.getImportBatch(request.user!, request.params.id),
  );

  app.get(
    '/admin/import/failures',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        querystring: adminListQuerySchema.extend({ batchId: z.string().uuid().optional() }),
      },
    },
    async (request) => importSvc.listFailedImports(request.user!, request.query),
  );

  app.post(
    '/admin/import/failures/:id/resolve',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ notes: z.string().optional() }),
      },
    },
    async (request) =>
      importSvc.resolveFailedImport(
        request.user!,
        request.params.id,
        request.body.notes,
        getRequestContext(request),
      ),
  );

  app.get(
    '/admin/import/duplicates',
    { preHandler: requireSuperAdminAuth, schema: { tags: ['Admin', 'Import'], querystring: adminListQuerySchema } },
    async (request) => importSvc.listDuplicateReviews(request.user!, request.query),
  );

  app.post(
    '/admin/import/duplicates/:id/review',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ action: z.enum(['approve', 'reject']) }),
      },
    },
    async (request) =>
      importSvc.reviewDuplicate(
        request.user!,
        request.params.id,
        request.body.action,
        getRequestContext(request),
      ),
  );

  app.get(
    '/admin/import/unmatched-specialties',
    { preHandler: requireSuperAdminAuth, schema: { tags: ['Admin', 'Import'], querystring: adminListQuerySchema } },
    async (request) => importSvc.listUnmatchedSpecialties(request.user!, request.query),
  );

  app.post(
    '/admin/import/unmatched-specialties/:id/map',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ specialtyId: z.string().uuid() }),
      },
    },
    async (request) =>
      importSvc.mapUnmatchedSpecialty(
        request.user!,
        request.params.id,
        request.body.specialtyId,
        getRequestContext(request),
      ),
  );

  app.post(
    '/admin/import/providers/:id/verify',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ verified: z.boolean() }),
      },
    },
    async (request) =>
      importSvc.verifyImportedProvider(
        request.user!,
        request.params.id,
        request.body.verified,
        getRequestContext(request),
      ),
  );
};
