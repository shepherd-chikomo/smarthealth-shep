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
        <form
          className="card mb-4 grid gap-3 sm:grid-cols-2"
          onSubmit={(e) => { e.preventDefault(); create.mutate(); }}
        >
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
          <button type="submit" className="btn-primary sm:col-span-2" disabled={create.isPending}>
            Create
          </button>
        </form>
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
                      <Link href="/hours" className="btn-secondary text-sm">
                        Manage hours
                      </Link>
                      <Link href="/availability" className="btn-secondary text-sm">
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
