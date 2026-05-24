import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { requireAuth } from '../plugins/auth-guard.js';
import { getRequestContext } from '../lib/request-context.js';
import {
  consentRecordSchema,
  consentTypeSchema,
  createFamilyMemberSchema,
  familyMemberSchema,
  grantConsentSchema,
  patientProfileSchema,
  updateFamilyMemberSchema,
  updatePatientProfileSchema,
} from '../schemas/common.js';
import * as patientsService from '../services/patients.service.js';
import * as consentService from '../services/consent.service.js';

export const patientsRoutes: FastifyPluginAsyncZod = async (app) => {
  app.addHook('preHandler', requireAuth);

  app.get(
    '/patients/me',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Get current patient profile',
        security: [{ bearerAuth: [] }],
        response: { 200: z.object({ profile: patientProfileSchema }) },
      },
    },
    async (request) => {
      const profile = await patientsService.getPatientProfile(
        request.user!.id,
        getRequestContext(request),
      );
      return { profile };
    },
  );

  app.patch(
    '/patients/me',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Update current patient profile',
        security: [{ bearerAuth: [] }],
        body: updatePatientProfileSchema,
        response: { 200: z.object({ profile: patientProfileSchema }) },
      },
    },
    async (request) => {
      const profile = await patientsService.updatePatientProfile(request.user!.id, request.body);
      return { profile };
    },
  );

  app.get(
    '/patients/family',
    {
      schema: {
        tags: ['Patients'],
        summary: 'List family members',
        security: [{ bearerAuth: [] }],
        response: { 200: z.object({ family: z.array(familyMemberSchema) }) },
      },
    },
    async (request) => {
      const family = await patientsService.listFamilyMembers(
        request.user!.id,
        getRequestContext(request),
      );
      return { family };
    },
  );

  app.post(
    '/patients/family',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Add family member',
        security: [{ bearerAuth: [] }],
        body: createFamilyMemberSchema,
        response: { 201: z.object({ member: familyMemberSchema }) },
      },
    },
    async (request, reply) => {
      const member = await patientsService.createFamilyMember(request.user!.id, request.body);
      return reply.status(201).send({ member });
    },
  );

  app.patch(
    '/patients/family/:id',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Update family member',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        body: updateFamilyMemberSchema,
        response: { 200: z.object({ member: familyMemberSchema }) },
      },
    },
    async (request) => {
      const member = await patientsService.updateFamilyMember(
        request.user!.id,
        request.params.id,
        request.body,
      );
      return { member };
    },
  );

  app.delete(
    '/patients/family/:id',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Delete family member',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ message: z.string() }) },
      },
    },
    async (request) => {
      await patientsService.deleteFamilyMember(request.user!.id, request.params.id);
      return { message: 'Family member deleted' };
    },
  );

  app.get(
    '/patients/consents',
    {
      schema: {
        tags: ['Patients'],
        summary: 'List patient consent records',
        security: [{ bearerAuth: [] }],
        response: { 200: z.object({ consents: z.array(consentRecordSchema) }) },
      },
    },
    async (request) => ({
      consents: await consentService.listConsents(request.user!.id),
    }),
  );

  app.post(
    '/patients/consents',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Grant patient consent',
        security: [{ bearerAuth: [] }],
        body: grantConsentSchema,
        response: { 201: z.object({ consent: consentRecordSchema }) },
      },
    },
    async (request, reply) => {
      const consent = await consentService.grantConsent(
        request.user!.id,
        request.body.consentType,
        request.body.version,
        getRequestContext(request),
        request.body.metadata,
      );
      return reply.status(201).send({ consent });
    },
  );

  app.delete(
    '/patients/consents/:consentType',
    {
      schema: {
        tags: ['Patients'],
        summary: 'Withdraw patient consent',
        security: [{ bearerAuth: [] }],
        params: z.object({ consentType: consentTypeSchema }),
        response: { 200: z.object({ consent: consentRecordSchema }) },
      },
    },
    async (request) => ({
      consent: await consentService.withdrawConsent(
        request.user!.id,
        request.params.consentType,
        getRequestContext(request),
      ),
    }),
  );
};
