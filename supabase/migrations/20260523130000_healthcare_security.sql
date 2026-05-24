-- SmartHealth: production healthcare security (consent, access logs, brute-force, retention)

begin;

-- ---------------------------------------------------------------------------
-- Patient consent tracking (HIPAA/GDPR-style)
-- ---------------------------------------------------------------------------

create table public.patient_consents (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles (id) on delete cascade,
  consent_type text not null
    check (consent_type in (
      'data_processing', 'telehealth', 'marketing', 'research',
      'third_party_sharing', 'emergency_contact'
    )),
  version text not null,
  granted_at timestamptz not null default timezone('utc', now()),
  withdrawn_at timestamptz,
  ip_address inet,
  user_agent text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index patient_consents_patient_idx
  on public.patient_consents (patient_id, consent_type, granted_at desc);

create unique index patient_consents_active_unique
  on public.patient_consents (patient_id, consent_type)
  where withdrawn_at is null;

create trigger patient_consents_updated_at
  before update on public.patient_consents
  for each row execute function public.set_updated_at();

create trigger audit_patient_consents
  after insert or update or delete on public.patient_consents
  for each row execute function audit.log_row_change();

alter table public.patient_consents enable row level security;

create policy patient_consents_select_own on public.patient_consents
  for select to authenticated
  using (patient_id = auth.uid() or public.is_super_admin());

create policy patient_consents_insert_own on public.patient_consents
  for insert to authenticated
  with check (patient_id = auth.uid());

create policy patient_consents_update_own on public.patient_consents
  for update to authenticated
  using (patient_id = auth.uid())
  with check (patient_id = auth.uid());

create policy patient_consents_staff_read on public.patient_consents
  for select to authenticated
  using (
    public.is_super_admin()
    or exists (
      select 1 from public.appointments a
      where a.patient_id = patient_consents.patient_id
        and public.has_facility_role(a.tenant_id, array['facility_admin', 'doctor', 'receptionist']::public.app_role[])
    )
  );

-- ---------------------------------------------------------------------------
-- Medical record access logs (read-side PHI auditing)
-- ---------------------------------------------------------------------------

create table audit.medical_access_logs (
  id bigserial primary key,
  actor_id uuid not null,
  patient_id uuid not null,
  resource_type text not null,
  resource_id uuid,
  action text not null default 'read'
    check (action in ('read', 'export', 'print', 'share')),
  tenant_id uuid,
  ip_address inet,
  user_agent text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index medical_access_logs_patient_idx
  on audit.medical_access_logs (patient_id, created_at desc);
create index medical_access_logs_actor_idx
  on audit.medical_access_logs (actor_id, created_at desc);
create index medical_access_logs_tenant_idx
  on audit.medical_access_logs (tenant_id, created_at desc);

alter table audit.medical_access_logs enable row level security;

create policy medical_access_logs_super_admin on audit.medical_access_logs
  for select to authenticated
  using (public.is_super_admin());

create policy medical_access_logs_facility_admin on audit.medical_access_logs
  for select to authenticated
  using (
    tenant_id is not null
    and public.has_facility_role(tenant_id, array['facility_admin']::public.app_role[])
  );

create policy medical_access_logs_patient_own on audit.medical_access_logs
  for select to authenticated
  using (patient_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Login attempt tracking (brute-force protection)
-- ---------------------------------------------------------------------------

create table private.login_attempts (
  id bigserial primary key,
  identifier text not null,
  attempt_type text not null default 'otp_verify'
    check (attempt_type in ('otp_send', 'otp_verify', 'refresh', 'recovery')),
  ip_address inet,
  user_agent text,
  success boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create index login_attempts_identifier_idx
  on private.login_attempts (identifier, created_at desc);
create index login_attempts_ip_idx
  on private.login_attempts (ip_address, created_at desc);

-- ---------------------------------------------------------------------------
-- Data retention policies
-- ---------------------------------------------------------------------------

create table audit.retention_policies (
  id uuid primary key default gen_random_uuid(),
  table_schema text not null,
  table_name text not null,
  retention_days int not null check (retention_days > 0),
  is_active boolean not null default true,
  last_purged_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  unique (table_schema, table_name)
);

insert into audit.retention_policies (table_schema, table_name, retention_days)
values
  ('audit', 'logs', 365),
  ('audit', 'security_events', 365),
  ('audit', 'medical_access_logs', 2555),
  ('private', 'login_attempts', 90),
  ('public', 'activity_logs', 365)
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- Backend security helpers (service role / API layer)
-- ---------------------------------------------------------------------------

create or replace function audit.log_security_event_backend(
  p_user_id uuid,
  p_event_type text,
  p_action text default 'access',
  p_outcome text default 'allowed',
  p_resource_type text default null,
  p_resource_id uuid default null,
  p_tenant_id uuid default null,
  p_ip_address inet default null,
  p_details jsonb default '{}'::jsonb
)
returns bigint
language plpgsql
security definer
set search_path = audit, public
as $$
declare
  v_id bigint;
begin
  insert into audit.security_events (
    user_id, tenant_id, event_type, resource_type, resource_id,
    action, outcome, details, ip_address
  )
  values (
    p_user_id, p_tenant_id, p_event_type, p_resource_type, p_resource_id,
    p_action, p_outcome, p_details, p_ip_address
  )
  returning id into v_id;

  if p_user_id is not null then
    insert into public.activity_logs (
      tenant_id, user_id, action, entity_type, entity_id, metadata
    )
    values (
      p_tenant_id,
      p_user_id,
      'security.' || p_event_type,
      p_resource_type,
      p_resource_id,
      jsonb_build_object('outcome', p_outcome) || p_details
    );
  end if;

  return v_id;
end;
$$;

create or replace function audit.log_medical_access_backend(
  p_actor_id uuid,
  p_patient_id uuid,
  p_resource_type text,
  p_resource_id uuid default null,
  p_action text default 'read',
  p_tenant_id uuid default null,
  p_ip_address inet default null,
  p_user_agent text default null,
  p_details jsonb default '{}'::jsonb
)
returns bigint
language plpgsql
security definer
set search_path = audit, public
as $$
declare
  v_id bigint;
begin
  insert into audit.medical_access_logs (
    actor_id, patient_id, resource_type, resource_id,
    action, tenant_id, ip_address, user_agent, details
  )
  values (
    p_actor_id, p_patient_id, p_resource_type, p_resource_id,
    p_action, p_tenant_id, p_ip_address, p_user_agent, p_details
  )
  returning id into v_id;

  perform audit.log_security_event_backend(
    p_actor_id, 'medical_record_access', p_action, 'allowed',
    p_resource_type, p_resource_id, p_tenant_id, p_ip_address,
    jsonb_build_object('patient_id', p_patient_id) || p_details
  );

  return v_id;
end;
$$;

create or replace function private.record_login_attempt(
  p_identifier text,
  p_attempt_type text,
  p_success boolean,
  p_ip_address inet default null,
  p_user_agent text default null
)
returns void
language plpgsql
security definer
set search_path = private
as $$
begin
  insert into private.login_attempts (identifier, attempt_type, success, ip_address, user_agent)
  values (p_identifier, p_attempt_type, p_success, p_ip_address, p_user_agent);
end;
$$;

create or replace function private.is_identifier_locked(
  p_identifier text,
  p_attempt_type text default 'otp_verify',
  p_max_failures int default 5,
  p_window_minutes int default 15
)
returns boolean
language plpgsql
security definer
set search_path = private
as $$
declare
  failure_count int;
begin
  select count(*)::int into failure_count
  from private.login_attempts
  where identifier = p_identifier
    and attempt_type = p_attempt_type
    and success = false
    and created_at > timezone('utc', now()) - (p_window_minutes || ' minutes')::interval;

  return failure_count >= p_max_failures;
end;
$$;

create or replace function private.validate_refresh_token(p_token_hash text)
returns table (user_id uuid, is_valid boolean, is_reuse boolean)
language plpgsql
security definer
set search_path = private
as $$
declare
  v_row private.refresh_tokens%rowtype;
begin
  select * into v_row
  from private.refresh_tokens
  where token_hash = p_token_hash;

  if not found then
    return query select null::uuid, false, false;
    return;
  end if;

  if v_row.revoked_at is not null then
    -- Token reuse detected — revoke all sessions for this user
    update private.refresh_tokens
    set revoked_at = timezone('utc', now())
    where user_id = v_row.user_id and revoked_at is null;

    return query select v_row.user_id, false, true;
    return;
  end if;

  if v_row.expires_at < timezone('utc', now()) then
    return query select v_row.user_id, false, false;
    return;
  end if;

  return query select v_row.user_id, true, false;
end;
$$;

create or replace function audit.apply_retention_policies()
returns table (table_schema text, table_name text, deleted_count bigint)
language plpgsql
security definer
set search_path = audit, private, public
as $$
declare
  pol record;
  cnt bigint;
begin
  for pol in
    select * from audit.retention_policies where is_active = true
  loop
    cnt := 0;

    if pol.table_schema = 'audit' and pol.table_name = 'logs' then
      delete from audit.logs
      where created_at < timezone('utc', now()) - (pol.retention_days || ' days')::interval;
      get diagnostics cnt = row_count;
    elsif pol.table_schema = 'audit' and pol.table_name = 'security_events' then
      delete from audit.security_events
      where created_at < timezone('utc', now()) - (pol.retention_days || ' days')::interval;
      get diagnostics cnt = row_count;
    elsif pol.table_schema = 'audit' and pol.table_name = 'medical_access_logs' then
      delete from audit.medical_access_logs
      where created_at < timezone('utc', now()) - (pol.retention_days || ' days')::interval;
      get diagnostics cnt = row_count;
    elsif pol.table_schema = 'private' and pol.table_name = 'login_attempts' then
      delete from private.login_attempts
      where created_at < timezone('utc', now()) - (pol.retention_days || ' days')::interval;
      get diagnostics cnt = row_count;
    elsif pol.table_schema = 'public' and pol.table_name = 'activity_logs' then
      delete from public.activity_logs
      where created_at < timezone('utc', now()) - (pol.retention_days || ' days')::interval;
      get diagnostics cnt = row_count;
    end if;

    update audit.retention_policies
    set last_purged_at = timezone('utc', now())
    where id = pol.id;

    table_schema := pol.table_schema;
    table_name := pol.table_name;
    deleted_count := cnt;
    return next;
  end loop;
end;
$$;

-- Account recovery sessions (time-limited recovery flows)
create table private.recovery_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  phone text not null,
  recovery_code_hash text not null,
  expires_at timestamptz not null,
  used_at timestamptz,
  ip_address inet,
  created_at timestamptz not null default timezone('utc', now())
);

create index recovery_sessions_user_idx on private.recovery_sessions (user_id);
create index recovery_sessions_expires_idx on private.recovery_sessions (expires_at);

create or replace function private.create_recovery_session(
  p_user_id uuid,
  p_phone text,
  p_code_hash text,
  p_ip_address inet default null,
  p_ttl_minutes int default 30
)
returns uuid
language plpgsql
security definer
set search_path = private
as $$
declare
  v_id uuid;
begin
  update private.recovery_sessions
  set used_at = timezone('utc', now())
  where user_id = p_user_id and used_at is null;

  insert into private.recovery_sessions (user_id, phone, recovery_code_hash, expires_at, ip_address)
  values (
    p_user_id, p_phone, p_code_hash,
    timezone('utc', now()) + (p_ttl_minutes || ' minutes')::interval,
    p_ip_address
  )
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function private.verify_recovery_session(
  p_phone text,
  p_code_hash text
)
returns uuid
language plpgsql
security definer
set search_path = private
as $$
declare
  v_user_id uuid;
begin
  select user_id into v_user_id
  from private.recovery_sessions
  where phone = p_phone
    and recovery_code_hash = p_code_hash
    and used_at is null
    and expires_at > timezone('utc', now())
  order by created_at desc
  limit 1;

  if v_user_id is null then
    return null;
  end if;

  update private.recovery_sessions
  set used_at = timezone('utc', now())
  where phone = p_phone and recovery_code_hash = p_code_hash and used_at is null;

  perform private.revoke_all_user_tokens(v_user_id);

  return v_user_id;
end;
$$;

commit;
