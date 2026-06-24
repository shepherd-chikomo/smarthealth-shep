import Image from 'next/image';
import Link from 'next/link';
import { site } from '@/lib/site';

type BrandLogoProps = {
  className?: string;
  showSubtitle?: boolean;
  size?: number;
  variant?: 'light' | 'dark';
};

export function BrandLogo({
  className = '',
  showSubtitle = true,
  size = 40,
  variant = 'light',
}: BrandLogoProps) {
  const titleClass = variant === 'dark' ? 'text-white' : 'text-slate-900';
  const subtitleClass = variant === 'dark' ? 'text-slate-400' : 'text-slate-500';

  return (
    <Link href="/" className={`flex items-center gap-3 ${className}`}>
      <Image
        src="/mypractice-icon.png"
        alt=""
        width={size}
        height={size}
        className="rounded-xl shadow-sm shadow-blue-500/20"
        priority
      />
      <div className="leading-tight">
        <div className={`text-base font-bold ${titleClass}`}>{site.name}</div>
        {showSubtitle && (
          <div className={`text-[10px] font-semibold tracking-widest ${subtitleClass}`}>
            BY SMARTHEALTH
          </div>
        )}
      </div>
    </Link>
  );
}
