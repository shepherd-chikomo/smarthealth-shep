import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { requireAuth } from '../plugins/auth-guard.js';
import { ValidationError } from '../lib/errors.js';
import { getRequestContext } from '../lib/request-context.js';
import {
  paymentInitiateSchema,
  paymentStatusSchema,
} from '../schemas/common.js';
import * as paymentsService from '../services/payments.service.js';

const webhookBodySchema = z.object({
  paymentId: z.string().uuid(),
  status: z.enum(['completed', 'failed']),
  externalReference: z.string().optional(),
  gatewayTransactionId: z.string().optional(),
});

export const paymentsRoutes: FastifyPluginAsyncZod = async (app) => {
  app.post(
    '/payments/initiate',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Payments'],
        summary: 'Initiate a payment',
        security: [{ bearerAuth: [] }],
        body: paymentInitiateSchema,
        response: {
          201: paymentStatusSchema.extend({
            checkoutUrl: z.string().url().optional(),
          }),
        },
      },
    },
    async (request, reply) => {
      const payment = await paymentsService.initiatePayment(
        request.user!.id,
        request.body,
        getRequestContext(request),
      );
      return reply.status(201).send(payment);
    },
  );

  app.post(
    '/payments/webhook',
    {
      schema: {
        tags: ['Payments'],
        summary: 'Payment gateway webhook',
        body: webhookBodySchema,
        response: { 200: z.object({ payment: paymentStatusSchema }) },
      },
    },
    async (request) => {
      const signature = request.headers['x-webhook-signature'] as string | undefined;
      const rawBody = JSON.stringify(request.body);

      if (!paymentsService.verifyWebhookSignature(rawBody, signature)) {
        throw new ValidationError('Invalid webhook signature');
      }

      const payment = await paymentsService.processPaymentWebhook(request.body);
      return { payment };
    },
  );

  app.get(
    '/payments/status/:id',
    {
      preHandler: requireAuth,
      schema: {
        tags: ['Payments'],
        summary: 'Get payment status',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ payment: paymentStatusSchema }) },
      },
    },
    async (request) => {
      const payment = await paymentsService.getPaymentStatus(request.user!.id, request.params.id);
      return { payment };
    },
  );
};
