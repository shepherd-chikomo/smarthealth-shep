import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar, StatCard } from '../components/ui';

export function QueuePage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);

  const stats = useQuery({ queryKey: ['queue-stats'], queryFn: () => api.queueStats(), refetchInterval: 15_000 });
  const queue = useQuery({ queryKey: ['live-queue', page], queryFn: () => api.liveQueue({ page, limit: 20 }), refetchInterval: 10_000 });

  const moderate = useMutation({
    mutationFn: ({ id, action }: { id: string; action: string }) =>
      api.moderateQueue(id, { action, reason: 'Admin moderation' }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['live-queue'] }),
  });

  const s = stats.data?.stats as Record<string, number> | undefined;

  return (
    <div>
      <PageHeader title="Queue Management" description="Live walk-in queues · auto-refreshes every 10s" />
      {s && (
        <div className="mb-6 grid gap-4 sm:grid-cols-4">
          <StatCard label="Waiting" value={s.waiting ?? 0} />
          <StatCard label="In progress" value={s.in_progress ?? 0} />
          <StatCard label="Completed today" value={s.completed_today ?? 0} />
          <StatCard label="Avg wait (min)" value={Math.round(Number(s.avg_wait) || 0)} />
        </div>
      )}
      {queue.isLoading && <LoadingState />}
      {queue.error && <ErrorState message={(queue.error as Error).message} />}
      {queue.data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Ticket</th><th>Patient</th><th>Provider</th><th>Status</th><th>Wait</th><th>Priority</th><th /></tr></thead>
              <tbody>
                {(queue.data.queue as Record<string, unknown>[]).map((item) => (
                  <tr key={String(item.id)}>
                    <td>#{String(item.ticketNumber)}</td>
                    <td>{String(item.patientName)}</td>
                    <td>{String(item.providerName ?? '—')}</td>
                    <td><span className="badge badge-amber">{String(item.queueStatus)}</span></td>
                    <td>{String(item.estimatedWaitMinutes ?? '—')} min</td>
                    <td>{String(item.priority)}</td>
                    <td className="space-x-2">
                      <button type="button" className="text-sm text-red-600" onClick={() => moderate.mutate({ id: String(item.id), action: 'cancel' })}>Cancel</button>
                      <button type="button" className="text-sm text-amber-600" onClick={() => moderate.mutate({ id: String(item.id), action: 'flag' })}>Flag</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={queue.data.pagination.page} totalPages={queue.data.pagination.totalPages} onPage={setPage} />
        </>
      )}
    </div>
  );
}
