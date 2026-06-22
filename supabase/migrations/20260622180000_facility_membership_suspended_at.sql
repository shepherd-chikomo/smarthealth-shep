-- Add suspended_at to facility_memberships so members can be temporarily
-- suspended without losing their membership record.

alter table public.facility_memberships
  add column if not exists suspended_at timestamptz;

comment on column public.facility_memberships.suspended_at is
  'Non-null when the member has been suspended; null means active.';
