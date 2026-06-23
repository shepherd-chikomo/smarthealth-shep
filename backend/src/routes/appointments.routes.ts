import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { requireAuth } from '../plugins/auth-guard.js';
import { getRequestContext } from '../lib/request-context.js';
import {
  appointmentFilterSchema,
  appointmentSchema,
  createAppointmentSchema,
  encounterSummarySchema,
  paginationMetaSchema,
  paginationQuerySchema,
  updateAppointmentSchema,
} from '../schemas/common.js';
import * as appointmentsService from '../services/appointments.service.js';
import * as encounterSummaryService from '../services/encounter-summary.service.js';

export const appointmentsRoutes: FastifyPluginAsyncZod = async (app) => {
  app.addHook('preHandler', requireAuth);

  app.post(
    '/appointments',
    {
      schema: {
        tags: ['Appointments'],
        summary: 'Book an appointment',
        security: [{ bearerAuth: [] }],
        body: createAppointmentSchema,
        response: { 201: z.object({ appointment: appointmentSchema }) },
      },
    },
    async (request, reply) => {
      const appointment = await appointmentsService.createAppointment(
        request.user!.id,
        request.body,
        getRequestContext(request),
      );
      return reply.status(201).send({ appointment });
    },
  );

  app.get(
    '/appointments',
    {
      schema: {
        tags: ['Appointments'],
        summary: 'List patient appointments',
        security: [{ bearerAuth: [] }],
        querystring: paginationQuerySchema.merge(appointmentFilterSchema),
        response: {
          200: z.object({
            appointments: z.array(appointmentSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query;
      return appointmentsService.listAppointments(request.user!.id, {
        page: q.page,
        limit: q.limit,
        status: q.status,
        providerId: q.providerId,
        facilityId: q.facilityId,
        from: q.from,
        to: q.to,
      });
    },
  );

  app.get(
    '/appointments/:id',
    {
      schema: {
        tags: ['Appointments'],
        summary: 'Get appointment by ID',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ appointment: appointmentSchema }) },
      },
    },
    async (request) => {
      const appointment = await appointmentsService.getAppointmentById(
        request.user!.id,
        request.params.id,
      );
      return { appointment };
    },
  );

  app.patch(
    '/appointments/:id',
    {
      schema: {
        tags: ['Appointments'],
        summary: 'Update appointment',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        body: updateAppointmentSchema,
        response: { 200: z.object({ appointment: appointmentSchema }) },
      },
    },
    async (request) => {
      const appointment = await appointmentsService.updateAppointment(
        request.user!.id,
        request.params.id,
        request.body,
      );
      return { appointment };
    },
  );

  app.get(
    '/appointments/:id/encounter-summary',
    {
      schema: {
        tags: ['Appointments'],
        summary: 'Get visit summary for an appointment',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ summary: encounterSummarySchema }) },
      },
    },
    async (request) => {
      const summary = await encounterSummaryService.getEncounterSummaryForAppointment(
        request.user!.id,
        request.params.id,
      );
      return { summary };
    },
  );

  app.delete(
    '/appointments/:id',
    {
      schema: {
        tags: ['Appointments'],
        summary: 'Cancel appointment',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ appointment: appointmentSchema }) },
      },
    },
    async (request) => {
      const appointment = await appointmentsService.cancelAppointment(
        request.user!.id,
        request.params.id,
      );
      return { appointment };
    },
  );
};
