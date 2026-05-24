import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { requireAuth } from '../plugins/auth-guard.js';
import {
  createReviewSchema,
  paginationMetaSchema,
  paginationQuerySchema,
  reviewSchema,
} from '../schemas/common.js';
import * as reviewsService from '../services/reviews.service.js';

export const reviewsRoutes: FastifyPluginAsyncZod = async (app) => {
  app.post(
    '/reviews',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Reviews'],
        summary: 'Submit a provider review',
        security: [{ bearerAuth: [] }],
        body: createReviewSchema,
        response: { 201: z.object({ review: reviewSchema }) },
      },
    },
    async (request, reply) => {
      const review = await reviewsService.createReview(request.user!.id, request.body);
      return reply.status(201).send({ review });
    },
  );

  app.get(
    '/reviews/provider/:id',
    {
      schema: {
        tags: ['Reviews'],
        summary: 'List reviews for a provider',
        params: z.object({ id: z.string().uuid() }),
        querystring: paginationQuerySchema,
        response: {
          200: z.object({
            reviews: z.array(reviewSchema),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const query = request.query as z.infer<typeof paginationQuerySchema>;
      return reviewsService.listProviderReviews(request.params.id, {
        page: query.page,
        limit: query.limit,
      });
    },
  );
};
