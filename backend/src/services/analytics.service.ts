import { query } from '../lib/db.js';
import { ForbiddenError } from '../lib/errors.js';
import type { AuthenticatedUser } from '../lib/auth.js';
import { assertFacilityAccess } from '../lib/facility-access.js';
import { isSuperAdmin } from '../lib/rbac.js';

export async function refreshAnalyticsAggregates(): Promise<void> {
  await query('SELECT public.refresh_analytics_aggregates()');
}

export async function getPlatformDashboard(_user: AuthenticatedUser) {
  if (!isSuperAdmin(_user)) throw new ForbiddenError('Super admin access required');

  const [summary, dauMau, growth, facilities, retention] = await Promise.all([
    query(`SELECT * FROM public.mv_analytics_platform_summary LIMIT 1`),
    query(
      `SELECT metric_date, dau, wau, mau, total_appointments, total_revenue_net_cents, new_patients
       FROM public.analytics_daily_platform
       WHERE metric_date >= (timezone('utc', now()))::date - 30
       ORDER BY metric_date ASC`,
    ),
    query(
      `SELECT metric_date, new_patients, cumulative_patients
       FROM public.analytics_patient_growth_platform
       WHERE metric_date >= (timezone('utc', now()))::date - 90
       ORDER BY metric_date ASC`,
    ),
    query(
      `SELECT tenant_id, facility_name, appointments_30d, revenue_net_30d_cents,
              new_patients_30d, walk_ins_30d, completed_30d
       FROM public.mv_analytics_facility_summary
       ORDER BY revenue_net_30d_cents DESC NULLS LAST
       LIMIT 50`,
    ),
    query(
      `SELECT tenant_id, cohort_month, period_number, cohort_size, retained_users, retention_rate
       FROM public.analytics_retention_cohorts
       WHERE cohort_month >= date_trunc('month', timezone('utc', now()))::date - interval '6 months'
       ORDER BY cohort_month, period_number`,
    ),
  ]);

  return {
    summary: summary.rows[0] ?? {},
    dauMauTrend: dauMau.rows,
    patientGrowth: growth.rows,
    facilityRankings: facilities.rows,
    retention: retention.rows,
    generatedAt: new Date().toISOString(),
  };
}

export async function getFacilityDashboard(user: AuthenticatedUser, facilityId: string) {
  await assertFacilityAccess(user, facilityId);

  const [summary, daily, growth, providers, retention, revenue] = await Promise.all([
    query(
      `SELECT * FROM public.mv_analytics_facility_summary WHERE tenant_id = $1`,
      [facilityId],
    ),
    query(
      `SELECT metric_date, appointments_total, appointments_completed, appointments_cancelled,
              walk_ins_total, revenue_net_cents, new_patients, returning_patients, unique_patients
       FROM public.analytics_daily_facility
       WHERE tenant_id = $1 AND metric_date >= (timezone('utc', now()))::date - 30
       ORDER BY metric_date ASC`,
      [facilityId],
    ),
    query(
      `SELECT metric_date, new_patients, cumulative_patients
       FROM public.analytics_patient_growth
       WHERE tenant_id = $1 AND metric_date >= (timezone('utc', now()))::date - 90
       ORDER BY metric_date ASC`,
      [facilityId],
    ),
    query(
      `SELECT provider_id, provider_name, appointments_30d, completed_30d, cancelled_30d,
              avg_rating, review_count, completion_rate
       FROM public.mv_analytics_provider_leaderboard
       WHERE tenant_id = $1
       ORDER BY appointments_30d DESC`,
      [facilityId],
    ),
    query(
      `SELECT cohort_month, period_number, cohort_size, retained_users, retention_rate
       FROM public.analytics_retention_cohorts
       WHERE tenant_id = $1
       ORDER BY cohort_month, period_number`,
      [facilityId],
    ),
    query(
      `SELECT report_date, net_revenue_cents, appointment_count, walk_in_count, payment_count
       FROM public.revenue_reports
       WHERE tenant_id = $1 AND period_type = 'daily'
         AND report_date >= (timezone('utc', now()))::date - 30
       ORDER BY report_date ASC`,
      [facilityId],
    ),
  ]);

  return {
    summary: summary.rows[0] ?? {},
    dailyTrend: daily.rows,
    patientGrowth: growth.rows,
    providerPerformance: providers.rows,
    retention: retention.rows,
    revenueTrend: revenue.rows,
    generatedAt: new Date().toISOString(),
  };
}

