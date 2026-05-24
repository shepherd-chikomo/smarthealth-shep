-- SmartHealth: RLS security helper functions, tenant isolation, audit events

begin;

-- ---------------------------------------------------------------------------
-- Role detection (membership-aware, not just primary_role)
-- ---------------------------------------------------------------------------

create or replace function public.get_facility_role(p_facility_id uuid)
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select fm.role
  from public.facility_memberships fm
  where fm.user_id = auth.uid()
    and fm.facility_id = p_facility_id
  limit 1;
$$;

create or replace function public.is_patient()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.get_user_role(), 'patient') = 'patient'
    and not exists (
      select 1 from public.facility_memberships fm where fm.user_id = auth.uid()
    );
$$;

create or replace function public.is_facility_admin(p_facility_id uuid default null)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_super_admin()
    or exists (
      select 1
      from public.facility_memberships fm
      where fm.user_id = auth.uid()
        and fm.role = 'facility_admin'
        and (p_facility_id is null or fm.facility_id = p_facility_id)
    );
$$;

create or replace function public.is_doctor(p_facility_id uuid default null)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.facility_memberships fm
    where fm.user_id = auth.uid()
      and fm.role = 'doctor'
      and (p_facility_id is null or fm.facility_id = p_facility_id)
  );
$$;

create or replace function public.is_receptionist(p_facility_id uuid default null)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.facility_memberships fm
    where fm.user_id = auth.uid()
      and fm.role = 'receptionist'
      and (p_facility_id is null or fm.facility_id = p_facility_id)
  );
$$;

