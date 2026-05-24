-- SmartHealth: analytics infrastructure — aggregation tables, materialized views, refresh jobs

begin;

-- ---------------------------------------------------------------------------
-- Daily facility aggregates
-- ---------------------------------------------------------------------------

create table public.analytics_daily_facility (
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  metric_date date not null,
  appointments_total int not null default 0,
  appointments_completed int not null default 0,
  appointments_cancelled int not null default 0,
  appointments_pending int not null default 0,
  walk_ins_total int not null default 0,
  revenue_gross_cents bigint not null default 0,
  revenue_net_cents bigint not null default 0,
  payments_count int not null default 0,
  refunds_cents bigint not null default 0,
  new_patients int not null default 0,
  returning_patients int not null default 0,
  unique_patients int not null default 0,
  active_providers int not null default 0,
  generated_at timestamptz not null default timezone('utc', now()),
  primary key (tenant_id, metric_date)
);

create index analytics_daily_facility_date_idx
  on public.analytics_daily_facility (metric_date desc);

-- ---------------------------------------------------------------------------
-- Daily platform aggregates
-- ---------------------------------------------------------------------------

create table public.analytics_daily_platform (
  metric_date date primary key,
  dau int not null default 0,
  wau int not null default 0,
  mau int not null default 0,
  total_appointments int not null default 0,
  total_walk_ins int not null default 0,
  total_revenue_net_cents bigint not null default 0,
  active_facilities int not null default 0,
  new_patients int not null default 0,
  new_facilities int not null default 0,
  total_providers int not null default 0,
  generated_at timestamptz not null default timezone('utc', now())
);

-- ---------------------------------------------------------------------------
-- Provider daily performance
-- ---------------------------------------------------------------------------

