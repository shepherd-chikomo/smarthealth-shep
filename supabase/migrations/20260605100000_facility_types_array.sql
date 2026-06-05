-- Multi-category classification for facilities (patient app home tiles / nearby filters).
alter table public.facilities
  add column if not exists facility_types public.facility_type[] not null default '{}';

-- Seed from existing primary type where unset.
update public.facilities
set facility_types = array[facility_type]::public.facility_type[]
where cardinality(facility_types) = 0;

create index if not exists facilities_facility_types_gin_idx
  on public.facilities using gin (facility_types);
