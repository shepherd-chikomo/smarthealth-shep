# Supabase Edge Function: notification dispatch webhook
# Triggered by database webhook on notifications INSERT or pg_notify listener

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

const API_URL = Deno.env.get('SMARTHEALTH_API_URL') ?? 'http://host.docker.internal:3000';
const DISPATCH_SECRET = Deno.env.get('NOTIFICATION_DISPATCH_SECRET') ?? 'dev-notification-dispatch-secret';

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  try {
    const body = await req.json();
    const notificationId = body.record?.id ?? body.notificationId ?? body.id;

    const res = await fetch(`${API_URL}/v1/notifications/dispatch`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        secret: DISPATCH_SECRET,
        notificationId,
      }),
    });

    const data = await res.json();
    return new Response(JSON.stringify(data), {
      status: res.status,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : 'Dispatch failed' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
