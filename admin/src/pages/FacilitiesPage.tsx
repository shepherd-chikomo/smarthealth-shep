import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Check } from 'lucide-react';
import { api } from '../lib/api';
import type { ImportReviewQueueItem } from '../lib/api';
import { ErrorState, LoadingState, Modal, PageHeader, PaginationBar, SearchBar } from '../components/ui';
import { AmbiguousFacilityPanel } from '../components/import-queue/AmbiguousFacilityPanel';
import { UnlinkedPractitionerPanel } from '../components/import-queue/UnlinkedPractitionerPanel';
import { NoEmailPractitionerPanel } from '../components/import-queue/NoEmailPractitionerPanel';
import { ManualValidationPanel } from '../components/import-queue/ManualValidationPanel';
import { GeocodingFailuresTab } from '../components/facilities/GeocodingFailuresTab';

type Tab =
  | 'facilities'
  | 'geocoding'
  | 'manual_association'
  | 'ambiguous_facility'
  | 'unlinked_practitioner'
  | 'no_email_practitioner'
  | 'manual_validation';

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
  const [q, setQ] = useState('');
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [associateFacilityId, setAssociateFacilityId] = useState<string | null>(null);
  const [providerSearch, setProviderSearch] = useState('');
  const [selectedProviderId, setSelectedProviderId] = useState('');
  const [selectedQueueId, setSelectedQueueId] = useState<string | undefined>();
  const [geocodingId, setGeocodingId] = useState<string | null>(null);

  const facilities = useQuery({
    queryKey: ['admin-facilities', 'all', page, q],
    queryFn: () => api.adminFacilities({ page, limit: 20, q: q || undefined }),
    enabled: tab === 'facilities',
  });

  const queueType =
    tab !== 'facilities' && tab !== 'manual_validation' && tab !== 'geocoding'
      ? tab
      : undefined;

  const queue = useQuery({
    queryKey: ['import-review-queue', page, queueType, q],
    queryFn: () => api.importReviewQueue({ page, limit: 20, queueType, q: q || undefined }),
    enabled: !!queueType,
  });

  const validation = useQuery({
    queryKey: ['manual-validation', page, q],
    queryFn: () => api.manualValidationTickets({ page, limit: 20, status: 'submitted', q: q || undefined }),
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

  const geocode = useMutation({
    mutationFn: (facilityId: string) => {
      setGeocodingId(facilityId);
      return api.geocodeFacility(facilityId);
    },
    onSettled: () => setGeocodingId(null),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['admin-facilities'] });
    },
  });

  function geocodeTooltip(quality: string | null, geocodedAt: string | null): string {
    const parts: string[] = [];
    if (quality) parts.push(quality);
    if (geocodedAt) parts.push(new Date(geocodedAt).toLocaleString());
    return parts.length > 0 ? parts.join(' · ') : 'Geocoded';
  }

  const tabs: { id: Tab; label: string }[] = [
    { id: 'facilities', label: 'All Facilities' },
    { id: 'geocoding', label: 'Geocoding' },
    { id: 'manual_association', label: 'Manual Association' },
    { id: 'ambiguous_facility', label: 'Ambiguous Facilities' },
    { id: 'unlinked_practitioner', label: 'Unlinked Practitioners' },
    { id: 'no_email_practitioner', label: 'No Email' },
    { id: 'manual_validation', label: 'Manual Validation' },
  ];

  function queueTitle(item: ImportReviewQueueItem): string {
    if (item.facilityName) return item.facilityName;
    if (item.providerName) return item.providerName;
    if (Array.isArray(item.rawData) && item.rawData.length > 0) {
      const raw = item.rawData[0] as Record<string, unknown>;
      if (raw.facilityName) return String(raw.facilityName);
    }
    return 'Review item';
  }

  function renderQueuePanel(item: ImportReviewQueueItem) {
    if (expandedId !== item.id) return null;
    const onDone = () => setExpandedId(null);
    if (item.queueType === 'ambiguous_facility') {
      return <AmbiguousFacilityPanel item={item} onDone={onDone} />;
    }
    if (item.queueType === 'unlinked_practitioner') {
      return <UnlinkedPractitionerPanel item={item} onDone={onDone} />;
    }
    if (item.queueType === 'no_email_practitioner') {
      return <NoEmailPractitionerPanel item={item} onDone={onDone} />;
    }
    return null;
  }

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
            onClick={() => { setTab(t.id); setPage(1); setExpandedId(null); }}
          >
            {t.label}
          </button>
        ))}
      </div>

      <div className="mb-4 flex flex-wrap gap-3">
        <SearchBar
          value={q}
          onChange={(v) => { setQ(v); setPage(1); }}
          placeholder="Search name, city, role-holder, reg no…"
        />
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
                    <th className="p-3">Geocode</th>
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
                      <td className="p-3">
                        {f.isGeocodedUpToDate ? (
                          <span
                            className="inline-flex text-teal-500"
                            title={geocodeTooltip(f.geocodeQuality, f.geocodedAt)}
                          >
                            <Check className="h-5 w-5" aria-label="Geocoded" />
                          </span>
                        ) : (
                          <button
                            type="button"
                            className="btn-secondary text-xs"
                            disabled={geocodingId === f.id}
                            onClick={() => geocode.mutate(f.id)}
                          >
                            {geocodingId === f.id ? 'Geocoding…' : 'Geocode'}
                          </button>
                        )}
                      </td>
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

      {tab === 'geocoding' && (
        <GeocodingFailuresTab page={page} q={q} onPage={setPage} />
      )}

      {queueType && (
        <>
          {queue.isLoading && <LoadingState />}
          {queue.error && <ErrorState message={(queue.error as Error).message} />}
          {queue.data && (
            <div className="card space-y-3 p-5">
              <p className="text-sm text-slate-500">{queueLabels[queueType] ?? queueType}</p>
              {queue.data.items.length === 0 && (
                <p className="text-sm text-slate-500">No pending items.</p>
              )}
              {queue.data.items.map((item) => (
                <div key={item.id} className="rounded-lg border border-slate-200 p-4 dark:border-slate-700">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <div>
                      <p className="font-medium">{queueTitle(item)}</p>
                      <p className="text-xs text-slate-500">{item.notes}</p>
                      {item.registrationNumber && (
                        <p className="text-xs text-slate-500">Reg: {item.registrationNumber}</p>
                      )}
                    </div>
                    <div className="flex shrink-0 gap-2">
                      {item.queueType === 'manual_association' && item.facilityId && (
                        <button
                          type="button"
                          className="btn-primary text-xs"
                          onClick={() => {
                            setAssociateFacilityId(item.facilityId);
                            setSelectedQueueId(item.id);
                          }}
                        >
                          Associate practitioner
                        </button>
                      )}
                      {['ambiguous_facility', 'unlinked_practitioner', 'no_email_practitioner'].includes(item.queueType) && (
                        <button
                          type="button"
                          className="btn-secondary text-xs"
                          onClick={() => setExpandedId(expandedId === item.id ? null : item.id)}
                        >
                          {expandedId === item.id ? 'Close' : 'Review & resolve'}
                        </button>
                      )}
                    </div>
                  </div>
                  {renderQueuePanel(item)}
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
            <div className="card space-y-3 p-5">
              {validation.data.tickets.length === 0 && (
                <p className="text-sm text-slate-500">No pending tickets.</p>
              )}
              {validation.data.tickets.map((t) => (
                <div key={t.id} className="rounded-lg border p-4">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <div>
                      <p className="font-medium">{t.registrationNumber} — {t.specialty}</p>
                      <p className="text-sm text-slate-500">
                        {t.submitterName ?? 'Unknown'} · {t.submitterEmail ?? 'No email'}
                      </p>
                      <p className="text-xs text-slate-400">Status: {t.status}</p>
                    </div>
                    <button
                      type="button"
                      className="btn-secondary text-xs"
                      onClick={() => setExpandedId(expandedId === t.id ? null : t.id)}
                    >
                      {expandedId === t.id ? 'Close' : 'Review'}
                    </button>
                  </div>
                  {expandedId === t.id && (
                    <ManualValidationPanel ticket={t} onDone={() => setExpandedId(null)} />
                  )}
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {associateFacilityId && (
        <Modal
          title="Associate practitioner"
          onClose={() => setAssociateFacilityId(null)}
          maxWidth="max-w-md"
        >
          <div className="space-y-3">
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
        </Modal>
      )}
    </div>
  );
}
