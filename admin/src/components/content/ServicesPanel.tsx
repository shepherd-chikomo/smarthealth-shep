import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';
import { ErrorState, LoadingState, Modal, PaginationBar, SearchBar } from '../ui';

export function ServicesPanel() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [label, setLabel] = useState('');
  const [pendingPage, setPendingPage] = useState(1);
  const [saveError, setSaveError] = useState('');

  const list = useQuery({
    queryKey: ['facility-services-admin', page, q],
    queryFn: () => api.facilityServices({ page, limit: 20, q }),
  });

  const pending = useQuery({
    queryKey: ['service-submissions-admin', pendingPage],
    queryFn: () => api.serviceSubmissions({ page: pendingPage, limit: 20, status: 'pending' }),
  });

  const create = useMutation({
    mutationFn: () => api.createFacilityService({ label: label.trim(), isPreset: true }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['facility-services-admin'] });
      setLabel('');
      setSaveError('');
    },
    onError: (err: Error) => setSaveError(err.message),
  });

  const approve = useMutation({
    mutationFn: ({ id, isPreset }: { id: string; isPreset: boolean }) =>
      api.approveServiceSubmission(id, { isPreset }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['service-submissions-admin'] }),
  });

  const reject = useMutation({
    mutationFn: (id: string) => api.rejectServiceSubmission(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['service-submissions-admin'] }),
  });

  const remove = useMutation({
    mutationFn: (id: string) => api.deleteFacilityService(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['facility-services-admin'] }),
  });

  return (
    <div className="space-y-8">
      <section>
        <h2 className="mb-2 font-semibold">Global facility services</h2>
        <div className="mb-3 flex flex-wrap gap-2">
          <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search services…" />
          <input className="input" placeholder="New service label" value={label} onChange={(e) => setLabel(e.target.value)} />
          <button type="button" className="btn-primary" disabled={!label.trim() || create.isPending} onClick={() => create.mutate()}>
            Add service
          </button>
        </div>
        {saveError && <p className="mb-2 text-sm text-red-600">{saveError}</p>}
        {list.isLoading && <LoadingState />}
        {list.error && <ErrorState message={(list.error as Error).message} />}
        {list.data && (
          <>
            <div className="table-wrap">
              <table className="data-table">
                <thead><tr><th>Label</th><th>Slug</th><th>Preset</th><th>Active</th><th /></tr></thead>
                <tbody>
                  {list.data.services.map((s) => (
                    <tr key={s.id}>
                      <td>{s.label}</td>
                      <td className="text-xs">{s.slug}</td>
                      <td>{s.isPreset ? 'Yes' : 'No'}</td>
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
          <p className="text-sm text-slate-500">No pending service submissions.</p>
        )}
        {pending.data && pending.data.submissions.length > 0 && (
          <>
            <div className="table-wrap">
              <table className="data-table">
                <thead><tr><th>Service</th><th>Facility</th><th>Submitted</th><th /></tr></thead>
                <tbody>
                  {pending.data.submissions.map((s) => (
                    <tr key={s.id}>
                      <td>{s.proposedLabel}</td>
                      <td>{s.facilityName ?? s.facilityId}</td>
                      <td>{new Date(s.createdAt).toLocaleString()}</td>
                      <td className="space-x-2 whitespace-nowrap">
                        <button type="button" className="text-sm text-teal-600" onClick={() => approve.mutate({ id: s.id, isPreset: true })}>Approve</button>
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
