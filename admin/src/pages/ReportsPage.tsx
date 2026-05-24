import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '../components/ui';

export function ReportsPage() {
  const [page, setPage] = useState(1);

  const { data, isLoading, error } = useQuery({
    queryKey: ['revenue-reports', page],
    queryFn: () => api.revenueReports({ page, limit: 20 }),
  });

  async function download(type: string, format: 'csv' | 'pdf') {
    const path = format === 'pdf' ? `/v1/admin/reports/export/${type}/pdf` : `/v1/admin/reports/export/${type}`;
    const token = localStorage.getItem('sh_admin_token');
    const res = await fetch(path, { headers: { Authorization: `Bearer ${token}` } });
    const blob = await res.blob();
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${type}-report.${format}`;
    a.click();
  }

  return (
    <div>
      <PageHeader
        title="Reporting"
        description="Revenue, usage, and facility reports with CSV/PDF export"
        actions={
          <>
            <button type="button" className="btn-secondary" onClick={() => download('revenue', 'csv')}>Export revenue CSV</button>
            <button type="button" className="btn-secondary" onClick={() => download('appointments', 'csv')}>Export appointments CSV</button>
            <button type="button" className="btn-secondary" onClick={() => download('revenue', 'pdf')}>Export PDF</button>
          </>
        }
      />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Facility</th><th>Period</th><th>Total</th><th>Appointments</th></tr></thead>
              <tbody>
                {(data.reports as Record<string, unknown>[]).map((r) => (
                  <tr key={String(r.id)}>
                    <td>{String(r.facility_name)}</td>
                    <td>{String(r.report_date)} ({String(r.period_type)})</td>
                    <td>${(Number(r.total_cents) / 100).toFixed(2)}</td>
                    <td>{String(r.appointment_count)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={data.pagination.page} totalPages={data.pagination.totalPages} onPage={setPage} />
        </>
      )}
    </div>
  );
}
