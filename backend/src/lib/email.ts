import { env } from '../config.js';

export interface EmailResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

export async function sendEmail(
  to: string,
  subject: string,
  html: string,
  templateKey?: string,
): Promise<EmailResult> {
  if (!env.RESEND_API_KEY) {
    if (env.NODE_ENV === 'development') {
      console.info('[Email dev]', to, subject, templateKey ?? '');
      return { success: true, messageId: `dev-email-${Date.now()}` };
    }
    return { success: false, error: 'Email provider not configured' };
  }

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: env.EMAIL_FROM ?? 'SmartHealth <notifications@smarthealth.co.zw>',
      to: [to],
      subject,
      html,
    }),
  });

  const data = (await res.json()) as { id?: string; message?: string };
  if (!res.ok) {
    return { success: false, error: data.message ?? `Email HTTP ${res.status}` };
  }
  return { success: true, messageId: data.id };
}
