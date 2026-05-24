import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { optionalAuthenticatedUser } from '../lib/auth.js';
import { paginationQuerySchema, paginationMetaSchema, providerSchema, searchQuerySchema, geoQuerySchema } from '../schemas/common.js';
import * as providersService from '../services/providers.service.js';

const listProvidersQuerySchema = paginationQuerySchema.extend({
  categoryId: z.string().optional(),
  specialtyId: z.string().uuid().optional(),
  isVerified: z.coerce.boolean().optional(),
  province: z.string().optional(),
  city: z.string().optional(),
});

const searchProvidersQuerySchema = paginationQuerySchema.merge(searchQuerySchema).merge(
  z.object({
    openNow: z.coerce.boolean().optional(),
    hasQueue: z.coerce.boolean().optional(),
    facilityId: z.string().uuid().optional(),
  }),
);

const nearbyProvidersQuerySchema = paginationQuerySchema.merge(geoQuerySchema);

const topRatedProvidersQuerySchema = paginationQuerySchema.extend({
  minReviews: z.coerce.number().int().min(1).optional(),
});

export const providersRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/providers',
    {
      schema: {
        tags: ['Providers'],
        summary: 'List healthcare providers',
        querystring: listProvidersQuerySchema,
        response: {
          200: z.object({
            providers: z.array(providerSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const { page, limit, sortBy, categoryId, specialtyId, isVerified, province, city } =
        request.query as z.infer<typeof listProvidersQuerySchema>;
      return providersService.listProviders({
        page,
        limit,
        sortBy,
        categoryId,
        specialtyId,
        isVerified,
        province,
        city,
      });
    },
  );

  app.get(
    '/providers/search',
    {
      schema: {
        tags: ['Providers'],
        summary: 'Search providers with filters',
        querystring: searchProvidersQuerySchema,
        response: {
          200: z.object({
            providers: z.array(providerSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query as z.infer<typeof searchProvidersQuerySchema>;
      return providersService.searchProviders({
        page: q.page,
        limit: q.limit,
        q: q.q,
        categoryId: q.categoryId,
        specialtyId: q.specialtyId,
        specialties: q.specialties?.split(',').filter(Boolean),
        conditions: q.conditions?.split(',').filter(Boolean),
        ageGroups: q.ageGroups?.split(',').filter(Boolean),
        lat: q.lat,
        lon: q.lon,
        radiusKm: q.radiusKm,
        isVerified: q.isVerified,
        openNow: q.openNow,
        hasQueue: q.hasQueue,
        city: q.city,
        province: q.province,
        facilityId: q.facilityId,
      });
    },
  );

  app.get(
    '/providers/nearby',
    {
      schema: {
        tags: ['Providers'],
        summary: 'Find nearby providers',
        querystring: nearbyProvidersQuerySchema,
        response: {
          200: z.object({
            providers: z.array(providerSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const { page, limit, lat, lon, radiusKm } =
        request.query as z.infer<typeof nearbyProvidersQuerySchema>;
      return providersService.nearbyProviders({ page, limit, lat, lon, radiusKm });
    },
  );

  app.get(
    '/providers/top-rated',
    {
      schema: {
        tags: ['Providers'],
        summary: 'List top-rated providers',
        querystring: topRatedProvidersQuerySchema,
        response: {
          200: z.object({
            providers: z.array(providerSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const { page, limit, minReviews } =
        request.query as z.infer<typeof topRatedProvidersQuerySchema>;
      return providersService.topRatedProviders({ page, limit, minReviews });
    },
  );

  app.get(
    '/providers/:id',
    {
      schema: {
        tags: ['Providers'],
        summary: 'Get provider by ID',
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ provider: providerSchema }) },
      },
    },
    async (request) => {
      optionalAuthenticatedUser(request);
      const provider = await providersService.getProviderById(request.params.id);
      return { provider };
    },
  );
};
