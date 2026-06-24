'use client';

import { Suspense, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { ClaimWizard } from './claim-wizard';

function ClaimPageInner() {
  const router = useRouter();
  const params = useSearchParams();

  useEffect(() => {
    if (params.get('mode') !== 'legacy') {
      router.replace('/claim/profile');
    }
  }, [params, router]);

  if (params.get('mode') !== 'legacy') {
    return <div className="p-8 text-center text-[var(--muted)]">Redirecting…</div>;
  }

  return <ClaimWizard />;
}

export default function ClaimPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-[var(--muted)]">Loading…</div>}>
      <ClaimPageInner />
    </Suspense>
  );
}
