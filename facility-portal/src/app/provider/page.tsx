'use client';

import Link from 'next/link';
import { useFacility } from '@/lib/facility-context';
import { LoadingState, PageHeader } from '@/components/ui';

export default function ProviderOverviewPage() {
  const { profile, loading } = useFacility();

  if (loading) return <LoadingState />;

  const provider = profile?.provider;

  return (
    <div>
      <PageHeader
        title="Provider overview"
        description="Your practitioner identity and registry-linked facilities"
      />

      <div className="card space-y-4">
        <h2 className="text-lg font-semibold">Your profile</h2>
        {provider ? (
          <dl className="grid gap-3 text-sm sm:grid-cols-2">
            <div>
              <dt className="text-[var(--muted)]">Name</dt>
              <dd className="font-medium">{provider.name}</dd>
            </div>
            <div>
              <dt className="text-[var(--muted)]">Specialty</dt>
              <dd className="font-medium">{provider.specialty ?? '—'}</dd>
            </div>
            <div>
              <dt className="text-[var(--muted)]">Registration</dt>
              <dd className="font-medium">{provider.registrationNumber ?? '—'}</dd>
            </div>
            <div>
              <dt className="text-[var(--muted)]">Email</dt>
              <dd className="font-medium">{profile?.email ?? '—'}</dd>
            </div>
          </dl>
        ) : (
          <p className="text-sm text-[var(--muted)]">
            No claimed practitioner profile on this account.{' '}
            <Link href="/claim/profile" className="text-teal-600 hover:underline">
              Claim your profile
            </Link>
          </p>
        )}
      </div>

      <div className="card mt-4 space-y-3">
        <h2 className="text-lg font-semibold">Next steps</h2>
        <p className="text-sm text-[var(--muted)]">
          Open the Facilities tab to see every site linked to your name in the HPA registry. Claim
          ownership for each facility you manage, then open facility operations to add staff and
          doctors.
        </p>
        <Link href="/provider/facilities" className="btn-primary inline-flex">
          Go to Facilities
        </Link>
      </div>
    </div>
  );
}
