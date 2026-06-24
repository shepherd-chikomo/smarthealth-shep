import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import {
  DEFAULT_PORTAL_URL,
  isMarketingHost,
  isPortalPath,
} from '@/lib/site-hosts';

export function middleware(request: NextRequest) {
  const host = request.headers.get('host');
  const { pathname, search } = request.nextUrl;
  const marketing = isMarketingHost(host);

  if (marketing) {
    if (isPortalPath(pathname)) {
      const target = new URL(`${pathname}${search}`, DEFAULT_PORTAL_URL);
      return NextResponse.redirect(target);
    }
    if (pathname === '/') {
      return NextResponse.rewrite(new URL('/marketing', request.url));
    }
    if (pathname.startsWith('/marketing')) {
      return NextResponse.next();
    }
    return NextResponse.redirect(new URL('/', request.url));
  }

  if (pathname === '/') {
    return NextResponse.redirect(new URL(`/dashboard${search}`, request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
};
