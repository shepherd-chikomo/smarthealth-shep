'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader } from '@/components/ui';

const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

type HourRow = {
  dayOfWeek: number;
  opensAt: string;
  closesAt: string;
  isClosed: boolean;
  is24Hours: boolean;
};

type HolidayRow = { date: string; label: string };

export default function HoursPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const { data, isLoading, error } = useQuery({
    queryKey: ['hours', facilityId],
    queryFn: () => api.hours(facilityId!),
    enabled: !!facilityId,
  });

  const overridesQuery = useQuery({
    queryKey: ['schedule-overrides', facilityId],
    queryFn: () => api.scheduleOverrides(facilityId!),
    enabled: !!facilityId,
  });

  const emergencyQuery = useQuery({
    queryKey: ['emergency', facilityId],
    queryFn: () => api.emergency(facilityId!),
    enabled: !!facilityId,
  });

  const [hours, setHours] = useState<HourRow[]>([]);
  const [initialized, setInitialized] = useState(false);
  const [temporarilyClosed, setTemporarilyClosed] = useState(false);
  const [closureReason, setClosureReason] = useState('');
  const [holidays, setHolidays] = useState<HolidayRow[]>([]);
  const [overridesInit, setOverridesInit] = useState(false);
  const [emergencyInit, setEmergencyInit] = useState(false);
  const [acceptsEmergency, setAcceptsEmergency] = useState(false);

  if (data && !initialized) {
    const existing = (data.hours as Record<string, unknown>[]).reduce<Record<number, HourRow>>((acc, h) => {
      acc[Number(h.day_of_week)] = {
        dayOfWeek: Number(h.day_of_week),
        opensAt: String(h.opens_at ?? '08:00'),
        closesAt: String(h.closes_at ?? '17:00'),
        isClosed: Boolean(h.is_closed),
        is24Hours: Boolean(h.is_24_hours),
      };
      return acc;
    }, {});
    setHours(DAYS.map((_, i) => existing[i] ?? {
      dayOfWeek: i, opensAt: '08:00', closesAt: '17:00', isClosed: false, is24Hours: false,
    }));
    setInitialized(true);
  }

  if (overridesQuery.data?.overrides && !overridesInit) {
    const o = overridesQuery.data.overrides as Record<string, unknown>;
    setTemporarilyClosed(Boolean(o.temporarilyClosed));
    setClosureReason(String(o.closureReason ?? ''));
    setHolidays(Array.isArray(o.holidays) ? (o.holidays as HolidayRow[]) : []);
    setOverridesInit(true);
  }

  if (emergencyQuery.data?.availability && !emergencyInit) {
    const a = emergencyQuery.data.availability as Record<string, unknown>;
    setAcceptsEmergency(Boolean(a.acceptsEmergency));
    setEmergencyInit(true);
  }

  const saveHours = useMutation({
    mutationFn: () => api.updateHours(facilityId!, hours),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['hours', facilityId] }),
  });

  const saveOverrides = useMutation({
    mutationFn: () =>
      api.updateScheduleOverrides(facilityId!, {
        temporarilyClosed,
        closureReason,
        holidays,
      }),
    onSuccess: () =>
      qc.invalidateQueries({ queryKey: ['schedule-overrides', facilityId] }),
  });

  const saveEmergency = useMutation({
    mutationFn: () => {
      const current = (emergencyQuery.data?.availability ?? {}) as Record<string, unknown>;
      return api.updateEmergency(facilityId!, {
        ...current,
        acceptsEmergency,
      });
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['emergency', facilityId] }),
  });

  const addHoliday = () => {
    setHolidays([...holidays, { date: '', label: '' }]);
  };

  return (
    <div>
      <PageHeader
        title="Operating Hours"
        description="Facility schedule, closures, holidays, and emergency availability"
      />
      {isLoading && <LoadingState />}
      {error && <ErrorState message={(error as Error).message} />}

      {temporarilyClosed && (
        <div className="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800 dark:border-red-900 dark:bg-red-950 dark:text-red-300">
          Facility is temporarily closed
          {closureReason ? `: ${closureReason}` : ''}
        </div>
      )}

      {initialized && (
        <>
          <div className="card mb-6 max-w-2xl space-y-4">
            <h2 className="text-sm font-semibold">Temporary closure</h2>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={temporarilyClosed}
                onChange={(e) => setTemporarilyClosed(e.target.checked)}
              />
              Close facility temporarily
            </label>
            {temporarilyClosed && (
              <div>
                <label className="text-sm font-medium">Reason (shown to patients)</label>
                <input
                  className="input mt-1 w-full"
                  value={closureReason}
                  onChange={(e) => setClosureReason(e.target.value)}
                  placeholder="e.g. Public holiday maintenance"
                />
              </div>
            )}
            <button
              type="button"
              className="btn-secondary"
              disabled={saveOverrides.isPending}
              onClick={() => saveOverrides.mutate()}
            >
              Save closure settings
            </button>
          </div>

          <div className="card mb-6 max-w-2xl space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold">Holiday overrides</h2>
              <button type="button" className="btn-secondary text-xs" onClick={addHoliday}>
                Add holiday
              </button>
            </div>
            {holidays.length === 0 && (
              <p className="text-sm text-[var(--muted)]">No holiday closures configured.</p>
            )}
            {holidays.map((h, i) => (
              <div key={i} className="grid gap-2 sm:grid-cols-3">
                <input
                  type="date"
                  className="input"
                  value={h.date}
                  onChange={(e) =>
                    setHolidays(holidays.map((x, j) => (j === i ? { ...x, date: e.target.value } : x)))
                  }
                />
                <input
                  className="input sm:col-span-2"
                  placeholder="Holiday name"
                  value={h.label}
                  onChange={(e) =>
                    setHolidays(holidays.map((x, j) => (j === i ? { ...x, label: e.target.value } : x)))
                  }
                />
              </div>
            ))}
            {holidays.length > 0 && (
              <button
                type="button"
                className="btn-secondary"
                disabled={saveOverrides.isPending}
                onClick={() => saveOverrides.mutate()}
              >
                Save holidays
              </button>
            )}
          </div>

          <div className="card mb-6 max-w-2xl space-y-3">
            <h2 className="text-sm font-semibold">Emergency availability</h2>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={acceptsEmergency}
                onChange={(e) => setAcceptsEmergency(e.target.checked)}
              />
              Accept emergency walk-ins
            </label>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                className="btn-secondary"
                disabled={saveEmergency.isPending}
                onClick={() => saveEmergency.mutate()}
              >
                Save emergency setting
              </button>
              <Link href="/emergency" className="btn-secondary">
                Full emergency settings
              </Link>
            </div>
          </div>

          <form
            className="card max-w-2xl space-y-3"
            onSubmit={(e) => {
              e.preventDefault();
              saveHours.mutate();
            }}
          >
            <h2 className="text-sm font-semibold">Weekly schedule</h2>
            {hours.map((h, i) => (
              <div key={h.dayOfWeek} className="grid grid-cols-2 items-center gap-2 border-t border-[var(--border)] pt-3 first:border-t-0 first:pt-0 sm:grid-cols-5">
                <span className="font-medium">{DAYS[i]}</span>
                <input
                  type="time"
                  className="input"
                  value={h.opensAt.slice(0, 5)}
                  disabled={h.isClosed}
                  onChange={(e) =>
                    setHours(hours.map((x, j) => (j === i ? { ...x, opensAt: e.target.value } : x)))
                  }
                />
                <input
                  type="time"
                  className="input"
                  value={h.closesAt.slice(0, 5)}
                  disabled={h.isClosed}
                  onChange={(e) =>
                    setHours(hours.map((x, j) => (j === i ? { ...x, closesAt: e.target.value } : x)))
                  }
                />
                <label className="flex items-center gap-1 text-sm">
                  <input
                    type="checkbox"
                    checked={h.isClosed}
                    onChange={(e) =>
                      setHours(hours.map((x, j) => (j === i ? { ...x, isClosed: e.target.checked } : x)))
                    }
                  />
                  Closed
                </label>
                <label className="flex items-center gap-1 text-sm">
                  <input
                    type="checkbox"
                    checked={h.is24Hours}
                    onChange={(e) =>
                      setHours(hours.map((x, j) => (j === i ? { ...x, is24Hours: e.target.checked } : x)))
                    }
                  />
                  24h
                </label>
              </div>
            ))}
            <button type="submit" className="btn-primary" disabled={saveHours.isPending}>
              Save hours
            </button>
          </form>
        </>
      )}
    </div>
  );
}
