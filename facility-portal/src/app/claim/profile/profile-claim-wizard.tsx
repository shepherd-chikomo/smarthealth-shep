'use client';

import { useState, type FormEvent } from 'react';
import Link from 'next/link';
import { claimApi } from '@/lib/claim-api';
import { createClient } from '@/lib/supabase/client';

export function ProfileClaimWizard() {
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [otpStep, setOtpStep] = useState<'email' | 'otp'>('email');
  const [otpDestination, setOtpDestination] = useState('');
  const [providerName, setProviderName] = useState('');
  const [providerSpecialty, setProviderSpecialty] = useState<string | null>(null);
  const [lookupPreview, setLookupPreview] = useState<string | null>(null);
  const [linkedCount, setLinkedCount] = useState(0);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function lookupEmail(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    setLookupPreview(null);
    try {
      const lookup = await claimApi.lookupProviderByEmail(email.trim());
      if (!lookup.matched) {
        throw new Error(
          'No practitioner profile found for this email. Try the manual claim flow or contact support.',
        );
      }
      if (lookup.alreadyClaimed) {
        throw new Error(
          'This practitioner profile is already claimed. Use facility portal login instead.',
        );
      }
      if (lookup.ambiguous) {
        throw new Error('Multiple profiles match this email. Contact validation@smarthealth.co.zw.');
      }
      setProviderName(lookup.provider!.name);
      setProviderSpecialty(lookup.provider!.specialty ?? null);
      const count = lookup.linkedFacilities?.length ?? 0;
      setLinkedCount(count);
      setLookupPreview(
        count > 0
          ? `${lookup.provider!.name} — ${count} linked ${count === 1 ? 'facility' : 'facilities'} in registry`
          : `${lookup.provider!.name} — profile ready to claim`,
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Lookup failed');
    } finally {
      setLoading(false);
    }
  }

  async function sendOtp(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
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
      setOtpDestination(data.destination ?? email);
      setOtpStep('otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed');
    } finally {
      setLoading(false);
    }
  }

  async function verifyOtp(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
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
        throw new Error(err?.error?.message ?? 'Invalid OTP');
      }
      const tokens = await res.json();
      const supabase = createClient();
      await supabase.auth.setSession({
        access_token: tokens.accessToken,
        refresh_token: tokens.refreshToken,
      });
      window.location.assign('/provider/facilities');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto min-h-screen max-w-2xl p-4 pb-16">
      <header className="mb-6">
        <Link href="/login" className="text-sm text-teal-600 hover:underline">
          ← Facility portal login
        </Link>
        <h1 className="mt-3 text-2xl font-bold text-teal-600">Claim your practitioner profile</h1>
        <p className="mt-1 text-sm text-[var(--muted)]">
          Verify your registry email to claim your MDPCZ profile. You can claim facilities separately
          after signing in.
        </p>
      </header>

      {error && (
        <p className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
          {error}
        </p>
      )}

      <div className="card space-y-4">
        <h2 className="text-lg font-semibold">Verify your registry email</h2>
        <p className="text-sm text-[var(--muted)]">
          Enter the email on file with MDPCZ. We will match it to your practitioner profile and send
          a verification code.
        </p>

        {otpStep === 'email' ? (
          <form onSubmit={lookupPreview ? sendOtp : lookupEmail} className="space-y-4">
            <label className="block text-sm font-medium">Email</label>
            <input
              className="input"
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                setLookupPreview(null);
                setOtpStep('email');
              }}
              placeholder="you@example.com"
              required
            />
            {lookupPreview && (
              <p className="rounded-lg bg-teal-50 p-3 text-sm text-teal-800 dark:bg-teal-950 dark:text-teal-200">
                <strong>{lookupPreview}</strong>
              </p>
            )}
            <button type="submit" className="btn-primary w-full justify-center" disabled={loading}>
              {loading
                ? 'Please wait…'
                : lookupPreview
                  ? 'Send verification code'
                  : 'Find my profile'}
            </button>
            {lookupPreview && (
              <button
                type="button"
                className="w-full text-sm text-teal-600"
                onClick={() => {
                  setLookupPreview(null);
                  setProviderName('');
                }}
              >
                Use a different email
              </button>
            )}
          </form>
        ) : (
          <form onSubmit={verifyOtp} className="space-y-4">
            {providerName && (
              <p className="rounded-lg bg-teal-50 p-3 text-sm text-teal-800 dark:bg-teal-950 dark:text-teal-200">
                Claiming profile for <strong>{providerName}</strong>
                {providerSpecialty ? ` · ${providerSpecialty}` : ''}
                {linkedCount > 0
                  ? ` — ${linkedCount} linked ${linkedCount === 1 ? 'facility' : 'facilities'} await in your portal`
                  : ''}
              </p>
            )}
            <p className="text-sm text-[var(--muted)]">
              Code sent to <strong>{otpDestination}</strong>
            </p>
            <label className="block text-sm font-medium">Verification code</label>
            <input
              className="input"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              placeholder="123456"
              inputMode="numeric"
              autoComplete="one-time-code"
              required
            />
            <button type="submit" className="btn-primary w-full justify-center" disabled={loading}>
              {loading ? 'Verifying…' : 'Verify & claim profile'}
            </button>
            <button
              type="button"
              className="w-full text-sm text-teal-600"
              onClick={() => setOtpStep('email')}
            >
              Resend code
            </button>
          </form>
        )}

        <p className="text-center text-xs text-[var(--muted)]">
          Not in the registry?{' '}
          <Link href="/claim?mode=legacy" className="text-teal-600 hover:underline">
            Use manual claim flow
          </Link>
        </p>
      </div>
    </div>
  );
}
