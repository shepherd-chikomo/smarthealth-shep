import { env } from '../config.js';
import { query } from './db.js';
import { AppError } from './errors.js';

interface SupabaseAuthResponse {
  access_token?: string;
  refresh_token?: string;
  expires_in?: number;
  token_type?: string;
  user?: {
    id: string;
    email?: string;
    phone?: string;
  };
  error?: string;
  error_description?: string;
  msg?: string;
}

export interface AuthUserResult {
  id: string;
  phone?: string;
  email?: string;
}

export interface AuthTokenResult {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: AuthUserResult;
}

/** Prefer direct GoTrue in Docker; Kong is for external clients only. */
function authServiceUrl(path: string): string {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  if (env.SUPABASE_URL.includes('kong')) {
    return `http://auth:9999${normalizedPath}`;
  }
  return `${env.SUPABASE_URL.replace(/\/$/, '')}/auth/v1${normalizedPath}`;
}

async function supabaseAuthRequest(
  path: string,
  body: Record<string, unknown>,
  useServiceRole = false,
): Promise<SupabaseAuthResponse> {
  const apiKey = useServiceRole ? env.SUPABASE_SERVICE_ROLE_KEY : env.SUPABASE_ANON_KEY;

  const response = await fetch(authServiceUrl(path), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: apiKey,
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });

  const data = (await response.json()) as SupabaseAuthResponse;

  if (!response.ok) {
    throw new AppError(
      response.status,
      'AUTH_ERROR',
      data.error_description ?? data.msg ?? data.error ?? 'Authentication failed',
    );
  }

  return data;
}

function mapAuthResponse(data: SupabaseAuthResponse): AuthTokenResult {
  if (!data.access_token || !data.refresh_token || !data.user) {
    throw new AppError(500, 'AUTH_ERROR', 'Incomplete auth response from Supabase');
  }

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token,
    expiresIn: data.expires_in ?? 3600,
    user: {
      id: data.user.id,
      phone: data.user.phone,
      email: data.user.email,
    },
  };
}

export function normalizeEmail(email: string): string {
  const normalized = email.trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
    throw new AppError(422, 'VALIDATION_ERROR', 'Email address is invalid');
  }
  return normalized;
}

export async function sendPhoneOtp(
  phone: string,
  createUser = true,
): Promise<{ message: string }> {
  await supabaseAuthRequest('/otp', {
    phone,
    create_user: createUser,
  });
  return { message: 'OTP sent successfully' };
}

export async function sendEmailOtp(
  email: string,
  createUser = true,
): Promise<{ message: string }> {
  await supabaseAuthRequest('/otp', {
    email,
    create_user: createUser,
  });
  return { message: 'OTP sent successfully' };
}

/** Sync profile email onto the GoTrue user so email OTP can be delivered. */
export async function ensureAuthUserEmail(userId: string, email: string): Promise<void> {
  const normalized = normalizeEmail(email);
  const current = await query<{ email: string | null }>(
    'SELECT email FROM auth.users WHERE id = $1',
    [userId],
  );
  if (current.rows[0]?.email?.trim().toLowerCase() === normalized) {
    return;
  }

  const authAdminBase = env.SUPABASE_URL.includes('kong')
    ? 'http://auth:9999'
    : `${env.SUPABASE_URL.replace(/\/$/, '')}/auth/v1`;

  const response = await fetch(`${authAdminBase}/admin/users/${userId}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      apikey: env.SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify({
      email: normalized,
      email_confirm: true,
    }),
  });

  if (!response.ok) {
    const data = (await response.json().catch(() => ({}))) as SupabaseAuthResponse;
    throw new AppError(
      response.status,
      'AUTH_ERROR',
      data.error_description ?? data.msg ?? data.error ?? 'Failed to sync auth email',
    );
  }
}

/** @deprecated Use sendPhoneOtp */
export async function sendOtp(phone: string): Promise<{ message: string }> {
  return sendPhoneOtp(phone, true);
}

export async function verifyPhoneOtp(phone: string, token: string): Promise<AuthTokenResult> {
  const data = await supabaseAuthRequest('/verify', {
    phone,
    token,
    type: 'sms',
  });
  return mapAuthResponse(data);
}

export async function verifyEmailOtp(email: string, token: string): Promise<AuthTokenResult> {
  const data = await supabaseAuthRequest('/verify', {
    email,
    token,
    type: 'email',
  });
  return mapAuthResponse(data);
}

/** @deprecated Use verifyPhoneOtp */
export async function verifyOtp(phone: string, token: string): Promise<AuthTokenResult> {
  return verifyPhoneOtp(phone, token);
}

export async function refreshTokens(refreshToken: string): Promise<{
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}> {
  const data = await supabaseAuthRequest('/token?grant_type=refresh_token', {
    refresh_token: refreshToken,
  });

  if (!data.access_token || !data.refresh_token) {
    throw new AppError(401, 'INVALID_REFRESH_TOKEN', 'Refresh token is invalid or expired');
  }

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token,
    expiresIn: data.expires_in ?? 3600,
  };
}

export async function logout(accessToken: string): Promise<{ message: string }> {
  const response = await fetch(authServiceUrl('/logout'), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: env.SUPABASE_ANON_KEY,
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok && response.status !== 204) {
    const data = (await response.json().catch(() => ({}))) as SupabaseAuthResponse;
    throw new AppError(
      response.status,
      'AUTH_ERROR',
      data.error_description ?? data.msg ?? 'Logout failed',
    );
  }

  return { message: 'Logged out successfully' };
}

export function normalizeZimbabwePhone(phone: string): string {
  const digits = phone.replace(/\D/g, '');
  if (digits.startsWith('263') && digits.length === 12) {
    return `+${digits}`;
  }
  if (digits.startsWith('0') && digits.length === 10) {
    return `+263${digits.slice(1)}`;
  }
  if (phone.startsWith('+263') && digits.length === 12) {
    return phone;
  }
  throw new AppError(422, 'VALIDATION_ERROR', 'Phone must be a valid Zimbabwe number (+263...)');
}
