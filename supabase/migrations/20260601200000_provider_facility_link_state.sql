-- ---------------------------------------------------------------------------
-- Per-facility provider state
--
-- A provider can work at multiple facilities (provider_facility_links is
-- many-to-many). Operational flags previously lived only on the shared
-- providers row, so toggling "accepting bookings" / "active" at one facility
-- affected every facility. Store these per-facility on the link so each
-- facility manages the provider independently. The providers-level columns
-- remain the global/default fallback (and the registry home facility).
-- ---------------------------------------------------------------------------

alter table public.provider_facility_links
  add column if not exists is_active boolean not null default true;

alter table public.provider_facility_links
  add column if not exists is_accepting_bookings boolean not null default true;
