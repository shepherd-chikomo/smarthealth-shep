import { Sparkles } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

export function SectionBadge({ children }: { children: React.ReactNode }) {
  return (
    <div className="badge-pill">
      <Sparkles size={14} className="shrink-0" />
      <span>{children}</span>
    </div>
  );
}

export function FeatureIconCard({
  icon: Icon,
  title,
  description,
  teal = false,
}: {
  icon: LucideIcon;
  title: string;
  description: string;
  teal?: boolean;
}) {
  return (
    <div className="card transition hover:border-sky-100 hover:shadow-md">
      <div className={teal ? 'icon-box-teal' : 'icon-box'}>
        <Icon size={20} />
      </div>
      <h3 className="mt-4 text-base font-bold text-slate-900">{title}</h3>
      <p className="mt-2 text-sm leading-relaxed text-slate-600">{description}</p>
    </div>
  );
}

export function ArrowLink({ children, href }: { children: React.ReactNode; href: string }) {
  return (
    <a href={href} className="btn-android">
      {children}
      <span aria-hidden>→</span>
    </a>
  );
}

export function IosDownloadLink({ children, href }: { children: React.ReactNode; href: string }) {
  return (
    <a href={href} className="btn-ios">
      {children}
    </a>
  );
}
