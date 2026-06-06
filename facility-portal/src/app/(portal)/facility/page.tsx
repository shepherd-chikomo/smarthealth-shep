'use client';

import dynamic from 'next/dynamic';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '@/lib/api';
import { FACILITY_CATEGORY_OPTIONS } from '@/lib/facility-categories';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';
import { LocationSaveModal } from '@/components/location-save-modal';
import type { MapPosition } from '@/components/facility-location-map';

const FacilityLocationMap = dynamic(
  () =>
    import('@/components/facility-location-map').then((m) => m.FacilityLocationMap),
  { ssr: false, loading: () => <p className="text-sm text-[var(--muted)]">Loading map…</p> },
);

function geocodeQualityLabel(quality: string | null | undefined): string {
  switch (quality) {
    case 'manual':
      return 'Set manually on map';
    case 'address':
      return 'Geocoded from address';
    case 'name':
      return 'Approximate location from name';
    case 'city_only':
    case 'city_centre':
      return 'City-centre estimate — drag the pin for accuracy';
    default:
      return 'Not set — click the map to place your facility';
  }
}

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
  const [mapPosition, setMapPosition] = useState<MapPosition | null>(null);
  const [pinDirty, setPinDirty] = useState(false);
  const [showLocationModal, setShowLocationModal] = useState(false);
  const pendingPayloadRef = useRef<Record<string, unknown> | null>(null);

  const f = data?.facility as Record<string, unknown> | undefined;

  const baseline = useMemo(
    () => ({
      addressLine1: f ? String(f.addressLine1 ?? '') : '',
      city: f ? String(f.city ?? '') : '',
    }),
    [f],
  );

  useEffect(() => {
    if (!f) return;
    const types = Array.isArray(f.facilityTypes)
      ? (f.facilityTypes as string[])
      : f.facilityType
        ? [String(f.facilityType)]
        : [];
    setFacilityTypes(types);

    const lat = f.latitude != null ? Number(f.latitude) : null;
    const lng = f.longitude != null ? Number(f.longitude) : null;
    if (lat != null && lng != null && !Number.isNaN(lat) && !Number.isNaN(lng)) {
      setMapPosition({ lat, lng });
    } else {
      setMapPosition(null);
    }
    setPinDirty(false);
    setForm({});
  }, [f?.id, f?.latitude, f?.longitude]);

  const effectiveAddress = form.addressLine1 ?? baseline.addressLine1;
  const effectiveCity = form.city ?? baseline.city;
  const addressChanged =
    effectiveAddress !== baseline.addressLine1 || effectiveCity !== baseline.city;

  const buildPayload = (locationMode?: 'manual' | 'geocode'): Record<string, unknown> => {
    const body: Record<string, unknown> = { ...form, facilityTypes };
    if (locationMode) body.locationMode = locationMode;
    if (locationMode === 'manual' && mapPosition) {
      body.latitude = mapPosition.lat;
      body.longitude = mapPosition.lng;
    }
    return body;
  };

  const submitProfile = (body: Record<string, unknown>) =>
    api.updateFacilityProfile(facilityId!, body);

  const save = useMutation({
    mutationFn: (body: Record<string, unknown>) => submitProfile(body),
    onSuccess: () => {
      setPinDirty(false);
      setShowLocationModal(false);
      pendingPayloadRef.current = null;
      qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] });
    },
  });

  const handleSave = (locationMode?: 'manual' | 'geocode') => {
    if (facilityTypes.length === 0) {
      setCategoryError('Select at least one category');
      return;
    }
    setCategoryError(null);

    if (addressChanged && pinDirty && !locationMode) {
      pendingPayloadRef.current = buildPayload();
      setShowLocationModal(true);
      return;
    }

    if (pinDirty && mapPosition && locationMode !== 'geocode') {
      save.mutate(buildPayload('manual'));
      return;
    }

    save.mutate(buildPayload(locationMode));
  };

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
            handleSave();
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
            <label className="text-sm font-medium">Location on map</label>
            <p className="mt-1 text-sm text-[var(--muted)]">
              Drag the pin or click the map to set where patients find you. This overrides
              automatic geocoding when you save.
            </p>
            <p className="mt-1 text-xs text-[var(--muted)]">
              {geocodeQualityLabel(f.geocodeQuality as string | null)}
              {mapPosition && (
                <>
                  {' '}
                  · {mapPosition.lat.toFixed(5)}, {mapPosition.lng.toFixed(5)}
                </>
              )}
            </p>
            <div className="mt-3">
              <FacilityLocationMap
                position={mapPosition}
                disabled={save.isPending}
                onChange={(pos) => {
                  setMapPosition(pos);
                  setPinDirty(true);
                }}
              />
            </div>
          </div>

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

      <LocationSaveModal
        open={showLocationModal}
        saving={save.isPending}
        onCancel={() => {
          setShowLocationModal(false);
          pendingPayloadRef.current = null;
        }}
        onKeepPin={() => {
          const base = pendingPayloadRef.current ?? buildPayload();
          save.mutate({
            ...base,
            locationMode: 'manual',
            latitude: mapPosition?.lat,
            longitude: mapPosition?.lng,
          });
        }}
        onRegeocode={() => {
          const base = pendingPayloadRef.current ?? buildPayload();
          const { latitude: _lat, longitude: _lng, locationMode: _mode, ...rest } = base;
          save.mutate({ ...rest, locationMode: 'geocode' });
        }}
      />
    </div>
  );
}
