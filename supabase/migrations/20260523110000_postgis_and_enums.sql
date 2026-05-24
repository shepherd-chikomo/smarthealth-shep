-- SmartHealth: PostGIS, extended enums, shared infrastructure

begin;

create extension if not exists postgis with schema extensions;

-- ---------------------------------------------------------------------------
-- Lifecycle & workflow enums
-- ---------------------------------------------------------------------------

create type public.verification_status as enum (
  'draft',
  'pending_review',
  'verified',
  'rejected',
  'suspended'
);

create type public.moderation_status as enum (
  'pending',
  'approved',
  'rejected',
  'flagged',
  'hidden'
);

create type public.claim_status as enum (
  'draft',
  'submitted',
  'under_review',
  'approved',
  'rejected',
  'withdrawn'
);

create type public.queue_status as enum (
  'waiting',
  'called',
  'in_service',
  'completed',
  'cancelled',
  'no_show'
);

create type public.walk_in_status as enum (
  'registered',
  'waiting',
  'called',
  'in_consultation',
  'completed',
  'cancelled',
  'no_show'
);

create type public.payment_status as enum (
  'pending',
  'processing',
  'completed',
  'failed',
  'refunded',
  'cancelled'
);

create type public.payment_method as enum (
  'cash',
  'mobile_money',
  'card',
  'bank_transfer',
  'insurance',
  'other'
);

create type public.invoice_status as enum (
  'draft',
  'sent',
  'partial',
  'paid',
  'overdue',
  'cancelled',
  'void'
);

create type public.refund_status as enum (
  'pending',
  'processing',
  'completed',
  'failed',
  'cancelled'
);

create type public.stock_movement_type as enum (
  'purchase',
  'sale',
  'adjustment',
  'transfer_in',
  'transfer_out',
  'expired',
  'damaged',
  'returned'
);

create type public.notification_channel as enum (
  'in_app',
  'push',
  'sms',
  'email'
);

create type public.notification_status as enum (
  'pending',
  'queued',
  'sent',
  'delivered',
  'failed',
  'read'
);

create type public.consultation_status as enum (
  'scheduled',
  'in_progress',
  'completed',
  'cancelled',
  'no_show'
);

create type public.diagnosis_certainty as enum (
  'confirmed',
  'provisional',
  'differential',
  'ruled_out'
);

create type public.allergy_severity as enum (
  'mild',
  'moderate',
  'severe',
  'life_threatening'
);

create type public.chronic_condition_status as enum (
  'active',
  'in_remission',
  'resolved',
  'monitoring'
);

create type public.lab_result_status as enum (
  'ordered',
  'sample_collected',
  'processing',
  'completed',
  'cancelled',
  'abnormal'
);

create type public.purchase_order_status as enum (
  'draft',
  'submitted',
  'approved',
  'ordered',
  'partial_received',
  'received',
  'cancelled'
);

create type public.emergency_service_type as enum (
  'ambulance',
  'fire',
  'police',
  'hospital_er',
  'poison_control',
  'mental_health_crisis',
  'disaster_response',
  'other'
);

-- ---------------------------------------------------------------------------
-- Shared column helpers
-- ---------------------------------------------------------------------------

create or replace function public.sync_location_from_coords()
returns trigger
language plpgsql
as $$
begin
  if new.latitude is not null and new.longitude is not null then
    new.location := extensions.st_setsrid(
      extensions.st_makepoint(new.longitude, new.latitude),
      4326
    )::extensions.geography;
  else
    new.location := null;
  end if;
  return new;
end;
$$;

create or replace function public.build_weighted_search_vector(variadic texts text[])
returns tsvector
language sql
immutable
as $$
  select coalesce(
    setweight(to_tsvector('english', coalesce(texts[1], '')), 'A') ||
    setweight(to_tsvector('english', coalesce(texts[2], '')), 'B') ||
    setweight(to_tsvector('english', coalesce(texts[3], '')), 'C') ||
    setweight(to_tsvector('english', coalesce(texts[4], '')), 'D'),
    ''::tsvector
  );
$$;

create or replace function public.is_not_soft_deleted(deleted_at timestamptz)
returns boolean
language sql
immutable
as $$
  select deleted_at is null;
$$;

commit;
