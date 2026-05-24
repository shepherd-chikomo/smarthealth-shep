-- SmartHealth: medical records (consultations, diagnoses, vitals, allergies, etc.)

begin;

-- Consultations
create table public.consultations (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  provider_id uuid not null references public.providers (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  appointment_id uuid references public.appointments (id) on delete set null,
  walk_in_session_id uuid references public.walk_in_sessions (id) on delete set null,
  status public.consultation_status not null default 'scheduled',
  chief_complaint text,
  history_of_present_illness text,
  examination_notes text,
  assessment text,
  plan text,
  follow_up_date date,
  started_at timestamptz,
  completed_at timestamptz,
  search_vector tsvector,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  deleted_by uuid references public.profiles (id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint consultations_tenant_match_chk check (tenant_id = facility_id)
);

create index consultations_patient_idx on public.consultations (patient_id) where deleted_at is null;
create index consultations_provider_idx on public.consultations (provider_id) where deleted_at is null;
create index consultations_tenant_date_idx on public.consultations (tenant_id, created_at desc);
create index consultations_search_idx on public.consultations using gin (search_vector);

create trigger consultations_set_updated_at
  before update on public.consultations
  for each row execute function public.set_updated_at();

-- Diagnoses
create table public.diagnoses (
  id uuid primary key default gen_random_uuid(),
  consultation_id uuid not null references public.consultations (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  provider_id uuid not null references public.providers (id) on delete restrict,
  icd10_code text,
  description text not null,
  certainty public.diagnosis_certainty not null default 'provisional',
  is_primary boolean not null default false,
  onset_date date,
  resolved_date date,
  notes text,
  search_vector tsvector,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index diagnoses_consultation_idx on public.diagnoses (consultation_id);
create index diagnoses_patient_idx on public.diagnoses (patient_id) where deleted_at is null;
create index diagnoses_icd10_idx on public.diagnoses (icd10_code) where icd10_code is not null;
create index diagnoses_search_idx on public.diagnoses using gin (search_vector);

create trigger diagnoses_set_updated_at
  before update on public.diagnoses
  for each row execute function public.set_updated_at();

-- Extend prescriptions with consultation link + clinical fields
alter table public.prescriptions
  add column if not exists tenant_id uuid references public.facilities (id) on delete restrict,
  add column if not exists consultation_id uuid references public.consultations (id) on delete set null,
  add column if not exists search_vector tsvector,
  add column if not exists deleted_at timestamptz,
  add column if not exists deleted_by uuid references public.profiles (id);

update public.prescriptions set tenant_id = facility_id where tenant_id is null;

alter table public.prescriptions
  alter column tenant_id set not null;

create index if not exists prescriptions_consultation_idx on public.prescriptions (consultation_id);
create index if not exists prescriptions_tenant_idx on public.prescriptions (tenant_id);
create index if not exists prescriptions_search_idx on public.prescriptions using gin (search_vector);

-- Lab results
create table public.lab_results (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  provider_id uuid references public.providers (id) on delete set null,
  consultation_id uuid references public.consultations (id) on delete set null,
  test_name text not null,
  test_code text,
  status public.lab_result_status not null default 'ordered',
  result_value text,
  result_unit text,
  reference_range text,
  is_abnormal boolean not null default false,
  ordered_at timestamptz not null default timezone('utc', now()),
  collected_at timestamptz,
  completed_at timestamptz,
  storage_path text,
  notes text,
  search_vector tsvector,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint lab_results_tenant_match_chk check (tenant_id = facility_id)
);

create index lab_results_patient_idx on public.lab_results (patient_id) where deleted_at is null;
create index lab_results_tenant_status_idx on public.lab_results (tenant_id, status);
create index lab_results_search_idx on public.lab_results using gin (search_vector);

create trigger lab_results_set_updated_at
  before update on public.lab_results
  for each row execute function public.set_updated_at();

-- Vitals
create table public.vitals (
  id uuid primary key default gen_random_uuid(),
  consultation_id uuid references public.consultations (id) on delete set null,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  family_member_id uuid references public.family_members (id) on delete set null,
  recorded_by uuid references public.profiles (id),
  recorded_at timestamptz not null default timezone('utc', now()),
  temperature_celsius numeric(4, 1),
  pulse_bpm smallint check (pulse_bpm is null or pulse_bpm between 20 and 300),
  respiratory_rate smallint check (respiratory_rate is null or respiratory_rate between 5 and 80),
  blood_pressure_systolic smallint check (blood_pressure_systolic is null or blood_pressure_systolic between 50 and 300),
  blood_pressure_diastolic smallint check (blood_pressure_diastolic is null or blood_pressure_diastolic between 30 and 200),
  oxygen_saturation smallint check (oxygen_saturation is null or oxygen_saturation between 50 and 100),
  weight_kg numeric(6, 2),
  height_cm numeric(5, 1),
  bmi numeric(4, 1) generated always as (
    case
      when height_cm > 0 and weight_kg > 0
      then round((weight_kg / ((height_cm / 100) ^ 2))::numeric, 1)
      else null
    end
  ) stored,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create index vitals_patient_recorded_idx
  on public.vitals (patient_id, recorded_at desc)
  where deleted_at is null;
create index vitals_consultation_idx on public.vitals (consultation_id);

-- Allergies (structured patient allergies)
create table public.allergies (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles (id) on delete cascade,
  family_member_id uuid references public.family_members (id) on delete cascade,
  tenant_id uuid references public.facilities (id) on delete set null,
  allergen text not null,
  reaction text,
  severity public.allergy_severity not null default 'moderate',
  diagnosed_at date,
  is_active boolean not null default true,
  verified_by uuid references public.profiles (id),
  notes text,
  search_vector tsvector,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint allergies_subject_chk check (
    family_member_id is not null or patient_id is not null
  )
);

create index allergies_patient_idx on public.allergies (patient_id) where deleted_at is null and is_active = true;
create index allergies_search_idx on public.allergies using gin (search_vector);

create trigger allergies_set_updated_at
  before update on public.allergies
  for each row execute function public.set_updated_at();

-- Chronic conditions
create table public.chronic_conditions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles (id) on delete cascade,
  family_member_id uuid references public.family_members (id) on delete cascade,
  tenant_id uuid references public.facilities (id) on delete set null,
  condition_name text not null,
  icd10_code text,
  status public.chronic_condition_status not null default 'active',
  diagnosed_at date,
  resolved_at date,
  managing_provider_id uuid references public.providers (id) on delete set null,
  notes text,
  search_vector tsvector,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index chronic_conditions_patient_idx
  on public.chronic_conditions (patient_id)
  where deleted_at is null;
create index chronic_conditions_search_idx on public.chronic_conditions using gin (search_vector);

create trigger chronic_conditions_set_updated_at
  before update on public.chronic_conditions
  for each row execute function public.set_updated_at();

commit;
