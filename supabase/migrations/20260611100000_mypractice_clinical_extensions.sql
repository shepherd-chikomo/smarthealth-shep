-- MyPractice: clinical extensions, ICD-11, EDLIZ, insurance claims

begin;

alter table public.consultations
  add column if not exists past_medical_history text,
  add column if not exists surgical_history text,
  add column if not exists family_history text,
  add column if not exists social_history text,
  add column if not exists follow_up_plan text;

alter table public.diagnoses
  add column if not exists icd11_code text;

alter table public.chronic_conditions
  add column if not exists icd11_code text;

create index if not exists diagnoses_icd11_idx
  on public.diagnoses (icd11_code) where icd11_code is not null;

create table if not exists public.icd11_codes (
  code text primary key,
  description text not null,
  search_vector tsvector,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists icd11_codes_search_idx
  on public.icd11_codes using gin (search_vector);

create table if not exists public.edliz_formulary (
  id uuid primary key default gen_random_uuid(),
  icd11_code text not null,
  first_line text not null,
  alternative text,
  recommended_dosage text,
  recommended_formulation text,
  notes text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists edliz_formulary_icd11_idx
  on public.edliz_formulary (icd11_code);

create table if not exists public.medications_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  formulation text,
  default_dosage text,
  search_vector tsvector,
  created_at timestamptz not null default timezone('utc', now())
);

create type public.insurance_claim_status as enum (
  'draft',
  'submitted',
  'received',
  'under_review',
  'approved',
  'partially_paid',
  'paid',
  'closed',
  'query_raised',
  'rejected'
);

create table if not exists public.insurance_claims (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  facility_id uuid not null references public.facilities (id) on delete restrict,
  patient_id uuid not null references public.profiles (id) on delete restrict,
  provider_id uuid references public.providers (id) on delete set null,
  consultation_id uuid references public.consultations (id) on delete set null,
  payer_key text not null,
  status public.insurance_claim_status not null default 'draft',
  amount numeric(12, 2) not null default 0,
  amount_paid numeric(12, 2) not null default 0,
  reference_number text,
  submitted_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint insurance_claims_tenant_match_chk check (tenant_id = facility_id)
);

create table if not exists public.insurance_claim_status_history (
  id uuid primary key default gen_random_uuid(),
  claim_id uuid not null references public.insurance_claims (id) on delete cascade,
  status public.insurance_claim_status not null,
  notes text,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.clinical_tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  facility_id uuid not null references public.facilities (id) on delete restrict,
  assignee_id uuid references public.profiles (id) on delete set null,
  patient_id uuid references public.profiles (id) on delete set null,
  title text not null,
  task_type text not null default 'follow_up',
  status text not null default 'open',
  due_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.internal_messages (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  facility_id uuid not null references public.facilities (id) on delete restrict,
  sender_id uuid not null references public.profiles (id) on delete restrict,
  recipient_id uuid not null references public.profiles (id) on delete restrict,
  body text not null,
  sent_at timestamptz not null default timezone('utc', now()),
  read_at timestamptz
);

create table if not exists public.practitioner_credentials (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  credential_type text not null,
  title text not null,
  issued_at date,
  expires_at date,
  storage_path text,
  created_at timestamptz not null default timezone('utc', now())
);

-- Seed sample ICD-11 and EDLIZ reference data
insert into public.icd11_codes (code, description) values
  ('1A00', 'Cholera'),
  ('1F40', 'Malaria'),
  ('5A10', 'Type 1 diabetes mellitus'),
  ('5A11', 'Type 2 diabetes mellitus'),
  ('BA00', 'Essential hypertension'),
  ('CA40', 'Acute upper respiratory infection'),
  ('MD11', 'Low back pain'),
  ('6A70', 'Single episode depressive disorder')
on conflict (code) do nothing;

insert into public.edliz_formulary (icd11_code, first_line, alternative, recommended_dosage, recommended_formulation) values
  ('BA00', 'Amlodipine 5mg', 'Enalapril 5mg', '5mg once daily', 'Tablet'),
  ('5A11', 'Metformin 500mg', 'Gliclazide 80mg', '500mg twice daily', 'Tablet'),
  ('CA40', 'Paracetamol 500mg', 'Ibuprofen 400mg', '500mg every 6 hours', 'Tablet'),
  ('1F40', 'Artemether-Lumefantrine', 'Quinine', 'Per weight-based protocol', 'Tablet')
on conflict do nothing;

insert into public.medications_catalog (name, formulation, default_dosage) values
  ('Paracetamol', 'Tablet', '500mg'),
  ('Amoxicillin', 'Capsule', '500mg'),
  ('Metformin', 'Tablet', '500mg'),
  ('Amlodipine', 'Tablet', '5mg'),
  ('Artemether-Lumefantrine', 'Tablet', '20/120mg')
on conflict do nothing;

commit;
