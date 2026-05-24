import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, PageHeader, PaginationBar } from '../components/ui';

type Tab = 'facilities' | 'manual_association' | 'ambiguous_facility' | 'unlinked_practitioner' | 'no_email_practitioner' | 'manual_validation';

const queueLabels: Record<string, string> = {
  manual_association: 'Manual Association',
  ambiguous_facility: 'Ambiguous Facilities',
  unlinked_practitioner: 'Unlinked Practitioners',
  no_email_practitioner: 'No Email (Manual Claim)',
};

export function FacilitiesPage() {
  const qc = useQueryClient();
  const [tab, setTab] = useState<Tab>('facilities');
  const [page, setPage] = useState(1);
  const [associateFacilityId, setAssociateFacilityId] = useState<string | null>(null);
  const [providerSearch, setProviderSearch] = useState('');
  const [selectedProviderId, setSelectedProviderId] = useState('');
  const [selectedQueueId, setSelectedQueueId] = useState<string | undefined>();

  const facilities = useQuery({
    queryKey: ['admin-facilities', page],
    queryFn: () => api.adminFacilities({ page, limit: 20 }),
    enabled: tab === 'facilities',
  });

  const queueType = tab !== 'facilities' && tab !== 'manual_validation' ? tab : undefined;

  const queue = useQuery({
    queryKey: ['import-review-queue', page, queueType],
    queryFn: () => api.importReviewQueue({ page, limit: 20, queueType }),
    enabled: !!queueType,
  });

  const validation = useQuery({
    queryKey: ['manual-validation', page],
    queryFn: () => api.manualValidationTickets({ page, limit: 20, status: 'submitted' }),
    enabled: tab === 'manual_validation',
  });

  const providerLookup = useQuery({
    queryKey: ['providers-for-association', providerSearch],
    queryFn: () => api.searchProvidersForAssociation({ q: providerSearch, limit: 10 }),
    enabled: associateFacilityId !== null && providerSearch.length >= 2,
  });

  const associate = useMutation({
    mutationFn: () =>
      api.associatePractitioner({
        facilityId: associateFacilityId!,
        providerId: selectedProviderId,
        queueItemId: selectedQueueId,
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['import-review-queue'] });
      qc.invalidateQueries({ queryKey: ['admin-facilities'] });
      setAssociateFacilityId(null);
      setSelectedProviderId('');
      setProviderSearch('');
    },
  });

  const tabs: { id: Tab; label: string }[] = [
    { id: 'facilities', label: 'All Facilities' },
    { id: 'manual_association', label: 'Manual Association' },
    { id: 'ambiguous_facility', label: 'Ambiguous Facilities' },
    { id: 'unlinked_practitioner', label: 'Unlinked Practitioners' },
    { id: 'no_email_practitioner', label: 'No Email' },
    { id: 'manual_validation', label: 'Manual Validation' },
  ];

  return (
    <div>
      <PageHeader
        title="Facilities"
        description="HPA facility registry, import review queues, and manual practitioner association"
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

      {tab === 'facilities' && (
        <>
          {facilities.isLoading && <LoadingState />}
          {facilities.error && <ErrorState message={(facilities.error as Error).message} />}
          {facilities.data && (
            <div className="card overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b text-left text-slate-500">
                    <th className="p-3">Name</th>
                    <th className="p-3">City</th>
                    <th className="p-3">Primary role-holder</th>
                    <th className="p-3">Linked</th>
                    <th className="p-3">Verified</th>
                    <th className="p-3">Claimed</th>
                  </tr>
                </thead>
                <tbody>
                  {facilities.data.facilities.map((f) => (
                    <tr key={f.id} className="border-b border-slate-100 dark:border-slate-800">
                      <td className="p-3 font-medium">{f.name}</td>
                      <td className="p-3">{f.city ?? '—'}</td>
                      <td className="p-3">{f.primaryRoleHolder?.trim() || '—'}</td>
                      <td className="p-3">{f.linkedProviderCount}</td>
                      <td className="p-3">{f.isVerified ? 'Yes' : 'No'}</td>
                      <td className="p-3">{f.isClaimed ? 'Yes' : 'No'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <PaginationBar page={page} totalPages={facilities.data.pagination.totalPages} onPage={setPage} />
            </div>
          )}
        </>
      )}

      {queueType && (
        <>
          {queue.isLoading && <LoadingState />}
          {queue.error && <ErrorState message={(queue.error as Error).message} />}
          {queue.data && (
            <div className="card space-y-3">
              <p className="text-sm text-slate-500">{queueLabels[queueType] ?? queueType}</p>
              {queue.data.items.length === 0 && (
                <p className="text-sm text-slate-500">No pending items.</p>
              )}
              {queue.data.items.map((item) => (
                <div key={item.id} className="rounded-lg border border-slate-200 p-4 dark:border-slate-700">
                  <p className="font-medium">{item.facilityName ?? item.providerName ?? 'Review item'}</p>
                  <p className="text-xs text-slate-500">{item.notes}</p>
                  {item.registrationNumber && (
                    <p className="text-xs text-slate-500">Reg: {item.registrationNumber}</p>
                  )}
                  {item.facilityId && tab === 'manual_association' && (
                    <button
                      type="button"
                      className="btn-primary mt-2"
                      onClick={() => {
                        setAssociateFacilityId(item.facilityId);
                        setSelectedQueueId(item.id);
                      }}
                    >
                      Associate practitioner
                    </button>
                  )}
                </div>
              ))}
              <PaginationBar page={page} totalPages={queue.data.pagination.totalPages} onPage={setPage} />
            </div>
          )}
        </>
      )}

      {tab === 'manual_validation' && (
        <>
          {validation.isLoading && <LoadingState />}
          {validation.data && (
            <div className="card space-y-3">
              {validation.data.tickets.map((t) => (
                <div key={t.id} className="rounded-lg border p-4">
                  <p className="font-medium">{t.registrationNumber} — {t.specialty}</p>
                  <p className="text-sm text-slate-500">
                    {t.submitterName ?? 'Unknown'} · {t.submitterEmail ?? 'No email'}
                  </p>
                  <p className="text-xs text-slate-400">Status: {t.status}</p>
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {associateFacilityId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="card w-full max-w-md space-y-3">
            <h3 className="font-semibold">Associate practitioner</h3>
            <input
              className="input w-full"
              placeholder="Search by name or registration number…"
              value={providerSearch}
              onChange={(e) => setProviderSearch(e.target.value)}
            />
            <ul className="max-h-48 space-y-1 overflow-y-auto">
              {providerLookup.data?.providers.map((p) => (
                <li key={p.id}>
                  <button
                    type="button"
                    className={`w-full rounded p-2 text-left text-sm ${
                      selectedProviderId === p.id ? 'bg-teal-50 dark:bg-teal-950' : 'hover:bg-slate-50 dark:hover:bg-slate-800'
                    }`}
                    onClick={() => setSelectedProviderId(p.id)}
                  >
                    {p.name} · {p.registrationNumber}
                  </button>
                </li>
              ))}
            </ul>
            <div className="flex gap-2">
              <button
                type="button"
                className="btn-primary flex-1"
                disabled={!selectedProviderId || associate.isPending}
                onClick={() => associate.mutate()}
              >
                Confirm
              </button>
              <button type="button" className="btn-secondary" onClick={() => setAssociateFacilityId(null)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
