import type { FastifyInstance } from 'fastify';
import { env } from '../config.js';

export async function registerSwagger(app: FastifyInstance) {
  await app.register(import('@fastify/swagger'), {
    openapi: {
      info: {
        title: 'SmartHealth API',
        description: 'Patient app REST API for SmartHealth — Zimbabwe healthcare platform',
        version: '1.0.0',
        contact: {
          name: 'SmartHealth',
          url: 'https://smarthealth.co.zw',
        },
      },
      servers: [
        { url: `http://localhost:${env.PORT}${env.API_PREFIX}`, description: 'Local development' },
        { url: 'https://api.smarthealth.co.zw/v1', description: 'Production' },
      ],
      tags: [
        { name: 'Auth', description: 'Authentication and session management' },
        { name: 'Patients', description: 'Patient profile and family members' },
        { name: 'Providers', description: 'Healthcare provider directory' },
        { name: 'Facilities', description: 'Healthcare facilities' },
        { name: 'Appointments', description: 'Appointment booking and management' },
        { name: 'Reviews', description: 'Provider reviews and ratings' },
        { name: 'Emergency', description: 'Emergency services directory' },
        { name: 'Notifications', description: 'In-app notifications' },
        { name: 'Payments', description: 'Payment initiation and status' },
        { name: 'Admin', description: 'Staff admin dashboard API' },
        { name: 'Health', description: 'Service health checks' },
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
            description: 'Supabase JWT access token',
          },
        },
      },
    },
  });

  await app.register(import('@fastify/swagger-ui'), {
    routePrefix: '/docs',
    uiConfig: {
      docExpansion: 'list',
      deepLinking: true,
    },
    staticCSP: true,
  });
}
