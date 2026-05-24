-- SmartHealth: audit logging infrastructure

begin;

create table audit.logs (
  id bigserial primary key,
  schema_name text not null,
  table_name text not null,
  record_id uuid,
  action public.audit_action not null,
  actor_id uuid,
  facility_id uuid,
  old_data jsonb,
  new_data jsonb,
  changed_fields text[],
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default timezone('utc', now())
);

create index audit_logs_table_record_idx on audit.logs (table_name, record_id);
create index audit_logs_actor_idx on audit.logs (actor_id);
create index audit_logs_facility_idx on audit.logs (facility_id);
create index audit_logs_created_at_idx on audit.logs (created_at desc);

alter table audit.logs enable row level security;

create policy "Super admins read audit logs"
  on audit.logs for select
  to authenticated
  using (public.is_super_admin());

create policy "Facility admins read facility audit logs"
  on audit.logs for select
  to authenticated
  using (
    facility_id is not null
    and public.has_facility_role(facility_id, array['facility_admin']::public.app_role[])
  );

-- Generic audit trigger function
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
         and key not in ('updated_at') then
        changed := array_append(changed, key);
      end if;
    end loop;
  end if;

  facility_uuid := coalesce(
    (new_json ->> 'facility_id')::uuid,
    (old_json ->> 'facility_id')::uuid
  );

  insert into audit.logs (
    schema_name,
    table_name,
    record_id,
    action,
    actor_id,
    facility_id,
    old_data,
    new_data,
    changed_fields
  )
  values (
    tg_table_schema,
    tg_table_name,
    record_uuid,
    lower(tg_op)::public.audit_action,
    auth.uid(),
    facility_uuid,
    old_json,
    new_json,
    changed
  );

  if tg_op = 'DELETE' then
    return old;
  end if;

  return new;
end;
$$;

-- Attach audit triggers to sensitive tables
create trigger audit_facilities
  after insert or update or delete on public.facilities
  for each row execute function audit.log_row_change();

create trigger audit_profiles
  after insert or update or delete on public.profiles
  for each row execute function audit.log_row_change();

create trigger audit_facility_memberships
  after insert or update or delete on public.facility_memberships
  for each row execute function audit.log_row_change();

create trigger audit_appointments
  after insert or update or delete on public.appointments
  for each row execute function audit.log_row_change();

create trigger audit_medical_documents
  after insert or update or delete on public.medical_documents
  for each row execute function audit.log_row_change();

create trigger audit_prescriptions
  after insert or update or delete on public.prescriptions
  for each row execute function audit.log_row_change();

-- Retention helper (run via pg_cron or external scheduler)
create or replace function audit.purge_old_logs(retention_days int default 365)
returns bigint
language plpgsql
security definer
set search_path = audit
as $$
declare
  deleted_count bigint;
begin
  delete from audit.logs
  where created_at < timezone('utc', now()) - make_interval(days => retention_days);

  get diagnostics deleted_count = row_count;
  return deleted_count;
end;
$$;

commit;
