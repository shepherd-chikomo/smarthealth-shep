/** Hostnames that serve the public MyPractice marketing site. */
export const MARKETING_HOSTS = [
  'mypractice.smarthealth.co.zw',
  'www.mypractice.smarthealth.co.zw',
] as const;

export const DEFAULT_PORTAL_URL =
  process.env.NEXT_PUBLIC_PORTAL_URL ?? 'https://dev.smarthealth.co.zw';

export function normalizeHost(host: string | null): string {
  return (host ?? '').split(':')[0].toLowerCase();
}

export function isMarketingHost(host: string | null): boolean {
  const h = normalizeHost(host);
  if (!h) return false;
  return MARKETING_HOSTS.some((m) => h === m);
}

/** Portal-only path prefixes (redirect to dev portal from marketing host). */
export const PORTAL_PATH_PREFIXES = [
  '/dashboard',
  '/facility',
  '/doctors',
  '/hours',
  '/availability',
  '/slots',
  '/patients',
  '/appointments',
  '/queue',
  '/emergency',
  '/billing',
  '/inventory',
  '/staff',
  '/analytics',
  '/reports',
  '/provider-analytics',
  '/login',
  '/claim',
  '/provider',
  '/admin',
] as const;

export function isPortalPath(pathname: string): boolean {
  return PORTAL_PATH_PREFIXES.some(
    (p) => pathname === p || pathname.startsWith(`${p}/`),
  );
}
