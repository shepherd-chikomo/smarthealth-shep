-- SmartHealth: Row Level Security policies

begin;

-- Enable RLS on all public tables
alter table public.facilities enable row level security;
alter table public.profiles enable row level security;
alter table public.facility_memberships enable row level security;
alter table public.specialties enable row level security;
alter table public.provider_categories enable row level security;
alter table public.providers enable row level security;
alter table public.provider_working_hours enable row level security;
alter table public.family_members enable row level security;
alter table public.appointments enable row level security;
alter table public.medical_documents enable row level security;
alter table public.prescriptions enable row level security;
alter table public.emergency_facilities enable row level security;

-- ---------------------------------------------------------------------------
-- Facilities
-- ---------------------------------------------------------------------------

create policy "Public can view active facilities"
  on public.facilities for select
  to anon, authenticated
  using (is_active = true);

create policy "Super admins manage all facilities"
  on public.facilities for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

create policy "Facility admins manage own facility"
  on public.facilities for update
  to authenticated
  using (public.has_facility_role(id, array['facility_admin']::public.app_role[]))
  with check (public.has_facility_role(id, array['facility_admin']::public.app_role[]));

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------

create policy "Users can view own profile"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_super_admin());

create policy "Staff can view facility patient profiles"
  on public.profiles for select
  to authenticated
  using (
    exists (
      select 1
      from public.appointments a
      join public.facility_memberships fm on fm.facility_id = a.facility_id
      where a.patient_id = profiles.id
        and fm.user_id = auth.uid()
    )
  );

create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy "Super admins manage profiles"
  on public.profiles for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Facility memberships
-- ---------------------------------------------------------------------------

create policy "Members can view own memberships"
  on public.facility_memberships for select
  to authenticated
  using (
    user_id = auth.uid()
    or public.has_facility_role(facility_id, array['facility_admin']::public.app_role[])
    or public.is_super_admin()
  );

create policy "Facility admins manage memberships"
  on public.facility_memberships for all
  to authenticated
  using (public.has_facility_role(facility_id, array['facility_admin']::public.app_role[]))
  with check (public.has_facility_role(facility_id, array['facility_admin']::public.app_role[]));

create policy "Super admins manage all memberships"
  on public.facility_memberships for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Reference data (public read)
-- ---------------------------------------------------------------------------

create policy "Anyone can read specialties"
  on public.specialties for select
  to anon, authenticated
  using (is_active = true);

create policy "Super admins manage specialties"
  on public.specialties for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

create policy "Anyone can read provider categories"
  on public.provider_categories for select
  to anon, authenticated
  using (is_active = true);

create policy "Super admins manage provider categories"
  on public.provider_categories for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Providers
-- ---------------------------------------------------------------------------

create policy "Public can view active providers"
  on public.providers for select
  to anon, authenticated
  using (is_active = true);

create policy "Facility staff manage providers"
  on public.providers for all
  to authenticated
  using (public.has_facility_role(facility_id, array['facility_admin', 'doctor']::public.app_role[]))
  with check (public.has_facility_role(facility_id, array['facility_admin', 'doctor']::public.app_role[]));

create policy "Super admins manage providers"
  on public.providers for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Provider working hours
-- ---------------------------------------------------------------------------

create policy "Public can view working hours"
  on public.provider_working_hours for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.providers p
      where p.id = provider_working_hours.provider_id and p.is_active = true
    )
  );

create policy "Facility staff manage working hours"
  on public.provider_working_hours for all
  to authenticated
  using (
    exists (
      select 1 from public.providers p
      where p.id = provider_working_hours.provider_id
        and public.has_facility_role(p.facility_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[])
    )
  )
  with check (
    exists (
      select 1 from public.providers p
      where p.id = provider_working_hours.provider_id
        and public.has_facility_role(p.facility_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[])
    )
  );

-- ---------------------------------------------------------------------------
-- Family members
-- ---------------------------------------------------------------------------

create policy "Account holders manage own family members"
  on public.family_members for all
  to authenticated
  using (account_holder_id = auth.uid())
  with check (account_holder_id = auth.uid());

create policy "Staff can view family members for facility appointments"
  on public.family_members for select
  to authenticated
  using (
    exists (
      select 1
      from public.appointments a
      join public.facility_memberships fm on fm.facility_id = a.facility_id
      where a.family_member_id = family_members.id
        and fm.user_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Appointments
-- ---------------------------------------------------------------------------

create policy "Patients view own appointments"
  on public.appointments for select
  to authenticated
  using (patient_id = auth.uid());

create policy "Patients create own appointments"
  on public.appointments for insert
  to authenticated
  with check (patient_id = auth.uid());

create policy "Patients cancel own pending appointments"
  on public.appointments for update
  to authenticated
  using (
    patient_id = auth.uid()
    and status in ('pending', 'confirmed')
  )
  with check (patient_id = auth.uid());

create policy "Facility staff manage facility appointments"
  on public.appointments for all
  to authenticated
  using (
    public.has_facility_role(
      facility_id,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  )
  with check (
    public.has_facility_role(
      facility_id,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  );

create policy "Super admins manage all appointments"
  on public.appointments for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Medical documents
-- ---------------------------------------------------------------------------

create policy "Patients view own medical documents"
  on public.medical_documents for select
  to authenticated
  using (patient_id = auth.uid());

create policy "Facility staff manage facility medical documents"
  on public.medical_documents for all
  to authenticated
  using (
    public.has_facility_role(
      facility_id,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  )
  with check (
    public.has_facility_role(
      facility_id,
      array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
    )
  );

create policy "Super admins manage all medical documents"
  on public.medical_documents for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Prescriptions
-- ---------------------------------------------------------------------------

create policy "Patients view own prescriptions"
  on public.prescriptions for select
  to authenticated
  using (patient_id = auth.uid());

create policy "Doctors manage prescriptions"
  on public.prescriptions for all
  to authenticated
  using (
    public.has_facility_role(facility_id, array['facility_admin', 'doctor']::public.app_role[])
  )
  with check (
    public.has_facility_role(facility_id, array['facility_admin', 'doctor']::public.app_role[])
  );

create policy "Super admins manage all prescriptions"
  on public.prescriptions for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- Emergency facilities (public directory)
-- ---------------------------------------------------------------------------

create policy "Anyone can view active emergency facilities"
  on public.emergency_facilities for select
  to anon, authenticated
  using (is_active = true);

create policy "Super admins manage emergency facilities"
  on public.emergency_facilities for all
  to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

commit;
