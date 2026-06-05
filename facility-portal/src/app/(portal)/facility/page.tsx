'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { FACILITY_CATEGORY_OPTIONS } from '@/lib/facility-categories';
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
  const [facilityTypes, setFacilityTypes] = useState<string[]>([]);
  const [categoryError, setCategoryError] = useState<string | null>(null);

  const f = data?.facility as Record<string, unknown> | undefined;

  useEffect(() => {
    if (!f) return;
    const types = Array.isArray(f.facilityTypes)
      ? (f.facilityTypes as string[])
      : f.facilityType
        ? [String(f.facilityType)]
        : [];
    setFacilityTypes(types);
  }, [f]);

  const save = useMutation({
    mutationFn: () => {
      if (facilityTypes.length === 0) {
        setCategoryError('Select at least one category');
        return Promise.reject(new Error('Select at least one category'));
      }
      setCategoryError(null);
      return api.updateFacilityProfile(facilityId!, {
        ...form,
        facilityTypes,
      });
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] }),
  });

  const toggleCategory = (id: string) => {
    setCategoryError(null);
    setFacilityTypes((prev) =>
      prev.includes(id) ? prev.filter((t) => t !== id) : [...prev, id],
    );
  };

  return (
    <div>
      <PageHeader
        title="Facility Profile"
        description="Manage your facility details and how patients find you"
      />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {f && (
        <form
          className="card max-w-2xl space-y-6"
          onSubmit={(e) => {
            e.preventDefault();
            save.mutate();
          }}
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

          <div>
            <label className="text-sm font-medium">Facility categories</label>
            <p className="mt-1 text-sm text-slate-600">
              Select every service your facility offers. Patients see you under each category on
              the MyHealth home screen (for example Clinics and Dental).
            </p>
            <div className="mt-3 grid gap-2 sm:grid-cols-2">
              {FACILITY_CATEGORY_OPTIONS.map((option) => {
                const checked = facilityTypes.includes(option.id);
                return (
                  <label
                    key={option.id}
                    className={`flex cursor-pointer items-center gap-2 rounded-lg border px-3 py-2 text-sm ${
                      checked
                        ? 'border-teal-600 bg-teal-50 text-teal-900'
                        : 'border-slate-200 bg-white text-slate-700'
                    }`}
                  >
                    <input
                      type="checkbox"
                      className="rounded border-slate-300"
                      checked={checked}
                      onChange={() => toggleCategory(option.id)}
                    />
                    {option.label}
                  </label>
                );
              })}
            </div>
            {categoryError && (
              <p className="mt-2 text-sm text-red-600">{categoryError}</p>
            )}
            {save.isError && (
              <p className="mt-2 text-sm text-red-600">{(save.error as Error).message}</p>
            )}
          </div>

          <button type="submit" className="btn-primary" disabled={save.isPending}>
            {save.isPending ? 'Saving…' : 'Save changes'}
          </button>
          {save.isSuccess && <p className="text-sm text-teal-600">Saved successfully.</p>}
        </form>
      )}
    </div>
  );
}
