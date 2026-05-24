import { createHash } from 'node:crypto';
import { query } from '../lib/db.js';
import { NotFoundError, ValidationError } from '../lib/errors.js';
import { env } from '../config.js';
import { logBillingAudit } from '../lib/audit-log.js';
import type { RequestContext } from '../lib/request-context.js';

interface PaymentRow {
  id: string;
  status: string;
  amount_cents: number;
  currency_code: string;
  reference_number: string | null;
  paid_at: Date | null;
  created_at: Date;
  facility_id: string;
  patient_id: string;
}

function mapPayment(row: PaymentRow) {
  return {
    id: row.id,
    status: row.status,
    amountCents: row.amount_cents,
    currencyCode: row.currency_code,
    referenceNumber: row.reference_number,
    paidAt: row.paid_at?.toISOString() ?? null,
    createdAt: row.created_at.toISOString(),
  };
}

function generateReferenceNumber(): string {
  const ts = Date.now().toString(36).toUpperCase();
  const rand = Math.random().toString(36).slice(2, 8).toUpperCase();
  return `PAY-${ts}-${rand}`;
}

export async function initiatePayment(
  userId: string,
  data: {
    appointmentId?: string;
    invoiceId?: string;
    amountCents: number;
    currencyCode: string;
    paymentMethod: string;
  },
  context?: RequestContext,
) {
  if (!data.appointmentId && !data.invoiceId) {
    throw new ValidationError('Either appointmentId or invoiceId is required');
  }

  let facilityId: string;
  let invoiceId: string | null = data.invoiceId ?? null;

  if (data.appointmentId) {
    const appt = await query<{ facility_id: string }>(
      'SELECT facility_id FROM public.appointments WHERE id = $1 AND patient_id = $2',
      [data.appointmentId, userId],
    );
    if (!appt.rows[0]) throw new NotFoundError('Appointment', data.appointmentId);
    facilityId = appt.rows[0].facility_id;
  } else if (data.invoiceId) {
    const invoice = await query<{ facility_id: string }>(
      'SELECT facility_id FROM public.invoices WHERE id = $1 AND patient_id = $2',
      [data.invoiceId, userId],
    );
    if (!invoice.rows[0]) throw new NotFoundError('Invoice', data.invoiceId);
    facilityId = invoice.rows[0].facility_id;
  } else {
    throw new ValidationError('Payment target not found');
  }

  const referenceNumber = generateReferenceNumber();

  const result = await query<PaymentRow>(
    `INSERT INTO public.payments (
       facility_id, tenant_id, invoice_id, patient_id,
       amount_cents, currency_code, payment_method, status, reference_number,
       metadata
     ) VALUES ($1, $1, $2, $3, $4, $5, $6::public.payment_method, 'pending', $7, $8)
     RETURNING id, status, amount_cents, currency_code, reference_number, paid_at, created_at, facility_id, patient_id`,
    [
      facilityId,
      invoiceId,
      userId,
      data.amountCents,
      data.currencyCode,
      data.paymentMethod,
      referenceNumber,
      JSON.stringify({
        appointmentId: data.appointmentId ?? null,
        initiatedAt: new Date().toISOString(),
      }),
    ],
  );

  const payment = result.rows[0];

  await query(
    `INSERT INTO public.payment_transactions (
       payment_id, tenant_id, gateway, status, amount_cents, currency_code, request_payload
     ) VALUES ($1, $2, 'smarthealth', 'pending', $3, $4, $5)`,
    [payment.id, facilityId, data.amountCents, data.currencyCode, JSON.stringify(data)],
  );

  await logBillingAudit(
    userId,
    'billing.payment.initiate',
    'payment',
    payment.id,
    facilityId,
    context,
    {
      amountCents: data.amountCents,
      currencyCode: data.currencyCode,
      referenceNumber: payment.reference_number,
    },
  );

  return {
    ...mapPayment(payment),
    checkoutUrl: `${env.SUPABASE_URL.replace('54321', '3000')}/checkout/${payment.id}`,
  };
}

export async function getPaymentStatus(userId: string, paymentId: string) {
  const result = await query<PaymentRow>(
    `SELECT id, status, amount_cents, currency_code, reference_number, paid_at, created_at, facility_id, patient_id
     FROM public.payments
     WHERE id = $1 AND patient_id = $2 AND deleted_at IS NULL`,
    [paymentId, userId],
  );

  if (!result.rows[0]) throw new NotFoundError('Payment', paymentId);
  return mapPayment(result.rows[0]);
}

export function verifyWebhookSignature(payload: string, signature: string | undefined): boolean {
  if (!signature) return false;
  const expected = createHash('sha256')
    .update(`${payload}.${env.PAYMENTS_WEBHOOK_SECRET}`)
    .digest('hex');
  return signature === expected;
}

export async function processPaymentWebhook(data: {
  paymentId: string;
  status: 'completed' | 'failed';
  externalReference?: string;
  gatewayTransactionId?: string;
}) {
  const result = await query<PaymentRow>(
    `UPDATE public.payments
     SET status = $2::public.payment_status,
         external_reference = COALESCE($3, external_reference),
         paid_at = CASE WHEN $2 = 'completed' THEN timezone('utc', now()) ELSE paid_at END,
         updated_at = timezone('utc', now())
     WHERE id = $1 AND deleted_at IS NULL
     RETURNING id, status, amount_cents, currency_code, reference_number, paid_at, created_at, facility_id, patient_id`,
    [data.paymentId, data.status, data.externalReference ?? null],
  );

  if (!result.rows[0]) throw new NotFoundError('Payment', data.paymentId);

  const payment = result.rows[0];
  await logBillingAudit(
    payment.patient_id,
    data.status === 'completed' ? 'billing.payment.complete' : 'billing.payment.failed',
    'payment',
    payment.id,
    payment.facility_id,
    undefined,
    { status: data.status, externalReference: data.externalReference },
  );

  await query(
    `UPDATE public.payment_transactions
     SET status = $2::public.payment_status,
         gateway_transaction_id = COALESCE($3, gateway_transaction_id),
         processed_at = timezone('utc', now()),
         response_payload = $4
     WHERE payment_id = $1`,
    [
      data.paymentId,
      data.status,
      data.gatewayTransactionId ?? null,
      JSON.stringify(data),
    ],
  );

  return mapPayment(result.rows[0]);
}
