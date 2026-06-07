import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import {
  paginationMetaSchema,
  paginationQuerySchema,
  profileConditionPublicSchema,
  profileConditionsGroupedSchema,
} from '../schemas/common.js';
import * as catalogService from '../services/catalog.service.js';
import * as profileConditions from '../services/profile-conditions.service.js';
import * as facilityServicesCatalog from '../services/facility-services-catalog.service.js';

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

const medicalAidSchemeSchema = z.object({
  schemeKey: z.string(),
  name: z.string(),
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

  app.get(
    '/catalog/profile-conditions',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Medical profile condition picker (common and non-common groups)',
        response: { 200: profileConditionsGroupedSchema },
      },
    },
    async () => profileConditions.listProfileConditions(),
  );

  app.get(
    '/catalog/profile-conditions/suggest',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Autocomplete suggestions for profile condition entry',
        querystring: z.object({
          q: z.string().default(''),
          limit: z.coerce.number().int().min(1).max(20).default(8),
        }),
        response: {
          200: z.object({
            suggestions: z.array(profileConditionPublicSchema),
          }),
        },
      },
    },
    async (request) =>
      profileConditions.suggestProfileConditions(request.query.q, request.query.limit),
  );

  app.get(
    '/catalog/facility-services',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Global facility service catalog for public profile configuration',
        response: {
          200: z.object({
            preset: z.array(
              z.object({ id: z.string(), label: z.string(), iconKey: z.string() }),
            ),
            other: z.array(
              z.object({ id: z.string(), label: z.string(), iconKey: z.string() }),
            ),
          }),
        },
      },
    },
    async () => facilityServicesCatalog.listFacilityServicesCatalog(),
  );

  app.get(
    '/catalog/facility-services/suggest',
    {
      schema: {
        tags: ['Catalog'],
        querystring: z.object({
          q: z.string().default(''),
          limit: z.coerce.number().int().min(1).max(20).default(8),
        }),
        response: {
          200: z.object({
            suggestions: z.array(
              z.object({ id: z.string(), label: z.string(), iconKey: z.string() }),
            ),
          }),
        },
      },
    },
    async (request) =>
      facilityServicesCatalog.suggestFacilityServices(request.query.q, request.query.limit),
  );

  app.get(
    '/catalog/medical-aids',
    {
      schema: {
        tags: ['Catalog'],
        summary: 'Platform medical aid schemes for patient profiles',
        response: {
          200: z.object({
            schemes: z.array(medicalAidSchemeSchema),
          }),
        },
      },
    },
    async () => catalogService.listMedicalAidCatalog(),
  );
};
