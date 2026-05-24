import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import {
  geoQuerySchema,
  healthcareSearchQuerySchema,
  paginationMetaSchema,
  paginationQuerySchema,
  providerSchema,
  searchQuerySchema,
} from '../schemas/common.js';
import * as searchService from '../services/search.service.js';

const providerSearchResultSchema = providerSchema.extend({
  facilityCity: z.string().nullable().optional(),
  facilityVerified: z.boolean().optional(),
  isOpenNow: z.boolean().optional(),
  hasQueue: z.boolean().optional(),
  relevanceScore: z.number().optional(),
});

const facilitySearchResultSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  slug: z.string(),
  facilityType: z.string(),
  description: z.string().nullable(),
  addressLine1: z.string().nullable(),
  city: z.string(),
  province: z.string(),
  phone: z.string().nullable(),
  email: z.string().nullable(),
  website: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  distanceKm: z.number().nullable().optional(),
  isVerified: z.boolean(),
  logoPath: z.string().nullable(),
  isOpenNow: z.boolean(),
  hasQueue: z.boolean(),
  providerCount: z.number(),
  relevanceScore: z.number(),
});

const specialtySearchResultSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  slug: z.string(),
  category: z.string().nullable(),
  description: z.string().nullable(),
  icdCode: z.string().nullable(),
});

function parseCsv(value?: string): string[] | undefined {
  if (!value) return undefined;
  const items = value.split(',').map((s) => s.trim()).filter(Boolean);
  return items.length > 0 ? items : undefined;
}

const unifiedSearchQuerySchema = z.object({
  q: z.string().max(200).optional(),
  lat: z.coerce.number().min(-90).max(90).optional(),
  lon: z.coerce.number().min(-180).max(180).optional(),
  radiusKm: z.coerce.number().min(0.1).max(500).optional(),
  limit: z.coerce.number().int().min(1).max(20).default(5),
});

const rankedProviderSearchQuerySchema = paginationQuerySchema
  .merge(searchQuerySchema)
  .merge(healthcareSearchQuerySchema);

const rankedFacilitySearchQuerySchema = paginationQuerySchema
  .merge(searchQuerySchema)
  .merge(healthcareSearchQuerySchema);

const specialtySearchQuerySchema = paginationQuerySchema.extend({
  q: z.string().max(200).optional(),
  facilityId: z.string().uuid().optional(),
});

const emergencySearchQuerySchema = paginationQuerySchema.merge(geoQuerySchema).extend({
  q: z.string().max(200).optional(),
  serviceType: z.string().optional(),
  openNow: z.coerce.boolean().optional(),
});

export const searchRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/search',
    {
      schema: {
        tags: ['Search'],
        summary: 'Unified healthcare search (providers, facilities, specialties, emergency)',
        querystring: unifiedSearchQuerySchema,
      },
    },
    async (request) => {
      const q = request.query as z.infer<typeof unifiedSearchQuerySchema>;
      return searchService.unifiedSearch({
        q: q.q,
        lat: q.lat,
        lon: q.lon,
        radiusKm: q.radiusKm,
        limit: q.limit,
      });
    },
  );

  app.get(
    '/search/providers',
    {
      schema: {
        tags: ['Search'],
        summary: 'Ranked provider search with fuzzy matching and healthcare filters',
        querystring: rankedProviderSearchQuerySchema,
        response: {
          200: z.object({
            providers: z.array(providerSearchResultSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
      config: { rateLimit: { max: 60, timeWindow: '1 minute' } },
    },
    async (request) => {
      const q = request.query as z.infer<typeof rankedProviderSearchQuerySchema>;
      return searchService.searchProvidersRanked({
        page: q.page,
        limit: q.limit,
        q: q.q,
        categoryId: q.categoryId,
        specialtyId: q.specialtyId,
        specialties: parseCsv(q.specialties),
        conditions: parseCsv(q.conditions),
        ageGroups: parseCsv(q.ageGroups),
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
    '/search/facilities',
    {
      schema: {
        tags: ['Search'],
        summary: 'Ranked facility search with open-now and queue filters',
        querystring: rankedFacilitySearchQuerySchema,
        response: {
          200: z.object({
            facilities: z.array(facilitySearchResultSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
      config: { rateLimit: { max: 60, timeWindow: '1 minute' } },
    },
    async (request) => {
      const q = request.query as z.infer<typeof rankedFacilitySearchQuerySchema>;
      return searchService.searchFacilitiesRanked({
        page: q.page,
        limit: q.limit,
        q: q.q,
        province: q.province,
        city: q.city,
        facilityType: q.facilityType,
        isVerified: q.isVerified,
        openNow: q.openNow,
        hasQueue: q.hasQueue,
        lat: q.lat,
        lon: q.lon,
        radiusKm: q.radiusKm,
      });
    },
  );

  app.get(
    '/search/specialties',
    {
      schema: {
        tags: ['Search'],
        summary: 'Specialty search with typo tolerance',
        querystring: specialtySearchQuerySchema,
        response: {
          200: z.object({
            specialties: z.array(specialtySearchResultSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query as z.infer<typeof specialtySearchQuerySchema>;
      return searchService.searchSpecialties({
        page: q.page,
        limit: q.limit,
        q: q.q,
        facilityId: q.facilityId,
      });
    },
  );

  app.get(
    '/search/emergency',
    {
      schema: {
        tags: ['Search'],
        summary: 'Nearby emergency services search',
        querystring: emergencySearchQuerySchema,
      },
    },
    async (request) => {
      const q = request.query as z.infer<typeof emergencySearchQuerySchema>;
      return searchService.searchEmergencyNearby({
        page: q.page,
        limit: q.limit,
        lat: q.lat,
        lon: q.lon,
        radiusKm: q.radiusKm,
        q: q.q,
        serviceType: q.serviceType,
        openNow: q.openNow,
      });
    },
  );
};
