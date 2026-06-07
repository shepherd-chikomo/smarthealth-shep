'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import Link from 'next/link';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '@/components/ui';

const EMPTY_FORM = {
  fullName: '',
  email: '',
  phone: '',
  role: 'receptionist',
};

export default function StaffPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [form, setForm] = useState(EMPTY_FORM);
  const [formError, setFormError] = useState('');

  const { data, isLoading, error } = useQuery({
    queryKey: ['staff', facilityId, page, q],
    queryFn: () => api.staff(facilityId!, { page, limit: 20, q }),
    enabled: !!facilityId,
  });

  const add = useMutation({
    mutationFn: () =>
      api.addStaff(facilityId!, {
        fullName: form.fullName.trim(),
        email: form.email.trim(),
        phone: form.phone.trim() || undefined,
        role: form.role,
      }),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['staff', facilityId] });
      setForm(EMPTY_FORM);
      setFormError('');
    },
    onError: (err: Error) => setFormError(err.message),
  });

  const remove = useMutation({
    mutationFn: (id: string) => api.removeStaff(facilityId!, id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['staff', facilityId] }),
  });

  return (
    <div>
      <PageHeader
        title="Staff Management"
        description="Manage facility team members and roles"
      />
      <div className="mb-4 flex flex-wrap gap-2">
        <Link href="/facility" className="btn-secondary text-sm">
          Back to facility profile
        </Link>
        <Link href="/facility/staff/doctors" className="btn-secondary text-sm">
          Doctors
        </Link>
      </div>
      <form
        className="card mb-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-5"
        onSubmit={(e) => {
          e.preventDefault();
          setFormError('');
          add.mutate();
        }}
      >
        <input
          className="input"
          placeholder="Full name"
          required
          value={form.fullName}
          onChange={(e) => setForm({ ...form, fullName: e.target.value })}
        />
        <input
          className="input"
          type="email"
          placeholder="Email address"
          required
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
        />
        <input
          className="input"
          placeholder="Phone (077…)"
          value={form.phone}
          onChange={(e) => setForm({ ...form, phone: e.target.value })}
        />
        <select
          className="input"
          value={form.role}
          onChange={(e) => setForm({ ...form, role: e.target.value })}
        >
          <option value="receptionist">Receptionist</option>
          <option value="doctor">Doctor</option>
          <option value="facility_admin">Facility Admin</option>
        </select>
        <button type="submit" className="btn-primary" disabled={add.isPending}>
          {add.isPending ? 'Adding…' : 'Add staff'}
        </button>
        {formError && (
          <p className="text-sm text-red-600 sm:col-span-2 lg:col-span-5">{formError}</p>
        )}
      </form>

      <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search staff…" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Role</th><th>Joined</th><th></th></tr></thead>
              <tbody>
                {(data.staff as Record<string, unknown>[]).map((s) => (
                  <tr key={String(s.id)}>
                    <td>{String(s.first_name)} {String(s.last_name ?? '')}</td>
                    <td>{String(s.email ?? '—')}</td>
                    <td>{String(s.phone ?? '—')}</td>
                    <td>{String(s.role)}</td>
                    <td>{new Date(String(s.joined_at)).toLocaleDateString()}</td>
                    <td>
                      <button type="button" className="btn-danger text-xs" onClick={() => remove.mutate(String(s.id))}>
                        Remove
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={data.pagination.page} totalPages={data.pagination.totalPages} onPage={setPage} />
        </>
      )}
    </div>
  );
}
