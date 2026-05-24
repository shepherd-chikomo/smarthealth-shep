-- SmartHealth: billing (invoices, payments, refunds)

begin;

create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  appointment_id uuid references public.appointments (id) on delete set null,
  consultation_id uuid references public.consultations (id) on delete set null,
  invoice_number text not null,
  status public.invoice_status not null default 'draft',
  currency_code char(3) not null default 'USD',
  subtotal_cents bigint not null default 0 check (subtotal_cents >= 0),
  tax_cents bigint not null default 0 check (tax_cents >= 0),
  discount_cents bigint not null default 0 check (discount_cents >= 0),
  total_cents bigint not null default 0 check (total_cents >= 0),
  amount_paid_cents bigint not null default 0 check (amount_paid_cents >= 0),
  due_date date,
  issued_at timestamptz,
  paid_at timestamptz,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint invoices_tenant_match_chk check (tenant_id = facility_id),
  unique (tenant_id, invoice_number)
);

create index invoices_tenant_status_idx on public.invoices (tenant_id, status) where deleted_at is null;
create index invoices_patient_idx on public.invoices (patient_id) where deleted_at is null;
create index invoices_due_date_idx on public.invoices (due_date) where status in ('sent', 'partial', 'overdue');

create trigger invoices_set_updated_at
  before update on public.invoices
  for each row execute function public.set_updated_at();

create table public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references public.invoices (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  description text not null,
  item_code text,
  quantity numeric(10, 2) not null default 1 check (quantity > 0),
  unit_price_cents bigint not null check (unit_price_cents >= 0),
  tax_rate numeric(5, 2) not null default 0 check (tax_rate >= 0),
  line_total_cents bigint generated always as (
    round(quantity * unit_price_cents)::bigint
  ) stored,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index invoice_items_invoice_idx on public.invoice_items (invoice_id);
create index invoice_items_tenant_idx on public.invoice_items (tenant_id);

-- Platform payments (linked to invoices)
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  invoice_id uuid references public.invoices (id) on delete set null,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  amount_cents bigint not null check (amount_cents > 0),
  currency_code char(3) not null default 'USD',
  payment_method public.payment_method not null,
  status public.payment_status not null default 'pending',
  reference_number text unique,
  external_reference text,
  paid_at timestamptz,
  received_by uuid references public.profiles (id),
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint payments_tenant_match_chk check (tenant_id = facility_id)
);

create index payments_tenant_status_idx on public.payments (tenant_id, status);
create index payments_invoice_idx on public.payments (invoice_id);
create index payments_patient_idx on public.payments (patient_id);

create trigger payments_set_updated_at
  before update on public.payments
  for each row execute function public.set_updated_at();

create table public.payment_transactions (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  gateway text not null,
  gateway_transaction_id text,
  status public.payment_status not null default 'pending',
  amount_cents bigint not null check (amount_cents > 0),
  currency_code char(3) not null default 'USD',
  request_payload jsonb,
  response_payload jsonb,
  error_message text,
  processed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create index payment_transactions_payment_idx on public.payment_transactions (payment_id);
create index payment_transactions_gateway_idx on public.payment_transactions (gateway, gateway_transaction_id);

create table public.refunds (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  invoice_id uuid references public.invoices (id) on delete set null,
  amount_cents bigint not null check (amount_cents > 0),
  currency_code char(3) not null default 'USD',
  status public.refund_status not null default 'pending',
  reason text,
  reference_number text unique,
  processed_by uuid references public.profiles (id),
  processed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index refunds_payment_idx on public.refunds (payment_id);
create index refunds_tenant_status_idx on public.refunds (tenant_id, status);

create trigger refunds_set_updated_at
  before update on public.refunds
  for each row execute function public.set_updated_at();

-- Invoice total recalculation trigger
create or replace function public.recalculate_invoice_totals()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_subtotal bigint;
  v_invoice_id uuid;
begin
  v_invoice_id := coalesce(new.invoice_id, old.invoice_id);

  select coalesce(sum(line_total_cents), 0)
  into v_subtotal
  from public.invoice_items
  where invoice_id = v_invoice_id;

  update public.invoices
  set
    subtotal_cents = v_subtotal,
    total_cents = v_subtotal + tax_cents - discount_cents,
    updated_at = timezone('utc', now())
  where id = v_invoice_id;

  return coalesce(new, old);
end;
$$;

create trigger invoice_items_recalc_totals
  after insert or update or delete on public.invoice_items
  for each row execute function public.recalculate_invoice_totals();

commit;
