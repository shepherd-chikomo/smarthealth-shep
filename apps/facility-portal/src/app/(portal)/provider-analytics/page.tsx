'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, StatCard, StatGrid } from '@/components/ui';

export default function ProviderAnalyticsPage() {
  const { facilityId } = useFacility();
  const [providerId, setProviderId] = useState('');

  const doctors = useQuery({
    queryKey: ['doctors-list', facilityId],
    queryFn: () => api.doctors(facilityId!, { limit: 100 }),
    enabled: !!facilityId,
  });

  const analytics = useQuery({
    queryKey: ['provider-analytics', facilityId, providerId],
    queryFn: () => api.providerAnalytics(facilityId!, providerId),
    enabled: !!facilityId && !!providerId,
    staleTime: 60_000,
  });

  const dash = analytics.data?.dashboard as Record<string, unknown> | undefined;
  const summary = dash?.summary as Record<string, unknown> | undefined;

  async function download() {
    if (!facilityId || !providerId) return;
    const csv = await api.exportProviderAnalytics(facilityId, providerId);
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'provider-analytics.csv';
    a.click();
  }

  return (
    <div>
      <PageHeader title="Provider Analytics" description="Individual doctor performance and trends" />
      <div className="mb-4 flex flex-wrap gap-2">
        <select className="input max-w-xs" value={providerId} onChange={(e) => setProviderId(e.target.value)}>
          <option value="">Select provider…</option>
          {((doctors.data?.doctors as Record<string, unknown>[]) ?? []).map((d) => (
            <option key={String(d.id)} value={String(d.id)}>{String(d.name)}</option>
          ))}
        </select>
        {providerId && (
          <button type="button" className="btn-secondary" onClick={download}>Export CSV</button>
        )}
      </div>
      {analytics.isLoading && <LoadingState />}
      {analytics.error && <ErrorState message={(analytics.error as Error).message} />}
      {summary && (
        <>
          <StatGrid>
            <StatCard label="Appointments (30d)" value={String(summary.appointments_30d ?? 0)} />
            <StatCard label="Completed" value={String(summary.completed_30d ?? 0)} />
            <StatCard label="Cancelled" value={String(summary.cancelled_30d ?? 0)} />
            <StatCard label="Avg rating" value={Number(summary.avg_rating ?? 0).toFixed(1)} />
            <StatCard label="Completion rate" value={`${(Number(summary.completion_rate ?? 0) * 100).toFixed(0)}%`} />
          </StatGrid>
          <h2 className="mb-2 mt-6 font-semibold">Daily trend</h2>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Date</th><th>Total</th><th>Completed</th><th>Rating</th></tr></thead>
              <tbody>
                {((dash?.dailyTrend as Record<string, unknown>[]) ?? []).map((r) => (
                  <tr key={String(r.metric_date)}>
                    <td>{String(r.metric_date)}</td>
                    <td>{String(r.appointments_total)}</td>
                    <td>{String(r.appointments_completed)}</td>
                    <td>{Number(r.avg_rating).toFixed(1)}</td>
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
