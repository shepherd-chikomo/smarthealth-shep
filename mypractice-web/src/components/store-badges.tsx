function AppleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M16.365 1.43c0 1.14-.493 2.27-1.177 3.08-.744.9-1.99 1.57-2.987 1.47-.12-1.06.46-2.21 1.084-2.99.76-.94 2.122-1.64 3.08-1.56zM20.88 17.17c-.57 1.31-.84 1.9-1.57 3.06-1.02 1.66-2.46 3.74-4.24 3.76-1.59.02-2.01-1.03-4.19-1.03-2.18 0-2.64 1.01-4.2 1.05-1.79.04-3.15-1.87-4.17-3.52-2.28-3.7-4.02-10.48-1.68-15.06 1.16-2.01 3.23-3.28 5.48-3.31 1.71-.03 3.33 1.15 4.19 1.15.85 0 2.44-1.42 4.12-1.21.7.03 2.67.28 3.93 2.1-3.4 1.85-2.85 6.68.57 8.01z" />
    </svg>
  );
}

function PlayIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M3.6 2.4A1.2 1.2 0 0 0 2 3.6v16.8a1.2 1.2 0 0 0 1.8 1.04l14.4-8.4a1.2 1.2 0 0 0 0-2.08L3.6 2.36z" />
    </svg>
  );
}

export function StoreBadges({ className = '' }: { className?: string }) {
  return (
    <div className={`flex flex-wrap gap-3 ${className}`}>
      <span className="inline-flex items-center gap-2.5 rounded-xl bg-slate-900 px-4 py-2.5 text-white shadow-sm">
        <AppleIcon />
        <span className="text-left leading-tight">
          <span className="block text-[9px] uppercase tracking-wide opacity-80">Download on the</span>
          <span className="block text-sm font-semibold">App Store</span>
        </span>
      </span>
      <span className="inline-flex items-center gap-2.5 rounded-xl bg-slate-900 px-4 py-2.5 text-white shadow-sm">
        <PlayIcon />
        <span className="text-left leading-tight">
          <span className="block text-[9px] uppercase tracking-wide opacity-80">Get it on</span>
          <span className="block text-sm font-semibold">Google Play</span>
        </span>
      </span>
    </div>
  );
}
