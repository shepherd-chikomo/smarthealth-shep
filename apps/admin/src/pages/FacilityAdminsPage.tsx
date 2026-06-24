import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '../components/ui';

export function FacilityAdminsPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [userId, setUserId] = useState('');
  const [facilityId, setFacilityId] = useState('');

  const { data, isLoading, error } = useQuery({
    queryKey: ['facility-admins', page, q],
    queryFn: () => api.facilityAdmins({ page, limit: 20, q }),
  });

  const create = useMutation({
    mutationFn: () => api.createFacilityAdmin({ userId, facilityId }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['facility-admins'] });
      setUserId('');
      setFacilityId('');
    },
  });

  const remove = useMutation({
    mutationFn: (id: string) => api.deleteFacilityAdmin(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['facility-admins'] }),
  });

  return (
    <div>
      <PageHeader title="Facility Admins" description="Manage facility administrator access" />
      <div className="card mb-6 grid gap-3 p-4 md:grid-cols-3">
        <input className="input" placeholder="User UUID" value={userId} onChange={(e) => setUserId(e.target.value)} />
        <input className="input" placeholder="Facility UUID" value={facilityId} onChange={(e) => setFacilityId(e.target.value)} />
        <button type="button" className="btn-primary" onClick={() => create.mutate()} disabled={!userId || !facilityId}>Add admin</button>
      </div>
      <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap mt-4">
            <table className="data-table">
              <thead><tr><th>Name</th><th>Email</th><th>Facility</th><th>Joined</th><th /></tr></thead>
              <tbody>
                {(data.admins as Record<string, string>[]).map((a) => (
                  <tr key={a.id}>
                    <td>{a.firstName} {a.lastName}</td>
                    <td>{a.email}</td>
                    <td>{a.facilityName}</td>
                    <td>{new Date(a.joinedAt).toLocaleDateString()}</td>
                    <td><button type="button" className="text-red-600 text-sm" onClick={() => remove.mutate(a.id)}>Remove</button></td>
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
