'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import Link from 'next/link';
import { useState } from 'react';
import { SectionCard } from '@/components/dashboard/section-card';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import {
  ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar, StatusBadge,
} from '@/components/ui';

export default function DoctorsPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ name: '', specialty: '', mdpczNumber: '', phone: '' });
  const [lookupNumber, setLookupNumber] = useState('');
  const [lookupResult, setLookupResult] = useState<
    { found: boolean; provider?: NonNullable<Awaited<ReturnType<typeof api.lookupProvider>>['provider']> } | null
  >(null);
  const [hoursFor, setHoursFor] = useState<string | null>(null);
  const [servicesFor, setServicesFor] = useState<string | null>(null);

  const profileQuery = useQuery({
    queryKey: ['facility-profile', facilityId],
    queryFn: () => api.facilityProfile(facilityId!),
    enabled: !!facilityId,
  });
  const offeredServices = (
    (profileQuery.data?.profileSettings as { services?: { id: string; name: string }[] } | undefined)
      ?.services ?? []
  );

  const { data, isLoading, error } = useQuery({
    queryKey: ['doctors', facilityId, page, q],
    queryFn: () => api.doctors(facilityId!, { page, limit: 20, q }),
    enabled: !!facilityId,
  });

  const create = useMutation({
    mutationFn: () => api.createDoctor(facilityId!, form),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['doctors', facilityId] });
      setShowForm(false);
      setForm({ name: '', specialty: '', mdpczNumber: '', phone: '' });
    },
  });

  const update = useMutation({
    mutationFn: ({ id, body }: { id: string; body: Record<string, unknown> }) =>
      api.updateDoctor(facilityId!, id, body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['doctors', facilityId] }),
  });

  const lookup = useMutation({
    mutationFn: () => api.lookupProvider(facilityId!, lookupNumber.trim()),
    onSuccess: (res) => setLookupResult(res),
  });

  const attach = useMutation({
    mutationFn: (providerId: string) => api.attachDoctor(facilityId!, providerId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['doctors', facilityId] });
      setShowForm(false);
      setLookupNumber('');
      setLookupResult(null);
    },
  });

  return (
    <div>
      <PageHeader
        title="Providers"
        description="Manage availability, hours, and active status"
      />
      <div className="mb-4 flex flex-wrap gap-2">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search doctors…" />
        <button type="button" className="btn-primary" onClick={() => setShowForm(!showForm)}>
          Add doctor
        </button>
      </div>

      {showForm && (
        <div className="mb-4 space-y-4">
          <div className="card space-y-3">
            <div>
              <h3 className="font-semibold">Find a registered practitioner</h3>
              <p className="text-sm text-[var(--muted)]">
                Enter an MDPCZ / registration number to attach an existing registered doctor to this
                facility (no duplicate is created).
              </p>
            </div>
            <form
              className="flex flex-wrap gap-2"
              onSubmit={(e) => { e.preventDefault(); if (lookupNumber.trim()) lookup.mutate(); }}
            >
              <input
                className="input flex-1"
                placeholder="e.g. SUR260053"
                value={lookupNumber}
                onChange={(e) => { setLookupNumber(e.target.value); setLookupResult(null); }}
              />
              <button
                type="submit"
                className="btn-secondary"
                disabled={lookup.isPending || !lookupNumber.trim()}
              >
                {lookup.isPending ? 'Searching…' : 'Find in register'}
              </button>
            </form>

            {lookup.isError && (
              <ErrorState message={(lookup.error as Error).message} />
            )}

            {lookupResult && !lookupResult.found && (
              <p className="rounded-lg bg-amber-50 p-3 text-sm text-amber-800 dark:bg-amber-950 dark:text-amber-200">
                No registered practitioner found for <strong>{lookupNumber.trim()}</strong>. You can
                add them manually below.
              </p>
            )}

            {lookupResult?.found && lookupResult.provider && (
              <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-teal-200 bg-teal-50 p-3 dark:border-teal-800 dark:bg-teal-950">
                <div>
                  <p className="font-medium">{lookupResult.provider.name}</p>
                  <p className="text-sm text-[var(--muted)]">
                    {lookupResult.provider.specialty ?? 'General'} · MDPCZ:{' '}
                    {lookupResult.provider.mdpczNumber ?? '—'}
                  </p>
                </div>
                {lookupResult.provider.alreadyAtFacility ? (
                  <StatusBadge status="already at facility" />
                ) : (
                  <button
                    type="button"
                    className="btn-primary"
                    disabled={attach.isPending}
                    onClick={() => attach.mutate(lookupResult.provider!.id)}
                  >
                    {attach.isPending ? 'Attaching…' : 'Attach to this facility'}
                  </button>
                )}
              </div>
            )}
          </div>

          <form
            className="card grid gap-3 sm:grid-cols-2"
            onSubmit={(e) => { e.preventDefault(); create.mutate(); }}
          >
            <p className="text-sm font-semibold sm:col-span-2">Or add a doctor manually</p>
            {(['name', 'specialty', 'mdpczNumber', 'phone'] as const).map((k) => (
              <input
                key={k}
                className="input"
                placeholder={k}
                required={k === 'name'}
                value={form[k]}
                onChange={(e) => setForm({ ...form, [k]: e.target.value })}
              />
            ))}
            {create.isError && (
              <div className="sm:col-span-2">
                <ErrorState message={(create.error as Error).message} />
              </div>
            )}
            <button type="submit" className="btn-primary sm:col-span-2" disabled={create.isPending}>
              Create
            </button>
          </form>
        </div>
      )}

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}

      {data && (
        <>
          <div className="space-y-3">
            {(data.doctors as Record<string, unknown>[]).map((d) => {
              const accepting = Boolean(d.isAcceptingBookings);
              const active = d.isActive !== false;
              return (
                <SectionCard key={String(d.id)} title={String(d.name)} className="mb-0">
                  <div className="flex flex-wrap items-start justify-between gap-4">
                    <div>
                      <p className="text-sm text-[var(--muted)]">{String(d.specialty ?? 'General')}</p>
                      <p className="mt-1 text-sm">MDPCZ: {String(d.mdpczNumber ?? '—')}</p>
                      <p className="text-sm">
                        Rating {Number(d.avgRating).toFixed(1)} ({String(d.reviewCount)} reviews)
                      </p>
                      <div className="mt-2 flex flex-wrap gap-2">
                        <StatusBadge status={accepting ? 'accepting bookings' : 'bookings closed'} />
                        <StatusBadge status={active ? 'active' : 'inactive'} />
                      </div>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      <button
                        type="button"
                        className="btn-secondary text-sm"
                        onClick={() => setHoursFor(hoursFor === String(d.id) ? null : String(d.id))}
                      >
                        {hoursFor === String(d.id) ? 'Close hours' : 'Manage hours'}
                      </button>
                      {offeredServices.length > 0 && (
                        <button
                          type="button"
                          className="btn-secondary text-sm"
                          onClick={() =>
                            setServicesFor(servicesFor === String(d.id) ? null : String(d.id))
                          }
                        >
                          {servicesFor === String(d.id) ? 'Close services' : 'Services'}
                        </button>
                      )}
                      <Link
                        href={`/availability?providerId=${String(d.id)}&name=${encodeURIComponent(String(d.name))}`}
                        className="btn-secondary text-sm"
                      >
                        Availability
                      </Link>
                      <button
                        type="button"
                        className="btn-secondary text-sm"
                        disabled={update.isPending}
                        onClick={() => update.mutate({
                          id: String(d.id),
                          body: { isAcceptingBookings: !accepting },
                        })}
                      >
                        {accepting ? 'Stop bookings' : 'Accept bookings'}
                      </button>
                      <button
                        type="button"
                        className={active ? 'btn-danger text-sm' : 'btn-primary text-sm'}
                        disabled={update.isPending}
                        onClick={() => update.mutate({
                          id: String(d.id),
                          body: { isActive: !active },
                        })}
                      >
                        {active ? 'Deactivate' : 'Activate'}
                      </button>
                    </div>
                  </div>
                  {hoursFor === String(d.id) && (
                    <DoctorHoursEditor
                      facilityId={facilityId!}
                      providerId={String(d.id)}
                      onClose={() => setHoursFor(null)}
                    />
                  )}
                  {servicesFor === String(d.id) && (
                    <DoctorServicesEditor
                      facilityId={facilityId!}
                      providerId={String(d.id)}
                      services={offeredServices}
                      initialIds={(d.serviceIds as string[] | undefined) ?? []}
                      onClose={() => setServicesFor(null)}
                    />
                  )}
                </SectionCard>
              );
            })}
          </div>
          <PaginationBar
            page={data.pagination.page}
            totalPages={data.pagination.totalPages}
            onPage={setPage}
          />
        </>
      )}
    </div>
  );
}

const DAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

type EditorRow = { dayOfWeek: number; opensAt: string; closesAt: string; isClosed: boolean };

function DoctorServicesEditor({
  facilityId,
  providerId,
  services,
  initialIds,
  onClose,
}: {
  facilityId: string;
  providerId: string;
  services: { id: string; name: string }[];
  initialIds: string[];
  onClose: () => void;
}) {
  const qc = useQueryClient();
  const [selected, setSelected] = useState<string[]>(initialIds);
  const save = useMutation({
    mutationFn: () => api.updateDoctorServices(facilityId, providerId, selected),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['doctors', facilityId] });
      onClose();
    },
  });

  return (
    <div className="mt-4 rounded-lg border border-[var(--border)] bg-[var(--card)] p-4">
      <h4 className="font-medium text-[var(--text)]">
        Services offered by this provider
      </h4>
      <div className="mt-2 grid gap-2 sm:grid-cols-2">
        {services.map((service) => (
          <label
            key={service.id}
            className="flex items-center gap-2 text-sm text-[var(--text)]"
          >
            <input
              type="checkbox"
              checked={selected.includes(service.id)}
              onChange={() =>
                setSelected((prev) =>
                  prev.includes(service.id)
                    ? prev.filter((id) => id !== service.id)
                    : [...prev, service.id],
                )
              }
            />
            {service.name}
          </label>
        ))}
      </div>
      <div className="mt-3 flex gap-2">
        <button
          type="button"
          className="btn-primary text-sm"
          disabled={save.isPending}
          onClick={() => save.mutate()}
        >
          Save services
        </button>
        <button type="button" className="btn-secondary text-sm" onClick={onClose}>
          Cancel
        </button>
      </div>
    </div>
  );
}

