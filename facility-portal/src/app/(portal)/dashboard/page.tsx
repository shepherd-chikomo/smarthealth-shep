'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { MyFacilitiesPanel } from '@/components/facility-tabs';
import { QuickActionsGrid } from '@/components/dashboard/quick-actions';
import { QueueOverviewPanel } from '@/components/dashboard/queue-overview';
import { SectionCard } from '@/components/dashboard/section-card';
import { api } from '@/lib/api';
import { claimApi } from '@/lib/claim-api';
import { refreshAuthSession } from '@/lib/auth-session';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, StatCard, StatGrid } from '@/components/ui';

type QueueEntry = Record<string, unknown>;

export default function DashboardPage() {
  const router = useRouter();
  const { facilityId, linkedFacilities, loadFacility, refresh, activateFacility } = useFacility();
  const [claimingId, setClaimingId] = useState<string | null>(null);
  const [facilityError, setFacilityError] = useState('');

  const dashboard = useQuery({
    queryKey: ['dashboard', facilityId],
    queryFn: () => api.dashboard(facilityId!),
    enabled: !!facilityId,
    refetchInterval: 30_000,
  });

  const queueStats = useQuery({
    queryKey: ['queue-stats', facilityId],
    queryFn: () => api.queueStats(facilityId!),
    enabled: !!facilityId,
    refetchInterval: 10_000,
  });

  const queue = useQuery({
    queryKey: ['queue-dashboard', facilityId],
    queryFn: () => api.queue(facilityId!, { page: 1, limit: 30 }),
    enabled: !!facilityId,
    refetchInterval: 10_000,
  });

  useEffect(() => {
    if (linkedFacilities.length > 0) {
      void refresh();
    }
  }, [linkedFacilities.length, refresh]);

  async function claimFacility(id: string) {
    setClaimingId(id);
    setFacilityError('');
    try {
      await claimApi.instantClaimFacility(id);
      await refreshAuthSession();
      const ok = await activateFacility(id);
      if (!ok) {
        throw new Error('Facility claimed but could not activate it. Refresh the page.');
      }
    } catch (err) {
      setFacilityError(err instanceof Error ? err.message : 'Could not claim facility');
    } finally {
      setClaimingId(null);
    }
  }

  function manageFacility(id: string) {
    loadFacility(id);
    router.refresh();
  }

  function switchFacility(id: string) {
    loadFacility(id);
    router.refresh();
  }

  const stats = dashboard.data?.stats as Record<string, unknown> | undefined;
  const queueEntries = (queue.data?.queue as QueueEntry[] | undefined) ?? [];
  const nowServing =
    queueEntries.find((w) => w.queue_status === 'in_progress')
    ?? queueEntries.find((w) => w.queue_status === 'called');
  const qStats = queueStats.data?.stats as Record<string, unknown> | undefined;
  const paused = Boolean(queueStats.data?.paused);

  const isLoading = dashboard.isLoading || queueStats.isLoading;

  return (
    <div>
      <PageHeader
        title="Operations dashboard"
        description="Today's activity, queue status, and quick actions — refreshes automatically"
      />

      {linkedFacilities.length > 0 && (
        <SectionCard
          title="My facilities"
          description="All registry-linked sites — claim ownership or switch the active facility"
        >
          {facilityError && (
            <p className="mb-3 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
              {facilityError}
            </p>
          )}
          <MyFacilitiesPanel
            facilities={linkedFacilities}
            activeFacilityId={facilityId}
            claimingId={claimingId}
            onClaim={(id) => void claimFacility(id)}
            onManage={manageFacility}
            onSwitch={switchFacility}
          />
        </SectionCard>
      )}

      {isLoading && <LoadingState />}
      {dashboard.error && <ErrorState message={(dashboard.error as Error).message} />}

      {stats && (
        <>
          <SectionCard title="Today" description="Live operational snapshot">
            <StatGrid>
              <StatCard label="Appointments today" value={String(stats.appointmentsToday ?? 0)} />
              <StatCard label="Active queue" value={String(stats.queueWaiting ?? 0)} />
              <StatCard label="Walk-ins today" value={String(stats.walkInsToday ?? 0)} />
              <StatCard label="Cancellations today" value={String(stats.cancellationsToday ?? 0)} />
            </StatGrid>
          </SectionCard>

          <SectionCard title="Quick actions" description="Common front-desk tasks">
            <QuickActionsGrid />
          </SectionCard>

          <SectionCard title="Queue overview" description="Current flow and wait times">
            <QueueOverviewPanel
              stats={qStats}
              nowServing={nowServing}
              avgWaitMinutes={
                stats.avgWaitMinutes != null ? Number(stats.avgWaitMinutes) : null
              }
              paused={paused}
            />
          </SectionCard>

          <SectionCard title="Facility health">
            <StatGrid>
              <StatCard
                label="Doctors active"
                value={`${stats.doctorsAcceptingBookings}/${stats.doctorsTotal}`}
              />
              <StatCard label="Pending appointments" value={String(stats.pendingAppointments ?? 0)} />
              <StatCard
                label="Revenue this month"
                value={`$${(Number(stats.revenueMonthCents) / 100).toFixed(0)}`}
              />
              <StatCard label="Low stock alerts" value={String(stats.lowStockItems ?? 0)} />
            </StatGrid>
          </SectionCard>
        </>
      )}
    </div>
  );
}
