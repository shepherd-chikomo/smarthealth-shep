import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';
import { env } from '../config.js';
import { requireAuth } from '../plugins/auth-guard.js';
import {
  notificationFilterSchema,
  notificationSchema,
  paginationMetaSchema,
  paginationQuerySchema,
} from '../schemas/common.js';
import * as dispatch from '../services/notification-dispatch.service.js';
import * as notificationsService from '../services/notifications.service.js';

const preferenceSchema = z.object({
  id: z.string().uuid(),
  channel: z.string(),
  category: z.string(),
  is_enabled: z.boolean(),
  quiet_hours_start: z.string().nullable().optional(),
  quiet_hours_end: z.string().nullable().optional(),
});

export const notificationsRoutes: FastifyPluginAsyncZod = async (app) => {
  // Internal dispatch webhook (Supabase trigger / edge function)
  app.post(
    '/notifications/dispatch',
    {
      schema: {
        tags: ['Notifications'],
        summary: 'Dispatch pending notification (internal)',
        body: z.object({
          notificationId: z.string().uuid().optional(),
          secret: z.string(),
        }),
      },
    },
    async (request, reply) => {
      if (request.body.secret !== env.NOTIFICATION_DISPATCH_SECRET) {
        return reply.status(403).send({ error: { code: 'FORBIDDEN', message: 'Invalid secret' } });
      }
      if (request.body.notificationId) {
        await dispatch.dispatchNotification(request.body.notificationId);
        return { message: 'Dispatched' };
      }
      const count = await dispatch.processPendingNotifications();
      return { message: 'Processed', count };
    },
  );

  app.addHook('preHandler', requireAuth);

  app.get(
    '/notifications',
    {
      schema: {
        tags: ['Notifications'],
        summary: 'List notifications for current user',
        security: [{ bearerAuth: [] }],
        querystring: paginationQuerySchema.merge(notificationFilterSchema).extend({
          category: z.string().optional(),
        }),
        response: {
          200: z.object({
            notifications: z.array(notificationSchema.extend({
              category: z.string(),
              payload: z.record(z.unknown()).optional(),
            })),
            pagination: paginationMetaSchema,
          }),
        },
      },
    },
    async (request) => {
      const q = request.query;
      return notificationsService.listNotifications(request.user!.id, {
        page: q.page,
        limit: q.limit,
        unreadOnly: q.unreadOnly,
        channel: q.channel,
        category: q.category,
      });
    },
  );

  app.get(
    '/notifications/unread-count',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        response: { 200: z.object({ count: z.number() }) },
      },
    },
    async (request) => ({
      count: await notificationsService.getUnreadCount(request.user!.id),
    }),
  );

  app.patch(
    '/notifications/read-all',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        response: { 200: z.object({ message: z.string() }) },
      },
    },
    async (request) => notificationsService.markAllNotificationsRead(request.user!.id),
  );

  app.get(
    '/notifications/dashboard-banner',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        response: {
          200: z.object({
            banner: notificationSchema.extend({
              dismissedAt: z.string().nullable().optional(),
            }).nullable(),
          }),
        },
      },
    },
    async (request) => notificationsService.getActiveDashboardBanner(request.user!.id),
  );

  app.patch(
    '/notifications/:id/dismiss',
    {
      schema: {
        tags: ['Notifications'],
        summary: 'Dismiss dashboard banner notification',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ notification: notificationSchema }) },
      },
    },
    async (request) => ({
      notification: await notificationsService.dismissNotification(
        request.user!.id,
        request.params.id,
      ),
    }),
  );

  app.patch(
    '/notifications/:id/read',
    {
      schema: {
        tags: ['Notifications'],
        summary: 'Mark notification as read',
        security: [{ bearerAuth: [] }],
        params: z.object({ id: z.string().uuid() }),
        response: { 200: z.object({ notification: notificationSchema }) },
      },
    },
    async (request) => {
      const notification = await notificationsService.markNotificationRead(
        request.user!.id,
        request.params.id,
      );
      return { notification };
    },
  );

  app.post(
    '/notifications/push-token',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        body: z.object({
          token: z.string().min(1),
          platform: z.enum(['ios', 'android', 'web']),
          deviceId: z.string().optional(),
          appVersion: z.string().optional(),
        }),
      },
    },
    async (request) =>
      notificationsService.registerPushToken(request.user!.id, request.body),
  );

  app.delete(
    '/notifications/push-token',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        body: z.object({ token: z.string().min(1) }),
      },
    },
    async (request) =>
      notificationsService.deactivatePushToken(request.user!.id, request.body.token),
  );

  app.get(
    '/notifications/preferences',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        response: { 200: z.object({ preferences: z.array(preferenceSchema) }) },
      },
    },
    async (request) => notificationsService.listPreferences(request.user!.id),
  );

  app.put(
    '/notifications/preferences',
    {
      schema: {
        tags: ['Notifications'],
        security: [{ bearerAuth: [] }],
        body: z.object({
          channel: z.enum(['in_app', 'push', 'sms', 'email']),
          category: z.string(),
          tenantId: z.string().uuid().optional(),
          isEnabled: z.boolean(),
          quietHoursStart: z.string().nullable().optional(),
          quietHoursEnd: z.string().nullable().optional(),
        }),
      },
    },
    async (request) =>
      notificationsService.updatePreference(request.user!.id, request.body),
  );
};
