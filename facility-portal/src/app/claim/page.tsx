import { Suspense } from 'react';
import { ClaimWizard } from './claim-wizard';

export default function ClaimPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-[var(--muted)]">Loading…</div>}>
      <ClaimWizard />
    </Suspense>
  );
}
