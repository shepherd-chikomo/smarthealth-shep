import type { FastifyInstance, FastifyError } from 'fastify';
import { ZodError } from 'zod';
import { AppError, toErrorResponse } from '../lib/errors.js';

export async function registerErrorHandler(app: FastifyInstance) {
  app.setErrorHandler((error: FastifyError | Error, request, reply) => {
    const requestId = request.id;

    if (error instanceof AppError) {
      request.log.warn({ err: error, requestId }, error.message);
      return reply.status(error.statusCode).send(toErrorResponse(error, requestId));
    }

    if (error instanceof ZodError) {
      request.log.warn({ err: error, requestId }, 'Validation failed');
      return reply.status(422).send(
        toErrorResponse(
          new AppError(422, 'VALIDATION_ERROR', 'Request validation failed', error.flatten()),
          requestId,
        ),
      );
    }

    if ('validation' in error && error.validation) {
      return reply.status(400).send({
        error: {
          code: 'VALIDATION_ERROR',
          message: error.message,
          details: error.validation,
          requestId,
        },
      });
    }

    const statusCode =
      'statusCode' in error && typeof error.statusCode === 'number'
        ? error.statusCode
        : undefined;

    if (statusCode === 429) {
      request.log.warn({ err: error, requestId }, 'Rate limit exceeded');
      return reply.status(429).send({
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: error.message || 'Too many requests. Please wait a moment and try again.',
          requestId,
        },
      });
    }

    request.log.error({ err: error, requestId }, 'Unhandled error');
    return reply.status(500).send({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
        requestId,
      },
    });
  });

  app.setNotFoundHandler((request, reply) => {
    reply.status(404).send({
      error: {
        code: 'NOT_FOUND',
        message: `Route ${request.method} ${request.url} not found`,
        requestId: request.id,
      },
    });
  });
}
