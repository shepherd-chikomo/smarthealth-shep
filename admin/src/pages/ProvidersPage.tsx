import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '../components/ui';

export function ProvidersPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');

  const { data, isLoading, error } = useQuery({
    queryKey: ['admin-providers', page, q, status],
    queryFn: () => api.providers({ page, limit: 20, q, status: status || undefined }),
  });

  const verify = useMutation({
    mutationFn: ({ id, verified }: { id: string; verified: boolean }) => api.verifyProvider(id, verified),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-providers'] }),
  });

  const suspend = useMutation({
    mutationFn: ({ id, suspended }: { id: string; suspended: boolean }) =>
      api.suspendProvider(id, suspended, 'Admin action'),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-providers'] }),
  });

  return (
    <div>
      <PageHeader title="Provider Management" description="Verify doctors, review ratings, suspend providers" />
      <div className="mb-4 flex flex-wrap gap-3">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} />
        <select className="input max-w-[160px]" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
          <option value="">All</option>
          <option value="verified">Verified</option>
          <option value="unverified">Unverified</option>
          <option value="suspended">Suspended</option>
        </select>
      </div>
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Name</th><th>Specialty</th><th>Facility</th><th>Rating</th><th>Status</th><th /></tr></thead>
              <tbody>
                {(data.providers as Record<string, unknown>[]).map((p) => (
                  <tr key={String(p.id)}>
                    <td>{String(p.name)}</td>
                    <td>{String(p.specialty ?? '—')}</td>
                    <td>{String(p.facilityName)}</td>
                    <td>{String(p.averageRating)} ({String(p.reviewCount)})</td>
                    <td>
                      {p.isVerified && <span className="badge badge-green mr-1">Verified</span>}
                      {p.isSuspended && <span className="badge badge-red">Suspended</span>}
                    </td>
                    <td className="space-x-2 whitespace-nowrap">
                      {!p.isVerified && (
                        <button type="button" className="text-sm text-teal-600" onClick={() => verify.mutate({ id: String(p.id), verified: true })}>Verify</button>
                      )}
                      {!p.isSuspended ? (
                        <button type="button" className="text-sm text-red-600" onClick={() => suspend.mutate({ id: String(p.id), suspended: true })}>Suspend</button>
                      ) : (
                        <button type="button" className="text-sm text-teal-600" onClick={() => suspend.mutate({ id: String(p.id), suspended: false })}>Restore</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={data.pagination.page} totalPages={data.pagination.totalPages} onPage={setPage} />
        </>
      )}
    </div>
  );
}
