'use client';

import Link from 'next/link';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '@/components/ui';

export default function PatientsPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ firstName: '', lastName: '', phone: '' });

  const { data, isLoading, error } = useQuery({
    queryKey: ['patients', facilityId, page, q],
    queryFn: () => api.patients(facilityId!, { page, limit: 20, q }),
    enabled: !!facilityId,
  });

  const register = useMutation({
    mutationFn: () => api.registerPatient(facilityId!, form),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['patients', facilityId] });
      setShowForm(false);
    },
  });

  return (
    <div>
      <PageHeader title="Patients" description="Register, search, and view patient history" />
      <div className="mb-4 flex flex-wrap gap-2">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search by name or phone…" />
        <button type="button" className="btn-primary" onClick={() => setShowForm(!showForm)}>Register patient</button>
      </div>

      {showForm && (
        <form className="card mb-4 grid gap-3 sm:grid-cols-3" onSubmit={(e) => { e.preventDefault(); register.mutate(); }}>
          <input className="input" placeholder="First name" required value={form.firstName}
            onChange={(e) => setForm({ ...form, firstName: e.target.value })} />
          <input className="input" placeholder="Last name" value={form.lastName}
            onChange={(e) => setForm({ ...form, lastName: e.target.value })} />
          <input className="input" placeholder="Phone (077…)" required value={form.phone}
            onChange={(e) => setForm({ ...form, phone: e.target.value })} />
          <button type="submit" className="btn-primary sm:col-span-3" disabled={register.isPending}>Register</button>
        </form>
      )}

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>Name</th><th>Phone</th><th>Last visit</th><th></th></tr></thead>
              <tbody>
                {(data.patients as Record<string, unknown>[]).map((p) => (
                  <tr key={String(p.id)}>
                    <td>{String(p.firstName)} {String(p.lastName ?? '')}</td>
                    <td>{String(p.phone ?? '—')}</td>
                    <td>{p.lastVisit ? new Date(String(p.lastVisit)).toLocaleDateString() : '—'}</td>
                    <td>
                      <Link href={`/patients/${p.id}`} className="text-sm text-teal-600 hover:underline">History</Link>
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
