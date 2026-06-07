import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import {
  emergencyHubSchema,
  emergencyServiceSchema,
  geoQuerySchema,
  paginationMetaSchema,
  paginationQuerySchema,
} from '../schemas/common.js';
import * as emergencyHubService from '../services/emergency-hub.service.js';
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
    '/emergency/hub',
    {
      schema: {
        tags: ['Emergency'],
        summary: 'Location-based emergency hub (services + facilities)',
        querystring: paginationQuerySchema.merge(geoQuerySchema.partial()).extend({
          radiusKm: z.coerce.number().min(0.1).max(500).default(50),
        }),
        response: { 200: emergencyHubSchema },
      },
    },
    async (request) => {
      const q = request.query;
      return emergencyHubService.getEmergencyHub({
        lat: q.lat,
        lon: q.lon,
        radiusKm: q.radiusKm,
        page: q.page,
        limit: q.limit,
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
