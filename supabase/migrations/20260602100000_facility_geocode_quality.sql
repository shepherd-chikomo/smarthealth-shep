-- Facility geocoding quality metadata (Nominatim accuracy / distance display)

alter table public.facilities
  add column if not exists geocode_quality text,
  add column if not exists geocoded_at timestamptz;

alter table public.facilities
  drop constraint if exists facilities_geocode_quality_check;

alter table public.facilities
  add constraint facilities_geocode_quality_check
  check (
    geocode_quality is null
    or geocode_quality in (
      'address',
      'name',
      'city_only',
      'city_centre',
      'manual'
    )
  );

create index if not exists facilities_geocode_quality_idx
  on public.facilities (geocode_quality)
  where geocode_quality is not null;
