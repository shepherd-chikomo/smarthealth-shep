'use client';

import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { SectionCard } from '@/components/dashboard/section-card';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, StatCard, StatGrid } from '@/components/ui';

export default function AnalyticsPage() {
  const { facilityId } = useFacility();
  const { data, isLoading, error } = useQuery({
    queryKey: ['analytics', facilityId],
    queryFn: () => api.analytics(facilityId!),
    enabled: !!facilityId,
    staleTime: 60_000,
  });

  const dash = data?.dashboard as Record<string, unknown> | undefined;
  const summary = dash?.summary as Record<string, unknown> | undefined;
  const daily = (dash?.dailyTrend as Record<string, unknown>[]) ?? [];
  const providers = (dash?.providerPerformance as Record<string, unknown>[]) ?? [];

  const missedAppointments = useMemo(() => {
    return daily.reduce(
      (sum, row) => sum + Number(row.appointments_cancelled ?? 0),
      0,
    );
  }, [daily]);

  const profileViews = useMemo(() => {
    return providers.reduce((sum, p) => sum + Number(p.review_count ?? 0), 0);
  }, [providers]);

  async function download(type: 'daily' | 'providers') {
    if (!facilityId) return;
    const csv = await api.exportAnalytics(facilityId, type);
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `facility-${type}.csv`;
    a.click();
  }

  return (
    <div>
      <PageHeader
        title="Analytics"
        description="Lightweight operational metrics for the last 30 days"
      />
      <div className="mb-4 flex gap-2">
        <button type="button" className="btn-secondary" onClick={() => download('daily')}>
          Export daily CSV
        </button>
        <button type="button" className="btn-secondary" onClick={() => download('providers')}>
          Export providers CSV
        </button>
      </div>

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}

      {summary && (
        <>
          <SectionCard title="Key metrics">
            <StatGrid>
              <StatCard label="Bookings (30d)" value={String(summary.appointments_30d ?? 0)} />
              <StatCard label="Queue usage (30d)" value={String(summary.walk_ins_30d ?? 0)} />
              <StatCard label="Profile views" value={String(profileViews)} />
              <StatCard label="Missed appointments" value={String(missedAppointments)} />
            </StatGrid>
          </SectionCard>

          <SectionCard title="Daily snapshot" description="Last 7 days">
            <div className="table-wrap">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Bookings</th>
                    <th>Completed</th>
                    <th>Cancelled</th>
                    <th>Walk-ins</th>
                  </tr>
                </thead>
                <tbody>
                  {daily.slice(-7).map((t) => (
                    <tr key={String(t.metric_date)}>
                      <td>{String(t.metric_date)}</td>
                      <td>{String(t.appointments_total)}</td>
                      <td>{String(t.appointments_completed)}</td>
                      <td>{String(t.appointments_cancelled)}</td>
                      <td>{String(t.walk_ins_total)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </SectionCard>

          <SectionCard title="Top providers" description="By booking volume">
            <div className="table-wrap">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Doctor</th>
                    <th>Bookings</th>
                    <th>Completed</th>
                    <th>Reviews</th>
                  </tr>
                </thead>
                <tbody>
                  {providers.slice(0, 5).map((d) => (
                    <tr key={String(d.provider_id)}>
                      <td>{String(d.provider_name)}</td>
                      <td>{String(d.appointments_30d)}</td>
                      <td>{String(d.completed_30d)}</td>
                      <td>{String(d.review_count)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </SectionCard>
        </>
      )}
    </div>
  );
}
