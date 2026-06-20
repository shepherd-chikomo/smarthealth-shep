'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import Link from 'next/link';
import { useMemo, useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '@/components/ui';

const EMPTY_FORM = {
  fullName: '',
  email: '',
  phone: '',
  role: 'receptionist',
};

type StaffRow = {
  membership_id?: string;
  id?: string;
  first_name?: string | null;
  last_name?: string | null;
  email?: string | null;
  phone?: string | null;
  role?: string;
  joined_at?: string;
};

function membershipId(row: StaffRow): string {
  return String(row.membership_id ?? row.id ?? '');
}

function fullName(row: StaffRow): string {
  return [row.first_name, row.last_name].filter(Boolean).join(' ').trim();
}

export default function StaffPage() {
  const { facilityId, profile } = useFacility();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [form, setForm] = useState(EMPTY_FORM);
  const [formError, setFormError] = useState('');
  const [formSuccess, setFormSuccess] = useState('');
  const [actionError, setActionError] = useState('');
  const [actionSuccess, setActionSuccess] = useState('');
  const [editing, setEditing] = useState<StaffRow | null>(null);
  const [editForm, setEditForm] = useState(EMPTY_FORM);

  const canManage = useMemo(() => {
    if (!facilityId || !profile) return false;
    if (profile.role === 'super_admin') return true;
    return profile.facilities.some(
      (f) => f.id === facilityId && f.role === 'facility_admin',
    );
  }, [facilityId, profile]);

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
    onSuccess: (result) => {
      void qc.invalidateQueries({ queryKey: ['staff', facilityId] });
      setForm(EMPTY_FORM);
      setFormError('');
      const emailSent = (result as { emailSent?: boolean }).emailSent;
      const emailError = (result as { emailError?: string | null }).emailError;
      setFormSuccess(
        emailSent
          ? 'Staff member added and invite email sent.'
          : emailError
            ? `Staff member added. Email failed: ${emailError}`
            : 'Staff member added. Invite email could not be sent — check server email configuration (Inbucket on dev: port 54324).',
      );
    },
    onError: (err: Error) => setFormError(err.message),
  });

  const remove = useMutation({
    mutationFn: (id: string) => api.removeStaff(facilityId!, id),
    onSuccess: async () => {
      setActionError('');
      setActionSuccess('Staff member removed.');
      await qc.invalidateQueries({ queryKey: ['staff', facilityId] });
    },
    onError: (err: Error) => {
      setActionSuccess('');
      setActionError(err.message);
    },
  });

  const update = useMutation({
    mutationFn: ({ id, body }: { id: string; body: Record<string, unknown> }) =>
      api.updateStaff(facilityId!, id, body),
    onSuccess: async () => {
      setActionError('');
      setActionSuccess('Staff member updated.');
      setEditing(null);
      await qc.invalidateQueries({ queryKey: ['staff', facilityId] });
    },
    onError: (err: Error) => setActionError(err.message),
  });

  function openEdit(row: StaffRow) {
    setEditing(row);
    setEditForm({
      fullName: fullName(row),
      email: row.email ?? '',
      phone: row.phone ?? '',
      role: row.role ?? 'receptionist',
    });
    setActionError('');
    setActionSuccess('');
  }

  function handleRemove(row: StaffRow) {
    const id = membershipId(row);
    if (!id) {
      setActionError('Could not determine staff membership id.');
      return;
    }
    const name = fullName(row) || row.email || 'this staff member';
    if (!window.confirm(`Remove ${name} from the facility team?`)) return;
    setActionError('');
    setActionSuccess('');
    remove.mutate(id);
  }

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

      {!canManage && (
        <p className="mb-4 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
          Only facility administrators can add, edit, or remove staff members.
        </p>
      )}

      {actionError && (
        <p className="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {actionError}
        </p>
      )}
      {actionSuccess && (
        <p className="mb-4 rounded-lg border border-teal-200 bg-teal-50 px-4 py-3 text-sm text-teal-800">
          {actionSuccess}
        </p>
      )}

      {canManage && (
        <form
          className="card mb-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-5"
          onSubmit={(e) => {
            e.preventDefault();
            setFormError('');
            setFormSuccess('');
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
          {formSuccess && (
            <p className="text-sm text-teal-600 sm:col-span-2 lg:col-span-5">{formSuccess}</p>
          )}
        </form>
      )}

      <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search staff…" />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Phone</th>
                  <th>Role</th>
                  <th>Joined</th>
                  {canManage && <th>Actions</th>}
                </tr>
              </thead>
              <tbody>
                {(data.staff as StaffRow[]).map((s) => {
                  const id = membershipId(s);
                  return (
                    <tr key={id || `${s.email}-${s.role}`}>
                      <td>{fullName(s) || '—'}</td>
                      <td>{s.email ?? '—'}</td>
                      <td>{s.phone ?? '—'}</td>
                      <td>{s.role ?? '—'}</td>
                      <td>
                        {s.joined_at
                          ? new Date(String(s.joined_at)).toLocaleDateString()
                          : '—'}
                      </td>
                      {canManage && (
                        <td className="space-x-2 whitespace-nowrap">
                          <button
                            type="button"
                            className="btn-secondary text-xs"
                            onClick={() => openEdit(s)}
                          >
                            Edit
                          </button>
                          <button
                            type="button"
                            className="btn-danger text-xs"
                            disabled={!id || remove.isPending}
                            onClick={() => handleRemove(s)}
                          >
                            {remove.isPending ? 'Removing…' : 'Remove'}
                          </button>
                        </td>
                      )}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          <PaginationBar page={data.pagination.page} totalPages={data.pagination.totalPages} onPage={setPage} />
        </>
      )}

      {editing && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <form
            className="card w-full max-w-lg space-y-4"
            onSubmit={(e) => {
              e.preventDefault();
              const id = membershipId(editing);
              if (!id) {
                setActionError('Could not determine staff membership id.');
                return;
              }
              update.mutate({
                id,
                body: {
                  fullName: editForm.fullName.trim(),
                  email: editForm.email.trim(),
                  phone: editForm.phone.trim(),
                  role: editForm.role,
                },
              });
            }}
          >
            <h3 className="text-lg font-semibold">Edit staff member</h3>
            <input
              className="input w-full"
              placeholder="Full name"
              required
              value={editForm.fullName}
              onChange={(e) => setEditForm({ ...editForm, fullName: e.target.value })}
            />
            <input
              className="input w-full"
              type="email"
              placeholder="Email address"
              required
              value={editForm.email}
              onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
            />
            <input
              className="input w-full"
              placeholder="Phone (077…)"
              value={editForm.phone}
              onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
            />
            <select
              className="input w-full"
              value={editForm.role}
              onChange={(e) => setEditForm({ ...editForm, role: e.target.value })}
            >
              <option value="receptionist">Receptionist</option>
              <option value="doctor">Doctor</option>
              <option value="facility_admin">Facility Admin</option>
            </select>
            <div className="flex gap-2">
              <button type="submit" className="btn-primary" disabled={update.isPending}>
                {update.isPending ? 'Saving…' : 'Save changes'}
              </button>
              <button
                type="button"
                className="btn-secondary"
                onClick={() => setEditing(null)}
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
