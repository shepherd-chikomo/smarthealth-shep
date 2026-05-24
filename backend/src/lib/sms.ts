import { env } from '../config.js';

export interface SmsResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

export async function sendSms(to: string, message: string): Promise<SmsResult> {
  if (!env.TWILIO_ACCOUNT_SID || !env.TWILIO_AUTH_TOKEN || !env.TWILIO_FROM_NUMBER) {
    if (env.NODE_ENV === 'development') {
      console.info('[SMS dev]', to, message.slice(0, 80));
      return { success: true, messageId: `dev-sms-${Date.now()}` };
    }
    return { success: false, error: 'Twilio not configured' };
  }

  const url = `https://api.twilio.com/2010-04-01/Accounts/${env.TWILIO_ACCOUNT_SID}/Messages.json`;
  const auth = Buffer.from(`${env.TWILIO_ACCOUNT_SID}:${env.TWILIO_AUTH_TOKEN}`).toString('base64');

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({ To: to, From: env.TWILIO_FROM_NUMBER, Body: message }),
  });

  const data = (await res.json()) as { sid?: string; message?: string };
  if (!res.ok) {
    return { success: false, error: data.message ?? `Twilio HTTP ${res.status}` };
  }
  return { success: true, messageId: data.sid };
}