function DoctorHoursEditor({
  facilityId,
  providerId,
  onClose,
}: {
  facilityId: string;
  providerId: string;
  onClose: () => void;
}) {
  const qc = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['provider-hours', facilityId, providerId],
    queryFn: () => api.availability(facilityId, providerId),
  });
  const [rows, setRows] = useState<EditorRow[] | null>(null);

  let seeded = rows;
  if (!seeded && data) {
    const byDay = (data.availability as Record<string, unknown>[]).reduce<Record<number, EditorRow>>(
      (acc, h) => {
        acc[Number(h.day_of_week)] = {
          dayOfWeek: Number(h.day_of_week),
          opensAt: String(h.opens_at ?? '08:00').slice(0, 5),
          closesAt: String(h.closes_at ?? '17:00').slice(0, 5),
          isClosed: Boolean(h.is_closed),
        };
        return acc;
      },
      {},
    );
    seeded = DAY_LABELS.map(
      (_, i) => byDay[i] ?? { dayOfWeek: i, opensAt: '08:00', closesAt: '17:00', isClosed: true },
    );
  }

  const save = useMutation({
    mutationFn: () =>
      api.updateAvailability(
        facilityId,
        providerId,
        (seeded ?? []).map((r) => ({
          dayOfWeek: r.dayOfWeek,
          opensAt: r.isClosed ? null : r.opensAt,
          closesAt: r.isClosed ? null : r.closesAt,
          isClosed: r.isClosed,
        })),
      ),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['provider-hours', facilityId, providerId] });
      qc.invalidateQueries({ queryKey: ['availability', facilityId] });
    },
  });

  const setRow = (i: number, patch: Partial<EditorRow>) =>
    setRows((seeded ?? []).map((r, j) => (j === i ? { ...r, ...patch } : r)));

  return (
    <div className="mt-4 border-t border-[var(--border)] pt-4">
      <h4 className="mb-2 text-sm font-semibold">Weekly working hours</h4>
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {seeded && (
        <div className="space-y-2">
          {seeded.map((r, i) => (
            <div key={r.dayOfWeek} className="grid grid-cols-2 items-center gap-2 sm:grid-cols-4">
              <span className="text-sm font-medium">{DAY_LABELS[r.dayOfWeek]}</span>
              <input
                type="time"
                className="input"
                value={r.opensAt}
                disabled={r.isClosed}
                onChange={(e) => setRow(i, { opensAt: e.target.value })}
              />
              <input
                type="time"
                className="input"
                value={r.closesAt}
                disabled={r.isClosed}
                onChange={(e) => setRow(i, { closesAt: e.target.value })}
              />
              <label className="flex items-center gap-1 text-sm">
                <input
                  type="checkbox"
                  checked={r.isClosed}
                  onChange={(e) => setRow(i, { isClosed: e.target.checked })}
                />
                Closed
              </label>
            </div>
          ))}
          <div className="flex flex-wrap items-center gap-2 pt-2">
            <button
              type="button"
              className="btn-primary text-sm"
              disabled={save.isPending}
              onClick={() => save.mutate()}
            >
              {save.isPending ? 'Saving…' : 'Save hours'}
            </button>
            <button type="button" className="btn-secondary text-sm" onClick={onClose}>
              Close
            </button>
            {save.isSuccess && <span className="text-sm text-teal-600">Saved</span>}
            {save.isError && (
              <span className="text-sm text-red-600">{(save.error as Error).message}</span>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
