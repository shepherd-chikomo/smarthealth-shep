-- SmartHealth: notifications (push, SMS, email)

begin;

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.facilities (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  channel public.notification_channel not null default 'in_app',
  status public.notification_status not null default 'pending',
  title text not null,
  body text not null,
  action_url text,
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  sent_at timestamptz,
  failed_at timestamptz,
  failure_reason text,
  created_at timestamptz not null default timezone('utc', now())
);

create index notifications_user_unread_idx
  on public.notifications (user_id, created_at desc)
  where read_at is null;
create index notifications_tenant_idx on public.notifications (tenant_id);
create index notifications_status_idx on public.notifications (status) where status in ('pending', 'queued');

create table public.push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('ios', 'android', 'web')),
  device_id text,
  app_version text,
  is_active boolean not null default true,
  last_used_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, token)
);

create index push_tokens_user_active_idx
  on public.push_tokens (user_id)
  where is_active = true;

create trigger push_tokens_set_updated_at
  before update on public.push_tokens
  for each row execute function public.set_updated_at();

create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  tenant_id uuid references public.facilities (id) on delete cascade,
  channel public.notification_channel not null,
  category text not null default 'general',
  is_enabled boolean not null default true,
  quiet_hours_start time,
  quiet_hours_end time,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, tenant_id, channel, category)
);

create index notification_preferences_user_idx
  on public.notification_preferences (user_id);

create trigger notification_preferences_set_updated_at
  before update on public.notification_preferences
  for each row execute function public.set_updated_at();

create table public.sms_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.facilities (id) on delete set null,
  user_id uuid references public.profiles (id) on delete set null,
  notification_id uuid references public.notifications (id) on delete set null,
  phone text not null,
  message text not null,
  provider text,
  provider_message_id text,
  status public.notification_status not null default 'pending',
  cost_cents int,
  sent_at timestamptz,
  delivered_at timestamptz,
  error_message text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index sms_logs_tenant_created_idx on public.sms_logs (tenant_id, created_at desc);
create index sms_logs_phone_idx on public.sms_logs (phone);
create index sms_logs_status_idx on public.sms_logs (status) where status in ('pending', 'queued');

create table public.email_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.facilities (id) on delete set null,
  user_id uuid references public.profiles (id) on delete set null,
  notification_id uuid references public.notifications (id) on delete set null,
  email text not null,
  subject text not null,
  template_key text,
  provider text,
  provider_message_id text,
  status public.notification_status not null default 'pending',
  sent_at timestamptz,
  delivered_at timestamptz,
  opened_at timestamptz,
  error_message text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index email_logs_tenant_created_idx on public.email_logs (tenant_id, created_at desc);
create index email_logs_email_idx on public.email_logs (email);
create index email_logs_status_idx on public.email_logs (status) where status in ('pending', 'queued');

commit;
