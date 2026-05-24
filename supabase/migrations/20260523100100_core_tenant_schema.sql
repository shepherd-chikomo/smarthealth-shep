-- SmartHealth: multi-tenant core schema (facilities, profiles, memberships)

begin;

-- ---------------------------------------------------------------------------
-- Facilities (tenants)
-- ---------------------------------------------------------------------------

create table public.facilities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  facility_type public.facility_type not null default 'clinic',
  description text,
  address_line1 text,
  address_line2 text,
  city text not null,
  province public.zimbabwe_province not null,
  postal_code text,
  country_code char(2) not null default 'ZW',
  phone text,
  email text,
  website text,
  latitude double precision,
  longitude double precision,
  logo_path text,
  is_verified boolean not null default false,
  is_active boolean not null default true,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint facilities_phone_zw_chk check (
    phone is null or public.normalize_zimbabwe_phone(phone) ~ '^\+263[0-9]{9}$'
  )
);

create index facilities_province_idx on public.facilities (province);
create index facilities_city_idx on public.facilities (city);
create index facilities_active_idx on public.facilities (is_active) where is_active = true;
create index facilities_location_idx on public.facilities (latitude, longitude)
  where latitude is not null and longitude is not null;

create trigger facilities_set_updated_at
  before update on public.facilities
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Profiles (extends auth.users)
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  primary_role public.app_role not null default 'patient',
  first_name text,
  last_name text,
  display_name text generated always as (
    nullif(trim(both ' ' from coalesce(first_name, '') || ' ' || coalesce(last_name, '')), '')
  ) stored,
  phone text,
  email text,
  national_id text,
  date_of_birth date,
  gender public.gender,
  avatar_path text,
  preferred_language text not null default 'en',
  timezone text not null default 'Africa/Harare',
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint profiles_phone_zw_chk check (
    phone is null or public.normalize_zimbabwe_phone(phone) ~ '^\+263[0-9]{9}$'
  )
);

create index profiles_role_idx on public.profiles (primary_role);
create index profiles_phone_idx on public.profiles (phone);
create unique index profiles_national_id_unique_idx
  on public.profiles (national_id)
  where national_id is not null;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Facility memberships (staff roles per tenant)
-- ---------------------------------------------------------------------------

create table public.facility_memberships (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role public.app_role not null,
  is_primary boolean not null default false,
  invited_by uuid references public.profiles (id),
  joined_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint facility_memberships_role_chk check (
    role in ('facility_admin', 'doctor', 'receptionist')
  ),
  constraint facility_memberships_unique_user_facility unique (facility_id, user_id)
);

create index facility_memberships_user_idx on public.facility_memberships (user_id);
create index facility_memberships_facility_role_idx
  on public.facility_memberships (facility_id, role);

create trigger facility_memberships_set_updated_at
  before update on public.facility_memberships
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Refresh token registry (server-side revocation / audit)
-- ---------------------------------------------------------------------------

create table private.refresh_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token_hash text not null unique,
  session_id uuid,
  user_agent text,
  ip_address inet,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create index refresh_tokens_user_idx on private.refresh_tokens (user_id);
create index refresh_tokens_expires_idx on private.refresh_tokens (expires_at);

-- ---------------------------------------------------------------------------
-- Specialties & categories
-- ---------------------------------------------------------------------------

create table public.specialties (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  category text,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now())
);

create table public.provider_categories (
  id text primary key,
  name text not null,
  icon_key text,
  sort_order int not null default 0,
  is_active boolean not null default true
);

commit;
