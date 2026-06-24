'use client';

import clsx from 'clsx';

export function SectionCard({
  title,
  description,
  children,
  className,
}: {
  title: string;
  description?: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={clsx('card mb-6', className)}>
      <div className="mb-4">
        <h2 className="text-sm font-semibold uppercase tracking-wide text-[var(--muted)]">
          {title}
        </h2>
        {description && (
          <p className="mt-1 text-sm text-[var(--muted)]">{description}</p>
        )}
      </div>
      {children}
    </section>
  );
}

export function ViewToggle<T extends string>({
  value,
  options,
  onChange,
}: {
  value: T;
  options: { id: T; label: string }[];
  onChange: (v: T) => void;
}) {
  return (
    <div className="inline-flex rounded-lg border border-[var(--border)] p-1">
      {options.map((opt) => (
        <button
          key={opt.id}
          type="button"
          className={clsx(
            'rounded-md px-3 py-1.5 text-sm font-medium transition-colors',
            value === opt.id
              ? 'bg-teal-600 text-white'
              : 'text-[var(--muted)] hover:text-[var(--text)]',
          )}
          onClick={() => onChange(opt.id)}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
}
