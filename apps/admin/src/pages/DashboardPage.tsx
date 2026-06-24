import { useQuery } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, StatCard } from '../components/ui';

export function DashboardPage() {
  const { data, isLoading, error, dataUpdatedAt } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: () => api.dashboardStats(),
    refetchInterval: 30_000,
  });

  const stats = data?.stats;

  return (
    <div>
      <PageHeader
        title="Dashboard"
        description={`Real-time overview · updated ${new Date(dataUpdatedAt).toLocaleTimeString()}`}
      />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {stats && (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          <StatCard label="Appointments" value={String(stats.appointmentsToday ?? 0)} />
          <StatCard label="Walk-ins (24h)" value={String(stats.walkIns24h ?? 0)} hint={`Avg wait ${stats.avgWaitMinutes ?? '—'} min`} />
          <StatCard label="Providers verified" value={`${stats.providersVerified}/${stats.providersTotal}`} />
          <StatCard label="Revenue (month)" value={`$${((Number(stats.revenueMonthCents) || 0) / 100).toFixed(2)}`} />
        </div>
      )}
    </div>
  );
}
