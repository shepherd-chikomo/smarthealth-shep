import { env } from '../config.js';

export interface FcmMessage {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export interface FcmResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

let accessTokenCache: { token: string; expiresAt: number } | null = null;

async function getFirebaseAccessToken(): Promise<string | null> {
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    return null;
  }

  if (accessTokenCache && accessTokenCache.expiresAt > Date.now() + 60_000) {
    return accessTokenCache.token;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = Buffer.from(JSON.stringify({ alg: 'RS256', typ: 'JWT' })).toString('base64url');
  const claim = Buffer.from(
    JSON.stringify({
      iss: env.FIREBASE_CLIENT_EMAIL,
      sub: env.FIREBASE_CLIENT_EMAIL,
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
    }),
  ).toString('base64url');

  const crypto = await import('crypto');
  const sign = crypto.createSign('RSA-SHA256');
  sign.update(`${header}.${claim}`);
  const signature = sign.sign(env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'), 'base64url');
  const jwt = `${header}.${claim}.${signature}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!res.ok) return null;
  const data = (await res.json()) as { access_token: string; expires_in: number };
  accessTokenCache = {
    token: data.access_token,
    expiresAt: Date.now() + data.expires_in * 1000,
  };
  return data.access_token;
}

export async function sendFcmMessage(message: FcmMessage): Promise<FcmResult> {
  const accessToken = await getFirebaseAccessToken();

  if (!accessToken || !env.FIREBASE_PROJECT_ID) {
    if (env.NODE_ENV === 'development') {
      console.info('[FCM dev]', message.title, '→', message.token.slice(0, 12));
      return { success: true, messageId: `dev-${Date.now()}` };
    }
    return { success: false, error: 'Firebase not configured' };
  }

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: message.token,
          notification: { title: message.title, body: message.body },
          data: message.data ?? {},
          android: { priority: 'HIGH' },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  );

  const data = (await res.json()) as { name?: string; error?: { message?: string } };
  if (!res.ok) {
    return { success: false, error: data.error?.message ?? `FCM HTTP ${res.status}` };
  }
  return { success: true, messageId: data.name };
}

export async function sendFcmToTokens(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<{ sent: number; failed: number }> {
  let sent = 0;
  let failed = 0;
  for (const token of tokens) {
    const result = await sendFcmMessage({ token, title, body, data });
    if (result.success) sent += 1;
    else failed += 1;
  }
  return { sent, failed };
}
