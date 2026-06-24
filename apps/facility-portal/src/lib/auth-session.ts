import { createClient } from './supabase/client';

/** Rotate Supabase tokens so JWT claims match the current DB role (via custom_access_token_hook). */
export async function refreshAuthSession(): Promise<boolean> {
  const supabase = createClient();
  const { data: { session } } = await supabase.auth.getSession();
  if (!session?.refresh_token) return false;

  const res = await fetch('/v1/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken: session.refresh_token }),
  });
  if (!res.ok) return false;

  const tokens = (await res.json()) as {
    accessToken: string;
    refreshToken: string;
  };

  const { error } = await supabase.auth.setSession({
    access_token: tokens.accessToken,
    refresh_token: tokens.refreshToken,
  });

  return !error;
}