export async function getProviderDashboard(
  user: AuthenticatedUser,
  providerId: string,
  facilityId?: string,
) {
  const provider = await query<{ facility_id: string; profile_id: string | null; name: string }>(
    `SELECT facility_id, profile_id, name FROM public.providers WHERE id = $1`,
    [providerId],
  );
  if (!provider.rows[0]) throw new ForbiddenError('Provider not found');

  const fid = provider.rows[0].facility_id;
  if (facilityId && facilityId !== fid) throw new ForbiddenError('Provider not in facility');

  if (!isSuperAdmin(user)) {
    if (user.id === provider.rows[0].profile_id) {
      // doctor viewing own stats
    } else {
      await assertFacilityAccess(user, fid);
    }
  }

  const [summary, daily, reviews] = await Promise.all([
    query(
      `SELECT * FROM public.mv_analytics_provider_leaderboard WHERE provider_id = $1`,
      [providerId],
    ),
    query(
      `SELECT metric_date, appointments_total, appointments_completed, appointments_cancelled,
              avg_rating, review_count
       FROM public.analytics_provider_daily
       WHERE provider_id = $1 AND metric_date >= (timezone('utc', now()))::date - 30
       ORDER BY metric_date ASC`,
      [providerId],
    ),
    query(
      `SELECT rating, created_at FROM public.provider_reviews
       WHERE provider_id = $1 ORDER BY created_at DESC LIMIT 20`,
      [providerId],
    ),
  ]);

  return {
    provider: { id: providerId, name: provider.rows[0].name, facilityId: fid },
    summary: summary.rows[0] ?? {},
    dailyTrend: daily.rows,
    recentReviews: reviews.rows,
    generatedAt: new Date().toISOString(),
  };
}

export async function exportAnalyticsCsv(
  user: AuthenticatedUser,
  scope: 'platform' | 'facility' | 'provider',
  type: string,
  opts: { facilityId?: string; providerId?: string },
): Promise<string> {
  if (scope === 'platform') {
    if (!isSuperAdmin(user)) throw new ForbiddenError('Super admin access required');
    const data = await getPlatformDashboard(user);
    if (type === 'facilities') {
      const header = 'facility,appointments_30d,revenue_cents,new_patients\n';
      const body = (data.facilityRankings as Record<string, unknown>[])
        .map((r) => `${r.facility_name},${r.appointments_30d},${r.revenue_net_30d_cents},${r.new_patients_30d}`)
        .join('\n');
      return header + body;
    }
    const header = 'date,dau,mau,appointments,revenue_cents,new_patients\n';
    const body = (data.dauMauTrend as Record<string, unknown>[])
      .map((r) => `${r.metric_date},${r.dau},${r.mau},${r.total_appointments},${r.total_revenue_net_cents},${r.new_patients}`)
      .join('\n');
    return header + body;
  }

  if (scope === 'facility') {
    if (!opts.facilityId) throw new ForbiddenError('facilityId required');
    const data = await getFacilityDashboard(user, opts.facilityId);
    if (type === 'providers') {
      const header = 'provider,appointments,completed,cancelled,rating,completion_rate\n';
      const body = (data.providerPerformance as Record<string, unknown>[])
        .map((r) => `${r.provider_name},${r.appointments_30d},${r.completed_30d},${r.cancelled_30d},${r.avg_rating},${r.completion_rate}`)
        .join('\n');
      return header + body;
    }
    const header = 'date,appointments,completed,cancelled,revenue_cents,new_patients\n';
    const body = (data.dailyTrend as Record<string, unknown>[])
      .map((r) => `${r.metric_date},${r.appointments_total},${r.appointments_completed},${r.appointments_cancelled},${r.revenue_net_cents},${r.new_patients}`)
      .join('\n');
    return header + body;
  }

  if (!opts.providerId) throw new ForbiddenError('providerId required');
  const data = await getProviderDashboard(user, opts.providerId, opts.facilityId);
  const header = 'date,appointments,completed,cancelled,rating,reviews\n';
  const body = (data.dailyTrend as Record<string, unknown>[])
    .map((r) => `${r.metric_date},${r.appointments_total},${r.appointments_completed},${r.appointments_cancelled},${r.avg_rating},${r.review_count}`)
    .join('\n');
  return header + body;
}
