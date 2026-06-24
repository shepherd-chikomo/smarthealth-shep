'use client';

import Link from 'next/link';
import { StatusBadge } from '@/components/ui';

type QueueEntry = Record<string, unknown>;

export function QueueOverviewPanel({
  stats,
  nowServing,
  avgWaitMinutes,
  paused,
}: {
  stats?: Record<string, unknown>;
  nowServing?: QueueEntry;
  avgWaitMinutes?: number | null;
  paused?: boolean;
}) {
  return (
    <div className="grid gap-4 lg:grid-cols-3">
      <div className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-4 lg:col-span-1">
        <p className="text-xs font-semibold uppercase tracking-wide text-[var(--muted)]">
          Now serving
        </p>
        {nowServing ? (
          <div className="mt-2">
            <p className="text-2xl font-bold text-teal-600">
              #{String(nowServing.ticket_number)}
            </p>
            <p className="mt-1 font-medium">{String(nowServing.patient_name)}</p>
            <p className="text-sm text-[var(--muted)]">
              {String(nowServing.provider_name ?? 'Any provider')}
            </p>
            <div className="mt-2">
              <StatusBadge status={String(nowServing.queue_status)} />
            </div>
          </div>
        ) : (
          <p className="mt-2 text-sm text-[var(--muted)]">No active consultation</p>
        )}
      </div>

      <div className="grid gap-3 sm:grid-cols-3 lg:col-span-2">
        <Metric label="Waiting" value={String(stats?.waiting ?? 0)} />
        <Metric
          label="Avg wait"
          value={
            avgWaitMinutes != null
              ? `${avgWaitMinutes} min`
              : stats?.avg_wait
                ? `${Math.round(Number(stats.avg_wait))} min`
                : '—'
          }
        />
        <Metric label="Completed today" value={String(stats?.completed_today ?? 0)} />
      </div>

      <div className="flex items-center justify-between lg:col-span-3">
        {paused && (
          <span className="badge badge-yellow">Queue paused</span>
        )}
        <Link href="/queue" className="btn-secondary ml-auto text-sm">
          Open queue panel
        </Link>
      </div>
    </div>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-4">
      <p className="text-xs text-[var(--muted)]">{label}</p>
      <p className="mt-1 text-xl font-bold text-teal-600 dark:text-teal-400">{value}</p>
    </div>
  );
}
