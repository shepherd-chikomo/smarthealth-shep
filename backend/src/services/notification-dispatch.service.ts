import { query } from '../lib/db.js';
import { sendEmail } from '../lib/email.js';
import { sendFcmToTokens } from '../lib/fcm.js';
import { sendSms } from '../lib/sms.js';

interface PendingNotification {
  id: string;
  user_id: string;
  tenant_id: string | null;
  category: string;
  title: string;
  body: string;
  action_url: string | null;
  payload: Record<string, unknown>;
  phone: string | null;
  email: string | null;
}

function isQuietHours(start: string | null, end: string | null): boolean {
  if (!start || !end) return false;
  const now = new Date();
  const mins = now.getHours() * 60 + now.getMinutes();
  const [sh, sm] = start.split(':').map(Number);
  const [eh, em] = end.split(':').map(Number);
  const startM = sh * 60 + sm;
  const endM = eh * 60 + em;
  if (startM <= endM) return mins >= startM && mins < endM;
  return mins >= startM || mins < endM;
}

async function isChannelEnabled(
  userId: string,
  tenantId: string | null,
  channel: string,
  category: string,
): Promise<boolean> {
  const result = await query<{ is_enabled: boolean; quiet_hours_start: string | null; quiet_hours_end: string | null }>(
    `SELECT is_enabled, quiet_hours_start, quiet_hours_end
     FROM public.notification_preferences
     WHERE user_id = $1
       AND channel = $2::public.notification_channel
       AND category = $3
       AND (tenant_id IS NULL OR tenant_id = $4)
     ORDER BY tenant_id NULLS LAST
     LIMIT 1`,
    [userId, channel, category, tenantId],
  );

  const pref = result.rows[0];
  if (!pref) return true;
  if (!pref.is_enabled) return false;
  if (channel === 'push' && isQuietHours(pref.quiet_hours_start, pref.quiet_hours_end)) {
    return false;
  }
  return true;
}

async function getActivePushTokens(userId: string): Promise<string[]> {
  const result = await query<{ token: string }>(
    `SELECT token FROM public.push_tokens
     WHERE user_id = $1 AND is_active = true
     ORDER BY last_used_at DESC NULLS LAST`,
    [userId],
  );
  return result.rows.map((r) => r.token);
}

function buildDeepLinkData(notification: PendingNotification): Record<string, string> {
  return {
    notificationId: notification.id,
    category: notification.category,
    actionUrl: notification.action_url ?? '/home',
    ...(Object.fromEntries(
      Object.entries(notification.payload).map(([k, v]) => [k, String(v)]),
    )),
  };
}

