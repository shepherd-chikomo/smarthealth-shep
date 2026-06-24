import Image from 'next/image';

const playStoreUrl = process.env.NEXT_PUBLIC_PLAY_STORE_URL ?? '#';
const appStoreUrl = process.env.NEXT_PUBLIC_APP_STORE_URL ?? '#';

export function StoreBadges({ className = '' }: { className?: string }) {
  return (
    <div className={`flex flex-wrap items-center gap-4 ${className}`}>
      <a
        href={playStoreUrl}
        className="inline-block overflow-hidden rounded-lg transition hover:opacity-90"
        aria-label="Get it on Google Play"
      >
        <Image
          src="/images/google-play-badge.png"
          alt="Get it on Google Play"
          width={637}
          height={183}
          unoptimized
          className="h-[52px] w-auto sm:h-[56px]"
        />
      </a>
      <a
        href={appStoreUrl}
        className="inline-block overflow-hidden rounded-lg transition hover:opacity-90"
        aria-label="Download on the App Store"
      >
        <Image
          src="/images/app-store-badge.png"
          alt="Download on the App Store"
          width={638}
          height={183}
          unoptimized
          className="h-[52px] w-auto sm:h-[56px]"
        />
      </a>
    </div>
  );
}
