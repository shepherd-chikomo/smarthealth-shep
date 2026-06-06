'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { api } from '@/lib/api';
import { PRESET_FACILITY_SERVICES, type FacilityServiceEntry, type ProfileSettings } from '@/lib/facility-services';

const TABS = [
  'General',
  'Logo',
  'Services',
  'Medical Aid',
  'Accessibility',
  'Booking',
  'Features',
] as const;

type Tab = (typeof TABS)[number];

function emptySettings(): ProfileSettings {
  return {
    services: [],
    medicalAids: [],
    accessibility: {},
    emergency: {},
    smarthealthFeatures: {},
    booking: { enabled: true, showSlots: true },
    waitTime: { mode: 'manual' },
  };
}

export function FacilityProfileTabs({
  facilityId,
  facility,
  onSaveGeneral,
  generalForm,
  setGeneralForm,
  facilityTypes,
  toggleCategory,
  categoryError,
  savingGeneral,
  generalSaved,
  mapSection,
}: {
  facilityId: string;
  facility: Record<string, unknown>;
  onSaveGeneral: () => void;
  generalForm: Record<string, string>;
  setGeneralForm: React.Dispatch<React.SetStateAction<Record<string, string>>>;
  facilityTypes: string[];
  toggleCategory: (id: string) => void;
  categoryError: string | null;
  savingGeneral: boolean;
  generalSaved: boolean;
  mapSection: React.ReactNode;
}) {
  const [tab, setTab] = useState<Tab>('General');
  const qc = useQueryClient();

  const { data: profileData } = useQuery({
    queryKey: ['facility-profile', facilityId],
    queryFn: () => api.facilityProfile(facilityId),
    enabled: !!facilityId,
  });

  const { data: catalogData } = useQuery({
    queryKey: ['medical-aid-catalog', facilityId],
    queryFn: () => api.medicalAidCatalog(facilityId),
    enabled: !!facilityId && tab === 'Medical Aid',
  });

  const { data: slotsData } = useQuery({
    queryKey: ['slots', facilityId],
    queryFn: () => api.slots(facilityId),
    enabled: !!facilityId && tab === 'Booking',
  });

  const profileSettings = useMemo(
    () => (profileData?.profileSettings as ProfileSettings | undefined) ?? emptySettings(),
    [profileData],
  );

  const [settings, setSettings] = useState<ProfileSettings | null>(null);
  const effective = settings ?? profileSettings;

  const saveSettings = useMutation({
    mutationFn: (body: Partial<ProfileSettings>) => api.updateProfileSettings(facilityId, body),
    onSuccess: () => {
      setSettings(null);
      qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] });
    },
  });

  const [logoPreviewUrl, setLogoPreviewUrl] = useState<string | null>(null);

  useEffect(() => {
    const url = profileData?.facility?.logoUrl;
    setLogoPreviewUrl(typeof url === 'string' && url.length > 0 ? url : null);
  }, [profileData?.facility?.logoUrl]);

  const uploadLogo = useMutation({
    mutationFn: (file: File) => api.uploadLogo(facilityId, file),
    onSuccess: (result) => {
      const url = (result as { logoUrl?: string })?.logoUrl;
      if (url) setLogoPreviewUrl(url);
      qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] });
    },
  });

  const removeLogo = useMutation({
    mutationFn: () => api.removeLogo(facilityId),
    onSuccess: () => {
      setLogoPreviewUrl(null);
      qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] });
    },
  });

  const saveSlots = useMutation({
    mutationFn: (body: Record<string, unknown>) => api.updateSlots(facilityId, body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['slots', facilityId] }),
  });

  const togglePresetService = (key: string) => {
    const preset = PRESET_FACILITY_SERVICES.find((s) => s.key === key);
    if (!preset) return;
    const exists = effective.services.find((s) => s.key === key);
    const nextServices = exists
      ? effective.services.filter((s) => s.key !== key)
      : [
          ...effective.services,
          {
            id: crypto.randomUUID(),
            key: preset.key,
            name: preset.name,
            iconKey: preset.iconKey,
            isCustom: false,
          },
        ];
    setSettings({ ...effective, services: nextServices });
  };

  const toggleMedicalAid = (schemeKey: string, name: string) => {
    const exists = effective.medicalAids.find((m) => m.schemeKey === schemeKey);
    const next = exists
      ? effective.medicalAids.filter((m) => m.schemeKey !== schemeKey)
      : [...effective.medicalAids, { schemeKey, name }];
    setSettings({ ...effective, medicalAids: next });
  };

  const toggleFlag = (
    group: 'accessibility' | 'emergency' | 'smarthealthFeatures',
    key: string,
  ) => {
    const current = effective[group] as Record<string, boolean | undefined>;
    setSettings({
      ...effective,
      [group]: { ...current, [key]: !current[key] },
    });
  };

  return (
    <div>
      <div className="mb-4 flex flex-wrap gap-2">
        {TABS.map((t) => (
          <button
            key={t}
            type="button"
            className={tab === t ? 'btn-primary text-sm' : 'btn-secondary text-sm'}
            onClick={() => setTab(t)}
          >
            {t}
          </button>
        ))}
      </div>

      {tab === 'General' && (
        <form
          className="card max-w-2xl space-y-6"
          onSubmit={(e) => {
            e.preventDefault();
            onSaveGeneral();
          }}
        >
          {[
            ['name', 'Name', 'name'],
            ['description', 'Description', 'description'],
            ['addressLine1', 'Address', 'addressLine1'],
            ['city', 'City', 'city'],
            ['phone', 'Phone', 'phone'],
            ['whatsappPhone', 'WhatsApp', 'whatsappPhone'],
            ['email', 'Email', 'email'],
            ['website', 'Website', 'website'],
          ].map(([key, label, field]) => (
            <div key={key}>
              <label className="text-sm font-medium">{label}</label>
              <input
                className="input mt-1"
                defaultValue={String(generalForm[field as string] ?? facility[field as string] ?? '')}
                onChange={(e) => setGeneralForm((prev) => ({ ...prev, [key]: e.target.value }))}
              />
            </div>
          ))}
          {mapSection}
          <button type="submit" className="btn-primary" disabled={savingGeneral}>
            {savingGeneral ? 'Saving…' : 'Save changes'}
          </button>
          {generalSaved && <p className="text-sm text-teal-600">Saved successfully.</p>}
          {categoryError && <p className="text-sm text-red-600">{categoryError}</p>}
        </form>
      )}

      {tab === 'Logo' && (
        <div className="card max-w-lg space-y-4">
          <p className="text-sm text-[var(--muted)]">
            Upload PNG, JPG, or WEBP (recommended 512×512). Shown on demand in the MyHealth app.
          </p>
          {logoPreviewUrl && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={logoPreviewUrl}
              alt="Facility logo"
              className="h-24 w-24 rounded-xl border object-cover"
            />
          )}
          <input
            type="file"
            accept="image/png,image/jpeg,image/webp"
            disabled={uploadLogo.isPending}
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (!file) return;
              const localPreview = URL.createObjectURL(file);
              setLogoPreviewUrl(localPreview);
              uploadLogo.mutate(file, {
                onSettled: () => URL.revokeObjectURL(localPreview),
              });
            }}
          />
          {uploadLogo.isPending && (
            <p className="text-sm text-[var(--muted)]">Uploading logo…</p>
          )}
          {uploadLogo.isSuccess && (
            <p className="text-sm text-teal-600">Logo uploaded successfully.</p>
          )}
          {uploadLogo.isError && (
            <p className="text-sm text-red-600">{(uploadLogo.error as Error).message}</p>
          )}
          {logoPreviewUrl && (
            <button
              type="button"
              className="btn-danger text-sm"
              disabled={removeLogo.isPending}
              onClick={() => removeLogo.mutate()}
            >
              Remove logo
            </button>
          )}
        </div>
      )}

      {tab === 'Services' && (
        <div className="card max-w-2xl space-y-4">
          <p className="text-sm text-[var(--muted)]">
            Services patients can book. Assign providers to services on the Doctors page.
          </p>
          <div className="grid gap-2 sm:grid-cols-2">
            {PRESET_FACILITY_SERVICES.map((preset) => {
              const checked = effective.services.some((s) => s.key === preset.key);
              return (
                <label key={preset.key} className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={checked}
                    onChange={() => togglePresetService(preset.key)}
                  />
                  {preset.name}
                </label>
              );
            })}
          </div>
          <CustomServiceForm
            onAdd={(name) => {
              const entry: FacilityServiceEntry = {
                id: crypto.randomUUID(),
                name,
                iconKey: 'custom',
                isCustom: true,
              };
              setSettings({ ...effective, services: [...effective.services, entry] });
            }}
          />
          <button
            type="button"
            className="btn-primary"
            disabled={saveSettings.isPending}
            onClick={() => saveSettings.mutate({ services: effective.services })}
          >
            Save services
          </button>
        </div>
      )}

      {tab === 'Medical Aid' && (
        <div className="card max-w-2xl space-y-4">
          <div className="grid gap-2 sm:grid-cols-2">
            {(catalogData?.schemes as { schemeKey: string; name: string }[] | undefined)?.map(
              (scheme) => {
                const checked = effective.medicalAids.some((m) => m.schemeKey === scheme.schemeKey);
                return (
                  <label key={scheme.schemeKey} className="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() => toggleMedicalAid(scheme.schemeKey, scheme.name)}
                    />
                    {scheme.name}
                  </label>
                );
              },
            )}
          </div>
          <button
            type="button"
            className="btn-primary"
            disabled={saveSettings.isPending}
            onClick={() => saveSettings.mutate({ medicalAids: effective.medicalAids })}
          >
            Save medical aid
          </button>
        </div>
      )}

      {tab === 'Accessibility' && (
        <div className="card max-w-2xl space-y-6">
          <section>
            <h3 className="font-semibold">Accessibility</h3>
            <div className="mt-2 grid gap-2 sm:grid-cols-2">
              {[
                ['wheelchair', 'Wheelchair accessible'],
                ['parking', 'Parking available'],
                ['elevator', 'Elevator available'],
                ['babyFacilities', 'Baby facilities'],
              ].map(([key, label]) => (
                <label key={key} className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={Boolean(effective.accessibility[key])}
                    onChange={() => toggleFlag('accessibility', key)}
                  />
                  {label}
                </label>
              ))}
            </div>
          </section>
          <section>
            <h3 className="font-semibold">Emergency services</h3>
            <div className="mt-2 grid gap-2 sm:grid-cols-2">
              {[
                ['department', 'Emergency department'],
                ['ambulance', 'Ambulance service'],
                ['trauma', 'Trauma unit'],
                ['icu', 'ICU'],
                ['is24Hour', '24-hour emergency'],
              ].map(([key, label]) => (
                <label key={key} className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={Boolean(effective.emergency[key])}
                    onChange={() => toggleFlag('emergency', key)}
                  />
                  {label}
                </label>
              ))}
            </div>
          </section>
          <button
            type="button"
            className="btn-primary"
            disabled={saveSettings.isPending}
            onClick={() =>
              saveSettings.mutate({
                accessibility: effective.accessibility,
                emergency: effective.emergency,
              })
            }
          >
            Save accessibility & emergency
          </button>
          <p className="text-sm text-[var(--muted)]">
            Operating hours: <Link href="/hours" className="text-teal-700 underline">configure hours</Link>
          </p>
        </div>
      )}

      {tab === 'Booking' && (
        <div className="card max-w-2xl space-y-4">
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={effective.booking.enabled !== false}
              onChange={() =>
                setSettings({
                  ...effective,
                  booking: { ...effective.booking, enabled: effective.booking.enabled === false },
                })
              }
            />
            Enable online booking
          </label>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={effective.booking.showSlots !== false}
              onChange={() =>
                setSettings({
                  ...effective,
                  booking: {
                    ...effective.booking,
                    showSlots: effective.booking.showSlots === false,
                  },
                })
              }
            />
            Show appointment slots on profile
          </label>
          <div>
            <label className="text-sm font-medium">Wait time (minutes)</label>
            <input
              type="number"
              className="input mt-1 w-32"
              min={0}
              value={effective.waitTime.minutes ?? ''}
              onChange={(e) =>
                setSettings({
                  ...effective,
                  waitTime: {
                    mode: 'manual',
                    minutes: e.target.value ? Number(e.target.value) : undefined,
                  },
                })
              }
            />
          </div>
          <button
            type="button"
            className="btn-primary"
            disabled={saveSettings.isPending}
            onClick={() =>
              saveSettings.mutate({
                booking: effective.booking,
                waitTime: effective.waitTime,
              })
            }
          >
            Save booking settings
          </button>
          {slotsData && (
            <div className="border-t pt-4">
              <p className="text-sm font-medium">Slot configuration</p>
              <button
                type="button"
                className="btn-secondary mt-2 text-sm"
                onClick={() =>
                  saveSlots.mutate({
                    ...(slotsData.settings as Record<string, unknown>),
                    slotDurationMinutes: Number(
                      (slotsData.settings as Record<string, unknown>).slotDurationMinutes ?? 30,
                    ),
                  })
                }
              >
                Sync slot defaults
              </button>
              <Link href="/slots" className="ml-2 text-sm text-teal-700 underline">
                Advanced slot settings
              </Link>
            </div>
          )}
        </div>
      )}

      {tab === 'Features' && (
        <div className="card max-w-2xl space-y-4">
          {[
            ['onlineBooking', 'Online booking enabled'],
            ['digitalPrescriptions', 'Digital prescriptions'],
            ['labResults', 'Lab results available'],
            ['patientPortal', 'Patient portal enabled'],
            ['telehealth', 'Telehealth enabled'],
          ].map(([key, label]) => (
            <label key={key} className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={Boolean(effective.smarthealthFeatures[key])}
                onChange={() => toggleFlag('smarthealthFeatures', key)}
              />
              {label}
            </label>
          ))}
          <button
            type="button"
            className="btn-primary"
            disabled={saveSettings.isPending}
            onClick={() =>
              saveSettings.mutate({ smarthealthFeatures: effective.smarthealthFeatures })
            }
          >
            Save SmartHealth features
          </button>
          <p className="text-sm text-[var(--muted)]">
            Specialists: <Link href="/doctors" className="text-teal-700 underline">manage doctors</Link>
          </p>
        </div>
      )}
    </div>
  );
}

function CustomServiceForm({ onAdd }: { onAdd: (name: string) => void }) {
  const [name, setName] = useState('');
  return (
    <div className="flex gap-2">
      <input
        className="input flex-1"
        placeholder="Custom service name"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />
      <button
        type="button"
        className="btn-secondary"
        disabled={!name.trim()}
        onClick={() => {
          onAdd(name.trim());
          setName('');
        }}
      >
        Add
      </button>
    </div>
  );
}