export async function dispatchNotification(notificationId: string): Promise<void> {
  const row = await query<PendingNotification>(
    `SELECT n.id, n.user_id, n.tenant_id, n.category::text, n.title, n.body,
            n.action_url, n.payload, p.phone, p.email
     FROM public.notifications n
     JOIN public.profiles p ON p.id = n.user_id
     WHERE n.id = $1 AND n.status = 'pending'
       AND (n.scheduled_at IS NULL OR n.scheduled_at <= timezone('utc', now()))`,
    [notificationId],
  );

  const notification = row.rows[0];
  if (!notification) return;

  await query(
    `UPDATE public.notifications SET status = 'queued' WHERE id = $1`,
    [notificationId],
  );

  const deepLinkData = buildDeepLinkData(notification);
  let delivered = false;
  let failureReason: string | null = null;

  // 1. Push (FCM)
  if (await isChannelEnabled(notification.user_id, notification.tenant_id, 'push', notification.category)) {
    const tokens = await getActivePushTokens(notification.user_id);
    if (tokens.length > 0) {
      const push = await sendFcmToTokens(
        tokens,
        notification.title,
        notification.body,
        deepLinkData,
      );
      if (push.sent > 0) {
        delivered = true;
        await query(
          `UPDATE public.push_tokens SET last_used_at = timezone('utc', now())
           WHERE user_id = $1 AND token = ANY($2::text[])`,
          [notification.user_id, tokens],
        );
      } else {
        failureReason = 'Push delivery failed';
      }
    } else {
      failureReason = 'No push tokens registered';
    }
  }

  // 2. SMS fallback
  if (!delivered && notification.phone
      && await isChannelEnabled(notification.user_id, notification.tenant_id, 'sms', notification.category)) {
    const smsText = `${notification.title}: ${notification.body}`;
    const sms = await sendSms(notification.phone, smsText);
    await query(
      `INSERT INTO public.sms_logs (
         tenant_id, user_id, notification_id, phone, message, provider,
         provider_message_id, status, sent_at
       ) VALUES ($1, $2, $3, $4, $5, 'twilio', $6, $7, timezone('utc', now()))`,
      [
        notification.tenant_id,
        notification.user_id,
        notificationId,
        notification.phone,
        smsText,
        sms.messageId ?? null,
        sms.success ? 'sent' : 'failed',
      ],
    );
    if (sms.success) delivered = true;
    else failureReason = sms.error ?? 'SMS failed';
  }

  // 3. Email fallback
  if (!delivered && notification.email
      && await isChannelEnabled(notification.user_id, notification.tenant_id, 'email', notification.category)) {
    const html = `
      <h2>${notification.title}</h2>
      <p>${notification.body}</p>
      ${notification.action_url ? `<p><a href="smarthealth://${notification.action_url.replace(/^\//, '')}">Open in SmartHealth</a></p>` : ''}
    `;
    const email = await sendEmail(
      notification.email,
      notification.title,
      html,
      notification.category,
    );
    await query(
      `INSERT INTO public.email_logs (
         tenant_id, user_id, notification_id, email, subject, template_key,
         provider, provider_message_id, status, sent_at
       ) VALUES ($1, $2, $3, $4, $5, $6, 'resend', $7, $8, timezone('utc', now()))`,
      [
        notification.tenant_id,
        notification.user_id,
        notificationId,
        notification.email,
        notification.title,
        notification.category,
        email.messageId ?? null,
        email.success ? 'sent' : 'failed',
      ],
    );
    if (email.success) delivered = true;
    else failureReason = email.error ?? 'Email failed';
  }

  // In-app record always exists; mark delivery status
  if (delivered) {
    await query(
      `UPDATE public.notifications SET status = 'delivered', sent_at = timezone('utc', now())
       WHERE id = $1`,
      [notificationId],
    );
  } else {
    await query(
      `UPDATE public.notifications SET
         status = 'sent',
         sent_at = timezone('utc', now()),
         failure_reason = $2
       WHERE id = $1`,
      [notificationId, failureReason],
    );
  }
}

export async function processPendingNotifications(limit = 50): Promise<number> {
  const pending = await query<{ id: string }>(
    `SELECT id FROM public.notifications
     WHERE status = 'pending'
       AND (scheduled_at IS NULL OR scheduled_at <= timezone('utc', now()))
     ORDER BY priority DESC, created_at ASC
     LIMIT $1`,
    [limit],
  );

  for (const row of pending.rows) {
    await dispatchNotification(row.id);
  }

  return pending.rows.length;
}

export async function sendProviderMessage(input: {
  userId: string;
  tenantId?: string;
  providerId: string;
  providerName: string;
  title: string;
  body: string;
}): Promise<string> {
  const result = await query<{ id: string }>(
    `SELECT public.enqueue_notification(
       $1::uuid, $2::uuid, 'provider_message'::public.notification_category,
       $3, $4, $5, $6::jsonb, null, null, 1
     ) AS id`,
    [
      input.userId,
      input.tenantId ?? null,
      input.title,
      input.body,
      `/provider/${input.providerId}`,
      JSON.stringify({ providerId: input.providerId, providerName: input.providerName }),
    ],
  );
  const id = result.rows[0].id;
  await dispatchNotification(id);
  return id;
}

export async function sendFacilityAnnouncement(input: {
  tenantId: string;
  title: string;
  body: string;
  actionUrl?: string;
  userIds: string[];
}): Promise<number> {
  let count = 0;
  for (const userId of input.userIds) {
    const result = await query<{ id: string }>(
      `SELECT public.enqueue_notification(
         $1::uuid, $2::uuid, 'facility_announcement'::public.notification_category,
         $3, $4, $5, '{}'::jsonb, null, $6, 0
       ) AS id`,
      [
        userId,
        input.tenantId,
        input.title,
        input.body,
        input.actionUrl ?? '/home',
        `facility_announce:${input.tenantId}:${userId}:${Date.now()}`,
      ],
    );
    await dispatchNotification(result.rows[0].id);
    count += 1;
  }
  return count;
}
