'use client';

import { useState, type FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

type OtpChannel = 'email' | 'phone';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<'email' | 'otp'>('email');
  const [channel, setChannel] = useState<OtpChannel>('email');
  const [destination, setDestination] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function sendOtp(usePhone = false) {
    setLoading(true);
    setError('');
    try {
      const res = await fetch('/v1/auth/otp/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          context: 'staff',
          email: email.trim(),
          channel: usePhone ? 'phone' : 'email',
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.error?.message ?? 'Failed to send verification code');
      }
      const data = await res.json();
      setChannel(data.channel === 'sms' ? 'phone' : 'email');
      setDestination(data.destination ?? email);
      setStep('otp');
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
            ?? 'This account does not have access to the facility portal. Ask an administrator to grant access, then try again.',
        );
      }

      router.push('/');
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <form
        onSubmit={step === 'email' ? (e) => { e.preventDefault(); void sendOtp(false); } : verifyOtp}
        className="card w-full max-w-md"
      >
        <h1 className="text-2xl font-bold text-teal-600">Facility Portal</h1>
        <p className="mt-1 text-sm text-[var(--muted)]">
          Staff login — verification code sent to your work email
        </p>

        {error && (
          <p className="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
            {error}
          </p>
        )}

        <label className="mt-6 block text-sm font-medium">Work email</label>
        <input
          className="input mt-1"
          type="email"
          value={email}
          onChange={(e) => {
            setEmail(e.target.value);
            setStep('email');
            setChannel('email');
          }}
          placeholder="staff@example.com"
          required
          disabled={step === 'otp'}
        />

        {step === 'otp' && (
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

        <button type="submit" className="btn-primary mt-6 w-full justify-center" disabled={loading || !email.trim()}>
          {loading ? 'Please wait…' : step === 'email' ? 'Send code' : 'Sign in'}
        </button>

        {step === 'email' ? (
          <button
            type="button"
            className="mt-2 w-full text-sm text-teal-600"
            disabled={loading || !email.trim()}
            onClick={() => void sendOtp(true)}
          >
            Send code to registered phone instead
          </button>
        ) : (
          <button type="button" className="mt-2 w-full text-sm text-teal-600" onClick={() => setStep('email')}>
            Use a different email
          </button>
        )}

        <p className="mt-6 text-center text-sm text-[var(--muted)]">
          Own a facility or practice?{' '}
          <a href="/claim" className="font-medium text-teal-600 hover:underline">
            Claim your listing
          </a>
        </p>
      </form>
    </div>
  );
}
