-- SmartHealth: healthcare domain entities

begin;

-- ---------------------------------------------------------------------------
-- Healthcare providers (doctors, clinics linked to facilities)
-- ---------------------------------------------------------------------------

create table public.providers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  profile_id uuid references public.profiles (id) on delete set null,
  category_id text references public.provider_categories (id),
  specialty_id uuid references public.specialties (id),
  name text not null,
  specialty text,
  mdpcz_number text,
  phone text,
  email text,
  about text,
  image_path text,
  hero_image_path text,
  is_verified boolean not null default false,
  is_accepting_bookings boolean not null default true,
  services text[] not null default '{}',
  conditions text[] not null default '{}',
  age_groups text[] not null default '{}',
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint providers_mdpcz_format_chk check (
    mdpcz_number is null or mdpcz_number ~ '^[A-Z0-9-]+$'
  )
);

create index providers_facility_idx on public.providers (facility_id);
create index providers_specialty_idx on public.providers (specialty_id);
create index providers_verified_idx on public.providers (is_verified) where is_verified = true;
create index providers_name_trgm_idx on public.providers using gin (name gin_trgm_ops);

create trigger providers_set_updated_at
  before update on public.providers
  for each row execute function public.set_updated_at();

create table public.provider_working_hours (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  day_of_week smallint not null check (day_of_week between 0 and 6),
  opens_at time,
  closes_at time,
  is_closed boolean not null default false,
  unique (provider_id, day_of_week)
);

-- ---------------------------------------------------------------------------
-- Family members (patient dependents)
-- ---------------------------------------------------------------------------

create table public.family_members (
  id uuid primary key default gen_random_uuid(),
  account_holder_id uuid not null references public.profiles (id) on delete cascade,
  first_name text not null,
  last_name text,
  relationship public.family_relationship not null default 'other',
  date_of_birth date,
  gender public.gender,
  medical_conditions text[] not null default '{}',
  allergies text,
  is_primary_account_holder boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index family_members_account_holder_idx
  on public.family_members (account_holder_id);

create trigger family_members_set_updated_at
  before update on public.family_members
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Appointments / bookings
-- ---------------------------------------------------------------------------

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  reference_number text not null unique,
  facility_id uuid not null references public.facilities (id) on delete restrict,
  provider_id uuid not null references public.providers (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  scheduled_at timestamptz not null,
  duration_minutes int not null default 30 check (duration_minutes > 0),
  status public.appointment_status not null default 'pending',
  notes text,
  cancellation_reason text,
  booked_by uuid references public.profiles (id),
  checked_in_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index appointments_facility_scheduled_idx
  on public.appointments (facility_id, scheduled_at);
create index appointments_provider_scheduled_idx
  on public.appointments (provider_id, scheduled_at);
create index appointments_patient_idx on public.appointments (patient_id);
create index appointments_status_idx on public.appointments (status);

create trigger appointments_set_updated_at
  before update on public.appointments
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Medical documents
-- ---------------------------------------------------------------------------

create table public.medical_documents (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  provider_id uuid references public.providers (id) on delete set null,
  uploaded_by uuid references public.profiles (id),
  document_type public.document_type not null default 'other',
  title text not null,
  description text,
  storage_path text not null,
  mime_type text,
  file_size_bytes bigint,
  is_confidential boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index medical_documents_patient_idx on public.medical_documents (patient_id);
create index medical_documents_facility_idx on public.medical_documents (facility_id);

create trigger medical_documents_set_updated_at
  before update on public.medical_documents
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Prescriptions
-- ---------------------------------------------------------------------------

create table public.prescriptions (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  provider_id uuid not null references public.providers (id) on delete restrict,
  appointment_id uuid references public.appointments (id) on delete set null,
  status public.prescription_status not null default 'draft',
  diagnosis text,
  medications jsonb not null default '[]'::jsonb,
  instructions text,
  storage_path text,
  issued_at timestamptz,
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index prescriptions_patient_idx on public.prescriptions (patient_id);
create index prescriptions_provider_idx on public.prescriptions (provider_id);
create index prescriptions_status_idx on public.prescriptions (status);

create trigger prescriptions_set_updated_at
  before update on public.prescriptions
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Emergency facilities (public directory)
-- ---------------------------------------------------------------------------

create table public.emergency_facilities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  facility_type public.facility_type not null default 'hospital',
  phone text not null,
  address text,
  city text not null,
  province public.zimbabwe_province not null,
  latitude double precision not null,
  longitude double precision not null,
  is_24_hours boolean not null default true,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index emergency_facilities_province_idx on public.emergency_facilities (province);
create index emergency_facilities_location_idx
  on public.emergency_facilities (latitude, longitude);

create trigger emergency_facilities_set_updated_at
  before update on public.emergency_facilities
  for each row execute function public.set_updated_at();

-- Reference number generator for appointments
create or replace function public.generate_appointment_reference()
returns text
language plpgsql
as $$
declare
  ref text;
begin
  ref := 'SH-' || to_char(timezone('utc', now()), 'YYYYMMDD') || '-'
    || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
  return ref;
end;
$$;

commit;
