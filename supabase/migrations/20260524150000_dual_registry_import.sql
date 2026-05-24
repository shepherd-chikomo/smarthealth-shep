-- SmartHealth: dual-registry import (HPA facilities + MDPCZ practitioners)

begin;

-- ---------------------------------------------------------------------------
-- Provider extensions
-- ---------------------------------------------------------------------------

alter table public.providers
  alter column facility_id drop not null;

alter table public.providers
  alter column tenant_id drop not null;

alter table public.providers
  add column if not exists gender public.gender,
  add column if not exists qualification text;

create unique index if not exists providers_registration_number_unique_idx
  on public.providers (registration_number)
  where registration_number is not null and deleted_at is null;

-- ---------------------------------------------------------------------------
-- Provider-facility link: HPA role-holder flag
-- ---------------------------------------------------------------------------

alter table public.provider_facility_links
  add column if not exists is_facility_role_holder boolean not null default false;

-- ---------------------------------------------------------------------------
-- Import review queues (manual association, ambiguous facilities, etc.)
-- ---------------------------------------------------------------------------

create type public.import_queue_type as enum (
  'ambiguous_facility',
  'manual_association',
  'unlinked_practitioner',
  'no_email_practitioner'
);

create table public.import_review_queue (
  id uuid primary key default gen_random_uuid(),
  queue_type public.import_queue_type not null,
  facility_id uuid references public.facilities (id) on delete cascade,
  provider_id uuid references public.providers (id) on delete cascade,
  import_batch_id uuid references public.import_logs (id) on delete set null,
  row_number int,
  raw_data jsonb not null default '{}'::jsonb,
  notes text,
  status text not null default 'pending',
  resolved_at timestamptz,
  resolved_by uuid references public.profiles (id) on delete set null,
  resolution_notes text,
  created_at timestamptz not null default timezone('utc', now())
);

create index import_review_queue_type_status_idx
  on public.import_review_queue (queue_type, status)
  where status = 'pending';

create index import_review_queue_facility_idx
  on public.import_review_queue (facility_id)
  where facility_id is not null;

create index import_review_queue_provider_idx
  on public.import_review_queue (provider_id)
  where provider_id is not null;

-- Pending HPA role-holder name for cross-linking
create table public.facility_role_holder_intents (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  practitioner_first_name text,
  practitioner_last_name text,
  normalized_full_name text not null,
  import_batch_id uuid references public.import_logs (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (facility_id)
);

create index facility_role_holder_intents_name_idx
  on public.facility_role_holder_intents (normalized_full_name);

-- Stable registry keys for diff sync
alter table public.facilities
  add column if not exists registry_key text;

alter table public.providers
  add column if not exists registry_key text;

create unique index if not exists facilities_registry_key_idx
  on public.facilities (registry_key)
  where registry_key is not null and deleted_at is null;

create unique index if not exists providers_registry_key_idx
  on public.providers (registry_key)
  where registry_key is not null and deleted_at is null;

-- ---------------------------------------------------------------------------
-- Registry diff (monthly refresh)
-- ---------------------------------------------------------------------------

create type public.registry_entity_type as enum ('facility', 'provider');
create type public.registry_change_type as enum ('added', 'updated', 'removed');

create table public.registry_diff_runs (
  id uuid primary key default gen_random_uuid(),
  source_type public.import_source_type not null,
  source_file text not null,
  status text not null default 'pending',
  added_count int not null default 0,
  updated_count int not null default 0,
  removed_count int not null default 0,
  started_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  notified_at timestamptz,
  report_json jsonb
);

create table public.registry_diff_items (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.registry_diff_runs (id) on delete cascade,
  entity_type public.registry_entity_type not null,
  change_type public.registry_change_type not null,
  entity_id uuid,
  stable_key text not null,
  field_changes jsonb not null default '{}'::jsonb,
  raw_data jsonb not null default '{}'::jsonb,
  status text not null default 'pending',
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  review_notes text,
  created_at timestamptz not null default timezone('utc', now())
);

create index registry_diff_items_run_status_idx
  on public.registry_diff_items (run_id, status);

create index registry_diff_runs_started_idx
  on public.registry_diff_runs (started_at desc);

-- ---------------------------------------------------------------------------
-- Practitioner invitations (verified practitioners only)
-- ---------------------------------------------------------------------------

create type public.invitation_status as enum (
  'pending',
  'accepted',
  'declined',
  'expired',
  'cancelled'
);

create table public.facility_practitioner_invitations (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  provider_id uuid not null references public.providers (id) on delete cascade,
  invited_by uuid not null references public.profiles (id) on delete cascade,
  status public.invitation_status not null default 'pending',
  created_at timestamptz not null default timezone('utc', now()),
  responded_at timestamptz
);

create unique index facility_practitioner_invitations_pending_unique_idx
  on public.facility_practitioner_invitations (facility_id, provider_id)
  where status = 'pending';

create index facility_practitioner_invitations_provider_idx
  on public.facility_practitioner_invitations (provider_id, status)
  where status = 'pending';

-- Facility admin invite by email
create table public.facility_admin_invitations (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  email text not null,
  invited_by uuid not null references public.profiles (id) on delete cascade,
  status public.invitation_status not null default 'pending',
  accepted_user_id uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  responded_at timestamptz
);

create index facility_admin_invitations_email_idx
  on public.facility_admin_invitations (email, status)
  where status = 'pending';

-- ---------------------------------------------------------------------------
-- Manual validation tickets (validation@smarthealth.co.zw)
-- ---------------------------------------------------------------------------

create table public.manual_validation_tickets (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid references public.providers (id) on delete set null,
  registration_number text not null,
  specialty text,
  submitter_name text,
  submitter_email text,
  submitter_phone text,
  evidence jsonb not null default '{}'::jsonb,
  status text not null default 'submitted',
  mdpcz_notes text,
  claimant_id uuid references public.profiles (id) on delete set null,
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  review_notes text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index manual_validation_tickets_status_idx
  on public.manual_validation_tickets (status)
  where status in ('submitted', 'under_review');

create trigger manual_validation_tickets_set_updated_at
  before update on public.manual_validation_tickets
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Practitioner claim OTP sessions (reg + email + specialty pre-check)
-- ---------------------------------------------------------------------------

create table public.practitioner_claim_sessions (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  registration_number text not null,
  email text not null,
  specialty_normalized text not null,
  otp_verified boolean not null default false,
  claimed_by uuid references public.profiles (id) on delete set null,
  expires_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index practitioner_claim_sessions_provider_idx
  on public.practitioner_claim_sessions (provider_id);

alter table public.provider_claims
  alter column tenant_id drop not null;

commit;
