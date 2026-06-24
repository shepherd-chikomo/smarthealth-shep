# SmartHealth Analytics Infrastructure

Pre-aggregated analytics using PostgreSQL tables, materialized views, and a scheduled backend worker.

## Data layers

| Layer | Purpose |
|-------|---------|
| **Source tables** | `appointments`, `walk_in_sessions`, `payments`, `activity_logs`, `profiles` |
| **Aggregation tables** | `analytics_daily_facility`, `analytics_daily_platform`, `analytics_provider_daily`, `analytics_patient_growth`, `analytics_retention_cohorts` |
| **Materialized views** | `mv_analytics_facility_summary`, `mv_analytics_platform_summary`, `mv_analytics_provider_leaderboard` |
| **Legacy sync** | `revenue_reports`, `usage_metrics` updated during refresh |

## Metrics

- **Revenue** — gross/net cents, payments, refunds per facility/day
- **Appointments** — total, completed, cancelled, pending
- **Facility** — walk-ins, unique/returning patients, active providers
- **DAU/WAU/MAU** — from `activity_logs` (platform daily)
- **Retention** — monthly cohorts with period-over-period rates
- **Patient growth** — new + cumulative patients
- **Provider performance** — appointments, ratings, completion rate

## Refresh schedule

```sql
SELECT public.refresh_analytics_aggregates();
```

Backend worker runs every hour (`ANALYTICS_REFRESH_INTERVAL_MS=3600000`).

Manual trigger:

```bash
curl -X POST http://localhost:3000/v1/analytics/refresh \
  -H "Authorization: Bearer $SUPER_ADMIN_JWT"
```

## API dashboards

| Audience | Endpoint | Export |
|----------|----------|--------|
| Super admin | `GET /v1/analytics/platform` | `GET /v1/analytics/platform/export?type=dau\|facilities` |
| Facility admin | `GET /v1/analytics/facility?facilityId=` | `GET /v1/analytics/facility/export?facilityId=&type=daily\|providers` |
| Provider | `GET /v1/analytics/provider?providerId=` | `GET /v1/analytics/provider/export?providerId=` |

## UI dashboards

- **Super admin** — `admin/` → Analytics (reads materialized views)
- **Facility admin** — `apps/facility-portal/` → Analytics
- **Provider** — `apps/facility-portal/` → My Performance

## Performance

Dashboard queries read from materialized views and pre-aggregated daily tables — no full-table scans on `appointments` at request time. Refresh runs off-peak via worker.

## Migration

`supabase/migrations/20260523120400_analytics_infrastructure.sql`

After deploy, run one refresh:

```sql
SELECT public.refresh_analytics_aggregates();
```
