-- SmartHealth: tenant infrastructure, ownership, claiming, core table extensions

begin;

-- ---------------------------------------------------------------------------
-- System reference: countries & cities
-- ---------------------------------------------------------------------------

create table public.countries (
  code char(2) primary key,
  name text not null,
  phone_prefix text not null,
  currency_code char(3) not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now())
);

create table public.cities (
  id uuid primary key default gen_random_uuid(),
  country_code char(2) not null references public.countries (code),
  name text not null,
  province text,
  latitude double precision,
  longitude double precision,
  location extensions.geography(point, 4326),
  population int,
  is_active boolean not null default true,
  search_vector tsvector,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (country_code, name, province)
);

create index cities_country_idx on public.cities (country_code);
create index cities_search_idx on public.cities using gin (search_vector);
create index cities_location_gix on public.cities using gist (location);

create trigger cities_set_updated_at
  before update on public.cities
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Extend facilities (tenant root)
-- ---------------------------------------------------------------------------

alter table public.facilities
  add column if not exists tenant_id uuid generated always as (id) stored,
  add column if not exists owner_id uuid references public.profiles (id) on delete set null,
  add column if not exists is_claimed boolean not null default false,
  add column if not exists verification_status public.verification_status not null default 'pending_review',
  add column if not exists verified_at timestamptz,
  add column if not exists verified_by uuid references public.profiles (id),
  add column if not exists rejection_reason text,
  add column if not exists moderation_status public.moderation_status not null default 'approved',
  add column if not exists moderated_at timestamptz,
  add column if not exists moderated_by uuid references public.profiles (id),
  add column if not exists location extensions.geography(point, 4326),
  add column if not exists city_id uuid references public.cities (id),
  add column if not exists search_vector tsvector,
  add column if not exists deleted_at timestamptz,
  add column if not exists deleted_by uuid references public.profiles (id),
  add column if not exists import_batch_id uuid,
  add column if not exists import_source text,
  add column if not exists imported_at timestamptz,
  add column if not exists imported_by uuid references public.profiles (id);

create index if not exists facilities_tenant_idx on public.facilities (tenant_id);
create index if not exists facilities_owner_idx on public.facilities (owner_id);
create index if not exists facilities_verification_idx on public.facilities (verification_status);
create index if not exists facilities_moderation_idx on public.facilities (moderation_status);
create index if not exists facilities_search_idx on public.facilities using gin (search_vector);
create index if not exists facilities_location_gix on public.facilities using gist (location);
create index if not exists facilities_active_not_deleted_idx
  on public.facilities (is_active)
  where deleted_at is null and is_active = true;

create trigger facilities_sync_location
  before insert or update of latitude, longitude on public.facilities
  for each row execute function public.sync_location_from_coords();

-- Facility operating hours
create table public.facility_operating_hours (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  day_of_week smallint not null check (day_of_week between 0 and 6),
  opens_at time,
  closes_at time,
  is_closed boolean not null default false,
  is_24_hours boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (facility_id, day_of_week),
  constraint facility_hours_tenant_match_chk check (tenant_id = facility_id)
);

create index facility_operating_hours_facility_idx
  on public.facility_operating_hours (facility_id);

create trigger facility_operating_hours_set_updated_at
  before update on public.facility_operating_hours
  for each row execute function public.set_updated_at();

-- Facility claiming workflow
create table public.facility_claims (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  claimant_id uuid not null references public.profiles (id) on delete cascade,
  status public.claim_status not null default 'draft',
  business_registration_number text,
  evidence jsonb not null default '{}'::jsonb,
  notes text,
  reviewed_by uuid references public.profiles (id),
  reviewed_at timestamptz,
  review_notes text,
  submitted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint facility_claims_tenant_match_chk check (tenant_id = facility_id)
);

create index facility_claims_facility_idx on public.facility_claims (facility_id);
create index facility_claims_claimant_idx on public.facility_claims (claimant_id);
create index facility_claims_status_idx on public.facility_claims (status);

