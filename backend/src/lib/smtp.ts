import nodemailer from 'nodemailer';
import { env } from '../config.js';

export interface SmtpSendResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

let transporter: nodemailer.Transporter | null = null;

function getTransporter(): nodemailer.Transporter | null {
  const host = env.SMTP_HOST;
  if (!host) return null;

  if (!transporter) {
    transporter = nodemailer.createTransport({
      host,
      port: env.SMTP_PORT,
      secure: env.SMTP_PORT === 465,
      auth:
        env.SMTP_USER && env.SMTP_PASS
          ? { user: env.SMTP_USER, pass: env.SMTP_PASS }
          : undefined,
    });
  }
  return transporter;
}

/** Send transactional email via configured SMTP (Gmail). */
export async function sendSmtpEmail(options: {
  host: string;
  port: number;
  from: string;
  to: string;
  subject: string;
  html: string;
}): Promise<SmtpSendResult> {
  const transport = getTransporter();
  if (!transport) {
    return { success: false, error: 'SMTP not configured' };
  }

  try {
    const info = await transport.sendMail({
      from: options.from,
      to: options.to,
      subject: options.subject,
      html: options.html,
    });
    return { success: true, messageId: info.messageId };
  } catch (err) {
    const message = err instanceof Error ? err.message : 'SMTP send failed';
    return { success: false, error: message };
  }
}
