import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { AlertTriangle, Check, History, X } from 'lucide-react';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '../components/ui';

interface ClaimRow {
  id: string;
  type: 'facility' | 'provider';
  status: string;
  facilityId?: string;
  facilityName?: string;
  providerId?: string;
  providerName?: string;
  claimantId: string;
  claimantName?: string;
  businessRegistrationNumber?: string;
  mdpczNumber?: string;
  notes?: string;
  evidence?: { documents?: { name: string; type: string }[] };
  submittedAt?: string;
}

function claimTitle(c: ClaimRow) {
  if (c.type === 'facility') return c.facilityName ?? 'Facility';
  return `${c.providerName ?? 'Provider'} · ${c.facilityName ?? ''}`;
}

export function ClaimsPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('under_review');
  const [selected, setSelected] = useState<ClaimRow | null>(null);
  const [reviewNotes, setReviewNotes] = useState('');
  const [historyEntity, setHistoryEntity] = useState<{
    type: 'facility' | 'provider';
    id: string;
    title: string;
  } | null>(null);

  const { data, isLoading, error } = useQuery({
    queryKey: ['admin-claims', page, status],
    queryFn: () => api.claims({ page, limit: 20, status }),
  });

  const duplicates = useQuery({
    queryKey: ['claim-duplicates', selected?.type, selected?.facilityId ?? selected?.providerId],
    queryFn: () =>
      api.claimDuplicates(
        selected!.type,
        selected!.type === 'facility' ? selected!.facilityId! : selected!.providerId!,
      ),
    enabled: Boolean(selected),
  });

  const history = useQuery({
    queryKey: ['claim-history', historyEntity?.type, historyEntity?.id],
    queryFn: () => api.claimHistory(historyEntity!.type, historyEntity!.id),
    enabled: Boolean(historyEntity),
  });

  const review = useMutation({
    mutationFn: ({
      type,
      id,
      action,
      notes,
    }: {
      type: 'facility' | 'provider';
      id: string;
      action: 'approve' | 'reject';
      notes?: string;
    }) => api.reviewClaim(type, id, action, notes),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin-claims'] });
      setSelected(null);
      setReviewNotes('');
    },
  });

  const rows: ClaimRow[] = [
    ...((data?.facilityClaims ?? []) as ClaimRow[]).map((c) => ({ ...c, type: 'facility' as const })),
    ...((data?.providerClaims ?? []) as ClaimRow[]).map((c) => ({ ...c, type: 'provider' as const })),
  ].sort((a, b) => String(a.submittedAt).localeCompare(String(b.submittedAt)));

  return (
    <div>
      <PageHeader
        title="Claim moderation"
        description="Review facility and practitioner ownership claims"
      />

      <div className="mb-4 flex flex-wrap gap-3">
        <select
          className="input max-w-[180px]"
          value={status}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
        >
          <option value="under_review">Pending review</option>
          <option value="submitted">Submitted</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
          <option value="draft">Draft</option>
        </select>
      </div>

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}

      {data && (
        <div className="grid gap-6 lg:grid-cols-5">
          <div className="lg:col-span-3">
            <div className="table-wrap">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Listing</th>
                    <th>Claimant</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {rows.map((c) => (
                    <tr
                      key={`${c.type}-${c.id}`}
                      className={selected?.id === c.id ? 'bg-teal-50/50 dark:bg-teal-950/20' : ''}
                    >
                      <td className="font-medium">{claimTitle(c)}</td>
                      <td>{c.claimantName ?? c.claimantId.slice(0, 8)}</td>
                      <td className="capitalize">{c.type}</td>
                      <td>
                        <span
                          className={
                            c.status === 'approved'
                              ? 'badge badge-green'
                              : c.status === 'rejected'
                                ? 'badge badge-red'
                                : 'badge badge-yellow'
                          }
                        >
                          {c.status.replace('_', ' ')}
                        </span>
                      </td>
                      <td>
                        <button
                          type="button"
                          className="text-sm text-teal-600"
                          onClick={() => setSelected(c)}
                        >
                          Review
                        </button>
                      </td>
                    </tr>
                  ))}
                  {rows.length === 0 && (
                    <tr>
                      <td colSpan={5} className="py-8 text-center text-slate-500">
                        No claims in this queue
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
            <PaginationBar
              page={data.pagination.page}
              totalPages={data.pagination.totalPages}
              onPage={setPage}
            />
          </div>

          <div className="lg:col-span-2">
            {selected ? (
              <div className="card space-y-4 p-6">
                <h2 className="font-semibold">{claimTitle(selected)}</h2>
                <dl className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <dt className="text-slate-500">Claimant</dt>
                    <dd>{selected.claimantName}</dd>
                  </div>
                  {selected.businessRegistrationNumber && (
                    <div className="flex justify-between">
                      <dt className="text-slate-500">Registration #</dt>
                      <dd>{selected.businessRegistrationNumber}</dd>
                    </div>
                  )}
                  {selected.mdpczNumber && (
                    <div className="flex justify-between">
                      <dt className="text-slate-500">MDPCZ</dt>
                      <dd>{selected.mdpczNumber}</dd>
                    </div>
                  )}
                  {selected.notes && (
                    <div>
                      <dt className="text-slate-500">Notes</dt>
                      <dd className="mt-1 rounded bg-slate-50 p-2 dark:bg-slate-800">{selected.notes}</dd>
                    </div>
                  )}
                </dl>

                {duplicates.data?.isDuplicate && (
                  <div className="flex items-start gap-2 rounded-lg border border-amber-200 bg-amber-50 p-3 text-sm text-amber-900 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-200">
                    <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0" />
                    <p>
                      Duplicate detection: {duplicates.data.pendingCount} pending claims from{' '}
                      {duplicates.data.claimantIds.length} claimant(s) for this listing.
                    </p>
                  </div>
                )}

                {selected.evidence?.documents && selected.evidence.documents.length > 0 && (
                  <div>
                    <p className="mb-2 text-sm font-medium">Evidence</p>
                    <ul className="space-y-1 text-sm">
                      {selected.evidence.documents.map((doc, i) => (
                        <li key={i} className="rounded border border-slate-200 px-2 py-1 dark:border-slate-700">
                          {doc.name} <span className="text-slate-400">({doc.type})</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                <textarea
                  className="input min-h-[72px]"
                  placeholder="Review notes (optional)"
                  value={reviewNotes}
                  onChange={(e) => setReviewNotes(e.target.value)}
                />

                {['submitted', 'under_review'].includes(selected.status) && (
                  <div className="flex gap-2">
                    <button
                      type="button"
                      className="btn-primary flex-1 justify-center"
                      disabled={review.isPending}
                      onClick={() =>
                        review.mutate({
                          type: selected.type,
                          id: selected.id,
                          action: 'approve',
                          notes: reviewNotes || undefined,
                        })
                      }
                    >
                      <Check className="h-4 w-4" /> Approve
                    </button>
                    <button
                      type="button"
                      className="btn-danger flex-1 justify-center"
                      disabled={review.isPending}
                      onClick={() =>
                        review.mutate({
                          type: selected.type,
                          id: selected.id,
                          action: 'reject',
                          notes: reviewNotes || undefined,
                        })
                      }
                    >
                      <X className="h-4 w-4" /> Reject
                    </button>
                  </div>
                )}

                <button
                  type="button"
                  className="btn-secondary w-full justify-center"
                  onClick={() =>
                    setHistoryEntity({
                      type: selected.type,
                      id:
                        selected.type === 'facility'
                          ? selected.facilityId!
                          : selected.providerId!,
                      title: claimTitle(selected),
                    })
                  }
                >
                  <History className="h-4 w-4" /> Ownership history
                </button>
              </div>
            ) : (
              <div className="card p-8 text-center text-slate-500">
                Select a claim to review evidence and approve or reject
              </div>
            )}

            {historyEntity && history.data && (
              <div className="card mt-4 space-y-3 p-6">
                <h3 className="font-medium">Verification history · {historyEntity.title}</h3>
                <ul className="space-y-2 text-sm">
                  {(history.data.history as Record<string, unknown>[]).map((h) => (
                    <li
                      key={String(h.id)}
                      className="flex justify-between gap-2 border-b border-slate-100 pb-2 dark:border-slate-800"
                    >
                      <span className="capitalize">{String(h.status).replace('_', ' ')}</span>
                      <span className="text-slate-400 text-xs">
                        {h.submitted_at
                          ? new Date(String(h.submitted_at)).toLocaleDateString()
                          : new Date(String(h.created_at)).toLocaleDateString()}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
