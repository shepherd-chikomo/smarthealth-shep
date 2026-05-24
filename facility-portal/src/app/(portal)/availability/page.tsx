'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';

const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export default function AvailabilityPage() {
  const { facilityId } = useFacility();
  const { data, isLoading, error } = useQuery({
    queryKey: ['availability', facilityId],
    queryFn: () => api.availability(facilityId!),
    enabled: !!facilityId,
  });

  return (
    <div>
      <PageHeader title="Doctor Availability" description="Per-doctor working hours and schedules" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <div className="table-wrap">
          <table className="data-table">
            <thead><tr><th>Doctor</th><th>Day</th><th>Opens</th><th>Closes</th><th>Closed</th></tr></thead>
            <tbody>
              {(data.availability as Record<string, unknown>[]).map((h) => (
                <tr key={String(h.id)}>
                  <td>{String(h.provider_name)}</td>
                  <td>{DAYS[Number(h.day_of_week)] ?? h.day_of_week}</td>
                  <td>{String(h.opens_at ?? '—')}</td>
                  <td>{String(h.closes_at ?? '—')}</td>
                  <td>{h.is_closed ? 'Yes' : 'No'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <p className="mt-4 text-sm text-[var(--muted)]">
        To update availability, use the API or contact your facility admin. Full edit UI coming in V1.1.
      </p>
    </div>
  );
}
