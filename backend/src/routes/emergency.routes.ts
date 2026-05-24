import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import {
  emergencyServiceSchema,
  geoQuerySchema,
  paginationMetaSchema,
  paginationQuerySchema,
} from '../schemas/common.js';
import * as emergencyService from '../services/emergency.service.js';

export const emergencyRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/emergency/services',
    {
      schema: {
        tags: ['Emergency'],
        summary: 'List emergency services',
        querystring: paginationQuerySchema.extend({
          q: z.string().optional(),
          serviceType: z.string().optional(),
          province: z.string().optional(),
          city: z.string().optional(),
        }),
        response: {
          200: z.object({
            services: z.array(emergencyServiceSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query;
      return emergencyService.listEmergencyServices({
        page: q.page,
        limit: q.limit,
        q: q.q,
        serviceType: q.serviceType,
        province: q.province,
        city: q.city,
      });
    },
  );

  app.get(
    '/emergency/nearest',
    {
      schema: {
        tags: ['Emergency'],
        summary: 'Find nearest emergency services',
        querystring: paginationQuerySchema.merge(geoQuerySchema).extend({
          serviceType: z.string().optional(),
        }),
        response: {
          200: z.object({
            services: z.array(emergencyServiceSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query;
      return emergencyService.nearestEmergencyServices({
        page: q.page,
        limit: q.limit,
        lat: q.lat,
        lon: q.lon,
        radiusKm: q.radiusKm,
        serviceType: q.serviceType,
      });
    },
  );
};
