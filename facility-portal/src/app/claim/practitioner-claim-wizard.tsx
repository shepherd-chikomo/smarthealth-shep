'use client';

import { useCallback, useEffect, useState, type FormEvent } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Building2, CheckCircle2, Clock, Stethoscope, Users } from 'lucide-react';
import {
  PractitionerStepper,
  type PractitionerStepId,
} from '@/components/practitioner-stepper';
import {
  claimApi,
  type LinkedFacility,
  type PractitionerClaimResult,
} from '@/lib/claim-api';
import { createClient } from '@/lib/supabase/client';

export function PractitionerClaimWizard() {
  const router = useRouter();
  const [step, setStep] = useState<PractitionerStepId>('account');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [otpStep, setOtpStep] = useState<'email' | 'otp'>('email');
  const [otpDestination, setOtpDestination] = useState('');
  const [providerName, setProviderName] = useState('');
  const [providerSpecialty, setProviderSpecialty] = useState<string | null>(null);
  const [linkedFacilities, setLinkedFacilities] = useState<LinkedFacility[]>([]);
  const [ownedFacilityIds, setOwnedFacilityIds] = useState<Set<string>>(new Set());
  const [lookupPreview, setLookupPreview] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [claimingId, setClaimingId] = useState<string | null>(null);

  const applyClaimResult = useCallback((result: PractitionerClaimResult) => {
    setProviderName(result.providerName);
    setLinkedFacilities(result.linkedFacilities);
    setOwnedFacilityIds(
      new Set(result.linkedFacilities.filter((f) => f.isOwnedByMe).map((f) => f.id)),
    );
    setStep('facilities');
  }, []);

  const refreshFacilities = useCallback(async () => {
    try {
      const { facilities } = await claimApi.myPrimaryFacilities();
      setLinkedFacilities(facilities);
      setOwnedFacilityIds(new Set(facilities.filter((f) => f.isOwnedByMe).map((f) => f.id)));
    } catch {
      /* session may not be ready yet */
    }
  }, []);

  const resumeSession = useCallback(async () => {
    const supabase = createClient();
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) return;

    try {
      const status = await claimApi.onboardingStatus();
      if (status.phase === 'unclaimed') return;

      setProviderName(status.provider?.name ?? '');
      setProviderSpecialty(status.provider?.specialty ?? null);
      if (status.linkedFacilities) {
        setLinkedFacilities(status.linkedFacilities);
        setOwnedFacilityIds(
          new Set(status.linkedFacilities.filter((f) => f.isOwnedByMe).map((f) => f.id)),
        );
      }

      if (status.phase === 'ready') {
        setStep('complete');
      } else {
        setStep('facilities');
        await refreshFacilities();
      }
    } catch {
      /* ignore */
    }
  }, [refreshFacilities]);

  useEffect(() => {
    void resumeSession();
  }, [resumeSession]);

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
      if (lookup.linkedFacilities) {
        setLinkedFacilities(lookup.linkedFacilities);
      }
      const facilityCount = lookup.linkedFacilities?.length ?? 0;
      setLookupPreview(
        facilityCount > 0
          ? `${lookup.provider!.name} — ${facilityCount} linked ${facilityCount === 1 ? 'facility' : 'facilities'} found`
          : `${lookup.provider!.name} — no linked facilities yet`,
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

      if (tokens.practitionerClaim) {
        applyClaimResult(tokens.practitionerClaim);
      } else {
        const status = await claimApi.onboardingStatus();
        if (status.phase === 'unclaimed') {
          throw new Error('Could not claim practitioner profile');
        }
        setProviderName(status.provider?.name ?? '');
        setProviderSpecialty(status.provider?.specialty ?? null);
        if (status.linkedFacilities) setLinkedFacilities(status.linkedFacilities);
        setStep(status.phase === 'ready' ? 'complete' : 'facilities');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed');
    } finally {
      setLoading(false);
    }
  }

  async function claimFacility(facilityId: string) {
    setClaimingId(facilityId);
    setError('');
    try {
      await claimApi.instantClaimFacility(facilityId);
      setOwnedFacilityIds((prev) => new Set(prev).add(facilityId));
      setLinkedFacilities((prev) =>
        prev.map((f) =>
          f.id === facilityId ? { ...f, isClaimed: true, canClaimOwnership: false } : f,
        ),
      );
      const status = await claimApi.onboardingStatus();
      if (status.phase === 'ready') {
        setStep('complete');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not claim facility');
    } finally {
      setClaimingId(null);
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
          Sign in with your registry email to claim your profile and linked facilities.
        </p>
        <div className="mt-4">
          <PractitionerStepper current={step} />
        </div>
      </header>

      {error && (
        <p className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
          {error}
        </p>
      )}

      {step === 'account' && (
        <div className="card space-y-4">
          <h2 className="text-lg font-semibold">1. Verify your registry email</h2>
          <p className="text-sm text-[var(--muted)]">
            Enter the email address on file with MDPCZ. We will match it to your practitioner
            profile and send a verification code.
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
      )}

      {step === 'facilities' && (
        <div className="card space-y-4">
          <h2 className="text-lg font-semibold">2. Claim your facilities</h2>
          <p className="text-sm text-[var(--muted)]">
            These facilities are linked to <strong>{providerName}</strong> in the HPA registry.
            Claim each one to manage it in the portal.
          </p>

          {linkedFacilities.length === 0 ? (
            <p className="rounded-lg border border-[var(--border)] p-4 text-sm text-[var(--muted)]">
              No facilities are linked to your profile yet. Contact validation@smarthealth.co.zw
              if you expect facilities to appear here.
            </p>
          ) : (
            <ul className="space-y-2">
              {linkedFacilities.map((f) => {
                const isOwned = Boolean(f.isOwnedByMe) || ownedFacilityIds.has(f.id);
                const isUnavailable = f.isClaimed && !isOwned;
                return (
                  <li
                    key={f.id}
                    className="flex items-center justify-between gap-3 rounded-lg border border-[var(--border)] p-3"
                  >
                    <div>
                      <p className="font-medium">{f.name}</p>
                      <p className="text-xs text-[var(--muted)]">
                        {f.city ?? 'Zimbabwe'}
                        {isOwned ? ' · You own this' : isUnavailable ? ' · Already claimed' : ''}
                      </p>
                    </div>
                    {isOwned ? (
                      <span className="badge badge-green inline-flex shrink-0">
                        <CheckCircle2 className="h-3 w-3" /> Claimed
                      </span>
                    ) : isUnavailable ? (
                      <span className="badge inline-flex shrink-0 text-[var(--muted)]">Unavailable</span>
                    ) : (
                      <button
                        type="button"
                        className="btn-primary shrink-0"
                        disabled={claimingId === f.id}
                        onClick={() => void claimFacility(f.id)}
                      >
                        {claimingId === f.id ? 'Claiming…' : 'Claim ownership'}
                      </button>
                    )}
                  </li>
                );
              })}
            </ul>
          )}

          {ownedFacilityIds.size > 0 && (
            <button
              type="button"
              className="btn-primary w-full justify-center"
              onClick={() => setStep('complete')}
            >
              Continue to portal
            </button>
          )}
        </div>
      )}

      {step === 'complete' && (
        <div className="card space-y-5">
          <div className="text-center">
            <h2 className="text-lg font-semibold text-teal-600">3. You&apos;re all set</h2>
            <p className="mt-2 text-sm text-[var(--muted)]">
              Your practitioner profile and {ownedFacilityIds.size}{' '}
              {ownedFacilityIds.size === 1 ? 'facility' : 'facilities'} are ready.
              Manage hours, invite practitioners, and add administrators from the portal.
            </p>
            <span className="badge badge-green mt-3 inline-flex">Verified Practitioner</span>
          </div>
          <div className="grid gap-2 sm:grid-cols-2">
            <Link href="/hours" className="btn-secondary justify-start">
              <Clock className="h-4 w-4" /> Operating hours
            </Link>
            <Link href="/doctors" className="btn-secondary justify-start">
              <Users className="h-4 w-4" /> Providers
            </Link>
            <Link href="/slots" className="btn-secondary justify-start">
              <Stethoscope className="h-4 w-4" /> Appointments
            </Link>
            <Link href="/queue" className="btn-secondary justify-start">
              <Building2 className="h-4 w-4" /> Queue preferences
            </Link>
          </div>
          <button
            type="button"
            className="btn-primary w-full justify-center"
            onClick={() => router.push('/')}
          >
            Open facility portal
          </button>
        </div>
      )}
    </div>
  );
}