create table public.analytics_provider_daily (
  provider_id uuid not null references public.providers (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  metric_date date not null,
  appointments_total int not null default 0,
  appointments_completed int not null default 0,
  appointments_cancelled int not null default 0,
  avg_rating numeric(4, 2),
  review_count int not null default 0,
  revenue_net_cents bigint not null default 0,
  generated_at timestamptz not null default timezone('utc', now()),
  primary key (provider_id, metric_date)
);

create index analytics_provider_daily_tenant_date_idx
  on public.analytics_provider_daily (tenant_id, metric_date desc);

-- ---------------------------------------------------------------------------
-- Patient growth (daily new + cumulative per tenant)
-- ---------------------------------------------------------------------------

create table public.analytics_patient_growth (
  tenant_id uuid references public.facilities (id) on delete cascade,
  metric_date date not null,
  new_patients int not null default 0,
  cumulative_patients bigint not null default 0,
  generated_at timestamptz not null default timezone('utc', now()),
  primary key (tenant_id, metric_date)
);

create table public.analytics_patient_growth_platform (
  metric_date date primary key,
  new_patients int not null default 0,
  cumulative_patients bigint not null default 0,
  generated_at timestamptz not null default timezone('utc', now())
);

-- ---------------------------------------------------------------------------
-- Retention cohorts (monthly)
-- ---------------------------------------------------------------------------

create table public.analytics_retention_cohorts (
  tenant_id uuid references public.facilities (id) on delete cascade,
  cohort_month date not null,
  period_number int not null check (period_number >= 0),
  cohort_size int not null default 0,
  retained_users int not null default 0,
  retention_rate numeric(6, 4) not null default 0,
  generated_at timestamptz not null default timezone('utc', now()),
  primary key (tenant_id, cohort_month, period_number)
);

create index analytics_retention_cohorts_tenant_idx
  on public.analytics_retention_cohorts (tenant_id, cohort_month);

-- ---------------------------------------------------------------------------
-- Refresh: populate aggregation tables for a single date
-- ---------------------------------------------------------------------------

create or replace function public.refresh_analytics_for_date(p_date date default (timezone('utc', now()))::date - 1)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Facility daily metrics
  insert into public.analytics_daily_facility (
    tenant_id, metric_date,
    appointments_total, appointments_completed, appointments_cancelled, appointments_pending,
    walk_ins_total, revenue_gross_cents, revenue_net_cents, payments_count, refunds_cents,
    new_patients, returning_patients, unique_patients, active_providers, generated_at
  )
  select
    f.id,
    p_date,
    coalesce(a.total, 0),
    coalesce(a.completed, 0),
    coalesce(a.cancelled, 0),
    coalesce(a.pending, 0),
    coalesce(w.walk_ins, 0),
    coalesce(rev.gross, 0),
    coalesce(rev.net, 0),
    coalesce(rev.payments, 0),
    coalesce(rev.refunds, 0),
    coalesce(pg.new_pts, 0),
    coalesce(pg.returning_pts, 0),
    coalesce(pg.unique_pts, 0),
    coalesce(pr.active_providers, 0),
    timezone('utc', now())
  from public.facilities f
  left join lateral (
    select
      count(*)::int as total,
      count(*) filter (where status = 'completed')::int as completed,
      count(*) filter (where status = 'cancelled')::int as cancelled,
      count(*) filter (where status in ('pending', 'confirmed'))::int as pending
    from public.appointments ap
    where ap.tenant_id = f.id
      and ap.deleted_at is null
      and ap.scheduled_at::date = p_date
  ) a on true
  left join lateral (
    select count(*)::int as walk_ins
    from public.walk_in_sessions wi
    where wi.tenant_id = f.id
      and wi.deleted_at is null
      and wi.registered_at::date = p_date
  ) w on true
  left join lateral (
    select
      coalesce(sum(gross_revenue_cents), 0)::bigint as gross,
      coalesce(sum(net_revenue_cents), 0)::bigint as net,
      coalesce(sum(payment_count), 0)::int as payments,
      coalesce(sum(refunds_cents), 0)::bigint as refunds
    from public.revenue_reports rr
    where rr.tenant_id = f.id and rr.report_date = p_date and rr.period_type = 'daily'
  ) rev on true
  left join lateral (
    select
      count(distinct ap.patient_id) filter (
        where not exists (
          select 1 from public.appointments ap2
          where ap2.patient_id = ap.patient_id
            and ap2.tenant_id = f.id
            and ap2.deleted_at is null
            and ap2.scheduled_at::date < p_date
        )
      )::int as new_pts,
      count(distinct ap.patient_id) filter (
        where exists (
          select 1 from public.appointments ap2
          where ap2.patient_id = ap.patient_id
            and ap2.tenant_id = f.id
            and ap2.deleted_at is null
            and ap2.scheduled_at::date < p_date
        )
      )::int as returning_pts,
      count(distinct ap.patient_id)::int as unique_pts
    from public.appointments ap
    where ap.tenant_id = f.id and ap.deleted_at is null and ap.scheduled_at::date = p_date
  ) pg on true
  left join lateral (
    select count(*)::int as active_providers
    from public.providers pr
    where pr.facility_id = f.id and pr.is_active = true
  ) pr on true
  where f.deleted_at is null and f.is_active = true
  on conflict (tenant_id, metric_date) do update set
    appointments_total = excluded.appointments_total,
    appointments_completed = excluded.appointments_completed,
    appointments_cancelled = excluded.appointments_cancelled,
    appointments_pending = excluded.appointments_pending,
    walk_ins_total = excluded.walk_ins_total,
    revenue_gross_cents = excluded.revenue_gross_cents,
    revenue_net_cents = excluded.revenue_net_cents,
    payments_count = excluded.payments_count,
    refunds_cents = excluded.refunds_cents,
    new_patients = excluded.new_patients,
    returning_patients = excluded.returning_patients,
    unique_patients = excluded.unique_patients,
    active_providers = excluded.active_providers,
    generated_at = excluded.generated_at;

  -- Provider daily metrics
  insert into public.analytics_provider_daily (
    provider_id, tenant_id, metric_date,
    appointments_total, appointments_completed, appointments_cancelled,
    avg_rating, review_count, revenue_net_cents, generated_at
  )
  select
    p.id,
    p.facility_id,
    p_date,
    coalesce(a.total, 0),
    coalesce(a.completed, 0),
    coalesce(a.cancelled, 0),
    coalesce(r.avg_rating, 0),
    coalesce(r.review_count, 0),
    0,
    timezone('utc', now())
  from public.providers p
  left join lateral (
    select
      count(*)::int as total,
      count(*) filter (where ap.status = 'completed')::int as completed,
      count(*) filter (where ap.status = 'cancelled')::int as cancelled
    from public.appointments ap
    where ap.provider_id = p.id
      and ap.deleted_at is null
      and ap.scheduled_at::date = p_date
  ) a on true
  left join lateral (
    select avg(rv.rating)::numeric(4,2) as avg_rating, count(*)::int as review_count
    from public.provider_reviews rv
    where rv.provider_id = p.id and rv.created_at::date <= p_date
  ) r on true
  where p.is_active = true
  on conflict (provider_id, metric_date) do update set
    appointments_total = excluded.appointments_total,
    appointments_completed = excluded.appointments_completed,
    appointments_cancelled = excluded.appointments_cancelled,
    avg_rating = excluded.avg_rating,
    review_count = excluded.review_count,
    generated_at = excluded.generated_at;

  -- Patient growth per facility
  insert into public.analytics_patient_growth (tenant_id, metric_date, new_patients, cumulative_patients, generated_at)
  select
    adf.tenant_id,
    p_date,
    adf.new_patients,
    (
      select count(distinct ap.patient_id)
      from public.appointments ap
      where ap.tenant_id = adf.tenant_id
        and ap.deleted_at is null
        and ap.scheduled_at::date <= p_date
    ),
    timezone('utc', now())
  from public.analytics_daily_facility adf
  where adf.metric_date = p_date
  on conflict (tenant_id, metric_date) do update set
    new_patients = excluded.new_patients,
    cumulative_patients = excluded.cumulative_patients,
    generated_at = excluded.generated_at;

  -- Platform daily (DAU/WAU/MAU from activity_logs + appointments)
  insert into public.analytics_daily_platform (
    metric_date, dau, wau, mau,
    total_appointments, total_walk_ins, total_revenue_net_cents,
    active_facilities, new_patients, new_facilities, total_providers, generated_at
  )
  select
    p_date,
    (select count(distinct user_id) from public.activity_logs
     where user_id is not null and created_at::date = p_date),
    (select count(distinct user_id) from public.activity_logs
     where user_id is not null and created_at::date between p_date - 6 and p_date),
    (select count(distinct user_id) from public.activity_logs
     where user_id is not null and created_at::date between p_date - 29 and p_date),
    coalesce((select sum(appointments_total) from public.analytics_daily_facility where metric_date = p_date), 0),
    coalesce((select sum(walk_ins_total) from public.analytics_daily_facility where metric_date = p_date), 0),
    coalesce((select sum(revenue_net_cents) from public.analytics_daily_facility where metric_date = p_date), 0),
    (select count(*) from public.facilities where is_active = true and deleted_at is null),
    coalesce((select sum(new_patients) from public.analytics_daily_facility where metric_date = p_date), 0),
    (select count(*) from public.facilities where created_at::date = p_date),
    (select count(*) from public.providers where is_active = true),
    timezone('utc', now())
  on conflict (metric_date) do update set
    dau = excluded.dau,
    wau = excluded.wau,
    mau = excluded.mau,
    total_appointments = excluded.total_appointments,
    total_walk_ins = excluded.total_walk_ins,
    total_revenue_net_cents = excluded.total_revenue_net_cents,
    active_facilities = excluded.active_facilities,
    new_patients = excluded.new_patients,
    new_facilities = excluded.new_facilities,
    total_providers = excluded.total_providers,
    generated_at = excluded.generated_at;

  -- Platform patient growth
  insert into public.analytics_patient_growth_platform (metric_date, new_patients, cumulative_patients, generated_at)
  select
    p_date,
    coalesce((select sum(new_patients) from public.analytics_daily_facility where metric_date = p_date), 0),
    (select count(distinct id) from public.profiles where primary_role = 'patient'),
    timezone('utc', now())
  on conflict (metric_date) do update set
    new_patients = excluded.new_patients,
    cumulative_patients = excluded.cumulative_patients,
    generated_at = excluded.generated_at;

  -- Sync revenue_reports from facility aggregates when missing
  insert into public.revenue_reports (
    tenant_id, report_date, period_type, gross_revenue_cents, net_revenue_cents,
    refunds_cents, appointment_count, walk_in_count, payment_count
  )
  select
    tenant_id, metric_date, 'daily', revenue_gross_cents, revenue_net_cents,
    refunds_cents, appointments_total, walk_ins_total, payments_count
  from public.analytics_daily_facility adf
  where adf.metric_date = p_date
    and not exists (
      select 1 from public.revenue_reports rr
      where rr.tenant_id = adf.tenant_id and rr.report_date = p_date and rr.period_type = 'daily'
    )
  on conflict do nothing;

  -- Usage metrics mirror for backward compatibility
  insert into public.usage_metrics (tenant_id, metric_date, metric_key, metric_value, dimensions)
  select tenant_id, metric_date, 'appointments_total', appointments_total, '{}'::jsonb
  from public.analytics_daily_facility where metric_date = p_date
  on conflict (tenant_id, metric_date, metric_key, dimensions) do update
    set metric_value = excluded.metric_value;

  insert into public.usage_metrics (tenant_id, metric_date, metric_key, metric_value, dimensions)
  select null, metric_date, 'platform_dau', dau, '{}'::jsonb
  from public.analytics_daily_platform where metric_date = p_date
  on conflict (tenant_id, metric_date, metric_key, dimensions) do update
    set metric_value = excluded.metric_value;

  insert into public.usage_metrics (tenant_id, metric_date, metric_key, metric_value, dimensions)
  select null, metric_date, 'platform_mau', mau, '{}'::jsonb
  from public.analytics_daily_platform where metric_date = p_date
  on conflict (tenant_id, metric_date, metric_key, dimensions) do update
    set metric_value = excluded.metric_value;
end;
$$;

-- Retention cohort refresh (last 6 cohort months)
create or replace function public.refresh_analytics_retention(p_tenant_id uuid default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_facility uuid;
  v_cohort date;
  v_period int;
begin
  for v_facility in
    select id from public.facilities
    where deleted_at is null and is_active = true
      and (p_tenant_id is null or id = p_tenant_id)
  loop
    for v_cohort in
      select date_trunc('month', d)::date
      from generate_series(
        date_trunc('month', timezone('utc', now()))::date - interval '5 months',
        date_trunc('month', timezone('utc', now()))::date,
        interval '1 month'
      ) as d
    loop
      for v_period in 0..5 loop
        insert into public.analytics_retention_cohorts (
          tenant_id, cohort_month, period_number, cohort_size, retained_users, retention_rate, generated_at
        )
        select
          v_facility,
          v_cohort,
          v_period,
          cohort.cohort_size,
          retained.retained_users,
          case when cohort.cohort_size > 0
            then round(retained.retained_users::numeric / cohort.cohort_size, 4)
            else 0 end,
          timezone('utc', now())
        from (
          select count(distinct ap.patient_id)::int as cohort_size
          from public.appointments ap
          where ap.tenant_id = v_facility
            and ap.deleted_at is null
            and date_trunc('month', ap.scheduled_at)::date = v_cohort
        ) cohort
        cross join (
          select count(distinct ap.patient_id)::int as retained_users
          from public.appointments ap
          where ap.tenant_id = v_facility
            and ap.deleted_at is null
            and ap.patient_id in (
              select ap2.patient_id from public.appointments ap2
              where ap2.tenant_id = v_facility
                and ap2.deleted_at is null
                and date_trunc('month', ap2.scheduled_at)::date = v_cohort
            )
            and date_trunc('month', ap.scheduled_at)::date =
              (v_cohort + (v_period || ' months')::interval)::date
        ) retained
        where cohort.cohort_size > 0
        on conflict (tenant_id, cohort_month, period_number) do update set
          cohort_size = excluded.cohort_size,
          retained_users = excluded.retained_users,
          retention_rate = excluded.retention_rate,
          generated_at = excluded.generated_at;
      end loop;
    end loop;
  end loop;
end;
$$;

-- Master refresh (yesterday + retention + materialized views)
create or replace function public.refresh_analytics_aggregates()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.refresh_analytics_for_date((timezone('utc', now()))::date);
  perform public.refresh_analytics_for_date((timezone('utc', now()))::date - 1);
  perform public.refresh_analytics_retention(null);
  perform public.refresh_analytics_materialized_views();
end;
$$;

-- ---------------------------------------------------------------------------
-- Materialized views (fast dashboard reads)
-- ---------------------------------------------------------------------------

create materialized view public.mv_analytics_facility_summary as
select
  adf.tenant_id,
  f.name as facility_name,
  sum(adf.appointments_total)::int as appointments_30d,
  sum(adf.appointments_completed)::int as completed_30d,
  sum(adf.appointments_cancelled)::int as cancelled_30d,
  sum(adf.walk_ins_total)::int as walk_ins_30d,
  sum(adf.revenue_net_cents)::bigint as revenue_net_30d_cents,
  sum(adf.new_patients)::int as new_patients_30d,
  avg(adf.unique_patients)::numeric(10,2) as avg_daily_patients,
  max(adf.metric_date) as last_metric_date
from public.analytics_daily_facility adf
join public.facilities f on f.id = adf.tenant_id
where adf.metric_date >= (timezone('utc', now()))::date - 30
group by adf.tenant_id, f.name;

create unique index mv_analytics_facility_summary_pk
  on public.mv_analytics_facility_summary (tenant_id);

create materialized view public.mv_analytics_platform_summary as
select
  coalesce(sum(total_appointments), 0)::int as appointments_30d,
  coalesce(sum(total_revenue_net_cents), 0)::bigint as revenue_net_30d_cents,
  coalesce(avg(dau), 0)::numeric(10,2) as avg_dau,
  coalesce(max(mau), 0)::int as latest_mau,
  coalesce(sum(new_patients), 0)::int as new_patients_30d,
  coalesce(max(active_facilities), 0)::int as active_facilities,
  coalesce(max(total_providers), 0)::int as total_providers,
  max(metric_date) as last_metric_date
from public.analytics_daily_platform
where metric_date >= (timezone('utc', now()))::date - 30;

create materialized view public.mv_analytics_provider_leaderboard as
select
  apd.provider_id,
  apd.tenant_id,
  p.name as provider_name,
  sum(apd.appointments_total)::int as appointments_30d,
  sum(apd.appointments_completed)::int as completed_30d,
  sum(apd.appointments_cancelled)::int as cancelled_30d,
  max(apd.avg_rating)::numeric(4,2) as avg_rating,
  max(apd.review_count)::int as review_count,
  case when sum(apd.appointments_total) > 0
    then round(sum(apd.appointments_completed)::numeric / sum(apd.appointments_total), 4)
    else 0 end as completion_rate
from public.analytics_provider_daily apd
join public.providers p on p.id = apd.provider_id
where apd.metric_date >= (timezone('utc', now()))::date - 30
group by apd.provider_id, apd.tenant_id, p.name;

create unique index mv_analytics_provider_leaderboard_pk
  on public.mv_analytics_provider_leaderboard (provider_id);

create or replace function public.refresh_analytics_materialized_views()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  refresh materialized view concurrently public.mv_analytics_facility_summary;
  refresh materialized view concurrently public.mv_analytics_platform_summary;
  refresh materialized view concurrently public.mv_analytics_provider_leaderboard;
exception
  when others then
    refresh materialized view public.mv_analytics_facility_summary;
    refresh materialized view public.mv_analytics_platform_summary;
    refresh materialized view public.mv_analytics_provider_leaderboard;
end;
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.analytics_daily_facility enable row level security;
alter table public.analytics_daily_platform enable row level security;
alter table public.analytics_provider_daily enable row level security;
alter table public.analytics_patient_growth enable row level security;
alter table public.analytics_patient_growth_platform enable row level security;
alter table public.analytics_retention_cohorts enable row level security;

create policy analytics_facility_staff_select on public.analytics_daily_facility
  for select to authenticated
  using (
    public.is_super_admin()
    or public.is_facility_staff(tenant_id)
  );

create policy analytics_platform_super_admin on public.analytics_daily_platform
  for select to authenticated
  using (public.is_super_admin());

create policy analytics_provider_staff_select on public.analytics_provider_daily
  for select to authenticated
  using (
    public.is_super_admin()
    or public.is_facility_staff(tenant_id)
  );

create policy analytics_patient_growth_select on public.analytics_patient_growth
  for select to authenticated
  using (
    public.is_super_admin()
    or (tenant_id is not null and public.is_facility_staff(tenant_id))
  );

create policy analytics_patient_growth_platform_select on public.analytics_patient_growth_platform
  for select to authenticated
  using (public.is_super_admin());

create policy analytics_retention_select on public.analytics_retention_cohorts
  for select to authenticated
  using (
    public.is_super_admin()
    or (tenant_id is not null and public.is_facility_staff(tenant_id))
  );

commit;
