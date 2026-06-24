'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'next/navigation';
import { Suspense, useEffect, useMemo, useState } from 'react';
import { AppointmentCalendar } from '@/components/appointments/appointment-calendar';
import { SectionCard, ViewToggle } from '@/components/dashboard/section-card';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import {
  ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar, StatusBadge,
} from '@/components/ui';

type AppointmentRow = Record<string, unknown>;
type ViewMode = 'list' | 'calendar';

const STATUS_OPTIONS = [
  '',
  'pending',
  'confirmed',
  'checked_in',
  'in_progress',
  'completed',
  'cancelled',
  'no_show',
] as const;

function calendarMonthRange(month: Date) {
  const start = new Date(month.getFullYear(), month.getMonth(), 1);
  const end = new Date(month.getFullYear(), month.getMonth() + 1, 0, 23, 59, 59, 999);
  return { from: start.toISOString(), to: end.toISOString() };
}

function AppointmentsContent() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const searchParams = useSearchParams();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [view, setView] = useState<ViewMode>('list');
  const [calendarMonth, setCalendarMonth] = useState(() => new Date());
  const [showCreate, setShowCreate] = useState(false);
  const [rescheduleId, setRescheduleId] = useState<string | null>(null);
  const [rescheduleAt, setRescheduleAt] = useState('');
  const [createForm, setCreateForm] = useState({
    patientId: '',
    providerId: '',
    scheduledAt: '',
    notes: '',
  });

  useEffect(() => {
    if (searchParams.get('create') === '1') setShowCreate(true);
  }, [searchParams]);

  const { data, isLoading, error } = useQuery({
    queryKey: ['appointments', facilityId, page, q, status, view, calendarMonth.toISOString()],
    queryFn: () => {
      if (view === 'calendar') {
        const range = calendarMonthRange(calendarMonth);
        return api.appointments(facilityId!, {
          page: 1,
          limit: 100,
          q,
          status: status || undefined,
          from: range.from,
          to: range.to,
          sortOrder: 'asc',
        });
      }
      return api.appointments(facilityId!, {
        page,
        limit: 20,
        q,
        status: status || undefined,
      });
    },
    enabled: !!facilityId,
  });

  const doctors = useQuery({
    queryKey: ['doctors-options', facilityId],
    queryFn: () => api.doctors(facilityId!, { limit: 100 }),
    enabled: !!facilityId && showCreate,
  });

  const cancel = useMutation({
    mutationFn: (id: string) => api.cancelAppointment(facilityId!, id, 'Cancelled by staff'),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['appointments', facilityId] }),
  });

  const create = useMutation({
    mutationFn: () => api.createAppointment(facilityId!, {
      ...createForm,
      scheduledAt: new Date(createForm.scheduledAt).toISOString(),
    }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['appointments', facilityId] });
      setShowCreate(false);
      setCreateForm({ patientId: '', providerId: '', scheduledAt: '', notes: '' });
    },
  });

  const reschedule = useMutation({
    mutationFn: () =>
      api.rescheduleAppointment(facilityId!, rescheduleId!, {
        scheduledAt: new Date(rescheduleAt).toISOString(),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['appointments', facilityId] });
      setRescheduleId(null);
      setRescheduleAt('');
    },
  });

  const appointments = useMemo(
    () => (data?.appointments as AppointmentRow[] | undefined) ?? [],
    [data],
  );

  return (
    <div>
      <PageHeader
        title="Appointments"
        description="Calendar and list views with status filters and quick reschedule"
      />

      <div className="mb-4 flex flex-wrap items-center gap-3">
        <ViewToggle
          value={view}
          options={[
            { id: 'list', label: 'List' },
            { id: 'calendar', label: 'Calendar' },
          ]}
          onChange={setView}
        />
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} />
        <select
          className="input max-w-[180px]"
          value={status}
          onChange={(e) => { setStatus(e.target.value); setPage(1); }}
        >
          <option value="">All statuses</option>
          {STATUS_OPTIONS.filter(Boolean).map((s) => (
            <option key={s} value={s}>{s.replace('_', ' ')}</option>
          ))}
        </select>
        <button type="button" className="btn-primary" onClick={() => setShowCreate(!showCreate)}>
          {showCreate ? 'Hide form' : 'Add appointment'}
        </button>
      </div>

      {showCreate && (
        <SectionCard title="New appointment" className="mb-4">
          <form
            className="grid gap-3 sm:grid-cols-2"
            onSubmit={(e) => { e.preventDefault(); create.mutate(); }}
          >
            <input
              className="input"
              placeholder="Patient ID"
              required
              value={createForm.patientId}
              onChange={(e) => setCreateForm({ ...createForm, patientId: e.target.value })}
            />
            <select
              className="input"
              required
              value={createForm.providerId}
              onChange={(e) => setCreateForm({ ...createForm, providerId: e.target.value })}
            >
              <option value="">Select doctor</option>
              {((doctors.data?.doctors as Record<string, unknown>[]) ?? []).map((d) => (
                <option key={String(d.id)} value={String(d.id)}>{String(d.name)}</option>
              ))}
            </select>
            <input
              className="input sm:col-span-2"
              type="datetime-local"
              required
              value={createForm.scheduledAt}
              onChange={(e) => setCreateForm({ ...createForm, scheduledAt: e.target.value })}
            />
            <input
              className="input sm:col-span-2"
              placeholder="Notes (optional)"
              value={createForm.notes}
              onChange={(e) => setCreateForm({ ...createForm, notes: e.target.value })}
            />
            <button type="submit" className="btn-primary sm:col-span-2" disabled={create.isPending}>
              {create.isPending ? 'Creating…' : 'Create appointment'}
            </button>
          </form>
        </SectionCard>
      )}

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}

      {data && view === 'calendar' && (
        <div className="card">
          <AppointmentCalendar
            appointments={appointments}
            month={calendarMonth}
            onMonthChange={setCalendarMonth}
            onSelect={(a) => {
              setRescheduleId(String(a.id));
              setRescheduleAt(new Date(String(a.scheduled_at)).toISOString().slice(0, 16));
            }}
          />
        </div>
      )}

      {data && view === 'list' && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Reference</th>
                  <th>Patient</th>
                  <th>Doctor</th>
                  <th>Scheduled</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((a) => (
                  <tr key={String(a.id)}>
                    <td>{String(a.reference_number)}</td>
                    <td>{String(a.patient_name)}</td>
                    <td>{String(a.provider_name)}</td>
                    <td>{new Date(String(a.scheduled_at)).toLocaleString()}</td>
                    <td><StatusBadge status={String(a.status)} /></td>
                    <td className="space-x-2 whitespace-nowrap">
                      {!['cancelled', 'completed', 'no_show'].includes(String(a.status)) && (
                        <>
                          <button
                            type="button"
                            className="btn-secondary text-xs"
                            onClick={() => {
                              setRescheduleId(String(a.id));
                              setRescheduleAt(
                                new Date(String(a.scheduled_at)).toISOString().slice(0, 16),
                              );
                            }}
                          >
                            Reschedule
                          </button>
                          <button
                            type="button"
                            className="btn-danger text-xs"
                            onClick={() => cancel.mutate(String(a.id))}
                          >
                            Cancel
                          </button>
                        </>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar
            page={data.pagination.page}
            totalPages={data.pagination.totalPages}
            onPage={setPage}
          />
        </>
      )}

      {rescheduleId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="card w-full max-w-md">
            <h3 className="mb-3 font-semibold">Quick reschedule</h3>
            <input
              className="input mb-4 w-full"
              type="datetime-local"
              value={rescheduleAt}
              onChange={(e) => setRescheduleAt(e.target.value)}
            />
            <div className="flex gap-2">
              <button
                type="button"
                className="btn-primary"
                disabled={!rescheduleAt || reschedule.isPending}
                onClick={() => reschedule.mutate()}
              >
                {reschedule.isPending ? 'Saving…' : 'Confirm'}
              </button>
              <button
                type="button"
                className="btn-secondary"
                onClick={() => { setRescheduleId(null); setRescheduleAt(''); }}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default function AppointmentsPage() {
  return (
    <Suspense fallback={<LoadingState />}>
      <AppointmentsContent />
    </Suspense>
  );
}
