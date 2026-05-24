import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, StatCard } from '../components/ui';

function fmtCents(cents: unknown) {
  return `$${((Number(cents) || 0) / 100).toFixed(0)}`;
}

export function AnalyticsPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['platform-analytics'],
    queryFn: () => api.platformAnalytics(),
    staleTime: 60_000,
  });

  const dash = data?.dashboard as Record<string, unknown> | undefined;
  const summary = dash?.summary as Record<string, unknown> | undefined;

  async function download(type: 'dau' | 'facilities') {
    const csv = await api.exportPlatformAnalytics(type);
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `platform-${type}.csv`;
    a.click();
  }

  return (
    <div>
      <PageHeader
        title="Analytics"
        description="Platform-wide revenue, appointments, DAU/MAU, retention, and patient growth"
        actions={
          <>
            <button type="button" className="btn-secondary" onClick={() => download('dau')}>Export DAU/MAU CSV</button>
            <button type="button" className="btn-secondary" onClick={() => download('facilities')}>Export facilities CSV</button>
          </>
        }
      />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {summary && (
        <>
          <div className="mb-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard label="Appointments (30d)" value={String(summary.appointments_30d ?? 0)} />
            <StatCard label="Revenue (30d)" value={fmtCents(summary.revenue_net_30d_cents)} />
            <StatCard label="Avg DAU" value={String(Number(summary.avg_dau ?? 0).toFixed(0))} />
            <StatCard label="Latest MAU" value={String(summary.latest_mau ?? 0)} />
            <StatCard label="New patients (30d)" value={String(summary.new_patients_30d ?? 0)} />
            <StatCard label="Active facilities" value={String(summary.active_facilities ?? 0)} />
            <StatCard label="Total providers" value={String(summary.total_providers ?? 0)} />
          </div>

          <h2 className="mb-2 font-semibold">DAU / MAU trend</h2>
          <div className="table-wrap mb-6">
            <table className="data-table">
              <thead><tr><th>Date</th><th>DAU</th><th>WAU</th><th>MAU</th><th>Appointments</th><th>Revenue</th></tr></thead>
              <tbody>
                {((dash?.dauMauTrend as Record<string, unknown>[]) ?? []).slice(-14).map((r) => (
                  <tr key={String(r.metric_date)}>
                    <td>{String(r.metric_date)}</td>
                    <td>{String(r.dau)}</td>
                    <td>{String(r.wau)}</td>
                    <td>{String(r.mau)}</td>
                    <td>{String(r.total_appointments)}</td>
                    <td>{fmtCents(r.total_revenue_net_cents)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <h2 className="mb-2 font-semibold">Facility rankings (30d)</h2>
          <div className="table-wrap mb-6">
            <table className="data-table">
              <thead><tr><th>Facility</th><th>Appointments</th><th>Revenue</th><th>New patients</th><th>Walk-ins</th></tr></thead>
              <tbody>
                {((dash?.facilityRankings as Record<string, unknown>[]) ?? []).map((r) => (
                  <tr key={String(r.tenant_id)}>
                    <td>{String(r.facility_name)}</td>
                    <td>{String(r.appointments_30d)}</td>
                    <td>{fmtCents(r.revenue_net_30d_cents)}</td>
                    <td>{String(r.new_patients_30d)}</td>
                    <td>{String(r.walk_ins_30d)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <h2 className="mb-2 font-semibold">Patient growth</h2>
          <div className="table-wrap mb-6">
            <table className="data-table">
              <thead><tr><th>Date</th><th>New</th><th>Cumulative</th></tr></thead>
              <tbody>
                {((dash?.patientGrowth as Record<string, unknown>[]) ?? []).slice(-14).map((r) => (
                  <tr key={String(r.metric_date)}>
                    <td>{String(r.metric_date)}</td>
                    <td>{String(r.new_patients)}</td>
                    <td>{String(r.cumulative_patients)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <h2 className="mb-2 font-semibold">Retention cohorts</h2>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Cohort</th><th>Period</th><th>Size</th><th>Retained</th><th>Rate</th></tr></thead>
              <tbody>
                {((dash?.retention as Record<string, unknown>[]) ?? []).slice(0, 30).map((r) => (
                  <tr key={`${r.tenant_id}-${r.cohort_month}-${r.period_number}`}>
                    <td>{String(r.cohort_month)}</td>
                    <td>{String(r.period_number)}</td>
                    <td>{String(r.cohort_size)}</td>
                    <td>{String(r.retained_users)}</td>
                    <td>{(Number(r.retention_rate) * 100).toFixed(1)}%</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
