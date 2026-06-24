'use client';

import { ProviderShell } from '@/components/provider-shell';

export default function ProviderLayout({ children }: { children: React.ReactNode }) {
  return <ProviderShell>{children}</ProviderShell>;
}
