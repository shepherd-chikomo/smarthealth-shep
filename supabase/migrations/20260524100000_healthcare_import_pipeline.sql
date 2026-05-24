-- SmartHealth: healthcare data import pipeline
-- Tables for batch tracking, failed rows, provider-facility links, geocoding cache

begin;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.import_source_type as enum ('MDPCZ', 'HPA', 'MANUAL', 'MIXED');
create type public.import_batch_status as enum (
  'pending',
  'running',
  'completed',
  'failed',
  'rolled_back'
);
create type public.verified_source as enum ('MDPCZ', 'HPA', 'MANUAL');
create type public.verified_status as enum ('pending', 'verified', 'rejected');
create type public.dedup_confidence as enum ('HIGH', 'MEDIUM', 'LOW');
create type public.provider_facility_link_type as enum (
  'primary',
  'affiliated',
  'visiting'
);

-- ---------------------------------------------------------------------------
-- Import batch logs
-- ---------------------------------------------------------------------------

create table public.import_logs (
  id uuid primary key default gen_random_uuid(),
  source_file text not null,
  source_type public.import_source_type not null default 'MIXED',
  status public.import_batch_status not null default 'pending',
  dry_run boolean not null default false,
  options jsonb not null default '{}'::jsonb,
  total_rows int not null default 0,
  imported_count int not null default 0,
  failed_count int not null default 0,
  duplicates_merged int not null default 0,
  facilities_created int not null default 0,
  providers_created int not null default 0,
  links_created int not null default 0,
  specialties_unmatched int not null default 0,
  cities_missing int not null default 0,
  geocoded_count int not null default 0,
  report_json jsonb,
  report_csv_path text,
  report_json_path text,
  error_message text,
  started_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz,
  started_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index import_logs_status_idx on public.import_logs (status);
create index import_logs_started_at_idx on public.import_logs (started_at desc);

create trigger import_logs_set_updated_at
  before update on public.import_logs
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Failed import rows
-- ---------------------------------------------------------------------------

create table public.failed_imports (
  id uuid primary key default gen_random_uuid(),
  import_batch_id uuid not null references public.import_logs (id) on delete cascade,
  row_number int not null,
  entity_type text not null default 'provider',
  raw_data jsonb not null default '{}'::jsonb,
  normalized_data jsonb,
  error_code text not null,
  error_message text not null,
  is_resolved boolean not null default false,
  resolved_at timestamptz,
  resolved_by uuid references public.profiles (id) on delete set null,
  resolution_notes text,
  created_at timestamptz not null default timezone('utc', now())
);

create index failed_imports_batch_idx on public.failed_imports (import_batch_id);
create index failed_imports_unresolved_idx
  on public.failed_imports (import_batch_id)
  where is_resolved = false;

-- ---------------------------------------------------------------------------
-- Provider specialties (many-to-many)
-- ---------------------------------------------------------------------------

create table public.provider_specialties (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  specialty_id uuid not null references public.specialties (id) on delete cascade,
  is_primary boolean not null default false,
  source text,
  import_batch_id uuid references public.import_logs (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (provider_id, specialty_id)
);

create index provider_specialties_provider_idx on public.provider_specialties (provider_id);
create index provider_specialties_specialty_idx on public.provider_specialties (specialty_id);

-- ---------------------------------------------------------------------------
-- Facility branches
-- ---------------------------------------------------------------------------

create table public.facility_branches (
  id uuid primary key default gen_random_uuid(),
  parent_facility_id uuid not null references public.facilities (id) on delete cascade,
  branch_facility_id uuid not null references public.facilities (id) on delete cascade,
  branch_name text,
  is_primary boolean not null default false,
  import_batch_id uuid references public.import_logs (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (parent_facility_id, branch_facility_id),
  constraint facility_branches_not_self_chk check (parent_facility_id <> branch_facility_id)
);

create index facility_branches_parent_idx on public.facility_branches (parent_facility_id);
create index facility_branches_branch_idx on public.facility_branches (branch_facility_id);

-- ---------------------------------------------------------------------------
-- Provider ↔ facility links (multi-site practitioners)
-- ---------------------------------------------------------------------------

create table public.provider_facility_links (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  facility_id uuid not null references public.facilities (id) on delete cascade,
  link_type public.provider_facility_link_type not null default 'affiliated',
  is_primary boolean not null default false,
  match_confidence public.dedup_confidence not null default 'MEDIUM',
  import_batch_id uuid references public.import_logs (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  unique (provider_id, facility_id)
);

create index provider_facility_links_provider_idx on public.provider_facility_links (provider_id);
create index provider_facility_links_facility_idx on public.provider_facility_links (facility_id);

-- ---------------------------------------------------------------------------
-- Geocoding cache
-- ---------------------------------------------------------------------------

create table public.geocode_cache (
  query_hash text primary key,
  query_text text not null,
  latitude double precision,
  longitude double precision,
  formatted_address text,
  provider text not null default 'nominatim',
  country_code char(2) not null default 'ZW',
  created_at timestamptz not null default timezone('utc', now()),
  last_used_at timestamptz not null default timezone('utc', now())
);

create index geocode_cache_query_trgm_idx
  on public.geocode_cache using gin (query_text gin_trgm_ops);

-- ---------------------------------------------------------------------------
-- Specialty alias mappings (import normalization)
-- ---------------------------------------------------------------------------

create table public.specialty_aliases (
  id uuid primary key default gen_random_uuid(),
  alias text not null,
  alias_normalized text not null,
  specialty_id uuid not null references public.specialties (id) on delete cascade,
  source text,
  created_at timestamptz not null default timezone('utc', now()),
  unique (alias_normalized)
);

create index specialty_aliases_trgm_idx
  on public.specialty_aliases using gin (alias_normalized gin_trgm_ops);

-- ---------------------------------------------------------------------------
-- Extend providers for import / search / verification
-- ---------------------------------------------------------------------------

alter table public.providers
  add column if not exists slug text,
  add column if not exists title text,
  add column if not exists first_name text,
  add column if not exists middle_name text,
  add column if not exists last_name text,
  add column if not exists profession text,
  add column if not exists license_status text,
  add column if not exists practice_type text,
  add column if not exists registration_number text,
  add column if not exists verified_source public.verified_source,
  add column if not exists verified_status public.verified_status not null default 'pending',
  add column if not exists license_verified_at timestamptz,
  add column if not exists search_keywords text[] not null default '{}',
  add column if not exists import_row_hash text,
  add column if not exists formatted_address text;

create unique index if not exists providers_slug_unique_idx
  on public.providers (slug)
  where slug is not null and deleted_at is null;

create unique index if not exists providers_import_row_hash_idx
  on public.providers (import_row_hash)
  where import_row_hash is not null;

create index if not exists providers_registration_number_idx
  on public.providers (registration_number)
  where registration_number is not null;

create index if not exists providers_verified_status_idx
  on public.providers (verified_status);

create index if not exists providers_search_keywords_gin_idx
  on public.providers using gin (search_keywords);

-- Extend facilities for import search keywords
alter table public.facilities
  add column if not exists search_keywords text[] not null default '{}',
  add column if not exists facility_category text,
  add column if not exists ownership_type text,
  add column if not exists import_row_hash text,
  add column if not exists formatted_address text;

create unique index if not exists facilities_import_row_hash_idx
  on public.facilities (import_row_hash)
  where import_row_hash is not null;

create index if not exists facilities_search_keywords_gin_idx
  on public.facilities using gin (search_keywords);

-- ---------------------------------------------------------------------------
-- Import dedup review queue (MEDIUM/LOW confidence merges)
-- ---------------------------------------------------------------------------

create table public.import_duplicate_reviews (
  id uuid primary key default gen_random_uuid(),
  import_batch_id uuid references public.import_logs (id) on delete set null,
  entity_type text not null,
  source_entity_id uuid not null,
  target_entity_id uuid not null,
  confidence public.dedup_confidence not null,
  match_reason text not null,
  match_score numeric(5, 4),
  status text not null default 'pending',
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create index import_duplicate_reviews_pending_idx
  on public.import_duplicate_reviews (status)
  where status = 'pending';

-- ---------------------------------------------------------------------------
-- Unmatched specialties from imports
-- ---------------------------------------------------------------------------

create table public.import_unmatched_specialties (
  id uuid primary key default gen_random_uuid(),
  import_batch_id uuid references public.import_logs (id) on delete cascade,
  raw_specialty text not null,
  occurrence_count int not null default 1,
  mapped_specialty_id uuid references public.specialties (id) on delete set null,
  is_resolved boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  unique (import_batch_id, raw_specialty)
);

-- ---------------------------------------------------------------------------
-- Search indexes (trigram + FTS supplements)
-- ---------------------------------------------------------------------------

create index if not exists providers_first_name_trgm_idx
  on public.providers using gin (first_name gin_trgm_ops)
  where first_name is not null;

create index if not exists providers_last_name_trgm_idx
  on public.providers using gin (last_name gin_trgm_ops)
  where last_name is not null;

create index if not exists facilities_name_trgm_idx
  on public.facilities using gin (name gin_trgm_ops);

create index if not exists facilities_address_trgm_idx
  on public.facilities using gin (address_line1 gin_trgm_ops)
  where address_line1 is not null;

-- ---------------------------------------------------------------------------
-- Seed specialty aliases (MDPCZ / HPA common variants)
-- ---------------------------------------------------------------------------

insert into public.specialty_aliases (alias, alias_normalized, specialty_id, source)
select v.alias, lower(trim(v.alias)), s.id, 'seed'
from (values
  ('GP', 'general-practice'),
  ('General Doctor', 'general-practice'),
  ('General Practitioner', 'general-practice'),
  ('Family Medicine', 'general-practice'),
  ('Paeds', 'paediatrics'),
  ('Pediatrics', 'paediatrics'),
  ('Paediatrician', 'paediatrics'),
  ('Obs & Gyn', 'obgyn'),
  ('Obs and Gyn', 'obgyn'),
  ('Obstetrics & Gynecology', 'obgyn'),
  ('Obstetrics & Gynaecology', 'obgyn'),
  ('O&G', 'obgyn'),
  ('OG', 'obgyn'),
  ('Internal Med', 'internal-medicine'),
  ('Physician', 'internal-medicine'),
  ('Psych', 'psychiatry'),
  ('Psychiatric', 'psychiatry'),
  ('Ortho', 'orthopaedics'),
  ('Orthopedic', 'orthopaedics'),
  ('Derm', 'dermatology'),
  ('Cardio', 'cardiology'),
  ('ENT', 'general-surgery'),
  ('Dental', 'dentistry'),
  ('Dentist', 'dentistry'),
  ('Optom', 'optometry'),
  ('Radiology', 'radiology'),
  ('Rad', 'radiology')
) as v(alias, slug)
join public.specialties s on s.slug = v.slug
on conflict (alias_normalized) do nothing;

commit;
