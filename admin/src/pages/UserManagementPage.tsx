import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Shield, UserPlus, UserMinus } from 'lucide-react';
import { api, type PlatformAdmin } from '../lib/api';
import { useAuth } from '../lib/auth';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '../components/ui';

function displayName(admin: PlatformAdmin) {
  const name = [admin.firstName, admin.lastName].filter(Boolean).join(' ').trim();
  return name || '—';
}

export function UserManagementPage() {
  const qc = useQueryClient();
  const { profile } = useAuth();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [formError, setFormError] = useState('');
  const isSuper = profile?.role === 'super_admin';

  const { data, isLoading, error } = useQuery({
    queryKey: ['platform-admins', page, q],
    queryFn: () => api.platformAdmins({ page, limit: 20, q }),
    enabled: isSuper,
  });

  const promote = useMutation({
    mutationFn: () =>
      api.promotePlatformAdmin({
        phone: phone.trim() || undefined,
        email: email.trim() || undefined,
        firstName: firstName.trim() || undefined,
        lastName: lastName.trim() || undefined,
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['platform-admins'] });
      setPhone('');
      setEmail('');
      setFirstName('');
      setLastName('');
      setFormError('');
    },
    onError: (err) => setFormError(err instanceof Error ? err.message : 'Failed to add administrator'),
  });

  const revoke = useMutation({
    mutationFn: (userId: string) => api.revokePlatformAdmin(userId),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['platform-admins'] }),
  });

  if (!isSuper) {
    return <ErrorState message="Super admin access required" />;
  }

  const canSubmit = Boolean(phone.trim() || email.trim());

  return (
    <div>
      <PageHeader
        title="User Management"
        description="Grant and revoke platform administrator access for the SmartHealth admin portal"
      />

      <div className="card mb-6 flex gap-3 border-teal-200 bg-teal-50/60 p-4 dark:border-teal-900 dark:bg-teal-950/30">
        <Shield className="mt-0.5 h-5 w-5 shrink-0 text-teal-600 dark:text-teal-400" />
        <div className="text-sm text-slate-600 dark:text-slate-300">
          <p className="font-medium text-slate-800 dark:text-slate-100">Platform administrators</p>
          <p className="mt-1">
            Platform admins have full access to system settings, data import, analytics, facility admin
            management, and all moderation tools. New admins sign in with their work email and a verification code.
            Phone OTP is available only when a registered mobile number is linked to the account.
            Revoked users keep their account but lose admin portal access after signing out.
          </p>
        </div>
      </div>

      <div className="card mb-6 p-5">
        <div className="mb-4 flex items-center gap-2">
          <UserPlus className="h-4 w-4 text-teal-600" />
          <h2 className="font-semibold">Add platform administrator</h2>
        </div>
        <p className="mb-4 text-sm text-slate-500">
          Enter a phone number to promote an existing user or create a new account. Email alone can
          promote users who have already signed in.
        </p>
        {formError && (
          <p className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
            {formError}
          </p>
        )}
        <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-4">
          <div>
            <label className="mb-1 block text-xs font-medium text-slate-500">Phone</label>
            <input
              className="input"
              placeholder="0771234567"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
            />
          </div>
          <div>
            <label className="mb-1 block text-xs font-medium text-slate-500">Email (optional)</label>
            <input
              className="input"
              type="email"
              placeholder="admin@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div>
            <label className="mb-1 block text-xs font-medium text-slate-500">First name</label>
            <input
              className="input"
              placeholder="First name"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
            />
          </div>
          <div>
            <label className="mb-1 block text-xs font-medium text-slate-500">Last name</label>
            <input
              className="input"
              placeholder="Last name"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
            />
          </div>
        </div>
        <button
          type="button"
          className="btn-primary mt-4"
          disabled={!canSubmit || promote.isPending}
          onClick={() => promote.mutate()}
        >
          {promote.isPending ? 'Adding…' : 'Add administrator'}
        </button>
      </div>

      <SearchBar
        value={q}
        onChange={(v) => {
          setQ(v);
          setPage(1);
        }}
        placeholder="Search by name, phone, or email…"
      />

      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}

      {data && (
        <>
          <div className="table-wrap mt-4">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Phone</th>
                  <th>Email</th>
                  <th>Last updated</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {data.admins.length === 0 && (
                  <tr>
                    <td colSpan={5} className="py-8 text-center text-slate-500">
                      No platform administrators found
                    </td>
                  </tr>
                )}
                {data.admins.map((admin) => {
                  const isSelf = admin.id === profile?.id;
                  return (
                    <tr key={admin.id}>
                      <td>
                        <div className="flex items-center gap-2">
                          <span>{displayName(admin)}</span>
                          {isSelf && (
                            <span className="badge badge-green text-xs">You</span>
                          )}
                        </div>
                      </td>
                      <td>{admin.phone ?? '—'}</td>
                      <td>{admin.email ?? '—'}</td>
                      <td>{new Date(admin.updatedAt).toLocaleString()}</td>
                      <td className="text-right">
                        {isSelf ? (
                          <span className="text-xs text-slate-400">Cannot revoke self</span>
                        ) : (
                          <button
                            type="button"
                            className="inline-flex items-center gap-1 text-sm text-red-600 hover:underline dark:text-red-400"
                            disabled={revoke.isPending}
                            onClick={() => {
                              if (
                                window.confirm(
                                  `Revoke platform administrator access for ${displayName(admin)}? They will lose admin portal access after signing out.`,
                                )
                              ) {
                                revoke.mutate(admin.id);
                              }
                            }}
                          >
                            <UserMinus className="h-3.5 w-3.5" />
                            Revoke
                          </button>
                        )}
                      </td>
                    </tr>
                  );
                })}
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
    </div>
  );
}
