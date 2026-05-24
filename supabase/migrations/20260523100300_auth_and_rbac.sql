-- SmartHealth: authentication hooks, JWT claims, and session helpers

begin;

-- ---------------------------------------------------------------------------
-- RBAC helper functions (used by RLS policies)
-- ---------------------------------------------------------------------------

create or replace function public.get_user_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (auth.jwt() ->> 'user_role')::public.app_role,
    (select primary_role from public.profiles where id = auth.uid())
  );
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.get_user_role() = 'super_admin';
$$;

create or replace function public.has_facility_role(
  target_facility_id uuid,
  allowed_roles public.app_role[]
)
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
      where fm.facility_id = target_facility_id
        and fm.user_id = auth.uid()
        and fm.role = any (allowed_roles)
    );
$$;

create or replace function public.is_facility_member(target_facility_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_facility_role(
    target_facility_id,
    array['facility_admin', 'doctor', 'receptionist']::public.app_role[]
  );
$$;

create or replace function public.user_facility_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select fm.facility_id
  from public.facility_memberships fm
  where fm.user_id = auth.uid();
$$;

-- ---------------------------------------------------------------------------
-- Custom access token hook (JWT claims for RBAC)
-- https://supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook
-- ---------------------------------------------------------------------------

create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  claims jsonb;
  user_role public.app_role;
  facility_ids jsonb;
begin
  select p.primary_role
  into user_role
  from public.profiles p
  where p.id = (event ->> 'user_id')::uuid;

  select coalesce(jsonb_agg(fm.facility_id), '[]'::jsonb)
  into facility_ids
  from public.facility_memberships fm
  where fm.user_id = (event ->> 'user_id')::uuid;

  claims := event -> 'claims';

  if user_role is not null then
    claims := jsonb_set(claims, '{user_role}', to_jsonb(user_role::text), true);
  end if;

  claims := jsonb_set(claims, '{facility_ids}', facility_ids, true);
  claims := jsonb_set(claims, '{app}', '"smarthealth"'::jsonb, true);

  event := jsonb_set(event, '{claims}', claims);
  return event;
end;
$$;

grant usage on schema public to supabase_auth_admin;
grant execute on function public.custom_access_token_hook(jsonb) to supabase_auth_admin;
revoke execute on function public.custom_access_token_hook(jsonb) from authenticated, anon, public;

-- ---------------------------------------------------------------------------
-- New user handler: create profile on signup
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  resolved_role public.app_role := 'patient';
  resolved_phone text;
begin
  if new.raw_user_meta_data ? 'role' then
    begin
      resolved_role := (new.raw_user_meta_data ->> 'role')::public.app_role;
    exception
      when others then
        resolved_role := 'patient';
    end;
  end if;

  -- Only super_admin can be bootstrapped via service role; public signup is patient
  if resolved_role <> 'patient' and coalesce(new.raw_app_meta_data ->> 'created_by', '') <> 'service_role' then
    resolved_role := 'patient';
  end if;

  resolved_phone := public.normalize_zimbabwe_phone(
    coalesce(new.phone, new.raw_user_meta_data ->> 'phone')
  );

  insert into public.profiles (
    id,
    primary_role,
    first_name,
    last_name,
    phone,
    email,
    preferred_language
  )
  values (
    new.id,
    resolved_role,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name',
    resolved_phone,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'preferred_language', 'en')
  );

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Refresh token tracking (called from client edge function or service role)
-- ---------------------------------------------------------------------------

create or replace function private.register_refresh_token(
  p_user_id uuid,
  p_token_hash text,
  p_session_id uuid default null,
  p_user_agent text default null,
  p_ip_address inet default null,
  p_expires_at timestamptz default null
)
returns uuid
language plpgsql
security definer
set search_path = private, public
as $$
declare
  token_id uuid;
begin
  insert into private.refresh_tokens (
    user_id,
    token_hash,
    session_id,
    user_agent,
    ip_address,
    expires_at
  )
  values (
    p_user_id,
    p_token_hash,
    p_session_id,
    p_user_agent,
    p_ip_address,
    coalesce(p_expires_at, timezone('utc', now()) + interval '7 days')
  )
  returning id into token_id;

  return token_id;
end;
$$;

create or replace function private.revoke_refresh_token(p_token_hash text)
returns void
language plpgsql
security definer
set search_path = private
as $$
begin
  update private.refresh_tokens
  set revoked_at = timezone('utc', now())
  where token_hash = p_token_hash
    and revoked_at is null;
end;
$$;

create or replace function private.revoke_all_user_tokens(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = private
as $$
begin
  update private.refresh_tokens
  set revoked_at = timezone('utc', now())
  where user_id = p_user_id
    and revoked_at is null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Phone normalization trigger on profiles
-- ---------------------------------------------------------------------------

create or replace function public.normalize_profile_phone()
returns trigger
language plpgsql
as $$
begin
  if new.phone is not null then
    new.phone := public.normalize_zimbabwe_phone(new.phone);
  end if;
  return new;
end;
$$;

create trigger profiles_normalize_phone
  before insert or update on public.profiles
  for each row execute function public.normalize_profile_phone();

commit;
