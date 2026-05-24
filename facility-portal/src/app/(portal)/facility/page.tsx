'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';

export default function FacilityProfilePage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['facility-profile', facilityId],
    queryFn: () => api.facilityProfile(facilityId!),
    enabled: !!facilityId,
  });

  const [form, setForm] = useState<Record<string, string>>({});

  const save = useMutation({
    mutationFn: () => api.updateFacilityProfile(facilityId!, form),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] }),
  });

  const f = data?.facility as Record<string, unknown> | undefined;

  return (
    <div>
      <PageHeader title="Facility Profile" description="Manage your facility details" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {f && (
        <form
          className="card max-w-2xl space-y-4"
          onSubmit={(e) => { e.preventDefault(); save.mutate(); }}
        >
          {[
            ['name', 'Name', 'name'],
            ['description', 'Description', 'description'],
            ['addressLine1', 'Address', 'addressLine1'],
            ['city', 'City', 'city'],
            ['phone', 'Phone', 'phone'],
            ['email', 'Email', 'email'],
            ['website', 'Website', 'website'],
          ].map(([key, label, field]) => (
            <div key={key}>
              <label className="text-sm font-medium">{label}</label>
              <input
                className="input mt-1"
                defaultValue={String(f[field as string] ?? '')}
                onChange={(e) => setForm((prev) => ({ ...prev, [key]: e.target.value }))}
              />
            </div>
          ))}
          <button type="submit" className="btn-primary" disabled={save.isPending}>
            {save.isPending ? 'Saving…' : 'Save changes'}
          </button>
          {save.isSuccess && <p className="text-sm text-teal-600">Saved successfully.</p>}
        </form>
      )}
    </div>
  );
}
