import Image from 'next/image';

const playStoreUrl = process.env.NEXT_PUBLIC_PLAY_STORE_URL ?? '#';
const appStoreUrl = process.env.NEXT_PUBLIC_APP_STORE_URL ?? '#';

export function StoreBadges({ className = '' }: { className?: string }) {
  return (
    <div className={`flex flex-wrap items-center gap-3 ${className}`}>
      <a
        href={playStoreUrl}
        className="inline-block transition hover:opacity-90"
        aria-label="Get it on Google Play"
      >
        <Image
          src="/images/google-play-badge.png"
          alt="Get it on Google Play"
          width={270}
          height={80}
          className="h-12 w-auto sm:h-14"
        />
      </a>
      <a
        href={appStoreUrl}
        className="inline-block transition hover:opacity-90"
        aria-label="Download on the App Store"
      >
        <Image
          src="/images/app-store-badge.png"
          alt="Download on the App Store"
          width={270}
          height={80}
          className="h-12 w-auto sm:h-14"
        />
      </a>
    </div>
  );
}
