-- SmartHealth: provider reviews for patient ratings

begin;

create table public.provider_reviews (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers (id) on delete cascade,
  patient_id uuid not null references public.profiles (id) on delete cascade,
  appointment_id uuid references public.appointments (id) on delete set null,
  rating smallint not null check (rating between 1 and 5),
  title text,
  comment text,
  is_verified_visit boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint provider_reviews_unique_patient unique (provider_id, patient_id)
);

create index provider_reviews_provider_idx
  on public.provider_reviews (provider_id)
  where deleted_at is null;

create index provider_reviews_patient_idx
  on public.provider_reviews (patient_id);

create index provider_reviews_rating_idx
  on public.provider_reviews (provider_id, rating)
  where deleted_at is null;

create trigger provider_reviews_set_updated_at
  before update on public.provider_reviews
  for each row execute function public.set_updated_at();

-- RLS: patients manage own reviews; public read for approved providers
alter table public.provider_reviews enable row level security;

create policy provider_reviews_select_public
  on public.provider_reviews for select
  using (deleted_at is null);

create policy provider_reviews_insert_own
  on public.provider_reviews for insert
  with check (patient_id = auth.uid());

create policy provider_reviews_update_own
  on public.provider_reviews for update
  using (patient_id = auth.uid())
  with check (patient_id = auth.uid());

create policy provider_reviews_delete_own
  on public.provider_reviews for delete
  using (patient_id = auth.uid());

commit;
