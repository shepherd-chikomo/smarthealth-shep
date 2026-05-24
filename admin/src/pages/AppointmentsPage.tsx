import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '../components/ui';

export function AppointmentsPage() {
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');

  const list = useQuery({
    queryKey: ['admin-appointments', page, q, status],
    queryFn: () => api.appointments({ page, limit: 20, q, status: status || undefined }),
  });

  const analytics = useQuery({
    queryKey: ['appointment-analytics'],
    queryFn: () => api.appointmentAnalytics(),
  });

  return (
    <div>
      <PageHeader title="Appointments" description="View bookings, cancellations, and analytics" />
      {analytics.data && (
        <div className="card mb-6 p-4">
          <p className="mb-2 text-sm font-medium">30-day booking trend</p>
          <div className="flex h-24 items-end gap-1">
            {(analytics.data.series as { day: string; total: number }[]).slice(-14).map((d) => (
              <div
                key={d.day}
                className="flex-1 rounded-t bg-teal-500/80"
                style={{ height: `${Math.max(8, (d.total / 10) * 100)}%` }}
                title={`${d.day}: ${d.total}`}
              />
            ))}
          </div>
        </div>
      )}
      <div className="mb-4 flex flex-wrap gap-3">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Reference, provider…" />
        <select className="input max-w-[160px]" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
          <option value="">All statuses</option>
          <option value="pending">Pending</option>
          <option value="confirmed">Confirmed</option>
          <option value="cancelled">Cancelled</option>
          <option value="completed">Completed</option>
        </select>
      </div>
      {list.isLoading && <LoadingState />}
      {list.error && <ErrorState message={(list.error as Error).message} />}
      {list.data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Reference</th><th>Provider</th><th>Facility</th><th>Scheduled</th><th>Status</th></tr></thead>
              <tbody>
                {(list.data.appointments as Record<string, string>[]).map((a) => (
                  <tr key={a.id}>
                    <td>{a.referenceNumber}</td>
                    <td>{a.providerName}</td>
                    <td>{a.facilityName}</td>
                    <td>{new Date(a.scheduledAt).toLocaleString()}</td>
                    <td><span className="badge badge-amber">{a.status}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={list.data.pagination.page} totalPages={list.data.pagination.totalPages} onPage={setPage} />
        </>
      )}
    </div>
  );
}