create or replace function public.is_facility_staff(p_facility_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_super_admin()
    or public.is_facility_admin(p_facility_id)
    or public.is_doctor(p_facility_id)
    or public.is_receptionist(p_facility_id);
$$;

-- ---------------------------------------------------------------------------
-- Provider assignment (doctor ↔ provider record)
-- ---------------------------------------------------------------------------

create or replace function public.current_user_provider_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.id
  from public.providers p
  where p.profile_id = auth.uid()
    and p.deleted_at is null
    and p.is_active = true;
$$;

create or replace function public.is_assigned_to_provider(p_provider_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_provider_id in (select public.current_user_provider_ids());
$$;

create or replace function public.is_assigned_appointment(p_appointment_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.appointments a
    where a.id = p_appointment_id
      and a.deleted_at is null
      and public.is_assigned_to_provider(a.provider_id)
  );
$$;

-- ---------------------------------------------------------------------------
-- Tenant isolation
-- ---------------------------------------------------------------------------

create or replace function public.can_access_tenant(p_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_super_admin()
    or public.is_facility_staff(p_tenant_id);
$$;

create or replace function public.is_same_tenant(p_tenant_id uuid, p_facility_id uuid)
returns boolean
language sql
immutable
as $$
  select p_tenant_id = p_facility_id;
$$;

create or replace function public.tenant_matches(
  p_row_tenant_id uuid,
  p_row_facility_id uuid default null
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_super_admin()
    or public.can_access_tenant(coalesce(p_row_tenant_id, p_row_facility_id));
$$;

-- ---------------------------------------------------------------------------
-- Patient / staff profile access
-- ---------------------------------------------------------------------------

create or replace function public.staff_can_view_patient_profile(p_patient_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.appointments a
    join public.facility_memberships fm on fm.facility_id = a.tenant_id
    where a.patient_id = p_patient_id
      and a.deleted_at is null
      and fm.user_id = auth.uid()
  )
  or exists (
    select 1
    from public.walk_in_sessions w
    join public.facility_memberships fm on fm.facility_id = w.tenant_id
    where w.patient_id = p_patient_id
      and w.deleted_at is null
      and fm.user_id = auth.uid()
  )
  or exists (
    select 1
    from public.consultations c
    join public.facility_memberships fm on fm.facility_id = c.tenant_id
    where c.patient_id = p_patient_id
      and c.deleted_at is null
      and fm.user_id = auth.uid()
  );
$$;

create or replace function public.owns_patient_record(p_patient_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_patient_id = auth.uid();
$$;

create or replace function public.owns_family_member(p_family_member_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.id = p_family_member_id
      and fm.account_holder_id = auth.uid()
  );
$$;

-- ---------------------------------------------------------------------------
-- Consultation ownership (doctor created / assigned)
-- ---------------------------------------------------------------------------

create or replace function public.owns_consultation(p_consultation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.consultations c
    where c.id = p_consultation_id
      and c.deleted_at is null
      and public.is_assigned_to_provider(c.provider_id)
  );
$$;

create or replace function public.can_manage_consultation(p_consultation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    public.is_super_admin()
    or public.owns_consultation(p_consultation_id)
    or exists (
      select 1
      from public.consultations c
      where c.id = p_consultation_id
        and public.is_facility_admin(c.tenant_id)
    );
$$;

-- ---------------------------------------------------------------------------
-- Soft-delete guard
-- ---------------------------------------------------------------------------

create or replace function public.is_visible_row(p_deleted_at timestamptz)
returns boolean
language sql
immutable
as $$
  select p_deleted_at is null;
$$;

-- ---------------------------------------------------------------------------
-- Security audit events
-- ---------------------------------------------------------------------------

create table if not exists audit.security_events (
  id bigserial primary key,
  user_id uuid,
  tenant_id uuid,
  event_type text not null,
  resource_type text,
  resource_id uuid,
  action text not null,
  outcome text not null default 'allowed'
    check (outcome in ('allowed', 'denied', 'error')),
  details jsonb not null default '{}'::jsonb,
  ip_address inet,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists security_events_user_idx
  on audit.security_events (user_id, created_at desc);
create index if not exists security_events_tenant_idx
  on audit.security_events (tenant_id, created_at desc);
create index if not exists security_events_type_idx
  on audit.security_events (event_type, created_at desc);

alter table audit.security_events enable row level security;

create or replace function public.log_security_event(
  p_event_type text,
  p_resource_type text default null,
  p_resource_id uuid default null,
  p_action text default 'access',
  p_outcome text default 'allowed',
  p_tenant_id uuid default null,
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
    action, outcome, details
  )
  values (
    auth.uid(), p_tenant_id, p_event_type, p_resource_type, p_resource_id,
    p_action, p_outcome, p_details
  )
  returning id into v_id;

  insert into public.activity_logs (
    tenant_id, user_id, action, entity_type, entity_id, metadata
  )
  values (
    p_tenant_id,
    auth.uid(),
    'security.' || p_event_type,
    p_resource_type,
    p_resource_id,
    jsonb_build_object('outcome', p_outcome) || p_details
  );

  return v_id;
end;
$$;

revoke all on function public.log_security_event(text, text, uuid, text, text, uuid, jsonb)
  from public;
grant execute on function public.log_security_event(text, text, uuid, text, text, uuid, jsonb)
  to authenticated, service_role;

-- Enhance audit trigger to capture tenant_id
create or replace function audit.log_row_change()
returns trigger
language plpgsql
security definer
set search_path = audit, public
as $$
declare
  record_uuid uuid;
  facility_uuid uuid;
  old_json jsonb;
  new_json jsonb;
  changed text[];
  key text;
begin
  if tg_op = 'DELETE' then
    old_json := to_jsonb(old);
    new_json := null;
    record_uuid := (old_json ->> 'id')::uuid;
  elsif tg_op = 'INSERT' then
    old_json := null;
    new_json := to_jsonb(new);
    record_uuid := (new_json ->> 'id')::uuid;
  else
    old_json := to_jsonb(old);
    new_json := to_jsonb(new);
    record_uuid := (new_json ->> 'id')::uuid;

    for key in select jsonb_object_keys(new_json)
    loop
      if old_json -> key is distinct from new_json -> key
         and key not in ('updated_at', 'search_vector') then
        changed := array_append(changed, key);
      end if;
    end loop;
  end if;

  facility_uuid := coalesce(
    (new_json ->> 'tenant_id')::uuid,
    (old_json ->> 'tenant_id')::uuid,
    (new_json ->> 'facility_id')::uuid,
    (old_json ->> 'facility_id')::uuid
  );

  insert into audit.logs (
    schema_name, table_name, record_id, action,
    actor_id, facility_id, old_data, new_data, changed_fields
  )
  values (
    tg_table_schema, tg_table_name, record_uuid, lower(tg_op)::public.audit_action,
    auth.uid(), facility_uuid, old_json, new_json, changed
  );

  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

-- Grant execute on helper functions to authenticated
grant execute on function public.get_facility_role(uuid) to authenticated;
grant execute on function public.is_patient() to authenticated;
grant execute on function public.is_facility_admin(uuid) to authenticated;
grant execute on function public.is_doctor(uuid) to authenticated;
grant execute on function public.is_receptionist(uuid) to authenticated;
grant execute on function public.is_facility_staff(uuid) to authenticated;
grant execute on function public.current_user_provider_ids() to authenticated;
grant execute on function public.is_assigned_to_provider(uuid) to authenticated;
grant execute on function public.is_assigned_appointment(uuid) to authenticated;
grant execute on function public.can_access_tenant(uuid) to authenticated;
grant execute on function public.staff_can_view_patient_profile(uuid) to authenticated;
grant execute on function public.owns_patient_record(uuid) to authenticated;
grant execute on function public.owns_consultation(uuid) to authenticated;
grant execute on function public.can_manage_consultation(uuid) to authenticated;

commit;