create trigger facility_claims_set_updated_at
  before update on public.facility_claims
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Extend providers
-- ---------------------------------------------------------------------------

alter table public.providers
  add column if not exists tenant_id uuid references public.facilities (id) on delete cascade,
  add column if not exists owner_id uuid references public.profiles (id) on delete set null,
  add column if not exists is_claimed boolean not null default false,
  add column if not exists verification_status public.verification_status not null default 'pending_review',
  add column if not exists verified_at timestamptz,
  add column if not exists verified_by uuid references public.profiles (id),
  add column if not exists rejection_reason text,
  add column if not exists moderation_status public.moderation_status not null default 'approved',
  add column if not exists moderated_at timestamptz,
  add column if not exists moderated_by uuid references public.profiles (id),
  add column if not exists search_vector tsvector,
  add column if not exists deleted_at timestamptz,
  add column if not exists deleted_by uuid references public.profiles (id),
  add column if not exists import_batch_id uuid,
  add column if not exists import_source text,
  add column if not exists imported_at timestamptz,
  add column if not exists imported_by uuid references public.profiles (id);

update public.providers set tenant_id = facility_id where tenant_id is null;

alter table public.providers
  alter column tenant_id set not null;

create index if not exists providers_tenant_idx on public.providers (tenant_id);
create index if not exists providers_owner_idx on public.providers (owner_id);
create index if not exists providers_search_idx on public.providers using gin (search_vector);
create index if not exists providers_active_not_deleted_idx
  on public.providers (facility_id)
  where deleted_at is null and is_active = true;

-- Provider claiming workflow
create table public.provider_claims (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  claimant_id uuid not null references public.profiles (id) on delete cascade,
  status public.claim_status not null default 'draft',
  mdpcz_number text,
  evidence jsonb not null default '{}'::jsonb,
  notes text,
  reviewed_by uuid references public.profiles (id),
  reviewed_at timestamptz,
  review_notes text,
  submitted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index provider_claims_provider_idx on public.provider_claims (provider_id);
create index provider_claims_claimant_idx on public.provider_claims (claimant_id);
create index provider_claims_status_idx on public.provider_claims (status);

create trigger provider_claims_set_updated_at
  before update on public.provider_claims
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Extend specialties
-- ---------------------------------------------------------------------------

alter table public.specialties
  add column if not exists tenant_id uuid references public.facilities (id) on delete cascade,
  add column if not exists country_code char(2) references public.countries (code) default 'ZW',
  add column if not exists icd_code text,
  add column if not exists search_vector tsvector,
  add column if not exists deleted_at timestamptz,
  add column if not exists updated_at timestamptz not null default timezone('utc', now());

create index if not exists specialties_tenant_idx on public.specialties (tenant_id);
create index if not exists specialties_search_idx on public.specialties using gin (search_vector);

create trigger specialties_set_updated_at
  before update on public.specialties
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Queue management
-- ---------------------------------------------------------------------------

create table public.queue_sessions (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  provider_id uuid references public.providers (id) on delete set null,
  session_date date not null default (timezone('utc', now()))::date,
  name text,
  current_ticket_number int not null default 0,
  is_active boolean not null default true,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint queue_sessions_tenant_match_chk check (tenant_id = facility_id)
);

create index queue_sessions_facility_date_idx
  on public.queue_sessions (facility_id, session_date);
create index queue_sessions_active_idx
  on public.queue_sessions (facility_id)
  where is_active = true;

create trigger queue_sessions_set_updated_at
  before update on public.queue_sessions
  for each row execute function public.set_updated_at();

-- App settings (platform + tenant scoped)
create table public.app_settings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.facilities (id) on delete cascade,
  scope text not null default 'platform' check (scope in ('platform', 'tenant', 'user')),
  key text not null,
  value jsonb not null default '{}'::jsonb,
  description text,
  is_public boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique nulls not distinct (tenant_id, scope, key)
);

create index app_settings_tenant_key_idx on public.app_settings (tenant_id, key);

create trigger app_settings_set_updated_at
  before update on public.app_settings
  for each row execute function public.set_updated_at();

commit;
