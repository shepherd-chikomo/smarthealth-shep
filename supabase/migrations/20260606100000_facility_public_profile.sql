-- Facility public profile: whatsapp, service-provider links, appointment metadata, medical aid catalog

begin;

alter table public.facilities
  add column if not exists whatsapp_phone text;

alter table public.facilities
  drop constraint if exists facilities_whatsapp_phone_zw_chk;

alter table public.facilities
  add constraint facilities_whatsapp_phone_zw_chk check (
    whatsapp_phone is null or public.normalize_zimbabwe_phone(whatsapp_phone) ~ '^\+263[0-9]{9}$'
  );

create table if not exists public.facility_service_providers (
  facility_id uuid not null references public.facilities (id) on delete cascade,
  service_id text not null,
  provider_id uuid not null references public.providers (id) on delete cascade,
  display_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (facility_id, service_id, provider_id)
);

create index if not exists facility_service_providers_facility_idx
  on public.facility_service_providers (facility_id);

create index if not exists facility_service_providers_provider_idx
  on public.facility_service_providers (provider_id);

create trigger facility_service_providers_set_updated_at
  before update on public.facility_service_providers
  for each row execute function public.set_updated_at();

alter table public.appointments
  add column if not exists metadata jsonb not null default '{}'::jsonb;

insert into public.app_settings (tenant_id, scope, key, value, description, is_public)
values (
  null,
  'platform',
  'medical_aid_catalog',
  '[
    {"schemeKey":"cimas","name":"Cimas"},
    {"schemeKey":"psmas","name":"PSMAS"},
    {"schemeKey":"first_mutual","name":"First Mutual"},
    {"schemeKey":"cellmed","name":"CellMed"},
    {"schemeKey":"alliance_health","name":"Alliance Health"}
  ]'::jsonb,
  'Platform medical aid scheme catalog',
  true
)
on conflict (scope, key) do update set
  value = excluded.value,
  description = excluded.description,
  is_public = excluded.is_public,
  updated_at = now();

commit;
