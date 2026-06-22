-- Allow a facility membership to carry additional roles beyond the primary one.
-- The primary `role` column continues to drive RLS/permissions.
-- `additional_roles` stores supplementary roles (e.g. a doctor who is also admin).
alter table public.facility_memberships
  add column if not exists additional_roles text[] not null default '{}';

comment on column public.facility_memberships.additional_roles
  is 'Secondary roles held by this member at this facility (permissions governed by primary `role`).';
