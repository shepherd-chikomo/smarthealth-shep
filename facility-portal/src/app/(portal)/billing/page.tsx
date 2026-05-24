'use client';

import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PlaceholderBanner, StatCard, StatGrid } from '@/components/ui';

export default function BillingPage() {
  const { facilityId } = useFacility();
  const { data, isLoading, error } = useQuery({
    queryKey: ['billing', facilityId],
    queryFn: () => api.billing(facilityId!),
    enabled: !!facilityId,
  });

  const payments = data?.paymentsTotal as Record<string, unknown> | undefined;

  return (
    <div>
      <PageHeader
        title="Billing Dashboard"
        description="Payments and medical aid claims — summary view only in V1"
      />
      <PlaceholderBanner message="Advanced accounting, invoicing workflows, and medical aid claim processing are planned for future phases. This dashboard shows read-only summary counts." />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <StatGrid>
            <StatCard label="Completed payments" value={String(payments?.count ?? 0)} />
            <StatCard label="Payment total" value={`$${(Number(payments?.total_cents ?? 0) / 100).toFixed(2)}`} />
            <StatCard label="Pending medical aid claims" value={String(data.pendingMedicalAidClaims ?? 0)} />
          </StatGrid>
          <h2 className="mb-2 font-semibold">Invoices by status</h2>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Status</th><th>Count</th><th>Total</th></tr></thead>
              <tbody>
                {((data.invoicesByStatus as Record<string, unknown>[]) ?? []).map((row) => (
                  <tr key={String(row.status)}>
                    <td>{String(row.status)}</td>
                    <td>{String(row.count)}</td>
                    <td>${(Number(row.total_cents) / 100).toFixed(2)}</td>
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
