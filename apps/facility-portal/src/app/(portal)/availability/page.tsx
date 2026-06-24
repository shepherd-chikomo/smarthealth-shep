'use client';

import { Suspense } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';

const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

function AvailabilityContent() {
  const { facilityId } = useFacility();
  const sp = useSearchParams();
  const providerId = sp.get('providerId') ?? undefined;
  const providerName = sp.get('name');

  const { data, isLoading, error } = useQuery({
    queryKey: ['availability', facilityId, providerId],
    queryFn: () => api.availability(facilityId!, providerId),
    enabled: !!facilityId,
  });

  return (
    <div>
      <PageHeader
        title={providerName ? `Availability — ${providerName}` : 'Doctor Availability'}
        description="Per-doctor working hours and schedules"
      />

      {providerId && (
        <Link href="/doctors" className="mb-4 inline-block text-sm text-teal-600 hover:underline">
          ← Back to providers
        </Link>
      )}

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (data.availability as unknown[]).length === 0 && (
        <p className="rounded-lg bg-slate-50 p-4 text-sm text-[var(--muted)] dark:bg-slate-800">
          No working hours set yet. Use <strong>Manage hours</strong> on the{' '}
          <Link href="/doctors" className="text-teal-600 hover:underline">
            Providers
          </Link>{' '}
          page to set this doctor&apos;s weekly schedule.
        </p>
      )}
      {data && (data.availability as unknown[]).length > 0 && (
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
        To edit a doctor&apos;s working hours, open <strong>Manage hours</strong> on the Providers page.
      </p>
    </div>
  );
}

export default function AvailabilityPage() {
  return (
    <Suspense fallback={<LoadingState />}>
      <AvailabilityContent />
    </Suspense>
  );
}
