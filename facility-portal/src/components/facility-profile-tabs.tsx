'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import Link from 'next/link';
import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '@/lib/api';
import { type ProfileSettings } from '@/lib/facility-services';

const TABS = [
  'General',
  'Logo',
  'Services',
  'Medical Aid',
  'Staff',
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

  const { data: servicesCatalogData } = useQuery({
    queryKey: ['services-catalog', facilityId],
    queryFn: () => api.servicesCatalog(facilityId),
    enabled: !!facilityId && tab === 'Services',
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
  const localLogoPreviewRef = useRef<string | null>(null);

  const clearLocalLogoPreview = () => {
    if (localLogoPreviewRef.current) {
      URL.revokeObjectURL(localLogoPreviewRef.current);
      localLogoPreviewRef.current = null;
    }
  };

  const serverLogoUrl =
    typeof profileData?.facility?.logoUrl === 'string' && profileData.facility.logoUrl.length > 0
      ? profileData.facility.logoUrl
      : null;

  useEffect(() => {
    if (localLogoPreviewRef.current) return;
    setLogoPreviewUrl(serverLogoUrl);
  }, [serverLogoUrl]);

  const uploadLogo = useMutation({
    mutationFn: (file: File) => api.uploadLogo(facilityId, file),
    onSuccess: (result) => {
      clearLocalLogoPreview();
      const url = (result as { logoUrl?: string })?.logoUrl;
      if (url) setLogoPreviewUrl(url);
      qc.invalidateQueries({ queryKey: ['facility-profile', facilityId] });
    },
    onError: () => {
      clearLocalLogoPreview();
      setLogoPreviewUrl(serverLogoUrl);
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

  const submitService = useMutation({
    mutationFn: (label: string) => api.submitServiceProposal(facilityId, { label }),
  });

  const submitMedicalAid = useMutation({
    mutationFn: (name: string) => api.submitMedicalAidProposal(facilityId, { name }),
  });

  const catalogServices = useMemo(
    () => [
      ...(servicesCatalogData?.preset ?? []),
      ...(servicesCatalogData?.other ?? []),
    ],
    [servicesCatalogData],
  );

  const toggleCatalogService = (slug: string, label: string, iconKey: string) => {
    const exists = effective.services.find((s) => s.key === slug);
    const nextServices = exists
      ? effective.services.filter((s) => s.key !== slug)
      : [
          ...effective.services,
          {
            id: crypto.randomUUID(),
            key: slug,
            name: label,
            iconKey,
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
              clearLocalLogoPreview();
              const localPreview = URL.createObjectURL(file);
              localLogoPreviewRef.current = localPreview;
              setLogoPreviewUrl(localPreview);
              uploadLogo.mutate(file);
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
            {catalogServices.map((item) => {
              const checked = effective.services.some((s) => s.key === item.id);
              return (
                <label key={item.id} className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={checked}
                    onChange={() => toggleCatalogService(item.id, item.label, item.iconKey)}
                  />
                  {item.label}
                </label>
              );
            })}
          </div>
          <CustomServiceForm
            pending={submitService.isPending}
            message={
              submitService.isSuccess
                ? submitService.data?.skipped
                  ? 'That service is already in the catalog or pending review.'
                  : 'Service submitted for admin review.'
                : submitService.isError
                  ? (submitService.error as Error).message
                  : null
            }
            onSubmit={(name) => submitService.mutate(name)}
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
          <CustomMedicalAidForm
            pending={submitMedicalAid.isPending}
            message={
              submitMedicalAid.isSuccess
                ? submitMedicalAid.data?.skipped
                  ? 'That scheme is already in the catalog or pending review.'
                  : 'Medical aid submitted for admin review.'
                : submitMedicalAid.isError
                  ? (submitMedicalAid.error as Error).message
                  : null
            }
            onSubmit={(name) => submitMedicalAid.mutate(name)}
          />
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

      {tab === 'Staff' && (
        <div className="card max-w-2xl space-y-4">
          <p className="text-sm text-[var(--muted)]">
            Manage facility team members and linked doctors from your profile.
          </p>
          <div className="flex flex-wrap gap-2">
            <Link href="/facility/staff" className="btn-primary text-sm">
              Team members
            </Link>
            <Link href="/facility/staff/doctors" className="btn-secondary text-sm">
              Doctors
            </Link>
          </div>
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
          <button
            type="button"
            className="btn-primary"
            disabled={saveSettings.isPending}
            onClick={() =>
              saveSettings.mutate({
                booking: effective.booking,
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

function CustomServiceForm({
  onSubmit,
  pending,
  message,
}: {
  onSubmit: (name: string) => void;
  pending: boolean;
  message: string | null;
}) {
  const [name, setName] = useState('');
  return (
    <div className="space-y-2">
      <p className="text-sm text-[var(--muted)]">
        Propose a service not listed above. Admin review adds it to the global catalog.
      </p>
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
          disabled={!name.trim() || pending}
          onClick={() => {
            onSubmit(name.trim());
            setName('');
          }}
        >
          {pending ? 'Submitting…' : 'Propose'}
        </button>
      </div>
      {message && <p className="text-sm text-slate-600">{message}</p>}
    </div>
  );
}

function CustomMedicalAidForm({
  onSubmit,
  pending,
  message,
}: {
  onSubmit: (name: string) => void;
  pending: boolean;
  message: string | null;
}) {
  const [name, setName] = useState('');
  return (
    <div className="space-y-2">
      <p className="text-sm text-[var(--muted)]">
        Propose a medical aid scheme not listed above.
      </p>
      <div className="flex gap-2">
        <input
          className="input flex-1"
          placeholder="Medical aid scheme name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <button
          type="button"
          className="btn-secondary"
          disabled={!name.trim() || pending}
          onClick={() => {
            onSubmit(name.trim());
            setName('');
          }}
        >
          {pending ? 'Submitting…' : 'Propose'}
        </button>
      </div>
      {message && <p className="text-sm text-slate-600">{message}</p>}
    </div>
  );
}
