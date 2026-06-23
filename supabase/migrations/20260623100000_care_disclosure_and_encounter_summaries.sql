-- Care disclosure consent types, facility-scoped active consent, encounter summaries

begin;

-- Extend consent types for provider data sharing
alter table public.patient_consents
  drop constraint if exists patient_consents_consent_type_check;

alter table public.patient_consents
  add constraint patient_consents_consent_type_check
  check (consent_type in (
    'data_processing', 'telehealth', 'marketing', 'research',
    'third_party_sharing', 'emergency_contact',
    'facility_phi_share', 'encounter_summary_receive', 'facility_ongoing_care'
  ));

drop index if exists public.patient_consents_active_unique;

create unique index patient_consents_active_facility_unique
  on public.patient_consents (patient_id, consent_type, ((metadata->>'facilityId')))
  where withdrawn_at is null and metadata->>'facilityId' is not null;

create unique index patient_consents_active_global_unique
  on public.patient_consents (patient_id, consent_type)
  where withdrawn_at is null and (metadata->>'facilityId' is null);

-- Patient-facing encounter summaries (Tier 3 return disclosure)
create table if not exists public.encounter_summaries (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  patient_id uuid not null references public.profiles (id) on delete cascade,
  appointment_id uuid references public.appointments (id) on delete set null,
  consultation_id uuid not null references public.consultations (id) on delete cascade,
  provider_id uuid references public.providers (id) on delete set null,
  chief_complaint text,
  assessment text,
  plan text,
  prescriptions_summary text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint encounter_summaries_tenant_match_chk check (tenant_id is not null)
);

create index encounter_summaries_patient_idx
  on public.encounter_summaries (patient_id, created_at desc);

create index encounter_summaries_appointment_idx
  on public.encounter_summaries (appointment_id)
  where appointment_id is not null;

create trigger encounter_summaries_set_updated_at
  before update on public.encounter_summaries
  for each row execute function public.set_updated_at();

alter table public.encounter_summaries enable row level security;

create policy encounter_summaries_patient_read on public.encounter_summaries
  for select to authenticated
  using (patient_id = auth.uid() or public.is_super_admin());

create policy encounter_summaries_staff_read on public.encounter_summaries
  for select to authenticated
  using (
    public.is_super_admin()
    or public.has_facility_role(tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[])
  );

commit;
