-- SmartHealth: appointments extended (walk-ins, history, notes, payments)

begin;

-- Extend appointments with tenant + soft delete
alter table public.appointments
  add column if not exists tenant_id uuid references public.facilities (id) on delete restrict,
  add column if not exists queue_session_id uuid,
  add column if not exists deleted_at timestamptz,
  add column if not exists deleted_by uuid references public.profiles (id);

update public.appointments set tenant_id = facility_id where tenant_id is null;

alter table public.appointments
  alter column tenant_id set not null;

create index if not exists appointments_tenant_idx on public.appointments (tenant_id);
create index if not exists appointments_not_deleted_idx
  on public.appointments (facility_id, scheduled_at)
  where deleted_at is null;

-- Walk-in sessions
create table public.walk_in_sessions (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  provider_id uuid references public.providers (id) on delete set null,
  queue_session_id uuid references public.queue_sessions (id) on delete set null,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  appointment_id uuid references public.appointments (id) on delete set null,
  ticket_number int not null,
  status public.walk_in_status not null default 'registered',
  queue_status public.queue_status not null default 'waiting',
  chief_complaint text,
  priority smallint not null default 0 check (priority between 0 and 5),
  registered_at timestamptz not null default timezone('utc', now()),
  called_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  estimated_wait_minutes int,
  registered_by uuid references public.profiles (id),
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint walk_in_tenant_match_chk check (tenant_id = facility_id)
);

create index walk_in_sessions_facility_status_idx
  on public.walk_in_sessions (facility_id, status)
  where deleted_at is null;
create index walk_in_sessions_queue_idx
  on public.walk_in_sessions (queue_session_id, ticket_number)
  where deleted_at is null;
create index walk_in_sessions_patient_idx on public.walk_in_sessions (patient_id);

create trigger walk_in_sessions_set_updated_at
  before update on public.walk_in_sessions
  for each row execute function public.set_updated_at();

-- Link appointments to queue after walk_in_sessions exists
alter table public.appointments
  add constraint appointments_queue_session_fk
  foreign key (queue_session_id) references public.queue_sessions (id) on delete set null;

-- Appointment status history (audit trail)
create table public.appointment_status_history (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  from_status public.appointment_status,
  to_status public.appointment_status not null,
  changed_by uuid references public.profiles (id),
  reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index appointment_status_history_appt_idx
  on public.appointment_status_history (appointment_id, created_at desc);
create index appointment_status_history_tenant_idx
  on public.appointment_status_history (tenant_id);

-- Auto-log appointment status changes
create or replace function public.log_appointment_status_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and old.status is distinct from new.status then
    insert into public.appointment_status_history (
      appointment_id, tenant_id, from_status, to_status, changed_by
    )
    values (
      new.id, new.tenant_id, old.status, new.status, auth.uid()
    );
  end if;
  return new;
end;
$$;

create trigger appointments_log_status_change
  after update of status on public.appointments
  for each row execute function public.log_appointment_status_change();

-- Appointment notes (clinical + admin)
create table public.appointment_notes (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null references public.appointments (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  author_id uuid not null references public.profiles (id) on delete restrict,
  note_type text not null default 'general' check (
    note_type in ('general', 'clinical', 'billing', 'internal')
  ),
  content text not null,
  is_pinned boolean not null default false,
  is_confidential boolean not null default false,
  deleted_at timestamptz,
  deleted_by uuid references public.profiles (id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index appointment_notes_appt_idx
  on public.appointment_notes (appointment_id)
  where deleted_at is null;
create index appointment_notes_tenant_idx on public.appointment_notes (tenant_id);

create trigger appointment_notes_set_updated_at
  before update on public.appointment_notes
  for each row execute function public.set_updated_at();

-- Appointment payments (linked to billing, lightweight pre-payment)
create table public.appointment_payments (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null references public.appointments (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  amount_cents bigint not null check (amount_cents >= 0),
  currency_code char(3) not null default 'USD',
  payment_method public.payment_method not null default 'cash',
  status public.payment_status not null default 'pending',
  reference_number text unique,
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index appointment_payments_appt_idx on public.appointment_payments (appointment_id);
create index appointment_payments_tenant_status_idx
  on public.appointment_payments (tenant_id, status);

create trigger appointment_payments_set_updated_at
  before update on public.appointment_payments
  for each row execute function public.set_updated_at();

commit;
