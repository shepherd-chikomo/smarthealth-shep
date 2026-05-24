-- SmartHealth: analytics, emergency services, activity logs

begin;

-- Emergency services (enhanced replacement for emergency_facilities)
create table public.emergency_services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  service_type public.emergency_service_type not null default 'hospital_er',
  facility_type public.facility_type,
  phone text not null,
  alternate_phone text,
  address text,
  city text not null,
  province public.zimbabwe_province not null,
  country_code char(2) not null default 'ZW',
  latitude double precision not null,
  longitude double precision not null,
  location extensions.geography(point, 4326),
  is_24_hours boolean not null default true,
  is_active boolean not null default true,
  verification_status public.verification_status not null default 'verified',
  moderation_status public.moderation_status not null default 'approved',
  search_vector tsvector,
  metadata jsonb not null default '{}'::jsonb,
  import_batch_id uuid,
  import_source text,
  imported_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index emergency_services_province_idx on public.emergency_services (province) where deleted_at is null;
create index emergency_services_type_idx on public.emergency_services (service_type);
create index emergency_services_location_gix on public.emergency_services using gist (location);
create index emergency_services_search_idx on public.emergency_services using gin (search_vector);

create trigger emergency_services_sync_location
  before insert or update of latitude, longitude on public.emergency_services
  for each row execute function public.sync_location_from_coords();

create trigger emergency_services_set_updated_at
  before update on public.emergency_services
  for each row execute function public.set_updated_at();

-- Migrate existing emergency_facilities data
insert into public.emergency_services (
  name, service_type, facility_type, phone, address, city, province,
  latitude, longitude, is_24_hours, is_active, metadata, created_at, updated_at
)
select
  ef.name,
  'hospital_er'::public.emergency_service_type,
  ef.facility_type,
  ef.phone,
  ef.address,
  ef.city,
  ef.province,
  ef.latitude,
  ef.longitude,
  ef.is_24_hours,
  ef.is_active,
  ef.metadata,
  ef.created_at,
  ef.updated_at
from public.emergency_facilities ef
where not exists (
  select 1 from public.emergency_services es
  where es.name = ef.name and es.city = ef.city
);

-- Backward-compatible view
create or replace view public.emergency_facilities_v as
select
  id,
  name,
  coalesce(facility_type, 'hospital'::public.facility_type) as facility_type,
  phone,
  address,
  city,
  province,
  latitude,
  longitude,
  is_24_hours,
  is_active,
  metadata,
  created_at,
  updated_at
from public.emergency_services
where deleted_at is null;

-- Activity logs (user-facing analytics)
create table public.activity_logs (
  id bigserial primary key,
  tenant_id uuid references public.facilities (id) on delete set null,
  user_id uuid references public.profiles (id) on delete set null,
  session_id uuid,
  action text not null,
  entity_type text,
  entity_id uuid,
  ip_address inet,
  user_agent text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index activity_logs_tenant_created_idx
  on public.activity_logs (tenant_id, created_at desc);
create index activity_logs_user_idx on public.activity_logs (user_id, created_at desc);
create index activity_logs_entity_idx on public.activity_logs (entity_type, entity_id);

-- Usage metrics (aggregated)
create table public.usage_metrics (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.facilities (id) on delete cascade,
  metric_date date not null,
  metric_key text not null,
  metric_value numeric(18, 4) not null default 0,
  dimensions jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  unique (tenant_id, metric_date, metric_key, dimensions)
);

create index usage_metrics_tenant_date_idx
  on public.usage_metrics (tenant_id, metric_date desc);
create index usage_metrics_key_idx on public.usage_metrics (metric_key);

-- Revenue reports (pre-aggregated billing analytics)
create table public.revenue_reports (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  report_date date not null,
  period_type text not null default 'daily' check (period_type in ('daily', 'weekly', 'monthly')),
  currency_code char(3) not null default 'USD',
  gross_revenue_cents bigint not null default 0,
  net_revenue_cents bigint not null default 0,
  refunds_cents bigint not null default 0,
  outstanding_cents bigint not null default 0,
  appointment_count int not null default 0,
  walk_in_count int not null default 0,
  payment_count int not null default 0,
  breakdown jsonb not null default '{}'::jsonb,
  generated_at timestamptz not null default timezone('utc', now()),
  unique (tenant_id, report_date, period_type, currency_code)
);

create index revenue_reports_tenant_date_idx
  on public.revenue_reports (tenant_id, report_date desc);

commit;
