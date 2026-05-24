'use client';

import clsx from 'clsx';

type AppointmentRow = Record<string, unknown>;

function dayKey(date: Date) {
  return `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`;
}

function parseScheduled(value: unknown) {
  return new Date(String(value));
}

export function AppointmentCalendar({
  appointments,
  month,
  onMonthChange,
  onSelect,
}: {
  appointments: AppointmentRow[];
  month: Date;
  onMonthChange: (d: Date) => void;
  onSelect?: (appointment: AppointmentRow) => void;
}) {
  const year = month.getFullYear();
  const monthIndex = month.getMonth();
  const firstDay = new Date(year, monthIndex, 1);
  const startOffset = firstDay.getDay();
  const daysInMonth = new Date(year, monthIndex + 1, 0).getDate();

  const byDay = new Map<string, AppointmentRow[]>();
  for (const appt of appointments) {
    const d = parseScheduled(appt.scheduled_at);
    const key = dayKey(d);
    const list = byDay.get(key) ?? [];
    list.push(appt);
    byDay.set(key, list);
  }

  const cells: (number | null)[] = [
    ...Array.from({ length: startOffset }, () => null),
    ...Array.from({ length: daysInMonth }, (_, i) => i + 1),
  ];

  while (cells.length % 7 !== 0) cells.push(null);

  return (
    <div>
      <div className="mb-4 flex items-center justify-between">
        <button
          type="button"
          className="btn-secondary"
          onClick={() => onMonthChange(new Date(year, monthIndex - 1, 1))}
        >
          Previous
        </button>
        <h3 className="font-semibold">
          {month.toLocaleString(undefined, { month: 'long', year: 'numeric' })}
        </h3>
        <button
          type="button"
          className="btn-secondary"
          onClick={() => onMonthChange(new Date(year, monthIndex + 1, 1))}
        >
          Next
        </button>
      </div>

      <div className="grid grid-cols-7 gap-1 text-center text-xs font-medium text-[var(--muted)]">
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => (
          <div key={d} className="py-2">{d}</div>
        ))}
      </div>

      <div className="grid grid-cols-7 gap-1">
        {cells.map((day, idx) => {
          if (day == null) {
            return <div key={`empty-${idx}`} className="min-h-[72px]" />;
          }
          const date = new Date(year, monthIndex, day);
          const items = byDay.get(dayKey(date)) ?? [];
          return (
            <div
              key={day}
              className="min-h-[72px] rounded-lg border border-[var(--border)] bg-[var(--card)] p-1"
            >
              <p className="text-xs font-semibold text-[var(--muted)]">{day}</p>
              <div className="mt-1 space-y-1">
                {items.slice(0, 2).map((a) => (
                  <button
                    key={String(a.id)}
                    type="button"
                    className={clsx(
                      'block w-full truncate rounded px-1 py-0.5 text-left text-[10px]',
                      'bg-teal-50 text-teal-800 dark:bg-teal-950 dark:text-teal-200',
                    )}
                    onClick={() => onSelect?.(a)}
                  >
                    {parseScheduled(a.scheduled_at).toLocaleTimeString([], {
                      hour: '2-digit',
                      minute: '2-digit',
                    })}{' '}
                    {String(a.patient_name).split(' ')[0]}
                  </button>
                ))}
                {items.length > 2 && (
                  <p className="text-[10px] text-[var(--muted)]">+{items.length - 2} more</p>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
