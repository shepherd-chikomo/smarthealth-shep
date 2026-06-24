'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'next/navigation';
import { Suspense, useEffect, useMemo, useState } from 'react';
import { SectionCard } from '@/components/dashboard/section-card';
import { QueueOverviewPanel } from '@/components/dashboard/queue-overview';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import {
  ErrorState, LoadingState, PageHeader, PaginationBar, StatusBadge,
} from '@/components/ui';

type QueueEntry = Record<string, unknown>;

const ACTIVE = ['waiting', 'called', 'in_progress'] as const;

function QueueContent() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const searchParams = useSearchParams();
  const [page, setPage] = useState(1);
  const [showWalkIn, setShowWalkIn] = useState(false);
  const [walkInForm, setWalkInForm] = useState({
    patientId: '',
    chiefComplaint: '',
  });

  useEffect(() => {
    if (searchParams.get('walkIn') === '1') setShowWalkIn(true);
  }, [searchParams]);

  const stats = useQuery({
    queryKey: ['queue-stats', facilityId],
    queryFn: () => api.queueStats(facilityId!),
    enabled: !!facilityId,
    refetchInterval: 10_000,
  });

  const queue = useQuery({
    queryKey: ['queue', facilityId, page],
    queryFn: () => api.queue(facilityId!, { page, limit: 30 }),
    enabled: !!facilityId,
    refetchInterval: 10_000,
  });

  const paused = Boolean(stats.data?.paused);

  const pauseQueue = useMutation({
    mutationFn: (next: boolean) => api.setQueuePaused(facilityId!, next),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['queue-stats', facilityId] }),
  });

  useEffect(() => {
    if (searchParams.get('pause') !== '1' || !facilityId || paused) return;
    void api.setQueuePaused(facilityId, true).then(() => {
      qc.invalidateQueries({ queryKey: ['queue-stats', facilityId] });
    });
  }, [searchParams, facilityId, paused, qc]);

  const updateStatus = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      api.updateQueueStatus(facilityId!, id, status),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['queue', facilityId] });
      qc.invalidateQueries({ queryKey: ['queue-stats', facilityId] });
      qc.invalidateQueries({ queryKey: ['queue-dashboard', facilityId] });
      qc.invalidateQueries({ queryKey: ['dashboard', facilityId] });
    },
  });

  const delayPatient = useMutation({
    mutationFn: (id: string) => api.delayQueuePatient(facilityId!, id, 15),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['queue', facilityId] });
      qc.invalidateQueries({ queryKey: ['queue-stats', facilityId] });
    },
  });

  const registerWalkIn = useMutation({
    mutationFn: (body: Record<string, unknown>) =>
      api.registerWalkIn(facilityId!, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['queue', facilityId] });
      qc.invalidateQueries({ queryKey: ['queue-stats', facilityId] });
      setWalkInForm({ patientId: '', chiefComplaint: '' });
      setShowWalkIn(false);
    },
  });

  const entries = (queue.data?.queue as QueueEntry[] | undefined) ?? [];

  const nowServing = useMemo(() => {
    return entries.find((w) => w.queue_status === 'in_progress')
      ?? entries.find((w) => w.queue_status === 'called');
  }, [entries]);

  const nextWaiting = useMemo(() => {
    return entries.find((w) => w.queue_status === 'waiting');
  }, [entries]);

  const s = stats.data?.stats as Record<string, unknown> | undefined;

  const callNext = () => {
    if (paused || !nextWaiting) return;
    updateStatus.mutate({ id: String(nextWaiting.id), status: 'called' });
  };

  const markComplete = () => {
    if (!nowServing) return;
    updateStatus.mutate({ id: String(nowServing.id), status: 'completed' });
  };

  return (
    <div>
      <PageHeader
        title="Queue panel"
        description="Call patients, manage wait times, and control queue flow"
      />

      {stats.isFetching && !stats.isLoading && (
        <p className="mb-3 text-xs text-[var(--muted)]">Refreshing queue data…</p>
      )}

      {paused && (
        <div className="mb-4 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-200">
          Queue is paused — patients remain registered but will not be called automatically.
        </div>
      )}

      <SectionCard title="Queue overview">
        <QueueOverviewPanel
          stats={s}
          nowServing={nowServing}
          paused={paused}
        />
      </SectionCard>

      <SectionCard title="Queue actions">
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            className="btn-primary"
            disabled={paused || !nextWaiting || updateStatus.isPending}
            onClick={callNext}
          >
            Call next patient
          </button>
          <button
            type="button"
            className="btn-secondary"
            disabled={!nowServing || updateStatus.isPending}
            onClick={markComplete}
          >
            Mark complete
          </button>
          <button
            type="button"
            className="btn-secondary"
            disabled={!nextWaiting || delayPatient.isPending}
            onClick={() => delayPatient.mutate(String(nextWaiting!.id))}
          >
            Delay patient (+15 min)
          </button>
          <button
            type="button"
            className={paused ? 'btn-primary' : 'btn-secondary'}
            disabled={pauseQueue.isPending}
            onClick={() => pauseQueue.mutate(!paused)}
          >
            {paused ? 'Resume queue' : 'Pause queue'}
          </button>
          <button
            type="button"
            className="btn-secondary"
            onClick={() => setShowWalkIn((v) => !v)}
          >
            {showWalkIn ? 'Hide walk-in form' : 'Add walk-in'}
          </button>
        </div>
      </SectionCard>

      {showWalkIn && (
        <SectionCard title="Walk-in registration">
          <form
            className="grid gap-3 sm:grid-cols-2"
            onSubmit={(e) => {
              e.preventDefault();
              if (!walkInForm.patientId.trim()) return;
              registerWalkIn.mutate({
                patientId: walkInForm.patientId.trim(),
                chiefComplaint: walkInForm.chiefComplaint.trim() || undefined,
              });
            }}
          >
            <label className="text-sm">
              Patient ID
              <input
                className="input mt-1 w-full"
                value={walkInForm.patientId}
                onChange={(e) => setWalkInForm((f) => ({ ...f, patientId: e.target.value }))}
                placeholder="Patient UUID"
                required
              />
            </label>
            <label className="text-sm">
              Chief complaint
              <input
                className="input mt-1 w-full"
                value={walkInForm.chiefComplaint}
                onChange={(e) => setWalkInForm((f) => ({ ...f, chiefComplaint: e.target.value }))}
                placeholder="Optional"
              />
            </label>
            <div className="sm:col-span-2">
              <button type="submit" className="btn-primary" disabled={registerWalkIn.isPending}>
                {registerWalkIn.isPending ? 'Registering…' : 'Add to queue'}
              </button>
            </div>
          </form>
        </SectionCard>
      )}

      {queue.isLoading && <LoadingState />}
      {queue.error && <ErrorState message={(queue.error as Error).message} />}

      {queue.data && (
        <>
          <h2 className="mb-2 text-sm font-semibold text-[var(--muted)]">Current queue</h2>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Patient</th>
                  <th>Doctor</th>
                  <th>Wait est.</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {entries.filter((w) => ACTIVE.includes(w.queue_status as typeof ACTIVE[number])).map((w) => (
                  <tr
                    key={String(w.id)}
                    className={w.id === nowServing?.id ? 'bg-teal-50/50 dark:bg-teal-950/20' : undefined}
                  >
                    <td className="font-bold text-teal-600">#{String(w.ticket_number)}</td>
                    <td>{String(w.patient_name)}</td>
                    <td>{String(w.provider_name ?? 'Any')}</td>
                    <td>{w.estimated_wait_minutes ? `${w.estimated_wait_minutes} min` : '—'}</td>
                    <td><StatusBadge status={String(w.queue_status)} /></td>
                    <td className="space-x-2 whitespace-nowrap">
                      {w.queue_status === 'waiting' && (
                        <button
                          type="button"
                          className="btn-secondary text-xs"
                          disabled={delayPatient.isPending}
                          onClick={() => delayPatient.mutate(String(w.id))}
                        >
                          Delay
                        </button>
                      )}
                      {w.queue_status !== 'completed' && (
                        <button
                          type="button"
                          className="btn-secondary text-xs"
                          disabled={updateStatus.isPending}
                          onClick={() => updateStatus.mutate({
                            id: String(w.id),
                            status: 'completed',
                          })}
                        >
                          Complete
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
                {entries.filter((w) => ACTIVE.includes(w.queue_status as typeof ACTIVE[number])).length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-8 text-center text-sm text-[var(--muted)]">
                      No patients in the active queue
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
          <PaginationBar
            page={queue.data.pagination.page}
            totalPages={queue.data.pagination.totalPages}
            onPage={setPage}
          />
        </>
      )}
    </div>
  );
}

export default function QueuePage() {
  return (
    <Suspense fallback={<LoadingState />}>
      <QueueContent />
    </Suspense>
  );
}
