import type pg from 'pg';

/** Idempotent DDL — mirrors supabase/migrations/20260602100000_facility_geocode_quality.sql */
export const GEOCODE_QUALITY_DDL = `
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
`;

type Queryable = Pick<pg.Pool, 'query'>;

/** Ensure geocode_quality columns exist (no migration file required). */
export async function ensureGeocodeQualityColumns(db: Queryable): Promise<void> {
  await db.query(GEOCODE_QUALITY_DDL);
}
