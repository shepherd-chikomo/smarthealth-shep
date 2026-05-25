import { useEffect, useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../../lib/api';
import type { ImportReviewQueueItem } from '../../lib/api';

function parseRawRows(rawData: unknown): Record<string, unknown>[] {
  if (Array.isArray(rawData)) return rawData as Record<string, unknown>[];
  return [];
}

function rowLabel(raw: Record<string, unknown>, index: number): string {
  const name = raw.facilityName ?? raw.facility_name ?? `Row ${index + 1}`;
  const holder = raw.practitionerName
    ?? [raw.practitionerFirstName, raw.practitionerLastName].filter(Boolean).join(' ');
  return `${String(name)}${holder ? ` · ${holder}` : ''}`;
}

interface Props {
  item: ImportReviewQueueItem;
  onDone: () => void;
}

export function AmbiguousFacilityPanel({ item, onDone }: Props) {
  const qc = useQueryClient();
  const rows = parseRawRows(item.rawData);
  const first = rows[0] ?? {};

  const [facilityName, setFacilityName] = useState(String(first.facilityName ?? item.facilityName ?? ''));
  const [address, setAddress] = useState(String(first.address ?? ''));
  const [city, setCity] = useState(String(first.city ?? item.facilityCity ?? ''));
  const [practitionerFirstName, setPractitionerFirstName] = useState(
    String(first.practitionerFirstName ?? '').trim(),
  );
  const [practitionerLastName, setPractitionerLastName] = useState(
    String(first.practitionerLastName ?? '').trim(),
  );
  const [error, setError] = useState('');

  useEffect(() => {
    const f = rows[0] ?? {};
    setFacilityName(String(f.facilityName ?? item.facilityName ?? ''));
    setAddress(String(f.address ?? ''));
    setCity(String(f.city ?? item.facilityCity ?? ''));
    setPractitionerFirstName(String(f.practitionerFirstName ?? '').trim());
    setPractitionerLastName(String(f.practitionerLastName ?? '').trim());
  }, [item.id]);

  const resolve = useMutation({
    mutationFn: (mode: 'merged' | 'distinct') =>
      api.resolveAmbiguousFacility({
        queueItemId: item.id,
        mode,
        facilityName: mode === 'merged' ? facilityName : undefined,
        address: mode === 'merged' ? address : undefined,
        city: mode === 'merged' ? city : undefined,
        practitionerFirstName: mode === 'merged' ? practitionerFirstName : undefined,
        practitionerLastName: mode === 'merged' ? practitionerLastName : undefined,
      }),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['import-review-queue'] });
      void qc.invalidateQueries({ queryKey: ['admin-facilities'] });
      onDone();
    },
    onError: (err: Error) => setError(err.message),
  });

  return (
    <div className="mt-3 space-y-3 border-t border-slate-200 pt-3 dark:border-slate-700">
      <p className="text-xs text-slate-500">{item.notes}</p>

      {rows.length > 0 && (
        <div className="overflow-x-auto">
          <table className="w-full text-xs">
            <thead>
              <tr className="border-b text-left text-slate-500">
                <th className="p-2">#</th>
                <th className="p-2">Facility</th>
                <th className="p-2">Address</th>
                <th className="p-2">City</th>
                <th className="p-2">Role-holder</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((raw, i) => (
                <tr key={i} className="border-b border-slate-100 dark:border-slate-800">
                  <td className="p-2">{i + 1}</td>
                  <td className="p-2">{String(raw.facilityName ?? '—')}</td>
                  <td className="p-2">{String(raw.address ?? '—')}</td>
                  <td className="p-2">{String(raw.city ?? '—')}</td>
                  <td className="p-2">{rowLabel(raw, i).split('·').pop()?.trim() ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <div className="space-y-2 rounded-lg border border-slate-200 p-3 dark:border-slate-700">
        <p className="text-sm font-medium">Edit and save as one facility</p>
        <input className="input w-full" placeholder="Facility name" value={facilityName} onChange={(e) => setFacilityName(e.target.value)} />
        <input className="input w-full" placeholder="Address" value={address} onChange={(e) => setAddress(e.target.value)} />
        <input className="input w-full" placeholder="City" value={city} onChange={(e) => setCity(e.target.value)} />
        <div className="grid grid-cols-2 gap-2">
          <input className="input" placeholder="Role-holder first name" value={practitionerFirstName} onChange={(e) => setPractitionerFirstName(e.target.value)} />
          <input className="input" placeholder="Role-holder last name" value={practitionerLastName} onChange={(e) => setPractitionerLastName(e.target.value)} />
        </div>
        <button
          type="button"
          className="btn-primary"
          disabled={resolve.isPending}
          onClick={() => { setError(''); resolve.mutate('merged'); }}
        >
          {resolve.isPending ? 'Saving…' : 'Save merged facility'}
        </button>
      </div>

      <div className="rounded-lg border border-slate-200 p-3 dark:border-slate-700">
        <p className="text-sm font-medium">These are distinct facilities (not a conflict)</p>
        <p className="mb-2 text-xs text-slate-500">
          Creates separate facilities for each row and remembers this decision for future HPA imports.
        </p>
        <button
          type="button"
          className="btn-secondary"
          disabled={resolve.isPending}
          onClick={() => { setError(''); resolve.mutate('distinct'); }}
        >
          Accept as distinct facilities
        </button>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  );
}
