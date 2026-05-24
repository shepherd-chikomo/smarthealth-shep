'use client';

import { useCallback, useEffect, useMemo, useState, type FormEvent } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { Building2, Clock, Stethoscope, Users } from 'lucide-react';
import { ClaimStepper, type ClaimStepId } from '@/components/claim-stepper';
import { FileUploadZone, type UploadedFile } from '@/components/file-upload-zone';
import {
  claimApi,
  type ClaimRecord,
  type ClaimableFacility,
  type ClaimableProvider,
} from '@/lib/claim-api';
import { createClient } from '@/lib/supabase/client';

type ClaimType = 'facility' | 'provider';

function evidenceFromFiles(files: UploadedFile[]) {
  return {
    documents: files.map((f) => ({
      name: f.name,
      type: f.type,
      size: f.size,
      dataUrl: f.dataUrl,
    })),
  };
}

function statusLabel(status: string) {
  switch (status) {
    case 'draft':
      return 'Draft';
    case 'submitted':
    case 'under_review':
      return 'Claim Pending';
    case 'approved':
      return 'Approved';
    case 'rejected':
      return 'Rejected';
    default:
      return status;
  }
}

export function ClaimWizard() {
  const router = useRouter();
  const params = useSearchParams();
  const initialType = (params.get('type') as ClaimType | null) ?? 'facility';
  const initialTargetId = params.get('targetId') ?? params.get('id');

  const [step, setStep] = useState<ClaimStepId>('account');
  const [claimType, setClaimType] = useState<ClaimType>(initialType);
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [otpStep, setOtpStep] = useState<'email' | 'otp'>('email');
  const [otpChannel, setOtpChannel] = useState<'email' | 'phone'>('email');
  const [otpDestination, setOtpDestination] = useState('');
  const [emailVerified, setEmailVerified] = useState(false);
  const [phoneVerified, setPhoneVerified] = useState(false);
  const [files, setFiles] = useState<UploadedFile[]>([]);
  const [searchQ, setSearchQ] = useState('');
  const [facilities, setFacilities] = useState<ClaimableFacility[]>([]);
  const [providers, setProviders] = useState<ClaimableProvider[]>([]);
  const [selectedFacility, setSelectedFacility] = useState<ClaimableFacility | null>(null);
  const [selectedProvider, setSelectedProvider] = useState<ClaimableProvider | null>(null);
  const [regNumber, setRegNumber] = useState('');
  const [mdpczNumber, setMdpczNumber] = useState('');
  const [notes, setNotes] = useState('');
  const [activeClaim, setActiveClaim] = useState<ClaimRecord | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [isAuthed, setIsAuthed] = useState(false);

  const checkAuth = useCallback(async () => {
    const supabase = createClient();
    const { data: { session } } = await supabase.auth.getSession();
    const authed = Boolean(session);
    setIsAuthed(authed);
    if (authed) {
      setPhoneVerified(true);
      setStep((s) => (s === 'account' ? 'verify' : s));
      try {
        const mine = await claimApi.myClaims();
        const pending = [...mine.facilityClaims, ...mine.providerClaims].find((c) =>
          ['draft', 'submitted', 'under_review', 'approved'].includes(c.status),
        );
        if (pending) {
          setActiveClaim(pending);
          if (pending.status === 'approved') setStep('approved');
          else if (['submitted', 'under_review'].includes(pending.status)) setStep('pending');
          else if (pending.status === 'draft') setStep('submit');
        }
      } catch {
        /* ignore — user may not have claims yet */
      }
    }
  }, []);

  useEffect(() => {
    void checkAuth();
  }, [checkAuth]);

  useEffect(() => {
    if (!initialTargetId || !isAuthed) return;
    void (async () => {
      try {
        if (initialType === 'facility') {
          const { facilities: list } = await claimApi.searchFacilities('');
          const match = list.find((f) => f.id === initialTargetId);
          if (match) {
            setSelectedFacility(match);
            setClaimType('facility');
            setStep('upload');
          }
        } else {
          const { providers: list } = await claimApi.searchProviders('');
          const match = list.find((p) => p.id === initialTargetId);
          if (match) {
            setSelectedProvider(match);
            setClaimType('provider');
            setStep('upload');
          }
        }
      } catch {
        /* deep link target may not be in first page */
      }
    })();
  }, [initialTargetId, initialType, isAuthed]);

  async function sendOtp(e: FormEvent, usePhone = false) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await fetch('/v1/auth/otp/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          context: 'mobile',
          email: usePhone ? undefined : email.trim(),
          phone: usePhone ? phone.trim() || undefined : undefined,
          channel: usePhone ? 'phone' : 'email',
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err?.error?.message ?? 'Failed to send verification code');
      }
      const data = await res.json();
      setOtpChannel(data.channel === 'sms' ? 'phone' : 'email');
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
          context: 'mobile',
          email: otpChannel === 'email' ? email.trim() : undefined,
          phone: otpChannel === 'phone' ? phone.trim() : undefined,
          otp,
          channel: otpChannel,
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
      setIsAuthed(true);
      setPhoneVerified(true);
      setStep('verify');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  }

  async function loadListings() {
    setLoading(true);
    setError('');
    try {
      if (claimType === 'facility') {
        const { facilities: list } = await claimApi.searchFacilities(searchQ || undefined);
        setFacilities(list);
      } else {
        const { providers: list } = await claimApi.searchProviders(searchQ || undefined);
        setProviders(list);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Search failed');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (step !== 'select') return;
    void loadListings();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [step, claimType]);

  async function createDraftClaim() {
    setLoading(true);
    setError('');
    try {
      const evidence = evidenceFromFiles(files);
      if (claimType === 'facility' && selectedFacility) {
        const { claim } = await claimApi.createFacilityClaim({
          facilityId: selectedFacility.id,
          businessRegistrationNumber: regNumber || undefined,
          notes: notes || undefined,
          evidence,
        });
        setActiveClaim(claim);
      } else if (claimType === 'provider' && selectedProvider) {
        const { claim } = await claimApi.createProviderClaim({
          providerId: selectedProvider.id,
          mdpczNumber: mdpczNumber || undefined,
          notes: notes || undefined,
          evidence,
        });
        setActiveClaim(claim);
      } else {
        throw new Error('Select a listing to claim');
      }
      setStep('submit');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not create claim');
    } finally {
      setLoading(false);
    }
  }

  async function submitClaim() {
    if (!activeClaim) return;
    setLoading(true);
    setError('');
    try {
      const evidence = evidenceFromFiles(files);
      if (activeClaim.type === 'facility') {
        await claimApi.updateFacilityClaim(activeClaim.id, {
          businessRegistrationNumber: regNumber || undefined,
          notes: notes || undefined,
          evidence,
        });
        const { claim } = await claimApi.submitFacilityClaim(activeClaim.id);
        setActiveClaim(claim);
      } else {
        const { claim } = await claimApi.submitProviderClaim(activeClaim.id);
        setActiveClaim(claim);
      }
      setStep('pending');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Submit failed');
    } finally {
      setLoading(false);
    }
  }

  const selectedName = useMemo(() => {
    if (claimType === 'facility') return selectedFacility?.name;
    return selectedProvider?.name;
  }, [claimType, selectedFacility, selectedProvider]);

  return (
    <div className="mx-auto min-h-screen max-w-2xl p-4 pb-16">
      <header className="mb-6">
        <Link href="/login" className="text-sm text-teal-600 hover:underline">
          ← Facility portal login
        </Link>
        <h1 className="mt-3 text-2xl font-bold text-teal-600">Claim your listing</h1>
        <p className="mt-1 text-sm text-[var(--muted)]">
          Verify ownership to manage hours, providers, appointments, and queue settings.
        </p>
        <div className="mt-4">
          <ClaimStepper current={step} />
        </div>
      </header>

      {error && (
        <p className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">
          {error}
        </p>
      )}

      {step === 'account' && (
        <form
          onSubmit={otpStep === 'email' ? (e) => void sendOtp(e, false) : verifyOtp}
          className="card space-y-4"
        >
          <h2 className="text-lg font-semibold">1. Create account</h2>
          <p className="text-sm text-[var(--muted)]">
            Sign in with your email to start a claim. We will send a verification code to your inbox.
          </p>
          <label className="block text-sm font-medium">Email</label>
          <input
            className="input"
            type="email"
            value={email}
            onChange={(e) => {
              setEmail(e.target.value);
              setOtpStep('email');
            }}
            placeholder="you@example.com"
            required
            disabled={otpStep === 'otp'}
          />
          {otpStep === 'otp' && (
            <>
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
            </>
          )}
          <button type="submit" className="btn-primary w-full justify-center" disabled={loading}>
            {loading ? 'Please wait…' : otpStep === 'email' ? 'Send code' : 'Verify & continue'}
          </button>
          {otpStep === 'email' ? (
            <>
              <label className="block text-sm font-medium">Phone (fallback if already registered)</label>
              <input
                className="input"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="0771234567"
              />
              <button
                type="button"
                className="w-full text-sm text-teal-600"
                disabled={loading || !phone.trim()}
                onClick={(e) => void sendOtp(e, true)}
              >
                Send code to phone instead
              </button>
            </>
          ) : (
            <button type="button" className="w-full text-sm text-teal-600" onClick={() => setOtpStep('email')}>
              Use a different email
            </button>
          )}
        </form>
      )}

      {step === 'verify' && (
        <div className="card space-y-4">
          <h2 className="text-lg font-semibold">2. Verify contact details</h2>
          <p className="text-sm text-[var(--muted)]">
            Confirm how we can reach you about this claim.
          </p>
          <label className="flex items-center gap-3 rounded-lg border border-[var(--border)] p-3">
            <input
              type="checkbox"
              checked={phoneVerified}
              onChange={(e) => setPhoneVerified(e.target.checked)}
              disabled
            />
            <span className="text-sm">Phone verified via OTP</span>
          </label>
          <label className="flex items-center gap-3 rounded-lg border border-[var(--border)] p-3">
            <input
              type="checkbox"
              checked={emailVerified}
              onChange={(e) => setEmailVerified(e.target.checked)}
            />
            <span className="text-sm">I confirm my email on file is current</span>
          </label>
          <button
            type="button"
            className="btn-primary w-full justify-center"
            disabled={!phoneVerified}
            onClick={() => setStep('upload')}
          >
            Continue
          </button>
        </div>
      )}

      {step === 'upload' && (
        <div className="card space-y-4">
          <h2 className="text-lg font-semibold">3. Upload proof documents</h2>
          <p className="text-sm text-[var(--muted)]">
            Business registration, practice license, MDPCZ certificate, or authorization letter.
          </p>
          <FileUploadZone files={files} onChange={setFiles} />
          <button
            type="button"
            className="btn-primary w-full justify-center"
            disabled={files.length === 0}
            onClick={() => setStep('select')}
          >
            Continue
          </button>
        </div>
      )}

      {step === 'select' && (
        <div className="card space-y-4">
          <h2 className="text-lg font-semibold">4. Select listing</h2>
          <div className="flex gap-2">
            <button
              type="button"
              className={claimType === 'facility' ? 'btn-primary' : 'btn-secondary'}
              onClick={() => setClaimType('facility')}
            >
              <Building2 className="h-4 w-4" /> Facility
            </button>
            <button
              type="button"
              className={claimType === 'provider' ? 'btn-primary' : 'btn-secondary'}
              onClick={() => setClaimType('provider')}
            >
              <Stethoscope className="h-4 w-4" /> Practitioner
            </button>
          </div>
          <div className="flex gap-2">
            <input
              className="input flex-1"
              placeholder="Search by name or city…"
              value={searchQ}
              onChange={(e) => setSearchQ(e.target.value)}
            />
            <button type="button" className="btn-secondary" onClick={() => void loadListings()}>
              Search
            </button>
          </div>
          <ul className="max-h-64 space-y-2 overflow-y-auto">
            {claimType === 'facility'
              ? facilities.map((f) => (
                  <li key={f.id}>
                    <button
                      type="button"
                      className={`w-full rounded-lg border p-3 text-left text-sm ${
                        selectedFacility?.id === f.id
                          ? 'border-teal-500 bg-teal-50 dark:bg-teal-950/40'
                          : 'border-[var(--border)]'
                      }`}
                      onClick={() => setSelectedFacility(f)}
                    >
                      <p className="font-medium">{f.name}</p>
                      <p className="text-xs text-[var(--muted)]">
                        {[f.city, f.province].filter(Boolean).join(', ') || 'Zimbabwe'}
                        {f.pendingClaims > 0 ? ` · ${f.pendingClaims} pending claim(s)` : ''}
                      </p>
                    </button>
                  </li>
                ))
              : providers.map((p) => (
                  <li key={p.id}>
                    <button
                      type="button"
                      className={`w-full rounded-lg border p-3 text-left text-sm ${
                        selectedProvider?.id === p.id
                          ? 'border-teal-500 bg-teal-50 dark:bg-teal-950/40'
                          : 'border-[var(--border)]'
                      }`}
                      onClick={() => setSelectedProvider(p)}
                    >
                      <p className="font-medium">{p.name}</p>
                      <p className="text-xs text-[var(--muted)]">
                        {p.specialty ?? 'Provider'} · {p.facilityName}
                      </p>
                    </button>
                  </li>
                ))}
          </ul>
          {claimType === 'facility' && (
            <label className="block text-sm">
              Business registration number
              <input
                className="input mt-1"
                value={regNumber}
                onChange={(e) => setRegNumber(e.target.value)}
                placeholder="Optional"
              />
            </label>
          )}
          {claimType === 'provider' && (
            <label className="block text-sm">
              MDPCZ number
              <input
                className="input mt-1"
                value={mdpczNumber}
                onChange={(e) => setMdpczNumber(e.target.value)}
                placeholder="Optional"
              />
            </label>
          )}
          <label className="block text-sm">
            Notes for reviewers
            <textarea
              className="input mt-1 min-h-[80px]"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Optional context for the SmartHealth team"
            />
          </label>
          <button
            type="button"
            className="btn-primary w-full justify-center"
            disabled={loading || (!selectedFacility && !selectedProvider)}
            onClick={() => void createDraftClaim()}
          >
            {loading ? 'Saving…' : 'Continue to review'}
          </button>
        </div>
      )}

      {step === 'submit' && (
        <div className="card space-y-4">
          <h2 className="text-lg font-semibold">5. Submit claim</h2>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between gap-4">
              <dt className="text-[var(--muted)]">Listing</dt>
              <dd className="font-medium text-right">{selectedName ?? activeClaim?.facilityName}</dd>
            </div>
            <div className="flex justify-between gap-4">
              <dt className="text-[var(--muted)]">Type</dt>
              <dd className="capitalize">{claimType}</dd>
            </div>
            <div className="flex justify-between gap-4">
              <dt className="text-[var(--muted)]">Documents</dt>
              <dd>{files.length} file(s)</dd>
            </div>
            <div className="flex justify-between gap-4">
              <dt className="text-[var(--muted)]">Status</dt>
              <dd>
                <span className="badge badge-yellow">{statusLabel(activeClaim?.status ?? 'draft')}</span>
              </dd>
            </div>
          </dl>
          <button
            type="button"
            className="btn-primary w-full justify-center"
            disabled={loading}
            onClick={() => void submitClaim()}
          >
            {loading ? 'Submitting…' : 'Submit for review'}
          </button>
        </div>
      )}

      {step === 'pending' && (
        <div className="card space-y-4 text-center">
          <h2 className="text-lg font-semibold">6. Pending review</h2>
          <p className="text-sm text-[var(--muted)]">
            Your claim for <strong>{selectedName ?? activeClaim?.facilityName}</strong> is under
            review. We typically respond within 2–3 business days.
          </p>
          <span className="badge badge-yellow inline-flex">Claim Pending</span>
          <p className="text-xs text-[var(--muted)]">
            You will receive a notification when your claim is approved or if we need more
            information.
          </p>
        </div>
      )}

      {step === 'approved' && (
        <div className="card space-y-5">
          <div className="text-center">
            <h2 className="text-lg font-semibold text-teal-600">7. Claim approved</h2>
            <p className="mt-2 text-sm text-[var(--muted)]">
              You now own this listing. Complete facility onboarding to go live for patients.
            </p>
            <span className="badge badge-green mt-3 inline-flex">
              {claimType === 'facility' ? 'Verified Facility' : 'Verified Practitioner'}
            </span>
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
