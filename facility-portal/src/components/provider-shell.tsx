'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { Building2, LayoutDashboard, LogOut, Menu, Stethoscope, X } from 'lucide-react';
import { useState } from 'react';
import clsx from 'clsx';
import { useFacility } from '@/lib/facility-context';
import { createClient } from '@/lib/supabase/client';

const NAV = [
  { href: '/provider', label: 'Overview', icon: LayoutDashboard },
  { href: '/provider/facilities', label: 'Facilities', icon: Building2 },
];

export function ProviderShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { profile, loading, authError } = useFacility();
  const [open, setOpen] = useState(false);

  async function logout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push('/login');
  }

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center text-[var(--muted)]">
        Loading provider portal…
      </div>
    );
  }

  if (!profile) {
    if (authError) {
      return (
        <div className="flex min-h-screen items-center justify-center p-4">
          <div className="card w-full max-w-md text-center">
            <h1 className="text-xl font-bold text-red-600">Access denied</h1>
            <p className="mt-3 text-sm text-[var(--muted)]">{authError}</p>
            <Link href="/claim/profile" className="btn-primary mt-6 inline-flex w-full justify-center">
              Claim practitioner profile
            </Link>
          </div>
        </div>
      );
    }
    router.push('/login');
    return null;
  }

  const displayName =
    profile.provider?.name ??
    [profile.firstName, profile.lastName].filter(Boolean).join(' ') ??
    'Practitioner';

  return (
    <div className="flex min-h-screen">
      <aside
        className={clsx(
          'fixed inset-y-0 left-0 z-40 w-64 transform border-r border-[var(--border)] bg-[var(--card)] transition-transform lg:static lg:translate-x-0',
          open ? 'translate-x-0' : '-translate-x-full',
        )}
      >
        <div className="flex h-14 items-center justify-between border-b border-[var(--border)] px-4">
          <span className="font-bold text-teal-600">Provider Portal</span>
          <button type="button" className="lg:hidden" onClick={() => setOpen(false)}>
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="border-b border-[var(--border)] p-3">
          <p className="text-xs text-[var(--muted)]">Signed in as</p>
          <p className="text-sm font-medium">{displayName}</p>
          {profile.provider?.specialty && (
            <p className="text-xs text-[var(--muted)]">{profile.provider.specialty}</p>
          )}
        </div>

        <nav className="overflow-y-auto p-3">
          {NAV.map(({ href, label, icon: Icon }) => (
            <Link
              key={href}
              href={href}
              onClick={() => setOpen(false)}
              className={clsx(
                'mb-1 flex items-center gap-2 rounded-lg px-3 py-2 text-sm transition-colors',
                pathname === href
                  ? 'bg-teal-600/10 font-medium text-teal-600'
                  : 'text-[var(--muted)] hover:bg-slate-100 dark:hover:bg-slate-800',
              )}
            >
              <Icon className="h-4 w-4" />
              {label}
            </Link>
          ))}
          {profile.facilities.length > 0 && profile.portalMode === 'facility' && (
            <Link
              href="/"
              className="mb-1 flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-[var(--muted)] hover:bg-slate-100 dark:hover:bg-slate-800"
            >
              <Stethoscope className="h-4 w-4" />
              Facility operations
            </Link>
          )}
        </nav>
      </aside>

      <div className="flex flex-1 flex-col">
        <header className="flex h-14 items-center justify-between border-b border-[var(--border)] bg-[var(--card)] px-4">
          <button type="button" className="lg:hidden" onClick={() => setOpen(true)}>
            <Menu className="h-5 w-5" />
          </button>
          <div className="flex-1 px-4">
            <p className="text-sm font-medium">Practitioner account</p>
            <p className="text-xs text-[var(--muted)]">
              Claim and manage your linked facilities before opening facility operations
            </p>
          </div>
          <button type="button" className="btn-secondary" onClick={logout}>
            <LogOut className="h-4 w-4" />
            Sign out
          </button>
        </header>
        <main className="flex-1 p-4 lg:p-6">{children}</main>
      </div>
    </div>
  );
}
