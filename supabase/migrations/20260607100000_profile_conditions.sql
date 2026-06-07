-- SmartHealth: medical profile conditions catalog and user submissions

begin;

create type public.condition_submission_status as enum (
  'pending',
  'approved',
  'rejected'
);

create table public.profile_conditions (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  label text not null,
  is_common boolean not null default true,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint profile_conditions_slug_unique unique (slug)
);

create index profile_conditions_common_idx
  on public.profile_conditions (is_common, sort_order)
  where deleted_at is null and is_active = true;

create index profile_conditions_label_trgm_idx
  on public.profile_conditions using gin (label gin_trgm_ops);

create trigger profile_conditions_set_updated_at
  before update on public.profile_conditions
  for each row execute function public.set_updated_at();

create table public.condition_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  family_member_id uuid references public.family_members (id) on delete set null,
  proposed_label text not null,
  proposed_slug text not null,
  status public.condition_submission_status not null default 'pending',
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  resulting_condition_id uuid references public.profile_conditions (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index condition_submissions_status_idx
  on public.condition_submissions (status, created_at desc);

create index condition_submissions_user_slug_idx
  on public.condition_submissions (user_id, proposed_slug)
  where status = 'pending';

create trigger condition_submissions_set_updated_at
  before update on public.condition_submissions
  for each row execute function public.set_updated_at();

-- Seed canonical profile conditions (matches mobile SearchFilterOptions.conditions)
insert into public.profile_conditions (slug, label, is_common, sort_order) values
  ('diabetes_type_2', 'Diabetes Type 2', true, 1),
  ('diabetes', 'Diabetes', true, 2),
  ('hypertension', 'Hypertension', true, 3),
  ('malaria', 'Malaria', true, 4),
  ('hiv_aids', 'HIV/AIDS', true, 5),
  ('pregnancy', 'Pregnancy', true, 6),
  ('asthma', 'Asthma', true, 7),
  ('mental_health', 'Mental Health', true, 8)
on conflict (slug) do nothing;

commit;
