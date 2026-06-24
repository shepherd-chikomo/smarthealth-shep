'use client';

import Link from 'next/link';
import {
  CalendarPlus,
  Clock,
  PauseCircle,
  UserPlus,
} from 'lucide-react';

const actions = [
  {
    href: '/queue?walkIn=1',
    label: 'Add walk-in',
    description: 'Register a patient in the queue',
    icon: UserPlus,
  },
  {
    href: '/hours',
    label: 'Update hours',
    description: 'Edit operating schedule',
    icon: Clock,
  },
  {
    href: '/queue?pause=1',
    label: 'Pause queue',
    description: 'Manage queue flow',
    icon: PauseCircle,
  },
  {
    href: '/appointments?create=1',
    label: 'Add appointment',
    description: 'Book a new visit',
    icon: CalendarPlus,
  },
] as const;

export function QuickActionsGrid() {
  return (
    <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      {actions.map(({ href, label, description, icon: Icon }) => (
        <Link
          key={href}
          href={href}
          className="rounded-xl border border-[var(--border)] bg-[var(--card)] p-4 transition-colors hover:border-teal-500/40 hover:bg-teal-50/30 dark:hover:bg-teal-950/20"
        >
          <Icon className="mb-2 h-5 w-5 text-teal-600 dark:text-teal-400" />
          <p className="font-semibold">{label}</p>
          <p className="mt-1 text-xs text-[var(--muted)]">{description}</p>
        </Link>
      ))}
    </div>
  );
}
