'use client';

import { useQuery } from '@tanstack/react-query';
import { useParams } from 'next/navigation';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, StatusBadge } from '@/components/ui';

export default function PatientHistoryPage() {
  const { facilityId } = useFacility();
  const params = useParams();
  const patientId = params.id as string;

  const { data, isLoading, error } = useQuery({
    queryKey: ['patient-history', facilityId, patientId],
    queryFn: () => api.patientHistory(facilityId!, patientId),
    enabled: !!facilityId && !!patientId,
  });

  const p = data?.patient as Record<string, unknown> | undefined;

  return (
    <div>
      <PageHeader
        title={p ? `${p.first_name} ${p.last_name ?? ''}` : 'Patient History'}
        description="Appointments and walk-in visits at this facility"
      />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="card mb-6 grid gap-2 sm:grid-cols-3 text-sm">
            <div><span className="text-[var(--muted)]">Phone:</span> {String(p?.phone ?? '—')}</div>
            <div><span className="text-[var(--muted)]">Email:</span> {String(p?.email ?? '—')}</div>
            <div><span className="text-[var(--muted)]">DOB:</span> {String(p?.date_of_birth ?? '—')}</div>
          </div>

          <h2 className="mb-2 font-semibold">Appointments</h2>
          <div className="table-wrap mb-6">
            <table className="data-table">
              <thead><tr><th>Reference</th><th>Date</th><th>Doctor</th><th>Status</th></tr></thead>
              <tbody>
                {(data.appointments as Record<string, unknown>[]).map((a) => (
                  <tr key={String(a.id)}>
                    <td>{String(a.reference_number)}</td>
                    <td>{new Date(String(a.scheduled_at)).toLocaleString()}</td>
                    <td>{String(a.provider_name)}</td>
                    <td><StatusBadge status={String(a.status)} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <h2 className="mb-2 font-semibold">Walk-ins</h2>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Ticket</th><th>Date</th><th>Doctor</th><th>Status</th></tr></thead>
              <tbody>
                {(data.walkIns as Record<string, unknown>[]).map((w) => (
                  <tr key={String(w.id)}>
                    <td>#{String(w.ticket_number)}</td>
                    <td>{new Date(String(w.registered_at)).toLocaleString()}</td>
                    <td>{String(w.provider_name ?? '—')}</td>
                    <td><StatusBadge status={String(w.status)} /></td>
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
