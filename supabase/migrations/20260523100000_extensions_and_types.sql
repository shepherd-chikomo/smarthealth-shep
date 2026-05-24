-- SmartHealth: extensions, enums, and shared types
-- Multi-tenant healthcare schema — Zimbabwe focus

begin;

create extension if not exists "pgcrypto" with schema extensions;
create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists "pg_trgm" with schema extensions;

create schema if not exists audit;
create schema if not exists private;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.app_role as enum (
  'super_admin',
  'facility_admin',
  'doctor',
  'receptionist',
  'patient'
);

create type public.facility_type as enum (
  'hospital',
  'clinic',
  'pharmacy',
  'laboratory',
  'dental',
  'optometry',
  'imaging',
  'other'
);

create type public.appointment_status as enum (
  'pending',
  'confirmed',
  'checked_in',
  'in_progress',
  'completed',
  'cancelled',
  'no_show'
);

create type public.document_type as enum (
  'lab_result',
  'imaging',
  'referral',
  'discharge_summary',
  'consent_form',
  'insurance',
  'other'
);

create type public.prescription_status as enum (
  'draft',
  'issued',
  'dispensed',
  'cancelled',
  'expired'
);

create type public.gender as enum (
  'male',
  'female',
  'other',
  'prefer_not_to_say'
);

create type public.family_relationship as enum (
  'self',
  'spouse',
  'child',
  'parent',
  'sibling',
  'other'
);

create type public.audit_action as enum (
  'insert',
  'update',
  'delete'
);

-- Zimbabwe provinces (10 provinces + metropolitan)
create type public.zimbabwe_province as enum (
  'Bulawayo',
  'Harare',
  'Manicaland',
  'Mashonaland Central',
  'Mashonaland East',
  'Mashonaland West',
  'Masvingo',
  'Matabeleland North',
  'Matabeleland South',
  'Midlands'
);

-- ---------------------------------------------------------------------------
-- Utility functions
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.normalize_zimbabwe_phone(phone text)
returns text
language plpgsql
immutable
as $$
declare
  digits text;
begin
  if phone is null or btrim(phone) = '' then
    return null;
  end if;

  digits := regexp_replace(phone, '[^0-9+]', '', 'g');

  if digits ~ '^\+263' then
    return digits;
  end if;

  if digits ~ '^263' then
    return '+' || digits;
  end if;

  if digits ~ '^0' then
    return '+263' || substring(digits from 2);
  end if;

  if length(digits) = 9 then
    return '+263' || digits;
  end if;

  return digits;
end;
$$;

commit;
