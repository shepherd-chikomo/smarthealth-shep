import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { facilityProfileSettingsPatchSchema } from '../lib/facility-profile-settings.js';
import { FACILITY_TYPE_VALUES } from '../lib/facility-types.js';
import { FACILITY_CLASSIFICATION_VALUES } from '../lib/facility-classification.js';
import { ValidationError } from '../lib/errors.js';
import { getRequestContext } from '../lib/request-context.js';
import { facilityListQuerySchema, requireFacilityStaffAuth } from '../plugins/facility-guard.js';
import * as facility from '../services/facility.service.js';
import * as facilityServicesCatalog from '../services/facility-services-catalog.service.js';
import * as medicalAidSchemes from '../services/medical-aid-schemes.service.js';
import * as invitations from '../services/invitations.service.js';

const hourEntrySchema = z.object({
  dayOfWeek: z.number().int().min(0).max(6),
  opensAt: z.string().nullable().optional(),
  closesAt: z.string().nullable().optional(),
  isClosed: z.boolean().optional(),
  is24Hours: z.boolean().optional(),
});

export const facilityRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/facility/me',
    {
      preHandler: async (request, reply) => {
        const { requireStaffAuth } = await import('../plugins/admin-guard.js');
        await requireStaffAuth(request, reply);
      },
      schema: { tags: ['Facility Portal'], security: [{ bearerAuth: [] }] },
    },
    async (request) => ({ profile: await facility.getPortalProfile(request.user!.id) }),
  );

  app.addHook('preHandler', requireFacilityStaffAuth);

  app.get(
    '/facility/dashboard',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => ({
      stats: await facility.getDashboard(request.user!, request.facilityId!),
    }),
  );

  // Facility profile
  app.get(
    '/facility/profile',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getFacilityProfile(request.user!, request.facilityId!),
  );

  app.patch(
    '/facility/profile',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z
          .object({
            name: z.string().optional(),
            description: z.string().optional(),
            addressLine1: z.string().optional(),
            addressLine2: z.string().optional(),
            city: z.string().optional(),
            phone: z.string().optional(),
            whatsappPhone: z.string().optional(),
            email: z.string().optional(),
            website: z.string().optional(),
            facilityTypes: z.array(z.enum(FACILITY_TYPE_VALUES)).min(1).optional(),
            facilityCategory: z.enum(FACILITY_CLASSIFICATION_VALUES).nullable().optional(),
            latitude: z.number().min(-90).max(90).optional(),
            longitude: z.number().min(-180).max(180).optional(),
            locationMode: z.enum(['manual', 'geocode']).optional(),
          })
          .refine(
            (body) =>
              (body.latitude === undefined && body.longitude === undefined) ||
              (body.latitude !== undefined && body.longitude !== undefined),
            { message: 'latitude and longitude must be sent together' },
          )
          .refine(
            (body) =>
              body.locationMode !== 'manual' ||
              (body.latitude !== undefined && body.longitude !== undefined),
            { message: 'locationMode manual requires latitude and longitude' },
          ),
      },
    },
    async (request) =>
      facility.updateFacilityProfile(request.user!, request.facilityId!, request.body),
  );

  app.patch(
    '/facility/profile-settings',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: facilityProfileSettingsPatchSchema,
      },
    },
    async (request) =>
      facility.updateFacilityProfileSettings(
        request.user!,
        request.facilityId!,
        request.body,
      ),
  );

  app.get(
    '/facility/medical-aid-catalog',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async () => facility.getMedicalAidCatalog(),
  );

  app.get(
    '/facility/services-catalog',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async () => facilityServicesCatalog.listFacilityServicesCatalog(),
  );

  app.post(
    '/facility/service-submissions',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ label: z.string().min(1).max(120), iconKey: z.string().max(40).optional() }),
      },
    },
    async (request, reply) => {
      const result = await facilityServicesCatalog.createServiceSubmission(
        request.user!,
        request.facilityId!,
        request.body,
      );
      return reply.status(result.skipped ? 200 : 201).send(result);
    },
  );

  app.get(
    '/facility/medical-aid-submissions',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({
          facilityId: z.string().uuid(),
          status: z.enum(['pending', 'approved', 'rejected']).optional(),
        }),
      },
    },
    async (request) =>
      medicalAidSchemes.listMedicalAidSubmissionsForFacility(
        request.user!,
        request.facilityId!,
        request.query.status,
      ),
  );

  app.post(
    '/facility/medical-aid-submissions',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ name: z.string().min(1).max(120) }),
      },
    },
    async (request, reply) => {
      const result = await medicalAidSchemes.createMedicalAidSubmission(
        request.user!,
        request.facilityId!,
        request.body,
      );
      return reply.status(result.skipped ? 200 : 201).send(result);
    },
  );

  app.post(
    '/facility/logo',
    {
      schema: {
        tags: ['Facility Portal'],
        consumes: ['multipart/form-data'],
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) => {
      const data = await request.file();
      if (!data) throw new ValidationError('No file uploaded');
      const buffer = await data.toBuffer();
      return facility.uploadFacilityLogoFile(
        request.user!,
        request.facilityId!,
        buffer,
        data.mimetype,
      );
    },
  );

  app.delete(
    '/facility/logo',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.removeFacilityLogo(request.user!, request.facilityId!),
  );

  app.post(
    '/facility/credentials',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          credentialType: z.enum(['registration', 'licence', 'certificate', 'cpd', 'other']),
          title: z.string().min(1).max(200),
          issuedAt: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
          expiresAt: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.createPractitionerCredential(
        request.user!,
        request.facilityId!,
        request.body,
      );
      return reply.status(201).send(result);
    },
  );

  app.get(
    '/facility/credentials',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.listMyCredentials(request.user!, request.facilityId!),
  );

  app.get(
    '/facility/messages',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.listInternalMessages(request.user!, request.facilityId!),
  );

  app.post(
    '/facility/messages',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          recipientId: z.string().uuid(),
          body: z.string().min(1).max(4000),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.sendInternalMessage(
        request.user!,
        request.facilityId!,
        request.body,
      );
      return reply.status(201).send(result);
    },
  );

  app.patch(
    '/facility/messages/:id/read',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) =>
      facility.markInternalMessageRead(
        request.user!,
        request.facilityId!,
        request.params.id,
      ),
  );

  // Doctors
  app.get(
    '/facility/doctors',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.listDoctors(request.user!, request.facilityId!, request.query),
  );

  app.post(
    '/facility/doctors',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          name: z.string().min(1),
          specialty: z.string().optional(),
          mdpczNumber: z.string().optional(),
          phone: z.string().optional(),
          email: z.string().email().optional(),
          isAcceptingBookings: z.boolean().optional(),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.createDoctor(request.user!, request.facilityId!, request.body);
      return reply.status(201).send(result);
    },
  );

  app.get(
    '/facility/doctors/lookup',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({
          facilityId: z.string().uuid(),
          mdpczNumber: z.string().min(1),
        }),
      },
    },
    async (request) =>
      facility.lookupRegisteredProvider(
        request.user!,
        request.facilityId!,
        request.query.mdpczNumber,
      ),
  );

  app.post(
    '/facility/doctors/attach',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ providerId: z.string().uuid() }),
      },
    },
    async (request, reply) => {
      const result = await facility.attachDoctor(
        request.user!,
        request.facilityId!,
        request.body.providerId,
      );
      return reply.status(201).send(result);
    },
  );

  app.patch(
    '/facility/doctors/:id',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          name: z.string().optional(),
          specialty: z.string().optional(),
          mdpczNumber: z.string().optional(),
          phone: z.string().optional(),
          email: z.string().email().optional(),
          isAcceptingBookings: z.boolean().optional(),
          isActive: z.boolean().optional(),
        }),
      },
    },
    async (request) =>
      facility.updateDoctor(request.user!, request.facilityId!, request.params.id, request.body),
  );

  app.get(
    '/facility/doctors/:id/services',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) =>
      facility.getDoctorServiceIds(request.user!, request.facilityId!, request.params.id),
  );

  app.put(
    '/facility/doctors/:id/services',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ serviceIds: z.array(z.string()) }),
      },
    },
    async (request) =>
      facility.updateDoctorServiceIds(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body.serviceIds,
      ),
  );

  // Operating hours
  app.get(
    '/facility/hours',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.listFacilityHours(request.user!, request.facilityId!),
  );

  app.put(
    '/facility/hours',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ hours: z.array(hourEntrySchema) }),
      },
    },
    async (request) =>
      facility.upsertFacilityHours(request.user!, request.facilityId!, request.body.hours),
  );

  // Provider availability
  app.get(
    '/facility/availability',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({
          facilityId: z.string().uuid(),
          providerId: z.string().uuid().optional(),
        }),
      },
    },
    async (request) =>
      facility.listProviderAvailability(
        request.user!,
        request.facilityId!,
        request.query.providerId,
      ),
  );

  app.put(
    '/facility/availability/:providerId',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ providerId: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          hours: z.array(
            hourEntrySchema.omit({ is24Hours: true }),
          ),
        }),
      },
    },
    async (request) =>
      facility.upsertProviderAvailability(
        request.user!,
        request.facilityId!,
        request.params.providerId,
        request.body.hours,
      ),
  );

  // Appointment slots
  app.get(
    '/facility/slots',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getSlotSettings(request.user!, request.facilityId!),
  );

  app.put(
    '/facility/slots',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.record(z.unknown()),
      },
    },
    async (request) =>
      facility.updateSlotSettings(request.user!, request.facilityId!, request.body),
  );

  // Patients
  app.get(
    '/facility/patients',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.listPatients(request.user!, request.facilityId!, request.query),
  );

  app.post(
    '/facility/patients',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          firstName: z.string().min(1),
          lastName: z.string().optional(),
          phone: z.string().min(9),
          email: z.string().email().optional(),
          dateOfBirth: z.string().optional(),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.registerPatient(
        request.user!,
        request.facilityId!,
        request.body,
      );
      return reply.status(201).send(result);
    },
  );

  app.get(
    '/facility/patients/:id/history',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) =>
      facility.getPatientHistory(
        request.user!,
        request.facilityId!,
        request.params.id,
        getRequestContext(request),
      ),
  );

  // Appointments
  app.get(
    '/facility/appointments',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.listAppointments(request.user!, request.facilityId!, request.query),
  );

  app.post(
    '/facility/appointments',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          patientId: z.string().uuid(),
          providerId: z.string().uuid(),
          scheduledAt: z.string().datetime(),
          durationMinutes: z.number().int().positive().optional(),
          notes: z.string().optional(),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.createAppointment(
        request.user!,
        request.facilityId!,
        request.body,
        getRequestContext(request),
      );
      return reply.status(201).send(result);
    },
  );

  app.patch(
    '/facility/appointments/:id/reschedule',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ scheduledAt: z.string().datetime(), notes: z.string().optional() }),
      },
    },
    async (request) =>
      facility.rescheduleAppointment(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body,
        getRequestContext(request),
      ),
  );

  app.patch(
    '/facility/appointments/:id/cancel',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ reason: z.string().optional() }),
      },
    },
    async (request) =>
      facility.cancelAppointment(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body.reason,
        getRequestContext(request),
      ),
  );

  // Queue
  app.get(
    '/facility/queue',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.listWalkIns(request.user!, request.facilityId!, request.query),
  );

  app.get(
    '/facility/queue/stats',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getQueueStats(request.user!, request.facilityId!),
  );

  app.post(
    '/facility/queue/walk-in',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          patientId: z.string().uuid(),
          providerId: z.string().uuid().optional(),
          chiefComplaint: z.string().optional(),
          priority: z.number().int().min(0).max(5).optional(),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.registerWalkIn(
        request.user!,
        request.facilityId!,
        request.body,
      );
      return reply.status(201).send(result);
    },
  );

  app.patch(
    '/facility/queue/:id/status',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          status: z.enum(['waiting', 'called', 'in_progress', 'completed', 'cancelled']),
        }),
      },
    },
    async (request) =>
      facility.updateWalkInStatus(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body.status,
      ),
  );

  app.patch(
    '/facility/queue/:id/delay',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ additionalMinutes: z.number().int().min(5).max(120).default(15) }),
      },
    },
    async (request) =>
      facility.delayWalkIn(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body.additionalMinutes,
      ),
  );

  app.put(
    '/facility/queue/pause',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ paused: z.boolean() }),
      },
    },
    async (request) =>
      facility.setQueuePaused(request.user!, request.facilityId!, request.body.paused),
  );

  // Emergency availability
  app.get(
    '/facility/emergency',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getEmergencyAvailability(request.user!, request.facilityId!),
  );

  app.put(
    '/facility/emergency',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.record(z.unknown()),
      },
    },
    async (request) =>
      facility.updateEmergencyAvailability(request.user!, request.facilityId!, request.body),
  );

  app.get(
    '/facility/schedule-overrides',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getScheduleOverrides(request.user!, request.facilityId!),
  );

  app.put(
    '/facility/schedule-overrides',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.record(z.unknown()),
      },
    },
    async (request) =>
      facility.updateScheduleOverrides(request.user!, request.facilityId!, request.body),
  );

  // Billing (V1 placeholder)
  app.get(
    '/facility/billing',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getBillingDashboard(request.user!, request.facilityId!),
  );

  // Inventory
  app.get(
    '/facility/inventory',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.listProducts(request.user!, request.facilityId!, request.query),
  );

  app.get(
    '/facility/inventory/alerts',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getInventoryAlerts(request.user!, request.facilityId!),
  );

  app.post(
    '/facility/inventory',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          sku: z.string().min(1),
          name: z.string().min(1),
          category: z.string().optional(),
          unitOfMeasure: z.string().optional(),
          reorderLevel: z.number().optional(),
          currentStock: z.number().optional(),
          unitPriceCents: z.number().int().optional(),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.createProduct(request.user!, request.facilityId!, request.body);
      return reply.status(201).send(result);
    },
  );

  app.patch(
    '/facility/inventory/:id',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          name: z.string().optional(),
          category: z.string().optional(),
          reorderLevel: z.number().optional(),
          unitPriceCents: z.number().int().optional(),
          isActive: z.boolean().optional(),
        }),
      },
    },
    async (request) =>
      facility.updateProduct(request.user!, request.facilityId!, request.params.id, request.body),
  );

  app.post(
    '/facility/inventory/:id/stock',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          quantity: z.number().positive(),
          movementType: z.enum(['purchase', 'sale', 'adjustment', 'expired', 'damaged', 'returned']),
          notes: z.string().optional(),
        }),
      },
    },
    async (request) =>
      facility.adjustStock(request.user!, request.facilityId!, request.params.id, request.body),
  );

  // Staff
  app.get(
    '/facility/staff',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.listStaff(request.user!, request.facilityId!, request.query),
  );

  app.post(
    '/facility/staff',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          fullName: z.string().min(1),
          email: z.string().email(),
          phone: z.string().optional(),
          role: z.enum(['doctor', 'receptionist', 'facility_admin']),
        }),
      },
    },
    async (request, reply) => {
      const result = await facility.addStaffMember(
        request.user!,
        request.facilityId!,
        request.body,
        getRequestContext(request),
      );
      return reply.status(201).send(result);
    },
  );

  app.delete(
    '/facility/staff/:id',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) =>
      facility.removeStaffMember(
        request.user!,
        request.facilityId!,
        request.params.id,
        getRequestContext(request),
      ),
  );

  app.patch(
    '/facility/staff/:id',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          fullName: z.string().min(1).optional(),
          email: z.string().email().optional(),
          phone: z.string().optional(),
          role: z.enum(['doctor', 'receptionist', 'facility_admin']).optional(),
        }),
      },
    },
    async (request) =>
      facility.updateStaffMember(
        request.user!,
        request.facilityId!,
        request.params.id,
        request.body,
        getRequestContext(request),
      ),
  );

  app.post(
    '/facility/staff/:id/suspend',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) =>
      facility.suspendStaffMember(
        request.user!,
        request.facilityId!,
        request.params.id,
        getRequestContext(request),
      ),
  );

  app.post(
    '/facility/staff/:id/unsuspend',
    {
      schema: {
        tags: ['Facility Portal'],
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ facilityId: z.string().uuid() }),
      },
    },
    async (request) =>
      facility.unsuspendStaffMember(
        request.user!,
        request.facilityId!,
        request.params.id,
        getRequestContext(request),
      ),
  );

  // Analytics & reporting
  app.get(
    '/facility/analytics',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => {
      const { getFacilityDashboard } = await import('../services/analytics.service.js');
      return { dashboard: await getFacilityDashboard(request.user!, request.facilityId!) };
    },
  );

  app.post(
    '/facility/announcements',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({
          title: z.string().min(1),
          body: z.string().min(1),
          actionUrl: z.string().optional(),
        }),
      },
    },
    async (request) => {
      const { sendFacilityAnnouncement } = await import('../services/notification-dispatch.service.js');
      const { query: dbQuery } = await import('../lib/db.js');
      const patients = await dbQuery<{ user_id: string }>(
        `SELECT DISTINCT patient_id AS user_id FROM public.appointments
         WHERE tenant_id = $1 AND deleted_at IS NULL`,
        [request.facilityId!],
      );
      const count = await sendFacilityAnnouncement({
        tenantId: request.facilityId!,
        title: request.body.title,
        body: request.body.body,
        actionUrl: request.body.actionUrl,
        userIds: patients.rows.map((r) => r.user_id),
      });
      return { message: 'Announcement sent', recipientCount: count };
    },
  );

  app.get(
    '/facility/reports/revenue',
    { schema: { tags: ['Facility Portal'], querystring: facilityListQuerySchema } },
    async (request) => facility.getRevenueReport(request.user!, request.facilityId!, request.query),
  );

  app.get(
    '/facility/reports/doctors',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getDoctorPerformance(request.user!, request.facilityId!),
  );

  app.get(
    '/facility/reports/appointments',
    { schema: { tags: ['Facility Portal'], querystring: z.object({ facilityId: z.string().uuid() }) } },
    async (request) => facility.getAppointmentTrends(request.user!, request.facilityId!),
  );

  app.get(
    '/facility/reports/export',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({
          facilityId: z.string().uuid(),
          type: z.enum(['revenue', 'appointments', 'doctors']),
        }),
      },
    },
    async (request, reply) => {
      const csv = await facility.exportReportsCsv(
        request.user!,
        request.facilityId!,
        request.query.type,
      );
      reply.header('Content-Type', 'text/csv');
      reply.header('Content-Disposition', `attachment; filename="${request.query.type}-report.csv"`);
      return csv;
    },
  );

  app.post(
    '/facility/practitioners/invite',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ registrationNumber: z.string().min(1) }),
      },
    },
    async (request, reply) => {
      const result = await invitations.invitePractitionerByRegNumber(
        request.user!,
        request.facilityId!,
        request.body.registrationNumber,
        getRequestContext(request),
      );
      return reply.status(201).send(result);
    },
  );

  app.delete(
    '/facility/practitioners/:providerId',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        params: z.object({ providerId: z.string().uuid() }),
      },
    },
    async (request) =>
      invitations.removeInvitedPractitioner(
        request.user!,
        request.facilityId!,
        request.params.providerId,
        getRequestContext(request),
      ),
  );

  app.post(
    '/facility/admins/invite',
    {
      schema: {
        tags: ['Facility Portal'],
        querystring: z.object({ facilityId: z.string().uuid() }),
        body: z.object({ email: z.string().email() }),
      },
    },
    async (request, reply) => {
      const result = await invitations.inviteFacilityAdminByEmail(
        request.user!,
        request.facilityId!,
        request.body.email,
        getRequestContext(request),
      );
      return reply.status(201).send(result);
    },
  );
};
