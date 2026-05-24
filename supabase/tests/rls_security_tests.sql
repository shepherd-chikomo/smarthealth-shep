-- SmartHealth RLS security tests
-- Run: psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/rls_security_tests.sql
--
-- Uses Supabase JWT simulation via request.jwt.claims and SET ROLE authenticated.

begin;

-- ---------------------------------------------------------------------------
-- Test fixtures (run as superuser / postgres — bypasses RLS)
-- ---------------------------------------------------------------------------

create temp table if not exists _rls_test_results (
  test_name text primary key,
  passed boolean not null,
  detail text
);

create or replace function _rls_assert(p_name text, p_condition boolean, p_detail text default '')
returns void language plpgsql as $$
begin
  insert into _rls_test_results (test_name, passed, detail)
  values (p_name, p_condition, p_detail)
  on conflict (test_name) do update
    set passed = excluded.passed, detail = excluded.detail;
  if not p_condition then
    raise warning 'FAIL: % — %', p_name, p_detail;
  end if;
end;
$$;

create or replace function _rls_auth_as(p_user_id uuid, p_role text default 'patient')
returns void language plpgsql as $$
begin
  perform set_config('role', 'authenticated', true);
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub', p_user_id::text,
      'role', 'authenticated',
      'user_role', p_role
    )::text,
    true
  );
end;
$$;

create or replace function _rls_auth_clear()
returns void language plpgsql as $$
begin
  perform set_config('role', 'postgres', true);
  perform set_config('request.jwt.claims', '', true);
end;
$$;

-- Fixed UUIDs for reproducibility
do $fixtures$
declare
  v_facility_a uuid := 'f0000000-0000-4000-a000-000000000001';
  v_facility_b uuid := 'f0000000-0000-4000-a000-000000000002';
  v_patient_1  uuid := 'p0000000-0000-4000-a000-000000000001';
  v_patient_2  uuid := 'p0000000-0000-4000-a000-000000000002';
  v_doctor_1   uuid := 'd0000000-0000-4000-a000-000000000001';
  v_doctor_2   uuid := 'd0000000-0000-4000-a000-000000000002';
  v_admin_a    uuid := 'a0000000-0000-4000-a000-000000000001';
  v_super      uuid := 's0000000-0000-4000-a000-000000000001';
  v_provider_a uuid := 'r0000000-0000-4000-a000-000000000001';
  v_provider_b uuid := 'r0000000-0000-4000-a000-000000000002';
  v_appt_p1    uuid := 'b0000000-0000-4000-a000-000000000001';
  v_appt_p2    uuid := 'b0000000-0000-4000-a000-000000000002';
  v_consult_a  uuid := 'c0000000-0000-4000-a000-000000000001';
  v_family_p1  uuid := 'e0000000-0000-4000-a000-000000000001';
