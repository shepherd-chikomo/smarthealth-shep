'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '@/components/ui';

export default function StaffPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [form, setForm] = useState({ userId: '', role: 'receptionist' });

  const { data, isLoading, error } = useQuery({
    queryKey: ['staff', facilityId, page, q],
    queryFn: () => api.staff(facilityId!, { page, limit: 20, q }),
    enabled: !!facilityId,
  });

  const add = useMutation({
    mutationFn: () => api.addStaff(facilityId!, form),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['staff', facilityId] }),
  });

  const remove = useMutation({
    mutationFn: (id: string) => api.removeStaff(facilityId!, id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['staff', facilityId] }),
  });

  return (
    <div>
      <PageHeader title="Staff Management" description="Manage facility team members and roles" />
      <form className="card mb-4 flex flex-wrap gap-2" onSubmit={(e) => { e.preventDefault(); add.mutate(); }}>
        <input className="input max-w-xs" placeholder="User UUID" required value={form.userId}
          onChange={(e) => setForm({ ...form, userId: e.target.value })} />
        <select className="input max-w-[180px]" value={form.role}
          onChange={(e) => setForm({ ...form, role: e.target.value })}>
          <option value="receptionist">Receptionist</option>
          <option value="doctor">Doctor</option>
          <option value="facility_admin">Facility Admin</option>
        </select>
        <button type="submit" className="btn-primary" disabled={add.isPending}>Add staff</button>
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
