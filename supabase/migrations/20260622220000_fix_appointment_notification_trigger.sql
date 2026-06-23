-- Fix appointment notification trigger: cast string literals to enum/smallint
-- so named-argument calls to enqueue_notification resolve correctly.

begin;

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

  if tg_op = 'UPDATE'
     and old.status is distinct from new.status
     and new.status = 'cancelled'
     and new.deleted_at is null then
    perform public.enqueue_notification(
      p_user_id := new.patient_id,
      p_tenant_id := new.tenant_id,
      p_category := 'appointment_cancellation'::public.notification_category,
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
      p_priority := 2::smallint
    );
  end if;

  if tg_op = 'INSERT' and new.deleted_at is null
     and new.status in ('pending', 'confirmed') then
    v_reminder_at := new.scheduled_at - interval '24 hours';
    if v_reminder_at > timezone('utc', now()) then
      perform public.enqueue_notification(
        p_user_id := new.patient_id,
        p_tenant_id := new.tenant_id,
        p_category := 'appointment_reminder'::public.notification_category,
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
        p_priority := 1::smallint
      );
    end if;

    v_reminder_at := new.scheduled_at - interval '2 hours';
    if v_reminder_at > timezone('utc', now()) then
      perform public.enqueue_notification(
        p_user_id := new.patient_id,
        p_tenant_id := new.tenant_id,
        p_category := 'appointment_reminder'::public.notification_category,
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
        p_priority := 2::smallint
      );
    end if;
  end if;

  return new;
end;
$$;

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
      p_category := 'emergency_alert'::public.notification_category,
      p_title := coalesce(new.metadata->>'title', 'Emergency alert'),
      p_body := coalesce(new.metadata->>'body', 'Important emergency information from your healthcare facility.'),
      p_action_url := '/emergency',
      p_payload := coalesce(new.metadata, '{}'::jsonb) || jsonb_build_object('activityLogId', new.id),
      p_dedupe_key := 'emergency:' || new.id::text || ':' || r.user_id::text,
      p_priority := 5::smallint
    );
  end loop;

  return new;
end;
$$;

commit;
