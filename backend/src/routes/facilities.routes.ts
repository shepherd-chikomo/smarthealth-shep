import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import {
  facilitySchema,
  geoQuerySchema,
  paginationMetaSchema,
  paginationQuerySchema,
  searchQuerySchema,
} from '../schemas/common.js';
import * as facilitiesService from '../services/facilities.service.js';
import * as publicProfile from '../services/facility-public-profile.service.js';
import * as availability from '../services/availability.service.js';

export const facilitiesRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/facilities',
    {
      schema: {
        tags: ['Facilities'],
        summary: 'List healthcare facilities',
        querystring: paginationQuerySchema.merge(searchQuerySchema),
        response: {
          200: z.object({
            facilities: z.array(facilitySchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query;
      return facilitiesService.listFacilities({
        page: q.page,
        limit: q.limit,
        sortBy: q.sortBy,
        q: q.q,
        province: q.province,
        city: q.city,
        facilityType: q.facilityType,
        isVerified: q.isVerified,
      });
    },
  );

  app.get(
    '/facilities/nearby',
    {
      schema: {
        tags: ['Facilities'],
        summary: 'Find nearby facilities',
        querystring: paginationQuerySchema
          .merge(geoQuerySchema)
          .extend({ facilityType: z.string().optional() }),
        response: {
          200: z.object({
            facilities: z.array(facilitySchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const { page, limit, lat, lon, radiusKm, facilityType } = request.query;
      return facilitiesService.nearbyFacilities({
        page,
        limit,
        lat,
        lon,
        radiusKm,
        facilityType,
      });
    },
  );

  app.get(
    '/facilities/:id',
    {
      schema: {
        tags: ['Facilities'],
        summary: 'Get facility by ID',
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ facility: facilitySchema }) },
      },
    },
    async (request) => {
      const facility = await facilitiesService.getFacilityById(request.params.id);
      return { facility };
    },
  );

  app.get(
    '/facilities/:id/public-profile',
    {
      schema: {
        tags: ['Facilities'],
        summary: 'Public facility profile for patient app',
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({ distanceKm: z.coerce.number().optional() }),
      },
    },
    async (request) =>
      publicProfile.getPublicProfile(request.params.id, request.query.distanceKm),
  );

  app.get(
    '/facilities/:id/specialists',
    {
      schema: {
        tags: ['Facilities'],
        summary: 'Specialists at a facility (lazy-loaded)',
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({
          limit: z.coerce.number().int().min(1).max(20).optional(),
          serviceId: z.string().optional(),
        }),
      },
    },
    async (request) =>
      publicProfile.getPublicSpecialists(request.params.id, {
        limit: request.query.limit,
        serviceId: request.query.serviceId,
      }),
  );

  app.get(
    '/facilities/:id/availability',
    {
      schema: {
        tags: ['Facilities'],
        summary: 'Available appointment slots at a facility',
        params: z.object({ id: z.string().uuid() }),
        querystring: z.object({
          serviceId: z.string().optional(),
          days: z.coerce.number().int().min(1).max(14).optional(),
        }),
      },
    },
    async (request) =>
      availability.getFacilityAvailability(request.params.id, {
        serviceId: request.query.serviceId,
        days: request.query.days,
      }),
  );
};
