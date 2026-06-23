import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { getRequestContext } from '../lib/request-context.js';
import { requireFacilityStaffAuth, facilityIdQuerySchema } from '../plugins/facility-guard.js';
import * as clinical from '../services/clinical.service.js';

export const clinicalRoutes: FastifyPluginAsyncZod = async (app) => {
  app.addHook('preHandler', requireFacilityStaffAuth);

  app.get(
    '/clinical/patients/:patientId/chart',
    {
      schema: {
        tags: ['Clinical'],
        security: [{ bearerAuth: [] }],
        params: z.object({ patientId: z.string().uuid() }),
        querystring: facilityIdQuerySchema,
      },
    },
    async (request) =>
      clinical.getPatientChart(
        request.user!,
        request.facilityId!,
        request.params.patientId,
        getRequestContext(request),
      ),
  );

  app.post(
    '/clinical/consultations',
    {
      schema: {
        tags: ['Clinical'],
        querystring: facilityIdQuerySchema,
        body: z.object({
          patientId: z.string().uuid(),
          providerId: z.string().uuid(),
          appointmentId: z.string().uuid().optional(),
          walkInSessionId: z.string().uuid().optional(),
        }),
      },
    },
    async (request) =>
      clinical.createConsultation(request.user!, request.facilityId!, request.body),
  );

  app.patch(
    '/clinical/consultations/:id',
    {
      schema: {
        tags: ['Clinical'],
        params: z.object({ id: z.string().uuid() }),
        querystring: facilityIdQuerySchema,
        body: z.record(z.unknown()),
      },
    },
    async (request) =>
      clinical.updateConsultation(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body,
      ),
  );

  app.post(
    '/clinical/consultations/:id/complete',
    {
      schema: {
        tags: ['Clinical'],
        params: z.object({ id: z.string().uuid() }),
        querystring: facilityIdQuerySchema,
      },
    },
    async (request) =>
      clinical.completeConsultation(
        request.user!,
        request.facilityId!,
        request.params.id,
      ),
  );

  app.post(
    '/clinical/consultations/:id/diagnoses',
    {
      schema: {
        tags: ['Clinical'],
        params: z.object({ id: z.string().uuid() }),
        querystring: facilityIdQuerySchema,
        body: z.object({
          description: z.string().min(1),
          icd10Code: z.string().optional(),
          icd11Code: z.string().optional(),
          isPrimary: z.boolean().optional(),
          providerId: z.string().uuid(),
          patientId: z.string().uuid(),
        }),
      },
    },
    async (request) =>
      clinical.addDiagnosis(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body,
      ),
  );

  app.post(
    '/clinical/vitals',
    {
      schema: {
        tags: ['Clinical'],
        querystring: facilityIdQuerySchema,
        body: z.object({
          consultationId: z.string().uuid().optional(),
          patientId: z.string().uuid(),
          temperatureCelsius: z.number().optional(),
          pulseBpm: z.number().int().optional(),
          bloodPressureSystolic: z.number().int().optional(),
          bloodPressureDiastolic: z.number().int().optional(),
          oxygenSaturation: z.number().int().optional(),
          weightKg: z.number().optional(),
          heightCm: z.number().optional(),
        }),
      },
    },
    async (request) =>
      clinical.recordVitals(request.user!, request.facilityId!, request.body),
  );

  app.post(
    '/clinical/prescriptions',
    {
      schema: {
        tags: ['Clinical'],
        querystring: facilityIdQuerySchema,
        body: z.object({
          consultationId: z.string().uuid(),
          patientId: z.string().uuid(),
          providerId: z.string().uuid(),
          medication: z.string().min(1),
          dosage: z.string().optional(),
          frequency: z.string().optional(),
          duration: z.string().optional(),
          instructions: z.string().optional(),
        }),
      },
    },
    async (request) =>
      clinical.createPrescription(request.user!, request.facilityId!, request.body),
  );

  app.get(
    '/clinical/claims/summary',
    {
      schema: {
        tags: ['Clinical'],
        querystring: facilityIdQuerySchema,
      },
    },
    async (request) => ({
      items: await clinical.getClaimsSummary(request.user!, request.facilityId!),
    }),
  );

  app.get(
    '/clinical/claims',
    {
      schema: {
        tags: ['Clinical'],
        querystring: facilityIdQuerySchema.extend({
          status: z.string().optional(),
        }),
      },
    },
    async (request) => ({
      items: await clinical.listClaims(
        request.user!,
        request.facilityId!,
        request.query.status,
      ),
    }),
  );

  app.post(
    '/clinical/audit',
    {
      schema: {
        tags: ['Clinical'],
        querystring: facilityIdQuerySchema,
        body: z.object({
          action: z.string(),
          subjectId: z.string().uuid().optional(),
          details: z.record(z.unknown()).optional(),
        }),
      },
    },
    async (request) => {
      await clinical.recordClinicalAudit(
        request.user!,
        request.facilityId!,
        request.body.action,
        request.body.subjectId,
        request.body.details ?? {},
      );
      return { ok: true };
    },
  );
};
