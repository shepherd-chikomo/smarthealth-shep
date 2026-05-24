-- SmartHealth: complete audit logging — unified action logs, immutability, compliance export

begin;

-- ---------------------------------------------------------------------------
-- Audit category enum
-- ---------------------------------------------------------------------------

do $$ begin
  create type audit.audit_category as enum (
    'login',
    'medical_access',
    'appointment',
    'billing',
    'permission',
    'admin',
    'security',
    'data_change'
  );
exception when duplicate_object then null;
end $$;

-- ---------------------------------------------------------------------------
-- Unified application audit log (compliance-ready)
-- ---------------------------------------------------------------------------

create table if not exists audit.action_logs (
  id bigserial primary key,
  user_id uuid,
  facility_id uuid,
  category audit.audit_category not null,
  action_type text not null,
  entity_type text,
  entity_id uuid,
  outcome text not null default 'allowed'
    check (outcome in ('allowed', 'denied', 'error')),
  ip_address inet,
  user_agent text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists action_logs_user_idx on audit.action_logs (user_id);
create index if not exists action_logs_facility_idx on audit.action_logs (facility_id);
create index if not exists action_logs_category_idx on audit.action_logs (category);
create index if not exists action_logs_action_type_idx on audit.action_logs (action_type);
create index if not exists action_logs_entity_idx on audit.action_logs (entity_type, entity_id);
create index if not exists action_logs_created_at_idx on audit.action_logs (created_at desc);
create index if not exists action_logs_outcome_idx on audit.action_logs (outcome) where outcome <> 'allowed';

alter table audit.action_logs enable row level security;

create policy "Super admins read action logs"
  on audit.action_logs for select
  to authenticated
  using (public.is_super_admin());

create policy "Facility admins read facility action logs"
  on audit.action_logs for select
  to authenticated
  using (
    facility_id is not null
    and public.has_facility_role(facility_id, array['facility_admin']::public.app_role[])
  );

-- ---------------------------------------------------------------------------
-- Immutability — audit records must never be modified or deleted
-- ---------------------------------------------------------------------------

create or replace function audit.prevent_audit_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Audit records are immutable and cannot be modified or deleted';
end;
$$;

do $$ declare
  t text;
begin
  foreach t in array array[
    'audit.action_logs',
    'audit.security_events',
    'audit.medical_access_logs',
    'audit.logs'
  ] loop
    execute format('drop trigger if exists prevent_mutation on %s', t);
    execute format(
      'create trigger prevent_mutation before update or delete on %s
       for each row execute function audit.prevent_audit_mutation()',
      t
    );
  end loop;
end $$;

-- Login attempts are append-only (no updates expected)
drop trigger if exists prevent_mutation on private.login_attempts;
create trigger prevent_mutation
  before update or delete on private.login_attempts
  for each row execute function audit.prevent_audit_mutation();

-- ---------------------------------------------------------------------------
-- Backend writer for unified action logs
-- ---------------------------------------------------------------------------

create or replace function audit.log_action_backend(
  p_user_id uuid,
  p_category text,
  p_action_type text,
  p_entity_type text default null,
  p_entity_id uuid default null,
  p_facility_id uuid default null,
  p_outcome text default 'allowed',
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
  insert into audit.action_logs (
    user_id, facility_id, category, action_type,
    entity_type, entity_id, outcome,
    ip_address, user_agent, details
  )
  values (
    p_user_id,
    p_facility_id,
    p_category::audit.audit_category,
    p_action_type,
    p_entity_type,
    p_entity_id,
    coalesce(p_outcome, 'allowed'),
    p_ip_address,
    p_user_agent,
    coalesce(p_details, '{}'::jsonb)
  )
  returning id into v_id;

  return v_id;
end;
$$;

-- Extend security event backend to capture user_agent
create or replace function audit.log_security_event_backend(
  p_user_id uuid,
  p_event_type text,
  p_action text default 'access',
  p_outcome text default 'allowed',
  p_resource_type text default null,
  p_resource_id uuid default null,
  p_tenant_id uuid default null,
  p_ip_address inet default null,
  p_details jsonb default '{}'::jsonb,
  p_user_agent text default null
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

  perform audit.log_action_backend(
    p_user_id,
    'security',
    p_event_type,
    p_resource_type,
    p_resource_id,
    p_tenant_id,
    p_outcome,
    p_ip_address,
    p_user_agent,
    jsonb_build_object('action', p_action) || p_details
  );

  if p_user_id is not null then
    insert into public.activity_logs (
      tenant_id, user_id, action, entity_type, entity_id, ip_address, user_agent, metadata
    )
    values (
      p_tenant_id,
      p_user_id,
      'security.' || p_event_type,
      p_resource_type,
      p_resource_id,
      p_ip_address,
      p_user_agent,
      jsonb_build_object('outcome', p_outcome) || p_details
    );
  end if;

  return v_id;
end;
$$;

-- Extend medical access backend to also write unified action log
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

  perform audit.log_action_backend(
    p_actor_id,
    'medical_access',
    'medical_record.' || p_action,
    p_resource_type,
    p_resource_id,
    p_tenant_id,
    'allowed',
    p_ip_address,
    p_user_agent,
    jsonb_build_object('patient_id', p_patient_id) || p_details
  );

  insert into audit.security_events (
    user_id, tenant_id, event_type, resource_type, resource_id,
    action, outcome, details, ip_address
  )
  values (
    p_actor_id, p_tenant_id, 'medical_record_access', p_resource_type, p_resource_id,
    p_action, 'allowed',
    jsonb_build_object('patient_id', p_patient_id) || p_details,
    p_ip_address
  );

  return v_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Compliance export view (searchable, unified)
-- ---------------------------------------------------------------------------

create or replace view audit.compliance_export_view as
select
  'action:' || id::text as log_key,
  id,
  'action_log'::text as source,
  user_id as actor_id,
  facility_id,
  category::text as category,
  action_type,
  entity_type,
  entity_id,
  outcome,
  ip_address,
  user_agent,
  details,
  created_at
from audit.action_logs

union all

select
  'login:' || id::text,
  id,
  'login_attempt',
  null,
  null,
  'login',
  attempt_type,
  'identifier',
  null,
  case when success then 'allowed' else 'denied' end,
  ip_address,
  user_agent,
  jsonb_build_object('identifier', identifier, 'success', success),
  created_at
from private.login_attempts

union all

select
  'row:' || id::text,
  id,
  'data_change',
  actor_id,
  facility_id,
  'data_change',
  action::text,
  table_name,
  record_id,
  'allowed',
  ip_address,
  user_agent,
  jsonb_build_object(
    'schema', schema_name,
    'changed_fields', to_jsonb(changed_fields),
    'old_data', old_data,
    'new_data', new_data
  ),
  created_at
from audit.logs;

-- Retention policy for unified action logs (7 years for compliance)
insert into audit.retention_policies (table_schema, table_name, retention_days)
values ('audit', 'action_logs', 2555)
on conflict (table_schema, table_name) do update set retention_days = 2555;

commit;
