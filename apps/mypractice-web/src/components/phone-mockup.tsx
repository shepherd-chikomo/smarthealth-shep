/** Simplified MyPractice dashboard mockup for marketing sections */
export function PhoneMockup({
  className = '',
  size = 'md',
}: {
  className?: string;
  size?: 'md' | 'lg';
}) {
  const width = size === 'lg' ? 'w-[280px] sm:w-[300px]' : 'w-[260px] sm:w-[280px]';
  return (
    <div
      className={`relative mx-auto ${width} rounded-[2rem] border-[6px] border-slate-900 bg-slate-900 p-1 shadow-2xl shadow-slate-900/30 ${className}`}
    >
      <div className="overflow-hidden rounded-[1.6rem] bg-slate-50">
        <div className="bg-white px-4 pb-3 pt-8">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[10px] text-slate-500">Good morning,</p>
              <p className="text-xs font-bold text-slate-900">Dr. Olivia Carter</p>
            </div>
            <div className="h-8 w-8 rounded-full bg-blue-100" />
          </div>
          <div className="mt-3 grid grid-cols-3 gap-1.5">
            {[
              { v: '24', l: 'Appts' },
              { v: '165', l: 'Patients' },
              { v: '8', l: 'Tasks' },
            ].map((s) => (
              <div key={s.l} className="rounded-lg bg-blue-50 p-2 text-center">
                <div className="text-sm font-bold text-blue-700">{s.v}</div>
                <div className="text-[8px] text-slate-500">{s.l}</div>
              </div>
            ))}
          </div>
        </div>
        <div className="space-y-2 bg-white px-3 pb-4">
          <p className="text-[10px] font-semibold text-slate-700">Today&apos;s Appointments</p>
          {[
            { name: 'James Anderson', time: '9:30 AM', status: 'Confirmed', color: 'bg-emerald-100 text-emerald-700' },
            { name: 'Sophia Martinez', time: '10:15 AM', status: 'Pending', color: 'bg-amber-100 text-amber-700' },
            { name: 'Michael Brown', time: '11:00 AM', status: 'Confirmed', color: 'bg-emerald-100 text-emerald-700' },
          ].map((a) => (
            <div key={a.name} className="flex items-center gap-2 rounded-lg border border-slate-100 p-2">
              <div className="min-w-0 flex-1">
                <p className="truncate text-[10px] font-medium text-slate-800">{a.name}</p>
                <p className="text-[8px] text-slate-500">{a.time}</p>
              </div>
              <span className={`rounded-full px-1.5 py-0.5 text-[7px] font-medium ${a.color}`}>
                {a.status}
              </span>
            </div>
          ))}
        </div>
        <div className="flex justify-around border-t border-slate-200 bg-white py-2">
          {['Home', 'Patients', 'Appts', 'More'].map((t) => (
            <span key={t} className="text-[8px] text-slate-400">
              {t}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}

export function FloatingStatCard({
  icon,
  title,
  subtitle,
  className = '',
  iconClassName = 'bg-blue-50',
}: {
  icon: React.ReactNode;
  title: string;
  subtitle: string;
  className?: string;
  iconClassName?: string;
}) {
  return (
    <div
      className={`absolute rounded-2xl border border-slate-100/90 bg-white/95 px-4 py-3 shadow-lg shadow-slate-300/50 backdrop-blur-sm ${className}`}
    >
      <div className="flex items-center gap-3">
        <div
          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${iconClassName}`}
        >
          {icon}
        </div>
        <div>
          <p className="text-sm font-bold leading-tight text-slate-900">{title}</p>
          <p className="text-xs text-slate-500">{subtitle}</p>
        </div>
      </div>
    </div>
  );
}
