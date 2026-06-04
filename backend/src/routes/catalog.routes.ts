import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { paginationMetaSchema, paginationQuerySchema } from '../schemas/common.js';
import * as catalogService from '../services/catalog.service.js';

const facilityTypeCatalogItemSchema = z.object({
  facilityType: z.string(),
  label: z.string(),
  count: z.number(),
});

const specialtyCatalogItemSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  slug: z.string(),
  category: z.string().nullable(),
  description: z.string().nullable(),
  icdCode: z.string().nullable(),
});

const catalogFilterItemSchema = z.object({
  id: z.string(),
  label: z.string(),
  count: z.number(),
});

export const catalogRoutes: FastifyPluginAsyncZod = async (app) => {
  app.get(
    '/catalog/facility-types',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Facility types with active counts (home category tiles)',
        response: {
          200: z.object({
            types: z.array(facilityTypeCatalogItemSchema),
          }),
        },
      },
    },
    async () => catalogService.listFacilityTypeCatalog(),
  );

  app.get(
    '/catalog/specialties',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Active specialties for search filter chips',
        querystring: paginationQuerySchema,
        response: {
          200: z.object({
            specialties: z.array(specialtyCatalogItemSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query;
      return catalogService.listCatalogSpecialties({
        page: q.page,
        limit: Math.min(q.limit, 50),
      });
    },
  );

  app.get(
    '/catalog/conditions',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Distinct conditions treated by active providers (search filters)',
        response: {
          200: z.object({
            conditions: z.array(catalogFilterItemSchema),
          }),
        },
      },
    },
    async () => catalogService.listConditionCatalog(),
  );

  app.get(
    '/catalog/age-groups',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Distinct patient age groups served by active providers (search filters)',
        response: {
          200: z.object({
            ageGroups: z.array(catalogFilterItemSchema),
          }),
        },
      },
    },
    async () => catalogService.listAgeGroupCatalog(),
  );
};
