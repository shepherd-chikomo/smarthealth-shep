import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '../components/ui';

type Tab = 'batches' | 'failures' | 'duplicates' | 'specialties';

export function ImportPage() {
  const qc = useQueryClient();
  const [tab, setTab] = useState<Tab>('batches');
  const [page, setPage] = useState(1);
  const [failureStatus, setFailureStatus] = useState('unresolved');

  const batches = useQuery({
    queryKey: ['import-batches', page],
    queryFn: () => api.importBatches({ page, limit: 20 }),
    enabled: tab === 'batches',
  });

  const failures = useQuery({
    queryKey: ['import-failures', page, failureStatus],
    queryFn: () => api.importFailures({ page, limit: 20, status: failureStatus }),
    enabled: tab === 'failures',
  });

  const duplicates = useQuery({
    queryKey: ['import-duplicates', page],
    queryFn: () => api.importDuplicates({ page, limit: 20, status: 'pending' }),
    enabled: tab === 'duplicates',
  });

  const specialties = useQuery({
    queryKey: ['import-specialties', page],
    queryFn: () => api.importUnmatchedSpecialties({ page, limit: 20 }),
    enabled: tab === 'specialties',
  });

  const resolveFailure = useMutation({
    mutationFn: (id: string) => api.resolveImportFailure(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['import-failures'] }),
  });

  const reviewDuplicate = useMutation({
    mutationFn: ({ id, action }: { id: string; action: 'approve' | 'reject' }) =>
      api.reviewImportDuplicate(id, action),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['import-duplicates'] }),
  });

  const tabs: { id: Tab; label: string }[] = [
    { id: 'batches', label: 'Import Batches' },
    { id: 'failures', label: 'Failed Rows' },
    { id: 'duplicates', label: 'Duplicate Reviews' },
    { id: 'specialties', label: 'Unmatched Specialties' },
  ];

  return (
    <div>
      <PageHeader
        title="Data Import"
        description="Review MDPCZ/HPA import batches, failed rows, duplicate merges, and specialty mappings"
      />

      <div className="mb-4 flex flex-wrap gap-2">
        {tabs.map((t) => (
          <button
            key={t.id}
            type="button"
            className={tab === t.id ? 'btn-primary' : 'btn-secondary'}
            onClick={() => { setTab(t.id); setPage(1); }}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'batches' && (
        <>
          {batches.isLoading && <LoadingState />}
          {batches.error && <ErrorState message={(batches.error as Error).message} />}
          {batches.data && (
            <>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Source</th>
                      <th>Status</th>
                      <th>Rows</th>
                      <th>Imported</th>
                      <th>Failed</th>
                      <th>Facilities</th>
                      <th>Providers</th>
                      <th>Started</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(batches.data.batches as Record<string, unknown>[]).map((b) => (
                      <tr key={String(b.id)}>
                        <td>{String(b.sourceFile)}</td>
                        <td>
                          <span className="badge badge-gray mr-1">{String(b.status)}</span>
                          {b.dryRun && <span className="badge badge-yellow">dry-run</span>}
                        </td>
                        <td>{String(b.totalRows)}</td>
                        <td>{String(b.importedCount)}</td>
                        <td>{String(b.failedCount)}</td>
                        <td>{String(b.facilitiesCreated)}</td>
                        <td>{String(b.providersCreated)}</td>
                        <td>{new Date(String(b.startedAt)).toLocaleString()}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <PaginationBar
                page={batches.data.pagination.page}
                totalPages={batches.data.pagination.totalPages}
                onPage={setPage}
              />
            </>
          )}
        </>
      )}

      {tab === 'failures' && (
        <>
          <div className="mb-4">
            <select
              className="input max-w-[180px]"
              value={failureStatus}
              onChange={(e) => { setFailureStatus(e.target.value); setPage(1); }}
            >
              <option value="unresolved">Unresolved</option>
              <option value="resolved">Resolved</option>
            </select>
          </div>
          {failures.isLoading && <LoadingState />}
          {failures.error && <ErrorState message={(failures.error as Error).message} />}
          {failures.data && (
            <>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Row</th>
                      <th>Source File</th>
                      <th>Error</th>
                      <th>Message</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {(failures.data.failures as Record<string, unknown>[]).map((f) => (
                      <tr key={String(f.id)}>
                        <td>{String(f.rowNumber)}</td>
                        <td>{String(f.sourceFile)}</td>
                        <td><code>{String(f.errorCode)}</code></td>
                        <td className="max-w-md truncate">{String(f.errorMessage)}</td>
                        <td>
                          {!f.isResolved && (
                            <button
                              type="button"
                              className="text-sm text-teal-600"
                              onClick={() => resolveFailure.mutate(String(f.id))}
                            >
                              Resolve
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <PaginationBar
                page={failures.data.pagination.page}
                totalPages={failures.data.pagination.totalPages}
                onPage={setPage}
              />
            </>
          )}
        </>
      )}

      {tab === 'duplicates' && (
        <>
          {duplicates.isLoading && <LoadingState />}
          {duplicates.error && <ErrorState message={(duplicates.error as Error).message} />}
          {duplicates.data && (
            <>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Type</th>
                      <th>Confidence</th>
                      <th>Score</th>
                      <th>Reason</th>
                      <th />
                    </tr>
                  </thead>
                  <tbody>
                    {(duplicates.data.reviews as Record<string, unknown>[]).map((d) => (
                      <tr key={String(d.id)}>
                        <td>{String(d.entity_type)}</td>
                        <td>{String(d.confidence)}</td>
                        <td>{Number(d.match_score).toFixed(2)}</td>
                        <td className="max-w-md truncate">{String(d.match_reason)}</td>
                        <td className="space-x-2 whitespace-nowrap">
                          <button
                            type="button"
                            className="text-sm text-teal-600"
                            onClick={() => reviewDuplicate.mutate({ id: String(d.id), action: 'approve' })}
                          >
                            Approve merge
                          </button>
                          <button
                            type="button"
                            className="text-sm text-red-600"
                            onClick={() => reviewDuplicate.mutate({ id: String(d.id), action: 'reject' })}
                          >
                            Reject
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <PaginationBar
                page={duplicates.data.pagination.page}
                totalPages={duplicates.data.pagination.totalPages}
                onPage={setPage}
              />
            </>
          )}
        </>
      )}

      {tab === 'specialties' && (
        <>
          {specialties.isLoading && <LoadingState />}
          {specialties.error && <ErrorState message={(specialties.error as Error).message} />}
          {specialties.data && (
            <>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Raw Specialty</th>
                      <th>Count</th>
                      <th>Source File</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(specialties.data.specialties as Record<string, unknown>[]).map((s) => (
                      <tr key={String(s.id)}>
                        <td>{String(s.raw_specialty)}</td>
                        <td>{String(s.occurrence_count)}</td>
                        <td>{String(s.source_file)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <PaginationBar
                page={specialties.data.pagination.page}
                totalPages={specialties.data.pagination.totalPages}
                onPage={setPage}
              />
            </>
          )}
        </>
      )}

      <div className="mt-8 rounded-lg border border-slate-200 bg-slate-50 p-4 dark:border-slate-700 dark:bg-slate-800">
        <h3 className="mb-2 font-semibold">CLI Import Commands</h3>
        <pre className="overflow-x-auto text-sm text-slate-700 dark:text-slate-300">{`cd backend
npm run import:providers -- path/to/practitioners.xlsx
npm run import:providers -- path/to/practitioners.xlsx --dry-run
npm run import:providers -- path/to/practitioners.xlsx --reset
npm run import:providers -- path/to/practitioners.xlsx --skip-geocoding`}</pre>
      </div>
    </div>
  );
}
