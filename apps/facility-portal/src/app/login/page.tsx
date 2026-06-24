'use client';

import Link from 'next/link';
import { useState, type FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import { claimApi } from '@/lib/claim-api';
import { createClient } from '@/lib/supabase/client';

type OtpChannel = 'email' | 'phone';

type FlowStep =
  | 'staff-email'
  | 'staff-otp'
  | 'claim-preview'
  | 'claim-otp'
  | 'no-match';

interface ClaimPreview {
  providerName: string;
  providerSpecialty: string | null;
  linkedCount: number;
  preview: string;
}

function resetClaimState(
  setStep: (step: FlowStep) => void,
  setClaimPreview: (preview: ClaimPreview | null) => void,
  setOtp: (otp: string) => void,
  setError: (error: string) => void,
) {
  setStep('staff-email');
  setClaimPreview(null);
  setOtp('');
  setError('');
}

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<FlowStep>('staff-email');
  const [channel, setChannel] = useState<OtpChannel>('email');
  const [destination, setDestination] = useState('');
  const [claimPreview, setClaimPreview] = useState<ClaimPreview | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingMessage, setLoadingMessage] = useState('Please wait…');

  async function attemptRegistryLookup(trimmedEmail: string): Promise<boolean> {
    setLoadingMessage('Searching MDPCZ registry…');
    const lookup = await claimApi.lookupProviderByEmail(trimmedEmail);

    if (!lookup.matched) {
      setStep('no-match');
      setError('');
      return true;
    }

    if (lookup.alreadyClaimed) {
      await sendStaffOtp(false, { skipRegistryFallback: true });
      return true;
    }

    if (lookup.ambiguous) {
      setError('Multiple profiles match this email. Contact validation@smarthealth.co.zw.');
      return true;
    }

    const linkedCount = lookup.linkedFacilities?.length ?? 0;
    const providerName = lookup.provider!.name;
    const providerSpecialty = lookup.provider!.specialty ?? null;
    const preview =
      linkedCount > 0
        ? `${providerName} — ${linkedCount} linked ${linkedCount === 1 ? 'facility' : 'facilities'} in registry`
        : `${providerName} — profile ready to claim`;

    setClaimPreview({ providerName, providerSpecialty, linkedCount, preview });
    setStep('claim-preview');
    setError('');
    return true;
  }

  async function sendStaffOtp(
    usePhone = false,
    options?: { skipRegistryFallback?: boolean },
  ) {
    setLoading(true);
    setLoadingMessage('Sending code…');
    setError('');
    const trimmedEmail = email.trim();

    try {
      const res = await fetch('/v1/auth/otp/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          context: 'staff',
          email: trimmedEmail,
          channel: usePhone ? 'phone' : 'email',
        }),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        const code = err?.error?.code as string | undefined;

        if (!usePhone && code === 'FORBIDDEN' && !options?.skipRegistryFallback) {
          await attemptRegistryLookup(trimmedEmail);
          return;
        }

        throw new Error(err?.error?.message ?? 'Failed to send verification code');
      }

      const data = await res.json();
      setChannel(data.channel === 'sms' ? 'phone' : 'email');
      setDestination(data.destination ?? trimmedEmail);
      setClaimPreview(null);
      setStep('staff-otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed');
    } finally {
      setLoading(false);
      setLoadingMessage('Please wait…');
    }
  }

  async function sendClaimOtp(e?: FormEvent) {
    e?.preventDefault();
    setLoading(true);
    setLoadingMessage('Sending code…');
    setError('');

    try {
      const res = await fetch('/v1/auth/otp/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          context: 'practitioner',
          email: email.trim(),
          channel: 'email',
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.error?.message ?? 'Failed to send verification code');
      }
      const data = await res.json();
      setDestination(data.destination ?? email.trim());
      setStep('claim-otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed');
    } finally {
      setLoading(false);
      setLoadingMessage('Please wait…');
    }
  }

  async function verifyStaffOtp(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setLoadingMessage('Signing in…');
    setError('');

    try {
      const res = await fetch('/v1/auth/otp/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          context: 'staff',
          email: email.trim(),
          otp,
          channel,
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.error?.message ?? 'Invalid verification code');
      }
      const tokens = await res.json();
      const supabase = createClient();
      const { error: sessionError } = await supabase.auth.setSession({
        access_token: tokens.accessToken,
        refresh_token: tokens.refreshToken,
      });
      if (sessionError) {
        throw new Error(sessionError.message);
      }

      const profileRes = await fetch('/v1/facility/me', {
        headers: { Authorization: `Bearer ${tokens.accessToken}` },
      });
      if (!profileRes.ok) {
        const err = await profileRes.json().catch(() => ({}));
        await supabase.auth.signOut();
        throw new Error(
          err?.error?.message
            ?? 'This account does not have access to the facility portal. Ask a facility administrator for access.',
        );
      }

      const profileData = await profileRes.json();
      const portalMode = profileData.profile?.portalMode as string | undefined;
      const hasMemberships = (profileData.profile?.facilities?.length ?? 0) > 0;

      if (portalMode === 'provider' || !hasMemberships) {
        window.location.assign('/provider/facilities');
      } else {
        router.push('/dashboard');
        router.refresh();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
      setLoadingMessage('Please wait…');
    }
  }

  async function verifyClaimOtp(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setLoadingMessage('Verifying…');
    setError('');

    try {
      const res = await fetch('/v1/auth/otp/verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          context: 'practitioner',
          email: email.trim(),
          otp,
          channel: 'email',
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.error?.message ?? 'Invalid verification code');
      }
      const tokens = await res.json();
      const supabase = createClient();
      const { error: sessionError } = await supabase.auth.setSession({
        access_token: tokens.accessToken,
        refresh_token: tokens.refreshToken,
      });
      if (sessionError) {
        throw new Error(sessionError.message);
      }
      window.location.assign('/provider/facilities');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
    } finally {
      setLoading(false);
      setLoadingMessage('Please wait…');
    }
  }

  function handleEmailChange(value: string) {
    setEmail(value);
    resetClaimState(setStep, setClaimPreview, setOtp, setError);
    setChannel('email');
    setDestination('');
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (step === 'staff-email') {
      void sendStaffOtp(false);
    } else if (step === 'staff-otp') {
      void verifyStaffOtp(e);
    } else if (step === 'claim-preview') {
      void sendClaimOtp(e);
    } else if (step === 'claim-otp') {
      void verifyClaimOtp(e);
    }
  }

  const emailLocked = step === 'staff-otp' || step === 'claim-otp';
  const showOtpField = step === 'staff-otp' || step === 'claim-otp';
  const primaryLabel =
    step === 'staff-email'
      ? 'Send code'
      : step === 'staff-otp'
        ? 'Sign in'
        : step === 'claim-preview'
          ? 'Send verification code'
          : step === 'claim-otp'
            ? 'Verify & claim profile'
            : null;

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="card w-full max-w-md">
        <h1 className="text-2xl font-bold text-teal-600">Facility Portal</h1>
        <p className="mt-1 text-sm text-[var(--muted)]">
          {step === 'claim-preview' || step === 'claim-otp'
            ? 'Claim your MDPCZ practitioner profile to get started'
            : step === 'no-match'
              ? 'We could not find an account for this email'
              : 'Staff login — verification code sent to your work email'}
        </p>

        {error && (
          <p className="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
            {error}
          </p>
        )}

        {step === 'no-match' && (
          <div className="mt-4 rounded-lg bg-amber-50 p-4 text-sm text-amber-900 dark:bg-amber-950 dark:text-amber-200">
            <p>
              No staff account or MDPCZ practitioner profile was found for{' '}
              <strong>{email.trim()}</strong>.
            </p>
            <p className="mt-2">Double-check the email address, or start a manual claim if you are not yet in the registry.</p>
          </div>
        )}

        {step !== 'no-match' && (
          <>
            <label className="mt-6 block text-sm font-medium">Work email</label>
            <input
              className="input mt-1"
              type="email"
              value={email}
              onChange={(e) => handleEmailChange(e.target.value)}
              placeholder="staff@example.com"
              required
              disabled={emailLocked}
            />
          </>
        )}

        {claimPreview && (step === 'claim-preview' || step === 'claim-otp') && (
          <p className="mt-4 rounded-lg bg-teal-50 p-3 text-sm text-teal-800 dark:bg-teal-950 dark:text-teal-200">
            {step === 'claim-otp' ? (
              <>
                Claiming profile for <strong>{claimPreview.providerName}</strong>
                {claimPreview.providerSpecialty ? ` · ${claimPreview.providerSpecialty}` : ''}
                {claimPreview.linkedCount > 0
                  ? ` — ${claimPreview.linkedCount} linked ${claimPreview.linkedCount === 1 ? 'facility' : 'facilities'} await in your portal`
                  : ''}
              </>
            ) : (
              <strong>{claimPreview.preview}</strong>
            )}
          </p>
        )}

        {showOtpField && (
          <>
            <p className="mt-4 text-sm text-[var(--muted)]">
              Code sent to <strong>{destination}</strong>
            </p>
            <label className="mt-4 block text-sm font-medium">Verification code</label>
            <input
              className="input mt-1"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              placeholder="123456"
              inputMode="numeric"
              autoComplete="one-time-code"
              required
            />
          </>
        )}

        {step !== 'no-match' && primaryLabel && (
          <button
            type="submit"
            className="btn-primary mt-6 w-full justify-center"
            disabled={loading || !email.trim()}
          >
            {loading ? loadingMessage : primaryLabel}
          </button>
        )}

        {step === 'staff-email' && (
          <button
            type="button"
            className="mt-2 w-full text-sm text-teal-600"
            disabled={loading || !email.trim()}
            onClick={() => void sendStaffOtp(true)}
          >
            Send code to registered phone instead
          </button>
        )}

        {step === 'staff-otp' && (
          <button
            type="button"
            className="mt-2 w-full text-sm text-teal-600"
            onClick={() => resetClaimState(setStep, setClaimPreview, setOtp, setError)}
          >
            Use a different email
          </button>
        )}

        {step === 'claim-preview' && (
          <button
            type="button"
            className="mt-2 w-full text-sm text-teal-600"
            onClick={() => resetClaimState(setStep, setClaimPreview, setOtp, setError)}
          >
            Use a different email
          </button>
        )}

        {step === 'claim-otp' && (
          <button
            type="button"
            className="mt-2 w-full text-sm text-teal-600"
            disabled={loading}
            onClick={() => void sendClaimOtp()}
          >
            Resend code
          </button>
        )}

        {step === 'no-match' && (
          <div className="mt-6 space-y-2">
            <button
              type="button"
              className="btn-primary w-full justify-center"
              onClick={() => resetClaimState(setStep, setClaimPreview, setOtp, setError)}
            >
              Try another email
            </button>
            <Link
              href={`/claim?mode=legacy&email=${encodeURIComponent(email.trim())}`}
              className="btn-secondary flex w-full justify-center"
            >
              Start manual claim
            </Link>
          </div>
        )}

        {step === 'staff-email' && (
          <p className="mt-6 text-center text-xs text-[var(--muted)]">
            MDPCZ practitioner without a staff account? Enter your registry email above — we will
            find your profile automatically.
          </p>
        )}
      </form>
    </div>
  );
}
