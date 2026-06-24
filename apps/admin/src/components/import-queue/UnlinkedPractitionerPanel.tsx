import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';
import type { ImportReviewQueueItem } from '../../lib/api';

interface Props {
  item: ImportReviewQueueItem;
  onDone: () => void;
}

export function UnlinkedPractitionerPanel({ item, onDone }: Props) {
  const qc = useQueryClient();
  const [facilitySearch, setFacilitySearch] = useState('');
  const [selectedFacilityId, setSelectedFacilityId] = useState('');
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');

  const facilities = useQuery({
    queryKey: ['facilities-for-association', facilitySearch],
    queryFn: () => api.searchFacilitiesForAssociation({ q: facilitySearch, limit: 10 }),
    enabled: facilitySearch.length >= 2,
  });

  const resolve = useMutation({
    mutationFn: (body: { action: 'associate' | 'no_link'; facilityId?: string; reason?: string }) =>
      api.resolveUnlinkedPractitioner(item.id, body),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['import-review-queue'] });
      onDone();
    },
    onError: (err: Error) => setError(err.message),
  });

  return (
    <div className="mt-3 space-y-3 border-t border-slate-200 pt-3 dark:border-slate-700">
      <p className="text-sm">
        <strong>{item.providerName ?? 'Unknown provider'}</strong>
        {item.registrationNumber ? ` · ${item.registrationNumber}` : ''}
      </p>
      <p className="text-xs text-slate-500">{item.notes}</p>

      <div className="space-y-2">
        <input
          className="input w-full"
          placeholder="Search facility to associate…"
          value={facilitySearch}
          onChange={(e) => setFacilitySearch(e.target.value)}
        />
        <ul className="max-h-32 space-y-1 overflow-y-auto">
          {facilities.data?.facilities.map((f) => (
            <li key={f.id}>
              <button
                type="button"
                className={`w-full rounded p-2 text-left text-sm ${
                  selectedFacilityId === f.id ? 'bg-teal-50 dark:bg-teal-950' : 'hover:bg-slate-50 dark:hover:bg-slate-800'
                }`}
                onClick={() => setSelectedFacilityId(f.id)}
              >
                {f.name} · {f.city ?? '—'}
              </button>
            </li>
          ))}
        </ul>
        <button
          type="button"
          className="btn-primary"
          disabled={!selectedFacilityId || resolve.isPending}
          onClick={() => {
            setError('');
            resolve.mutate({ action: 'associate', facilityId: selectedFacilityId });
          }}
        >
          Associate with facility
        </button>
      </div>

      <div className="space-y-2 border-t border-slate-200 pt-3 dark:border-slate-700">
        <input
          className="input w-full"
          placeholder="Reason (optional) — no facility link expected"
          value={reason}
          onChange={(e) => setReason(e.target.value)}
        />
        <button
          type="button"
          className="btn-secondary"
          disabled={resolve.isPending}
          onClick={() => {
            setError('');
            resolve.mutate({ action: 'no_link', reason: reason || undefined });
          }}
        >
          No facility link expected
        </button>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
