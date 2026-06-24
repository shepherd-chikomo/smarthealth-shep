'use client';

import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '@/components/ui';

export default function ReportsPage() {
  const { facilityId } = useFacility();
  const [page, setPage] = useState(1);
  const [exporting, setExporting] = useState<string | null>(null);

  const revenue = useQuery({
    queryKey: ['reports-revenue', facilityId, page],
    queryFn: () => api.revenueReport(facilityId!, { page, limit: 20 }),
    enabled: !!facilityId,
  });

  const doctors = useQuery({
    queryKey: ['reports-doctors', facilityId],
    queryFn: () => api.doctorReport(facilityId!),
    enabled: !!facilityId,
  });

  async function download(type: string) {
    if (!facilityId) return;
    setExporting(type);
    try {
      const csv = await api.exportReport(facilityId, type);
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${type}-report.csv`;
      a.click();
      URL.revokeObjectURL(url);
    } finally {
      setExporting(null);
    }
  }

  return (
    <div>
      <PageHeader title="Reporting" description="Revenue, doctor performance, and appointment trends with CSV export" />
      <div className="mb-6 flex flex-wrap gap-2">
        {(['revenue', 'appointments', 'doctors'] as const).map((type) => (
          <button key={type} type="button" className="btn-secondary" disabled={exporting === type}
            onClick={() => download(type)}>
            {exporting === type ? 'Exporting…' : `Export ${type} CSV`}
          </button>
        ))}
      </div>

      <h2 className="mb-2 font-semibold">Revenue reports</h2>
      {revenue.isLoading && <LoadingState />}
      {revenue.error && <ErrorState message={(revenue.error as Error).message} />}
      {revenue.data && (
        <>
          <div className="table-wrap mb-6">
            <table className="data-table">
              <thead><tr><th>Date</th><th>Period</th><th>Net revenue</th><th>Appointments</th><th>Walk-ins</th></tr></thead>
              <tbody>
                {(revenue.data.reports as Record<string, unknown>[]).map((r) => (
                  <tr key={String(r.report_date)}>
                    <td>{String(r.report_date)}</td>
                    <td>{String(r.period_type)}</td>
                    <td>${(Number(r.net_revenue_cents) / 100).toFixed(2)}</td>
                    <td>{String(r.appointment_count)}</td>
                    <td>{String(r.walk_in_count)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={revenue.data.pagination.page} totalPages={revenue.data.pagination.totalPages} onPage={setPage} />
        </>
      )}

      <h2 className="mb-2 mt-8 font-semibold">Doctor performance (30 days)</h2>
      {doctors.isLoading && <LoadingState />}
      {doctors.data && (
        <div className="table-wrap">
          <table className="data-table">
            <thead><tr><th>Doctor</th><th>Appointments</th><th>Completed</th><th>Rating</th></tr></thead>
            <tbody>
              {(doctors.data.doctors as Record<string, unknown>[]).map((d) => (
                <tr key={String(d.id)}>
                  <td>{String(d.name)}</td>
                  <td>{String(d.appointment_count)}</td>
                  <td>{String(d.completed)}</td>
                  <td>{Number(d.avg_rating).toFixed(1)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
