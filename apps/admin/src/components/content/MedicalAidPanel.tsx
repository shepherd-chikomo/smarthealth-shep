import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';
import { ErrorState, LoadingState, PaginationBar, SearchBar } from '../ui';

export function MedicalAidPanel() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [name, setName] = useState('');
  const [pendingPage, setPendingPage] = useState(1);
  const [saveError, setSaveError] = useState('');

  const list = useQuery({
    queryKey: ['medical-aid-schemes-admin', page, q],
    queryFn: () => api.medicalAidSchemes({ page, limit: 20, q }),
  });

  const pending = useQuery({
    queryKey: ['medical-aid-submissions-admin', pendingPage],
    queryFn: () => api.medicalAidSubmissions({ page: pendingPage, limit: 20, status: 'pending' }),
  });

  const create = useMutation({
    mutationFn: () => api.createMedicalAidScheme({ name: name.trim() }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['medical-aid-schemes-admin'] });
      setName('');
      setSaveError('');
    },
    onError: (err: Error) => setSaveError(err.message),
  });

  const approve = useMutation({
    mutationFn: (id: string) => api.approveMedicalAidSubmission(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['medical-aid-submissions-admin'] });
      qc.invalidateQueries({ queryKey: ['medical-aid-schemes-admin'] });
    },
  });

  const reject = useMutation({
    mutationFn: (id: string) => api.rejectMedicalAidSubmission(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['medical-aid-submissions-admin'] }),
  });

  const remove = useMutation({
    mutationFn: (id: string) => api.deleteMedicalAidScheme(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['medical-aid-schemes-admin'] }),
  });

  return (
    <div className="space-y-8">
      <section>
        <h2 className="mb-2 font-semibold">Medical aid schemes</h2>
        <div className="mb-3 flex flex-wrap gap-2">
          <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search schemes…" />
          <input className="input" placeholder="New scheme name" value={name} onChange={(e) => setName(e.target.value)} />
          <button type="button" className="btn-primary" disabled={!name.trim() || create.isPending} onClick={() => create.mutate()}>
            Add scheme
          </button>
        </div>
        {saveError && <p className="mb-2 text-sm text-red-600">{saveError}</p>}
        {list.isLoading && <LoadingState />}
        {list.error && <ErrorState message={(list.error as Error).message} />}
        {list.data && (
          <>
            <div className="table-wrap">
              <table className="data-table">
                <thead><tr><th>Name</th><th>Key</th><th>Active</th><th /></tr></thead>
                <tbody>
                  {list.data.schemes.map((s) => (
                    <tr key={s.id}>
                      <td>{s.name}</td>
                      <td className="text-xs">{s.schemeKey}</td>
                      <td>{s.isActive ? 'Yes' : 'No'}</td>
                      <td><button type="button" className="text-sm text-red-600" onClick={() => remove.mutate(s.id)}>Delete</button></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <PaginationBar page={page} totalPages={list.data.pagination.totalPages} onPage={setPage} />
          </>
        )}
      </section>

      <section>
        <h2 className="mb-2 font-semibold">Pending facility submissions</h2>
        {pending.isLoading && <LoadingState />}
        {pending.data && pending.data.submissions.length === 0 && (
          <p className="text-sm text-slate-500">No pending medical aid submissions.</p>
        )}
        {pending.data && pending.data.submissions.length > 0 && (
          <>
            <div className="table-wrap">
              <table className="data-table">
                <thead><tr><th>Scheme</th><th>Facility</th><th>Submitted</th><th /></tr></thead>
                <tbody>
                  {pending.data.submissions.map((s) => (
                    <tr key={s.id}>
                      <td>{s.proposedName}</td>
                      <td>{s.facilityName ?? s.facilityId}</td>
                      <td>{new Date(s.createdAt).toLocaleString()}</td>
                      <td className="space-x-2 whitespace-nowrap">
                        <button type="button" className="text-sm text-teal-600" onClick={() => approve.mutate(s.id)}>Approve</button>
                        <button type="button" className="text-sm text-red-600" onClick={() => reject.mutate(s.id)}>Reject</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <PaginationBar page={pendingPage} totalPages={pending.data.pagination.totalPages} onPage={setPendingPage} />
          </>
        )}
      </section>
    </div>
  );
}
