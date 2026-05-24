'use client';

import clsx from 'clsx';
import { CheckCircle2 } from 'lucide-react';
import type { LinkedFacility } from '@/lib/api';

export function facilityStatusLabel(f: LinkedFacility): string {
  if (f.isOwnedByMe) return 'Owned by you';
  if (f.isClaimed) return 'Claimed by another';
  return 'Unclaimed';
}

interface FacilityTabsProps {
  facilities: LinkedFacility[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}

export function FacilityTabs({ facilities, selectedId, onSelect }: FacilityTabsProps) {
  if (facilities.length === 0) {
    return (
      <p className="rounded-lg border border-[var(--border)] p-4 text-sm text-[var(--muted)]">
        No facilities are linked to your profile in the registry yet.
      </p>
    );
  }

  return (
    <div className="flex flex-wrap gap-2 border-b border-[var(--border)] pb-3">
      {facilities.map((f) => {
        const active = f.id === selectedId;
        return (
          <button
            key={f.id}
            type="button"
            onClick={() => onSelect(f.id)}
            className={clsx(
              'rounded-full px-3 py-1.5 text-sm font-medium transition-colors',
              active && 'bg-teal-600 text-white',
              !active && 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300',
            )}
          >
            {f.name}
            {f.isOwnedByMe && (
              <CheckCircle2 className="ml-1 inline h-3 w-3 text-teal-200" aria-hidden />
            )}
          </button>
        );
      })}
    </div>
  );
}

interface FacilityTabPanelProps {
  facility: LinkedFacility | null;
  claimingId: string | null;
  onClaim: (id: string) => void;
  onManage: (id: string) => void;
}

export function FacilityTabPanel({
  facility,
  claimingId,
  onClaim,
  onManage,
}: FacilityTabPanelProps) {
  if (!facility) return null;

  return (
    <div className="mt-4 rounded-lg border border-[var(--border)] p-4">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h3 className="text-lg font-semibold">{facility.name}</h3>
          <p className="text-sm text-[var(--muted)]">{facility.city ?? 'Zimbabwe'}</p>
          <span
            className={clsx(
              'badge mt-2 inline-flex',
              facility.isOwnedByMe && 'badge-green',
              !facility.isOwnedByMe && facility.isClaimed && 'text-[var(--muted)]',
              !facility.isOwnedByMe && !facility.isClaimed && 'badge-yellow',
            )}
          >
            {facilityStatusLabel(facility)}
          </span>
        </div>
        <div className="flex shrink-0 flex-col gap-2 sm:flex-row">
          {facility.isOwnedByMe ? (
            <button type="button" className="btn-primary" onClick={() => onManage(facility.id)}>
              Manage facility
            </button>
          ) : facility.canClaimOwnership ? (
            <button
              type="button"
              className="btn-primary"
              disabled={claimingId === facility.id}
              onClick={() => onClaim(facility.id)}
            >
              {claimingId === facility.id ? 'Claiming…' : 'Claim ownership'}
            </button>
          ) : null}
        </div>
      </div>
      {facility.isOwnedByMe && (
        <p className="mt-3 text-sm text-[var(--muted)]">
          Open the facility portal to manage hours, staff, doctors, appointments, and queue settings
          for this site.
        </p>
      )}
      {!facility.isOwnedByMe && facility.canClaimOwnership && (
        <p className="mt-3 text-sm text-[var(--muted)]">
          You are listed as the HPA role-holder for this facility. Claim ownership to manage it in
          SmartHealth.
        </p>
      )}
    </div>
  );
}

interface MyFacilitiesPanelProps {
  facilities: LinkedFacility[];
  activeFacilityId: string | null;
  compact?: boolean;
  claimingId?: string | null;
  onClaim?: (id: string) => void;
  onManage?: (id: string) => void;
  onSwitch?: (id: string) => void;
}

export function MyFacilitiesPanel({
  facilities,
  activeFacilityId,
  compact = false,
  claimingId = null,
  onClaim,
  onManage,
  onSwitch,
}: MyFacilitiesPanelProps) {
  if (facilities.length === 0) return null;

  return (
    <ul className={clsx('space-y-2', compact ? 'text-sm' : '')}>
      {facilities.map((f) => {
        const isActive = f.id === activeFacilityId;
        return (
          <li
            key={f.id}
            className={clsx(
              'flex flex-wrap items-center justify-between gap-2 rounded-lg border p-3',
              isActive ? 'border-teal-500 bg-teal-50/50 dark:bg-teal-950/30' : 'border-[var(--border)]',
            )}
          >
            <div>
              <p className="font-medium">{f.name}</p>
              <p className="text-xs text-[var(--muted)]">
                {f.city ?? 'Zimbabwe'} · {facilityStatusLabel(f)}
                {isActive ? ' · Active' : ''}
              </p>
            </div>
            <div className="flex shrink-0 gap-2">
              {f.isOwnedByMe && onManage && !isActive && onSwitch && (
                <button type="button" className="btn-secondary text-xs" onClick={() => onSwitch(f.id)}>
                  Switch to
                </button>
              )}
              {f.isOwnedByMe && onManage && (
                <button type="button" className="btn-primary text-xs" onClick={() => onManage(f.id)}>
                  Manage
                </button>
              )}
              {!f.isOwnedByMe && f.canClaimOwnership && onClaim && (
                <button
                  type="button"
                  className="btn-primary text-xs"
                  disabled={claimingId === f.id}
                  onClick={() => onClaim(f.id)}
                >
                  {claimingId === f.id ? 'Claiming…' : 'Claim'}
                </button>
              )}
            </div>
          </li>
        );
      })}
    </ul>
  );
}
