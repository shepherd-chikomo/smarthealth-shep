import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { getRequestContext } from '../lib/request-context.js';
import { adminListQuerySchema } from '../lib/admin-query.js';
import { requireAdminAuth, requireStaffAuth, requireSuperAdminAuth } from '../plugins/admin-guard.js';
import * as admin from '../services/admin.service.js';
import * as audit from '../services/audit.service.js';
import * as importSvc from '../services/import.service.js';
import * as importUpload from '../services/import-upload.service.js';
import { ValidationError } from '../lib/errors.js';
import * as facilitiesAdmin from '../services/facilities-admin.service.js';
import * as registryDiff from '../services/registry-diff.service.js';
import * as practitionerClaim from '../services/practitioner-claim.service.js';
import * as platformBroadcast from '../services/platform-broadcast.service.js';

const emergencyServiceBodySchema = z.object({
  name: z.string().min(1),
  serviceType: z.enum([
    'ambulance', 'fire', 'police', 'hospital_er', 'poison_control',
    'mental_health_crisis', 'disaster_response', 'other',
  ]),
  phone: z.string().min(1),
  alternatePhone: z.string().optional().nullable(),
  address: z.string().optional().nullable(),
  city: z.string().min(1),
  province: z.enum([
    'Bulawayo', 'Harare', 'Manicaland', 'Mashonaland Central', 'Mashonaland East',
    'Mashonaland West', 'Masvingo', 'Matabeleland North', 'Matabeleland South', 'Midlands',
  ]),
  latitude: z.number(),
  longitude: z.number(),
  is24Hours: z.boolean().optional(),
  isActive: z.boolean().optional(),
});

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

  app.patch(
    '/admin/providers/:id',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({
          title: z.string().nullable().optional(),
          firstName: z.string().min(1).optional(),
          lastName: z.string().min(1).optional(),
          specialty: z.string().nullable().optional(),
          email: z.string().email().nullable().optional(),
          phone: z.string().nullable().optional(),
          gender: z.enum(['male', 'female', 'other']).nullable().optional(),
          qualification: z.string().nullable().optional(),
          registrationNumber: z.string().min(1).optional(),
        }),
      },
    },
    async (request) =>
      admin.updateProviderAdmin(
        request.user!,
        request.params.id,
        request.body,
        getRequestContext(request),
      ),
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

  app.post(
    '/admin/content/emergency',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin'], body: emergencyServiceBodySchema },
    },
    async (request, reply) => {
      const result = await admin.createEmergencyService(request.body);
      return reply.status(201).send(result);
    },
  );

  app.put(
    '/admin/content/emergency/:id',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin'],
        params: z.object({ id: z.string().uuid() }),
        body: emergencyServiceBodySchema.partial(),
      },
    },
    async (request) => admin.updateEmergencyService(request.params.id, request.body),
  );

  app.delete(
    '/admin/content/emergency/:id',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin'], params: z.object({ id: z.string().uuid() }) },
    },
    async (request) => admin.deleteEmergencyService(request.params.id),
  );

  app.post(
    '/admin/notifications/broadcast',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin'],
        body: z.object({
          title: z.string().min(1),
          body: z.string().min(1),
          actionUrl: z.string().optional(),
        }),
      },
    },
    async (request) =>
      platformBroadcast.broadcastToAllUsers(request.user!.id, request.body),
  );

  app.get(
    '/admin/notifications/broadcasts',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin'], querystring: adminListQuerySchema },
    },
    async (request) => platformBroadcast.listPlatformBroadcasts(request.query),
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

  // In-process uploads (multipart .xlsx). No Zod body schema — the file is
  // read via request.file(); the dry-run flag comes from the querystring.
  app.post(
    '/admin/import/practitioners',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        consumes: ['multipart/form-data'],
        querystring: z.object({ dryRun: z.enum(['true', 'false']).optional() }),
      },
    },
    async (request) => {
      const data = await request.file();
      if (!data) throw new ValidationError('No file uploaded');
      const buffer = await data.toBuffer();
      return importUpload.importProvidersUpload(
        request.user!,
        buffer,
        data.filename,
        request.query.dryRun === 'true',
      );
    },
  );

  app.post(
    '/admin/import/facilities',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Import'],
        consumes: ['multipart/form-data'],
        querystring: z.object({ dryRun: z.enum(['true', 'false']).optional() }),
      },
    },
    async (request) => {
      const data = await request.file();
      if (!data) throw new ValidationError('No file uploaded');
      const buffer = await data.toBuffer();
      return importUpload.importFacilitiesUpload(
        request.user!,
        buffer,
        data.filename,
        request.query.dryRun === 'true',
      );
    },
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

  // Facilities registry admin
  app.get(
    '/admin/facilities',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        querystring: adminListQuerySchema.extend({
          queue: z
            .enum([
              'all',
              'ambiguous_facility',
              'manual_association',
              'unlinked_practitioner',
              'no_email_practitioner',
            ])
            .optional(),
        }),
      },
    },
    async (request) => facilitiesAdmin.listFacilities(request.user!, request.query),
  );

  app.get(
    '/admin/import-review-queue',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        querystring: adminListQuerySchema.extend({
          queueType: z
            .enum([
              'all',
              'ambiguous_facility',
              'manual_association',
              'unlinked_practitioner',
              'no_email_practitioner',
            ])
            .optional(),
        }),
      },
    },
    async (request) => facilitiesAdmin.listImportReviewQueue(request.user!, request.query),
  );

  app.get(
    '/admin/import-review-queue/:id',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        params: z.object({ id: z.string().uuid() }),
      },
    },
    async (request) => facilitiesAdmin.getImportReviewQueueItem(request.user!, request.params.id),
  );

  app.post(
    '/admin/facilities/associate',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        body: z.object({
          facilityId: z.string().uuid(),
          providerId: z.string().uuid(),
          queueItemId: z.string().uuid().optional(),
        }),
      },
    },
    async (request) =>
      facilitiesAdmin.associatePractitionerWithFacility(
        request.user!,
        request.body,
        getRequestContext(request),
      ),
  );

  app.post(
    '/admin/facilities/resolve-ambiguous',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        body: z.object({
          queueItemId: z.string().uuid(),
          mode: z.enum(['merged', 'distinct']),
          facilityName: z.string().min(1).optional(),
          address: z.string().min(1).optional(),
          city: z.string().optional(),
          practitionerFirstName: z.string().optional(),
          practitionerLastName: z.string().optional(),
        }),
      },
    },
    async (request) =>
      facilitiesAdmin.resolveAmbiguousFacility(
        request.user!,
        request.body.queueItemId,
        request.body,
        getRequestContext(request),
      ),
  );

  app.post(
    '/admin/import-review-queue/:id/resolve-unlinked',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({
          action: z.enum(['associate', 'no_link']),
          facilityId: z.string().uuid().optional(),
          reason: z.string().optional(),
        }),
      },
    },
    async (request) =>
      facilitiesAdmin.resolveUnlinkedPractitioner(
        request.user!,
        request.params.id,
        request.body,
        getRequestContext(request),
      ),
  );

  app.post(
    '/admin/import-review-queue/:id/resolve-no-email',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Facilities'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({
          action: z.enum(['set_email', 'manual_claim_only']),
          email: z.string().email().optional(),
          notes: z.string().optional(),
        }),
      },
    },
    async (request) =>
      facilitiesAdmin.resolveNoEmailPractitioner(
        request.user!,
        request.params.id,
        request.body,
        getRequestContext(request),
      ),
  );

  app.get(
    '/admin/facilities/search-for-association',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin', 'Facilities'], querystring: adminListQuerySchema },
    },
    async (request) => facilitiesAdmin.searchFacilitiesForAssociation(request.user!, request.query),
  );

  app.get(
    '/admin/providers/search-for-association',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin', 'Facilities'], querystring: adminListQuerySchema },
    },
    async (request) => facilitiesAdmin.searchProvidersForAssociation(request.user!, request.query),
  );

  // Registry diff (monthly refresh)
  app.get(
    '/admin/registry-changes',
    {
      preHandler: requireSuperAdminAuth,
      schema: { tags: ['Admin', 'Registry'], querystring: adminListQuerySchema },
    },
    async (request) => registryDiff.listRegistryDiffRuns(request.user!, request.query),
  );

  app.get(
    '/admin/registry-changes/:runId/items',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Registry'],
        params: z.object({ runId: z.string().uuid() }),
        querystring: adminListQuerySchema.extend({ status: z.string().optional() }),
      },
    },
    async (request) =>
      registryDiff.listRegistryDiffItems(request.user!, request.params.runId, request.query),
  );

  app.post(
    '/admin/registry-changes/items/:id/review',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Registry'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({
          action: z.enum(['approve', 'ignore']),
          reviewNotes: z.string().optional(),
        }),
      },
    },
    async (request) =>
      registryDiff.reviewRegistryDiffItem(
        request.user!,
        request.params.id,
        request.body.action,
        request.body.reviewNotes,
        getRequestContext(request),
      ),
  );

  // Manual validation tickets
  app.get(
    '/admin/manual-validation',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        querystring: adminListQuerySchema.extend({ status: z.string().optional() }),
      },
    },
    async (request) =>
      practitionerClaim.listManualValidationTickets({
        page: request.query.page,
        limit: request.query.limit,
        status: request.query.status,
        q: request.query.q,
      }),
  );

  app.post(
    '/admin/manual-validation/:id/approve',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({
          claimantId: z.string().uuid(),
          mdpczNotes: z.string().optional(),
        }),
      },
    },
    async (request) =>
      practitionerClaim.approveManualValidationTicket(
        request.user!.id,
        request.params.id,
        request.body,
      ),
  );

  app.post(
    '/admin/manual-validation/:id/reject',
    {
      preHandler: requireSuperAdminAuth,
      schema: {
        tags: ['Admin', 'Claims'],
        params: z.object({ id: z.string().uuid() }),
        body: z.object({ mdpczNotes: z.string().optional() }),
      },
    },
    async (request) => {
      await practitionerClaim.rejectManualValidationTicket(
        request.user!.id,
        request.params.id,
        request.body,
      );
      return { status: 'rejected' };
    },
  );
};
