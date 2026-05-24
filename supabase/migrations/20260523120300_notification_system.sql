-- SmartHealth: notification system — categories, scheduling, Supabase triggers

begin;

-- Notification categories
create type public.notification_category as enum (
  'appointment_reminder',
  'appointment_cancellation',
  'emergency_alert',
  'provider_message',
  'facility_announcement',
  'general'
);

alter table public.notifications
  add column if not exists category public.notification_category not null default 'general',
  add column if not exists scheduled_at timestamptz,
  add column if not exists dedupe_key text,
  add column if not exists priority smallint not null default 0 check (priority between 0 and 5);

create unique index if not exists notifications_dedupe_key_idx
  on public.notifications (dedupe_key)
  where dedupe_key is not null;

create index if not exists notifications_scheduled_idx
  on public.notifications (scheduled_at)
  where status = 'pending' and scheduled_at is not null;

-- ---------------------------------------------------------------------------
-- Enqueue helper (called by triggers and application code)
-- ---------------------------------------------------------------------------

create or replace function public.enqueue_notification(
  p_user_id uuid,
  p_tenant_id uuid,
  p_category public.notification_category,
  p_title text,
  p_body text,
  p_action_url text default null,
  p_payload jsonb default '{}'::jsonb,
  p_scheduled_at timestamptz default null,
  p_dedupe_key text default null,
  p_priority smallint default 0
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if p_dedupe_key is not null then
    select id into v_id from public.notifications where dedupe_key = p_dedupe_key;
    if v_id is not null then
      return v_id;
    end if;
  end if;

  insert into public.notifications (
    user_id, tenant_id, channel, status, category,
    title, body, action_url, payload, scheduled_at, dedupe_key, priority
  ) values (
    p_user_id, p_tenant_id, 'in_app', 'pending', p_category,
    p_title, p_body, p_action_url, p_payload, p_scheduled_at, p_dedupe_key, p_priority
  )
  returning id into v_id;

  -- Notify dispatch worker (LISTEN/NOTIFY or edge function webhook)
  perform pg_notify('notification_dispatch', json_build_object(
    'id', v_id,
    'user_id', p_user_id,
    'category', p_category,
    'scheduled_at', p_scheduled_at
  )::text);

  return v_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Appointment triggers
-- ---------------------------------------------------------------------------

create or replace function public.trigger_appointment_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_name text;
  v_reminder_at timestamptz;
begin
  select name into v_provider_name from public.providers where id = NEW.provider_id;

  -- Cancellation
  if tg_op = 'UPDATE'
     and old.status is distinct from new.status
     and new.status = 'cancelled'
     and new.deleted_at is null then
    perform public.enqueue_notification(
      p_user_id := new.patient_id,
      p_tenant_id := new.tenant_id,
      p_category := 'appointment_cancellation',
      p_title := 'Appointment cancelled',
      p_body := coalesce(
        'Your appointment with ' || v_provider_name || ' was cancelled.',
        'Your appointment ' || new.reference_number || ' was cancelled.'
      ),
      p_action_url := '/bookings',
      p_payload := jsonb_build_object(
        'appointmentId', new.id,
        'referenceNumber', new.reference_number,
        'providerId', new.provider_id
      ),
      p_dedupe_key := 'appt_cancel:' || new.id::text,
      p_priority := 2
    );
  end if;

  -- Schedule reminders on new confirmed/pending appointments
  if tg_op = 'INSERT' and new.deleted_at is null
     and new.status in ('pending', 'confirmed') then
    -- 24-hour reminder
    v_reminder_at := new.scheduled_at - interval '24 hours';
    if v_reminder_at > timezone('utc', now()) then
      perform public.enqueue_notification(
        p_user_id := new.patient_id,
        p_tenant_id := new.tenant_id,
        p_category := 'appointment_reminder',
        p_title := 'Appointment tomorrow',
        p_body := 'Reminder: appointment with ' || coalesce(v_provider_name, 'your provider')
          || ' at ' || to_char(new.scheduled_at at time zone 'Africa/Harare', 'Mon DD HH24:MI'),
        p_action_url := '/bookings',
        p_payload := jsonb_build_object(
          'appointmentId', new.id,
          'providerId', new.provider_id,
          'scheduledAt', new.scheduled_at
        ),
        p_scheduled_at := v_reminder_at,
        p_dedupe_key := 'appt_remind_24h:' || new.id::text,
        p_priority := 1
      );
    end if;

    -- 2-hour reminder
    v_reminder_at := new.scheduled_at - interval '2 hours';
    if v_reminder_at > timezone('utc', now()) then
      perform public.enqueue_notification(
        p_user_id := new.patient_id,
        p_tenant_id := new.tenant_id,
        p_category := 'appointment_reminder',
        p_title := 'Appointment in 2 hours',
        p_body := 'Your appointment with ' || coalesce(v_provider_name, 'your provider') || ' starts soon.',
        p_action_url := '/bookings',
        p_payload := jsonb_build_object(
          'appointmentId', new.id,
          'providerId', new.provider_id,
          'scheduledAt', new.scheduled_at
        ),
        p_scheduled_at := v_reminder_at,
        p_dedupe_key := 'appt_remind_2h:' || new.id::text,
        p_priority := 2
      );
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists appointments_notification_trg on public.appointments;
create trigger appointments_notification_trg
  after insert or update of status on public.appointments
  for each row execute function public.trigger_appointment_notification();

-- ---------------------------------------------------------------------------
-- Emergency alert broadcast (insert into activity_logs with action = emergency_alert)
-- ---------------------------------------------------------------------------

create or replace function public.trigger_emergency_alert_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
begin
  if new.action <> 'emergency_alert' or new.tenant_id is null then
    return new;
  end if;

  for r in
    select distinct a.patient_id as user_id
    from public.appointments a
    where a.tenant_id = new.tenant_id
      and a.deleted_at is null
      and a.scheduled_at >= timezone('utc', now()) - interval '90 days'
      and a.status not in ('cancelled')
  loop
    perform public.enqueue_notification(
      p_user_id := r.user_id,
      p_tenant_id := new.tenant_id,
      p_category := 'emergency_alert',
      p_title := coalesce(new.metadata->>'title', 'Emergency alert'),
      p_body := coalesce(new.metadata->>'body', 'Important emergency information from your healthcare facility.'),
      p_action_url := '/emergency',
      p_payload := coalesce(new.metadata, '{}'::jsonb) || jsonb_build_object('activityLogId', new.id),
      p_dedupe_key := 'emergency:' || new.id::text || ':' || r.user_id::text,
      p_priority := 5
    );
  end loop;

  return new;
end;
$$;

drop trigger if exists activity_logs_emergency_alert_trg on public.activity_logs;
create trigger activity_logs_emergency_alert_trg
  after insert on public.activity_logs
  for each row execute function public.trigger_emergency_alert_notification();

-- ---------------------------------------------------------------------------
-- Default notification preferences for new profiles
-- ---------------------------------------------------------------------------

create or replace function public.seed_notification_preferences()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notification_preferences (user_id, tenant_id, channel, category, is_enabled)
  select
    new.id,
    null,
    ch.channel,
    cat.category,
    true
  from (
    values
      ('in_app'::public.notification_channel),
      ('push'::public.notification_channel),
      ('sms'::public.notification_channel),
      ('email'::public.notification_channel)
  ) as ch(channel)
  cross join (
    values
      ('appointment_reminder'),
      ('appointment_cancellation'),
      ('emergency_alert'),
      ('provider_message'),
      ('facility_announcement'),
      ('general')
  ) as cat(category)
  on conflict do nothing;

  return new;
end;
$$;

drop trigger if exists profiles_seed_notification_prefs on public.profiles;
create trigger profiles_seed_notification_prefs
  after insert on public.profiles
  for each row execute function public.seed_notification_preferences();

commit;
