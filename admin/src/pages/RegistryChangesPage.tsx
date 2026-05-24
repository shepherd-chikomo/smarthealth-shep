import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '../components/ui';

export function RegistryChangesPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [selectedRunId, setSelectedRunId] = useState<string | null>(null);
  const [itemsPage, setItemsPage] = useState(1);

  const runs = useQuery({
    queryKey: ['registry-changes', page],
    queryFn: () => api.registryDiffRuns({ page, limit: 20 }),
  });

  const items = useQuery({
    queryKey: ['registry-diff-items', selectedRunId, itemsPage],
    queryFn: () => api.registryDiffItems(selectedRunId!, { page: itemsPage, limit: 20, status: 'pending' }),
    enabled: !!selectedRunId,
  });

  const review = useMutation({
    mutationFn: ({ id, action }: { id: string; action: 'approve' | 'ignore' }) =>
      api.reviewRegistryDiffItem(id, action),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['registry-diff-items'] }),
  });

  return (
    <div>
      <PageHeader
        title="Registry Changes"
        description="Monthly HPA/MDPCZ diff reports — review adds, updates, and removals before applying"
      />

      {runs.isLoading && <LoadingState />}
      {runs.error && <ErrorState message={(runs.error as Error).message} />}

      {runs.data && (
        <div className="grid gap-6 lg:grid-cols-2">
          <div className="card">
            <h2 className="mb-3 font-semibold">Diff runs</h2>
            <ul className="space-y-2">
              {runs.data.runs.map((run) => (
                <li key={run.id}>
                  <button
                    type="button"
                    className={`w-full rounded-lg border p-3 text-left text-sm ${
                      selectedRunId === run.id
                        ? 'border-teal-500 bg-teal-50 dark:bg-teal-950/40'
                        : 'border-slate-200 dark:border-slate-700'
                    }`}
                    onClick={() => { setSelectedRunId(run.id); setItemsPage(1); }}
                  >
                    <p className="font-medium">{run.sourceType} — {run.sourceFile.split(/[/\\]/).pop()}</p>
                    <p className="text-xs text-slate-500">
                      +{run.addedCount} / ~{run.updatedCount} / −{run.removedCount} · {run.status}
                    </p>
                    <p className="text-xs text-slate-400">{new Date(run.startedAt).toLocaleString()}</p>
                  </button>
                </li>
              ))}
            </ul>
            <PaginationBar page={page} totalPages={runs.data.pagination.totalPages} onPage={setPage} />
          </div>

          <div className="card">
            <h2 className="mb-3 font-semibold">Pending changes</h2>
            {!selectedRunId && <p className="text-sm text-slate-500">Select a diff run.</p>}
            {items.isLoading && selectedRunId && <LoadingState />}
            {items.data && (
              <ul className="space-y-2">
                {items.data.items.length === 0 && (
                  <p className="text-sm text-slate-500">No pending items.</p>
                )}
                {items.data.items.map((item) => (
                  <li key={item.id} className="rounded-lg border border-slate-200 p-3 dark:border-slate-700">
                    <p className="text-sm font-medium">
                      {item.changeType.toUpperCase()} {item.entityType}
                    </p>
                    <p className="text-xs text-slate-500">{item.stableKey}</p>
                    {Object.keys(item.fieldChanges ?? {}).length > 0 && (
                      <pre className="mt-1 overflow-x-auto text-xs text-slate-600 dark:text-slate-400">
                        {JSON.stringify(item.fieldChanges, null, 2)}
                      </pre>
                    )}
                    <div className="mt-2 flex gap-2">
                      <button
                        type="button"
                        className="btn-primary text-xs"
                        disabled={review.isPending}
                        onClick={() => review.mutate({ id: item.id, action: 'approve' })}
                      >
                        Apply
                      </button>
                      <button
                        type="button"
                        className="btn-secondary text-xs"
                        disabled={review.isPending}
                        onClick={() => review.mutate({ id: item.id, action: 'ignore' })}
                      >
                        Ignore
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            )}
            {items.data && (
              <PaginationBar
                page={itemsPage}
                totalPages={items.data.pagination.totalPages}
                onPage={setItemsPage}
              />
            )}
          </div>
        </div>
      )}
    </div>
  );
}