begin
  -- Auth users (minimal)
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, raw_app_meta_data, raw_user_meta_data)
  values
    (v_patient_1, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'patient1@rls.test', crypt('test', gen_salt('bf')), now(), now(), now(), '', '{}', '{}'),
    (v_patient_2, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'patient2@rls.test', crypt('test', gen_salt('bf')), now(), now(), now(), '', '{}', '{}'),
    (v_doctor_1,  '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'doctor1@rls.test',  crypt('test', gen_salt('bf')), now(), now(), now(), '', '{}', '{}'),
    (v_doctor_2,  '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'doctor2@rls.test',  crypt('test', gen_salt('bf')), now(), now(), now(), '', '{}', '{}'),
    (v_admin_a,   '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@rls.test',   crypt('test', gen_salt('bf')), now(), now(), now(), '', '{}', '{}'),
    (v_super,     '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'super@rls.test',   crypt('test', gen_salt('bf')), now(), now(), now(), '', '{}', '{}')
  on conflict (id) do nothing;

  insert into public.profiles (id, primary_role, first_name, email) values
    (v_patient_1, 'patient', 'Patient One', 'patient1@rls.test'),
    (v_patient_2, 'patient', 'Patient Two', 'patient2@rls.test'),
    (v_doctor_1,  'doctor',  'Doctor One',  'doctor1@rls.test'),
    (v_doctor_2,  'doctor',  'Doctor Two',  'doctor2@rls.test'),
    (v_admin_a,   'facility_admin', 'Admin A', 'admin@rls.test'),
    (v_super,     'super_admin', 'Super', 'super@rls.test')
  on conflict (id) do update set primary_role = excluded.primary_role;

  insert into public.facilities (id, name, slug, city, province, is_active, moderation_status, verification_status) values
    (v_facility_a, 'RLS Test Clinic A', 'rls-clinic-a', 'Harare', 'Harare', true, 'approved', 'verified'),
    (v_facility_b, 'RLS Test Clinic B', 'rls-clinic-b', 'Bulawayo', 'Bulawayo', true, 'approved', 'verified')
  on conflict (id) do nothing;

  insert into public.facility_memberships (facility_id, user_id, role) values
    (v_facility_a, v_doctor_1, 'doctor'),
    (v_facility_b, v_doctor_2, 'doctor'),
    (v_facility_a, v_admin_a, 'facility_admin')
  on conflict (facility_id, user_id) do update set role = excluded.role;

  insert into public.providers (id, facility_id, tenant_id, profile_id, name, is_active, moderation_status, verification_status) values
    (v_provider_a, v_facility_a, v_facility_a, v_doctor_1, 'Dr RLS One', true, 'approved', 'verified'),
    (v_provider_b, v_facility_b, v_facility_b, v_doctor_2, 'Dr RLS Two', true, 'approved', 'verified')
  on conflict (id) do nothing;

  insert into public.appointments (id, reference_number, facility_id, tenant_id, provider_id, patient_id, scheduled_at, status) values
    (v_appt_p1, 'RLS-APPT-001', v_facility_a, v_facility_a, v_provider_a, v_patient_1, now() + interval '1 day', 'confirmed'),
    (v_appt_p2, 'RLS-APPT-002', v_facility_b, v_facility_b, v_provider_b, v_patient_2, now() + interval '1 day', 'confirmed')
  on conflict (id) do nothing;

  insert into public.consultations (id, facility_id, tenant_id, provider_id, patient_id, appointment_id, status) values
    (v_consult_a, v_facility_a, v_facility_a, v_provider_a, v_patient_1, v_appt_p1, 'completed')
  on conflict (id) do nothing;

  insert into public.family_members (id, account_holder_id, first_name, relationship) values
    (v_family_p1, v_patient_1, 'Child One', 'child')
  on conflict (id) do nothing;
end;
$fixtures$;

-- ---------------------------------------------------------------------------
-- PATIENT tests
-- ---------------------------------------------------------------------------

do $tests$
declare
  v_patient_1 uuid := 'p0000000-0000-4000-a000-000000000001';
  v_patient_2 uuid := 'p0000000-0000-4000-a000-000000000002';
  v_count int;
begin
  perform _rls_auth_as(v_patient_1, 'patient');

  select count(*) into v_count from public.profiles;
  perform _rls_assert('patient_sees_only_own_profile', v_count = 1,
    format('expected 1 profile, got %s', v_count));

  select count(*) into v_count from public.appointments;
  perform _rls_assert('patient_sees_only_own_appointments', v_count = 1,
    format('expected 1 appointment, got %s', v_count));

  select count(*) into v_count from public.family_members;
  perform _rls_assert('patient_manages_own_family', v_count = 1,
    format('expected 1 family member, got %s', v_count));

  perform _rls_assert('patient_cannot_see_other_patient_appointment',
    not exists (
      select 1 from public.appointments where patient_id = v_patient_2
    ), 'cross-patient appointment visible');

  perform _rls_auth_clear();
end;
$tests$;

-- ---------------------------------------------------------------------------
-- DOCTOR tests (assigned appointments / own consultations only)
-- ---------------------------------------------------------------------------

do $tests$
declare
  v_doctor_1 uuid := 'd0000000-0000-4000-a000-000000000001';
  v_count int;
begin
  perform _rls_auth_as(v_doctor_1, 'doctor');

  select count(*) into v_count from public.appointments;
  perform _rls_assert('doctor_sees_assigned_appointments_only', v_count = 1,
    format('expected 1 assigned appointment, got %s', v_count));

  select count(*) into v_count from public.consultations;
  perform _rls_assert('doctor_sees_own_consultations', v_count = 1,
    format('expected 1 consultation, got %s', v_count));

  perform _rls_assert('doctor_cannot_see_other_facility_appointments',
    not exists (
      select 1 from public.appointments a
      join public.facilities f on f.id = a.tenant_id
      where f.slug = 'rls-clinic-b'
    ), 'doctor sees clinic B appointments');

  perform _rls_auth_clear();
end;
$tests$;

-- ---------------------------------------------------------------------------
-- FACILITY ADMIN tests
-- ---------------------------------------------------------------------------

do $tests$
declare
  v_admin_a uuid := 'a0000000-0000-4000-a000-000000000001';
  v_facility_a uuid := 'f0000000-0000-4000-a000-000000000001';
  v_count int;
begin
  perform _rls_auth_as(v_admin_a, 'facility_admin');

  select count(*) into v_count
  from public.facility_memberships
  where facility_id = v_facility_a;
  perform _rls_assert('admin_manages_facility_staff', v_count >= 2,
    format('expected >=2 memberships at clinic A, got %s', v_count));

  select count(*) into v_count
  from public.providers
  where tenant_id = v_facility_a;
  perform _rls_assert('admin_manages_facility_providers', v_count >= 1,
    format('expected >=1 provider, got %s', v_count));

  perform _rls_assert('admin_cannot_see_other_tenant_revenue',
    not exists (
      select 1 from public.revenue_reports rr
      join public.facilities f on f.id = rr.tenant_id
      where f.slug = 'rls-clinic-b'
    ), 'admin sees clinic B revenue');

  perform _rls_auth_clear();
end;
$tests$;

-- ---------------------------------------------------------------------------
-- TENANT ISOLATION (doctor at A cannot manage clinic B resources)
-- ---------------------------------------------------------------------------

do $tests$
declare
  v_doctor_1 uuid := 'd0000000-0000-4000-a000-000000000001';
  v_provider_b uuid := 'r0000000-0000-4000-a000-000000000002';
  v_rows int;
begin
  perform _rls_auth_as(v_doctor_1, 'doctor');

  update public.providers
  set name = 'Hacked Provider'
  where id = v_provider_b;

  get diagnostics v_rows = row_count;
  perform _rls_assert('doctor_cannot_update_other_tenant_provider', v_rows = 0,
    format('doctor updated %s rows in clinic B', v_rows));

  perform _rls_auth_clear();
end;
$tests$;

-- ---------------------------------------------------------------------------
-- SUPER ADMIN tests
-- ---------------------------------------------------------------------------

do $tests$
declare
  v_super uuid := 's0000000-0000-4000-a000-000000000001';
  v_count int;
begin
  perform _rls_auth_as(v_super, 'super_admin');

  select count(*) into v_count from public.appointments;
  perform _rls_assert('super_admin_full_appointment_access', v_count >= 2,
    format('expected >=2 appointments, got %s', v_count));

  select count(*) into v_count from public.facilities;
  perform _rls_assert('super_admin_full_facility_access', v_count >= 2,
    format('expected >=2 facilities, got %s', v_count));

  perform _rls_auth_clear();
end;
$tests$;

-- ---------------------------------------------------------------------------
-- Report
-- ---------------------------------------------------------------------------

do $report$
declare
  v_total int;
  v_failed int;
  r record;
begin
  select count(*), count(*) filter (where not passed)
  into v_total, v_failed
  from _rls_test_results;

  raise notice '=== SmartHealth RLS Security Tests ===';
  raise notice 'Total: %, Failed: %', v_total, v_failed;

  if v_failed > 0 then
    for r in select * from _rls_test_results where not passed loop
      raise notice '  FAIL: % — %', r.test_name, r.detail;
    end loop;
    raise exception 'RLS security tests failed (%/% failed)', v_failed, v_total;
  else
    for r in select * from _rls_test_results where passed loop
      raise notice '  PASS: %', r.test_name;
    end loop;
    raise notice 'All % RLS security tests passed.', v_total;
  end if;
end;
$report$;

rollback;
