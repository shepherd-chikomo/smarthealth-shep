import { query } from '../lib/db.js';
import { buildPaginationMeta } from '../lib/pagination.js';
import { adminOffset, type AdminListQuery } from '../lib/admin-query.js';
import { dispatchNotification } from './notification-dispatch.service.js';

const BATCH_SIZE = 100;

export async function broadcastToAllUsers(
  adminUserId: string,
  data: { title: string; body: string; actionUrl?: string },
): Promise<{ broadcastId: string; recipientCount: number }> {
  const broadcast = await query<{ id: string }>(
    `INSERT INTO public.platform_broadcasts (title, body, action_url, created_by)
     VALUES ($1, $2, $3, $4)
     RETURNING id`,
    [data.title, data.body, data.actionUrl ?? '/home', adminUserId],
  );
  const broadcastId = broadcast.rows[0].id;

  const recipients = await query<{ id: string }>(
    `SELECT id FROM public.profiles
     WHERE deleted_at IS NULL AND primary_role = 'patient'::public.app_role`,
  );

  let count = 0;
  for (let i = 0; i < recipients.rows.length; i += BATCH_SIZE) {
    const batch = recipients.rows.slice(i, i + BATCH_SIZE);
    for (const row of batch) {
      const dedupeKey = `platform_broadcast:${broadcastId}:${row.id}`;
      const result = await query<{ id: string }>(
        `SELECT public.enqueue_notification(
           $1::uuid, null, 'general'::public.notification_category,
           $2, $3, $4, $5::jsonb, null, $6, 5
         ) AS id`,
        [
          row.id,
          data.title,
          data.body,
          data.actionUrl ?? '/home',
          JSON.stringify({ requiresDashboardDismiss: true, broadcastId }),
          dedupeKey,
        ],
      );
      await dispatchNotification(result.rows[0].id);
      count += 1;
    }
  }

  await query(
    `UPDATE public.platform_broadcasts SET recipient_count = $2 WHERE id = $1`,
    [broadcastId, count],
  );

  return { broadcastId, recipientCount: count };
}

export async function listPlatformBroadcasts(opts: AdminListQuery) {
  const offset = adminOffset(opts.page, opts.limit);
  const count = await query<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM public.platform_broadcasts`,
  );
  const rows = await query(
    `SELECT id, title, body, action_url, recipient_count, created_at,
            (SELECT email FROM public.profiles WHERE id = created_by) AS created_by_email
     FROM public.platform_broadcasts
     ORDER BY created_at DESC
     LIMIT $1 OFFSET $2`,
    [opts.limit, offset],
  );
  return {
    broadcasts: rows.rows.map((r) => ({
      id: r.id,
      title: r.title,
      body: r.body,
      actionUrl: r.action_url,
      recipientCount: r.recipient_count,
      createdAt: (r.created_at as Date).toISOString(),
      createdByEmail: r.created_by_email,
    })),
    pagination: buildPaginationMeta(opts.page, opts.limit, Number(count.rows[0]?.count ?? 0)),
  };
}
