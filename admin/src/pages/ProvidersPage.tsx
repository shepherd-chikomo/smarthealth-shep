import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../lib/api';
import { ErrorState, LoadingState, Modal, PageHeader, PaginationBar, SearchBar } from '../components/ui';

interface AdminProvider {
  id: string;
  name: string;
  title: string | null;
  firstName: string | null;
  lastName: string | null;
  specialty: string | null;
  gender: string | null;
  qualification: string | null;
  email: string | null;
  phone: string | null;
  registrationNumber: string | null;
  facilityName: string | null;
  averageRating: number;
  reviewCount: number;
  isVerified: boolean;
  isSuspended: boolean;
}

const PAGE_SIZE = 50;

export function ProvidersPage() {
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [editing, setEditing] = useState<AdminProvider | null>(null);

  const { data, isLoading, error } = useQuery({
    queryKey: ['admin-providers', page, q, status],
    queryFn: () => api.providers({ page, limit: PAGE_SIZE, q, status: status || undefined }),
  });

  const verify = useMutation({
    mutationFn: ({ id, verified }: { id: string; verified: boolean }) => api.verifyProvider(id, verified),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-providers'] }),
  });

  const suspend = useMutation({
    mutationFn: ({ id, suspended }: { id: string; suspended: boolean }) =>
      api.suspendProvider(id, suspended, 'Admin action'),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-providers'] }),
  });

  const update = useMutation({
    mutationFn: (body: {
      id: string;
      title?: string | null;
      firstName?: string;
      lastName?: string;
      specialty?: string | null;
      email?: string | null;
      phone?: string | null;
      gender?: 'male' | 'female' | 'other' | null;
      qualification?: string | null;
      registrationNumber?: string | null;
    }) => {
      const { id, ...rest } = body;
      return api.updateProvider(id, rest);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin-providers'] });
      setEditing(null);
    },
  });

  return (
    <div>
      <PageHeader
        title="Provider Management"
        description="MDPCZ practitioners linked to HPA facilities — verify, edit registry details, suspend"
      />
      <div className="mb-4 flex flex-wrap gap-3">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search name, reg no, email…" />
        <select className="input max-w-[160px]" value={status} onChange={(e) => { setStatus(e.target.value); setPage(1); }}>
          <option value="">All</option>
          <option value="verified">Verified</option>
          <option value="unverified">Unverified</option>
          <option value="suspended">Suspended</option>
        </select>
      </div>
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}
      {data && (
        <>
          <div className="table-wrap overflow-x-auto">
            <table className="data-table min-w-[1100px]">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Reg #</th>
                  <th>Specialty</th>
                  <th>Gender</th>
                  <th>Qualification</th>
                  <th>Email</th>
                  <th>HPA Facility</th>
                  <th>Rating</th>
                  <th>Status</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {(data.providers as AdminProvider[]).map((p) => (
                  <tr key={p.id}>
                    <td className="whitespace-nowrap">{p.name}</td>
                    <td className="font-mono text-sm">{p.registrationNumber ?? '—'}</td>
                    <td>{p.specialty ?? '—'}</td>
                    <td>{p.gender ?? '—'}</td>
                    <td>{p.qualification ?? '—'}</td>
                    <td className="max-w-[180px] truncate">{p.email ?? '—'}</td>
                    <td className="max-w-[220px] truncate">{p.facilityName ?? '—'}</td>
                    <td>{p.averageRating} ({p.reviewCount})</td>
                    <td>
                      {p.isVerified && <span className="badge badge-green mr-1">Verified</span>}
                      {!p.isVerified && <span className="badge badge-amber mr-1">Unverified</span>}
                      {p.isSuspended && <span className="badge badge-red">Suspended</span>}
                    </td>
                    <td className="space-x-2 whitespace-nowrap">
                      <button type="button" className="text-sm text-blue-600" onClick={() => setEditing(p)}>Edit</button>
                      {!p.isVerified && (
                        <button type="button" className="text-sm text-teal-600" onClick={() => verify.mutate({ id: p.id, verified: true })}>Verify</button>
                      )}
                      {!p.isSuspended ? (
                        <button type="button" className="text-sm text-red-600" onClick={() => suspend.mutate({ id: p.id, suspended: true })}>Suspend</button>
                      ) : (
                        <button type="button" className="text-sm text-teal-600" onClick={() => suspend.mutate({ id: p.id, suspended: false })}>Restore</button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={data.pagination.page} totalPages={data.pagination.totalPages} onPage={setPage} />
        </>
      )}

      {editing && (
        <EditProviderModal
          provider={editing}
          saving={update.isPending}
          error={update.error as Error | null}
          onClose={() => setEditing(null)}
          onSave={(body) => update.mutate({ id: editing.id, ...body })}
        />
      )}
    </div>
  );
}

function EditProviderModal({
  provider,
  saving,
  error,
  onClose,
  onSave,
}: {
  provider: AdminProvider;
  saving: boolean;
  error: Error | null;
  onClose: () => void;
  onSave: (body: {
    title?: string | null;
    firstName?: string;
    lastName?: string;
    specialty?: string | null;
    email?: string | null;
    phone?: string | null;
    gender?: 'male' | 'female' | 'other' | null;
    qualification?: string | null;
    registrationNumber?: string | null;
  }) => void;
}) {
  const [title, setTitle] = useState(provider.title ?? '');
  const [firstName, setFirstName] = useState(provider.firstName ?? '');
  const [lastName, setLastName] = useState(provider.lastName ?? '');
  const [specialty, setSpecialty] = useState(provider.specialty ?? '');
  const [email, setEmail] = useState(provider.email ?? '');
  const [phone, setPhone] = useState(provider.phone ?? '');
  const [gender, setGender] = useState(provider.gender ?? '');
  const [qualification, setQualification] = useState(provider.qualification ?? '');
  const [registrationNumber, setRegistrationNumber] = useState(provider.registrationNumber ?? '');

  return (
    <Modal title="Edit practitioner" onClose={onClose}>
      <div className="grid gap-3 sm:grid-cols-2">
          <label className="block sm:col-span-2">
            <span className="text-sm text-gray-600">Title</span>
            <input className="input mt-1 w-full" value={title} onChange={(e) => setTitle(e.target.value)} />
          </label>
          <label className="block">
            <span className="text-sm text-gray-600">First name</span>
            <input className="input mt-1 w-full" value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
          </label>
          <label className="block">
            <span className="text-sm text-gray-600">Last name</span>
            <input className="input mt-1 w-full" value={lastName} onChange={(e) => setLastName(e.target.value)} required />
          </label>
          <label className="block sm:col-span-2">
            <span className="text-sm text-gray-600">Registration number</span>
            <input className="input mt-1 w-full font-mono" value={registrationNumber} onChange={(e) => setRegistrationNumber(e.target.value)} />
          </label>
          <label className="block sm:col-span-2">
            <span className="text-sm text-gray-600">Specialty</span>
            <input className="input mt-1 w-full" value={specialty} onChange={(e) => setSpecialty(e.target.value)} />
          </label>
          <label className="block">
            <span className="text-sm text-gray-600">Gender</span>
            <select className="input mt-1 w-full" value={gender} onChange={(e) => setGender(e.target.value)}>
              <option value="">—</option>
              <option value="male">Male</option>
              <option value="female">Female</option>
              <option value="other">Other</option>
            </select>
          </label>
          <label className="block">
            <span className="text-sm text-gray-600">Qualification</span>
            <input className="input mt-1 w-full" value={qualification} onChange={(e) => setQualification(e.target.value)} />
          </label>
          <label className="block sm:col-span-2">
            <span className="text-sm text-gray-600">Email</span>
            <input className="input mt-1 w-full" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
          </label>
          <label className="block sm:col-span-2">
            <span className="text-sm text-gray-600">Phone</span>
            <input className="input mt-1 w-full" value={phone} onChange={(e) => setPhone(e.target.value)} />
          </label>
          <p className="text-sm text-gray-500 sm:col-span-2">
            HPA facility: {provider.facilityName ?? 'Not linked — use Facilities tab to associate'}
          </p>
      </div>
      {error && <p className="mt-3 text-sm text-red-600">{error.message}</p>}
      <div className="mt-6 flex justify-end gap-2">
        <button type="button" className="btn-secondary" onClick={onClose}>Cancel</button>
        <button
          type="button"
          className="btn-primary"
          disabled={saving || !firstName.trim() || !lastName.trim()}
          onClick={() =>
            onSave({
              title: title.trim() || null,
              firstName: firstName.trim(),
              lastName: lastName.trim(),
              specialty: specialty.trim() || null,
              email: email.trim() || null,
              phone: phone.trim() || null,
              gender: (gender as 'male' | 'female' | 'other') || null,
              qualification: qualification.trim() || null,
              registrationNumber: registrationNumber.trim() || undefined,
            })
          }
        >
          {saving ? 'Saving…' : 'Save'}
        </button>
      </div>
    </Modal>
  );
}
