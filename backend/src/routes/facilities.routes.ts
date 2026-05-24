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
        querystring: paginationQuerySchema.merge(geoQuerySchema),
        response: {
          200: z.object({
            facilities: z.array(facilitySchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const { page, limit, lat, lon, radiusKm } = request.query;
      return facilitiesService.nearbyFacilities({ page, limit, lat, lon, radiusKm });
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
};
