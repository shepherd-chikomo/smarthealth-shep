import { useState, type FormEvent } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../lib/auth';
import { api, type OtpChannel } from '../lib/api';

export function LoginPage() {
  const { login, profile, loading } = useAuth();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [channel, setChannel] = useState<OtpChannel>('email');
  const [destination, setDestination] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && profile) return <Navigate to="/" replace />;

  async function onSendOtp(usePhone = false) {
    setSubmitting(true);
    setError('');
    try {
      const result = await api.sendOtp({
        context: 'staff',
        email: email.trim(),
        channel: usePhone ? 'phone' : 'email',
      });
      setChannel(result.channel === 'sms' ? 'phone' : 'email');
      setDestination(result.destination);
      setOtpSent(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to send OTP');
    } finally {
      setSubmitting(false);
    }
  }

  async function onSignIn(e: FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError('');
    try {
      await login({
        context: 'staff',
        email: email.trim(),
        otp,
        channel,
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <form onSubmit={otpSent ? onSignIn : (e) => { e.preventDefault(); void onSendOtp(false); }} className="card w-full max-w-md p-8">
        <h1 className="text-2xl font-bold text-teal-600">SmartHealth Admin</h1>
        <p className="mt-1 text-sm text-slate-500">
          Staff login — verification code sent to your email
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
            setOtpSent(false);
            setChannel('email');
          }}
          placeholder="admin@smarthealth.co.zw"
          required
          disabled={otpSent}
        />

        {otpSent && (
          <>
            <p className="mt-4 text-sm text-slate-600 dark:text-slate-300">
              Code sent to <strong>{destination}</strong>
            </p>
            <label className="mt-4 block text-sm font-medium">Verification code</label>
            <input
              className="input mt-1"
              type="password"
              inputMode="numeric"
              autoComplete="one-time-code"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              placeholder="123456"
              required
              autoFocus
            />
            <p className="mt-1 text-xs text-[var(--muted)]">
              Local dev: open <a href="http://localhost:54324" className="text-teal-600 hover:underline" target="_blank" rel="noreferrer">Inbucket</a> (mailbox: first part of your email) if you did not receive the code
            </p>
          </>
        )}

        <button type="submit" className="btn-primary mt-6 w-full justify-center" disabled={submitting || !email.trim()}>
          {submitting ? (otpSent ? 'Signing in…' : 'Sending code…') : otpSent ? 'Sign in' : 'Send code'}
        </button>

        {otpSent ? (
          <button
            type="button"
            className="mt-3 w-full text-sm text-teal-600 hover:underline"
            disabled={submitting}
            onClick={() => void onSendOtp(false)}
          >
            Resend code
          </button>
        ) : (
          <button
            type="button"
            className="mt-3 w-full text-sm text-teal-600 hover:underline"
            disabled={submitting || !email.trim()}
            onClick={() => void onSendOtp(true)}
          >
            Send code to registered phone instead
          </button>
        )}

        {otpSent && (
          <button
            type="button"
            className="mt-2 w-full text-sm text-slate-500 hover:underline"
            onClick={() => {
              setOtpSent(false);
              setOtp('');
              setChannel('email');
            }}
          >
            Use a different email
          </button>
        )}
      </form>
    </div>
  );
}
