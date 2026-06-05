import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api, type AdminFacility } from '../../lib/api';
import { ErrorState, LoadingState, Modal, PaginationBar } from '../ui';

const statusLabels: Record<AdminFacility['geocodeStatus'], string> = {
  ok: 'OK',
  missing: 'Missing coordinates',
  low_quality: 'Low quality',
};

interface Props {
  page: number;
  q: string;
  onPage: (page: number) => void;
}

export function GeocodingFailuresTab({ page, q, onPage }: Props) {
  const qc = useQueryClient();
  const [editFacility, setEditFacility] = useState<AdminFacility | null>(null);
  const [name, setName] = useState('');
  const [address, setAddress] = useState('');
  const [city, setCity] = useState('');
  const [formError, setFormError] = useState('');
  const [geocodingId, setGeocodingId] = useState<string | null>(null);

  const failures = useQuery({
    queryKey: ['admin-facilities', 'geocoding', page, q],
    queryFn: () =>
      api.adminFacilities({ page, limit: 20, q: q || undefined, queue: 'geocoding' }),
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

  const saveAddress = useMutation({
    mutationFn: () =>
      api.updateFacilityAddress(editFacility!.id, {
        name: name.trim(),
        address: address.trim(),
        city: city.trim(),
      }),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['admin-facilities'] });
      setEditFacility(null);
      setFormError('');
    },
    onError: (err: Error) => setFormError(err.message),
  });

  function openEdit(f: AdminFacility) {
    setEditFacility(f);
    setName(f.name);
    setAddress(f.address ?? '');
    setCity(f.city ?? '');
    setFormError('');
  }

  if (failures.isLoading) return <LoadingState />;
  if (failures.error) return <ErrorState message={(failures.error as Error).message} />;
  if (!failures.data) return null;

  return (
    <>
      <div className="card overflow-x-auto">
        <p className="border-b border-slate-100 p-3 text-sm text-slate-500 dark:border-slate-800">
          Facilities missing coordinates or with low-precision geocoding. Edit the address or run
          Geocode to retry.
        </p>
        {failures.data.facilities.length === 0 ? (
          <p className="p-5 text-sm text-slate-500">No geocoding failures.</p>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b text-left text-slate-500">
                <th className="p-3">Name</th>
                <th className="p-3">Address</th>
                <th className="p-3">City</th>
                <th className="p-3">Status</th>
                <th className="p-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {failures.data.facilities.map((f) => (
                <tr key={f.id} className="border-b border-slate-100 dark:border-slate-800">
                  <td className="p-3 font-medium">{f.name}</td>
                  <td className="p-3">{f.address ?? '—'}</td>
                  <td className="p-3">{f.city ?? '—'}</td>
                  <td className="p-3">{statusLabels[f.geocodeStatus] ?? f.geocodeStatus}</td>
                  <td className="p-3">
                    <div className="flex flex-wrap gap-2">
                      <button
                        type="button"
                        className="btn-secondary text-xs"
                        onClick={() => openEdit(f)}
                      >
                        Edit address
                      </button>
                      <button
                        type="button"
                        className="btn-secondary text-xs"
                        disabled={geocodingId === f.id}
                        onClick={() => geocode.mutate(f.id)}
                      >
                        {geocodingId === f.id ? 'Geocoding…' : 'Geocode'}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <PaginationBar
          page={page}
          totalPages={failures.data.pagination.totalPages}
          onPage={onPage}
        />
      </div>

      {editFacility && (
        <Modal title="Edit facility address" onClose={() => setEditFacility(null)} maxWidth="max-w-md">
          <div className="space-y-3">
            <label className="block text-sm">
              <span className="text-slate-500">Facility name</span>
              <input
                className="input mt-1 w-full"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </label>
            <label className="block text-sm">
              <span className="text-slate-500">Address</span>
              <input
                className="input mt-1 w-full"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
              />
            </label>
            <label className="block text-sm">
              <span className="text-slate-500">City</span>
              <input
                className="input mt-1 w-full"
                value={city}
                onChange={(e) => setCity(e.target.value)}
              />
            </label>
            {formError && <p className="text-sm text-red-600">{formError}</p>}
            <div className="flex gap-2">
              <button
                type="button"
                className="btn-primary flex-1"
                disabled={saveAddress.isPending || !name.trim()}
                onClick={() => saveAddress.mutate()}
              >
                {saveAddress.isPending ? 'Saving…' : 'Save & geocode'}
              </button>
              <button type="button" className="btn-secondary" onClick={() => setEditFacility(null)}>
                Cancel
              </button>
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}
