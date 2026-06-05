'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  BarChart3, Building2, Calendar, Clock, FileText,
  LayoutDashboard, LogOut, Menu, Stethoscope, Users, UserCog,
  AlertTriangle, X,
} from 'lucide-react';
import { useState } from 'react';
import clsx from 'clsx';
import { useFacility } from '@/lib/facility-context';
import { createClient } from '@/lib/supabase/client';

const NAV = [
  { href: '/', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/facility', label: 'Facility Profile', icon: Building2 },
  { href: '/doctors', label: 'Doctors', icon: Stethoscope },
  { href: '/hours', label: 'Operating Hours', icon: Clock },
  { href: '/availability', label: 'Availability', icon: Calendar },
  { href: '/slots', label: 'Appointment Slots', icon: Calendar },
  { href: '/patients', label: 'Patients', icon: Users },
  { href: '/appointments', label: 'Appointments', icon: Calendar },
  { href: '/queue', label: 'Queue / Walk-ins', icon: Users },
  { href: '/emergency', label: 'Emergency', icon: AlertTriangle },
  { href: '/staff', label: 'Staff', icon: UserCog },
  { href: '/analytics', label: 'Analytics', icon: BarChart3 },
  { href: '/provider-analytics', label: 'My Performance', icon: Stethoscope },
  { href: '/reports', label: 'Reports', icon: FileText },
];

export function PortalShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { profile, facilityId, setFacilityId, loading, authError } = useFacility();
  const [open, setOpen] = useState(false);

  async function logout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push('/login');
  }

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center text-[var(--muted)]">
        Loading portal…
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
            <p className="mt-3 text-sm text-[var(--muted)]">
              Local dev: sign in once with test phone <strong>0771234567</strong> / OTP{' '}
              <strong>123456</strong>, then run{' '}
              <code className="rounded bg-slate-100 px-1 dark:bg-slate-800">scripts\setup-dev-admin.ps1</code>{' '}
              and sign in again.
            </p>
            <button type="button" className="btn-primary mt-6 w-full justify-center" onClick={logout}>
              Sign out
            </button>
          </div>
        </div>
      );
    }
    router.push('/login');
    return null;
  }

  const currentFacility = profile.facilities.find((f) => f.id === facilityId);

  return (
    <div className="flex min-h-screen">
      <aside
        className={clsx(
          'fixed inset-y-0 left-0 z-40 w-64 transform border-r border-[var(--border)] bg-[var(--card)] transition-transform lg:static lg:translate-x-0',
          open ? 'translate-x-0' : '-translate-x-full',
        )}
      >
        <div className="flex h-14 items-center justify-between border-b border-[var(--border)] px-4">
          <span className="font-bold text-teal-600">SmartHealth</span>
          <button type="button" className="lg:hidden" onClick={() => setOpen(false)}>
            <X className="h-5 w-5" />
          </button>
        </div>

        {profile.facilities.length > 1 && (
          <div className="border-b border-[var(--border)] p-3">
            <label className="text-xs text-[var(--muted)]">Facility</label>
            <select
              className="input mt-1"
              value={facilityId ?? ''}
              onChange={(e) => setFacilityId(e.target.value)}
            >
              {profile.facilities.map((f) => (
                <option key={f.id} value={f.id}>{f.name}</option>
              ))}
            </select>
          </div>
        )}

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
        </nav>
      </aside>

      <div className="flex flex-1 flex-col">
        <header className="flex h-14 items-center justify-between border-b border-[var(--border)] bg-[var(--card)] px-4">
          <button type="button" className="lg:hidden" onClick={() => setOpen(true)}>
            <Menu className="h-5 w-5" />
          </button>
          <div className="flex-1 px-4">
            <p className="text-sm font-medium">{currentFacility?.name ?? 'Facility Portal'}</p>
            <p className="text-xs text-[var(--muted)]">
              {profile.firstName} {profile.lastName} · {currentFacility?.role}
            </p>
          </div>
          <Link href="/provider/facilities" className="btn-secondary mr-2 hidden sm:inline-flex">
            Provider portal
          </Link>
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
