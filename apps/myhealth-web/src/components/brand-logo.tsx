import Image from 'next/image';
import Link from 'next/link';
import { site } from '@/lib/site';

type BrandLogoProps = {
  className?: string;
  showText?: boolean;
  size?: number;
  variant?: 'light' | 'dark';
};

export function BrandLogo({
  className = '',
  showText = true,
  size = 40,
  variant = 'light',
}: BrandLogoProps) {
  const textClass = variant === 'dark' ? 'text-white' : 'text-slate-900';

  return (
    <Link href="/" className={`flex items-center gap-3 ${className}`}>
      <Image
        src="/myhealth-icon.png"
        alt=""
        width={size}
        height={size}
        className="rounded-xl shadow-sm shadow-sky-500/20"
        priority
      />
      {showText && (
        <div className={`text-lg font-bold tracking-tight ${textClass}`}>{site.name}</div>
      )}
    </Link>
  );
}
