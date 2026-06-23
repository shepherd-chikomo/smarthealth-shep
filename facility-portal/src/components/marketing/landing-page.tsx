import Link from 'next/link';
import {
  Calendar,
  ChartLine,
  ClipboardList,
  Globe,
  HeartPulse,
  Mic,
  ShieldCheck,
  Smartphone,
  Stethoscope,
  Users,
  Building2,
  CheckCircle2,
} from 'lucide-react';
import { DEFAULT_PORTAL_URL } from '@/lib/site-hosts';

const portal = DEFAULT_PORTAL_URL;

const FEATURES = [
  {
    icon: Calendar,
    title: 'Manage Your Schedule',
    description: 'Control your availability and appointments in real time.',
  },
  {
    icon: ChartLine,
    title: 'Grow Your Practice',
    description: 'Increase visibility and help patients find your services.',
  },
  {
    icon: Users,
    title: 'Manage Patients',
    description: 'Access patient encounters, notes and consultation history.',
  },
  {
    icon: Smartphone,
    title: 'Practice Anywhere',
    description: 'Stay connected to your practice from your phone.',
  },
  {
    icon: ClipboardList,
    title: 'Clinical Documentation',
    description: 'Record consultations quickly and efficiently.',
  },
  {
    icon: Stethoscope,
    title: 'Provider Profile',
    description: 'Create a professional healthcare profile patients can discover.',
  },
  {
    icon: Building2,
    title: 'Facility Management',
    description: 'Claim and manage healthcare facility listings.',
  },
  {
    icon: ChartLine,
    title: 'Analytics & Performance',
    description: 'Track appointments, patient volume and practice performance.',
  },
] as const;

const SPECIALTIES = [
  'Doctors',
  'Specialists',
  'Dentists',
  'Physiotherapists',
  'Occupational Therapists',
  'Psychologists',
  'Pharmacists',
  'Nurses',
  'Midwives',
  'Optometrists',
  'Nutritionists',
  'Allied Health',
  'Administrators',
] as const;

const STEPS = [
  { n: '01', title: 'Download MyPractice', body: 'Available on Google Play and the App Store.' },
  {
    n: '02',
    title: 'Create your profile',
    body: 'Add qualifications, specialties and locations.',
  },
  {
    n: '03',
    title: 'Verify credentials',
    body: 'Submit your registration for verification.',
  },
  {
    n: '04',
    title: 'Manage & grow',
    body: 'Run your schedule and expand patient reach.',
  },
] as const;

const FAQ = [
  {
    q: 'Is MyPractice free?',
    a: 'Basic professional profiles are free. Advanced features may be available through participating SmartHealth facilities.',
  },
  {
    q: 'Who can register?',
    a: 'Licensed healthcare professionals and facility administrators across supported specialties.',
  },
  {
    q: 'Can I manage multiple facilities?',
    a: 'Yes — MyPractice supports multi-facility workflows for providers who work across sites.',
  },
  {
    q: 'Is patient information secure?',
    a: 'Yes. Security and patient privacy are built into the platform with encryption and access controls.',
  },
  {
    q: 'Can I update my availability?',
    a: 'Yes — update availability instantly so patients only see open slots.',
  },
  {
    q: 'Can patients find me through MyPractice?',
    a: 'Yes — patients can discover you via the MyHealth patient app based on specialty, location and availability.',
  },
] as const;

const TESTIMONIALS = [
  {
    quote:
      'MyPractice simplified appointment management and improved patient engagement.',
    role: 'General Practitioner',
    city: 'Harare',
    initial: 'G',
  },
  {
    quote: 'The mobile dashboard helps me stay connected to my practice wherever I am.',
    role: 'Specialist Physician',
    city: 'Bulawayo',
    initial: 'S',
  },
  {
    quote: 'Our providers now manage schedules more efficiently than ever before.',
    role: 'Clinic Owner',
    city: 'Avondale',
    initial: 'C',
  },
] as const;

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <a
      href={href}
      className="text-sm font-medium text-slate-600 transition-colors hover:text-teal-700"
    >
      {children}
    </a>
  );
}

function PrimaryButton({
  href,
  children,
  variant = 'solid',
}: {
  href: string;
  children: React.ReactNode;
  variant?: 'solid' | 'outline';
}) {
  const base =
    'inline-flex items-center justify-center rounded-xl px-5 py-2.5 text-sm font-semibold transition-colors';
  const styles =
    variant === 'solid'
      ? 'bg-teal-600 text-white hover:bg-teal-700 shadow-sm shadow-teal-600/20'
      : 'border border-slate-200 bg-white text-slate-800 hover:border-teal-300 hover:bg-teal-50';
  return (
    <Link href={href} className={`${base} ${styles}`}>
      {children}
    </Link>
  );
}

export function LandingPage() {
  return (
    <>
      <header className="sticky top-0 z-50 border-b border-slate-200/80 bg-white/90 backdrop-blur-md">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <Link href="/" className="flex items-center gap-2">
            <span className="text-lg font-bold text-teal-700">MyPractice</span>
            <span className="hidden text-xs text-slate-500 sm:inline">by SmartHealth</span>
          </Link>
          <nav className="hidden items-center gap-6 md:flex">
            <NavLink href="#features">Features</NavLink>
            <NavLink href="#how-it-works">How it works</NavLink>
            <NavLink href="#ecosystem">Ecosystem</NavLink>
            <NavLink href="#faq">FAQ</NavLink>
          </nav>
          <div className="flex items-center gap-2">
            <PrimaryButton href={`${portal}/login`} variant="outline">
              Join
            </PrimaryButton>
            <PrimaryButton href="#download">Download</PrimaryButton>
          </div>
        </div>
      </header>

      <main>
        {/* Hero */}
        <section className="relative overflow-hidden bg-gradient-to-b from-teal-50 via-white to-white">
          <div className="mx-auto grid max-w-6xl gap-10 px-4 py-16 sm:px-6 lg:grid-cols-2 lg:items-center lg:py-24">
            <div>
              <p className="mb-3 inline-flex rounded-full bg-teal-100 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-teal-800">
                Powered by SmartHealth Africa
              </p>
              <h1 className="text-4xl font-bold tracking-tight text-slate-900 sm:text-5xl lg:text-[3.25rem] lg:leading-tight">
                Your Entire Practice
                <span className="block text-teal-600">In Your Pocket</span>
              </h1>
              <p className="mt-5 max-w-xl text-lg text-slate-600">
                Manage appointments, patients, availability, consultations, performance and
                professional visibility from anywhere with MyPractice.
              </p>
              <div className="mt-8 flex flex-wrap gap-3">
                <PrimaryButton href={`${portal}/login`}>Join MyPractice</PrimaryButton>
                <PrimaryButton href={`${portal}/claim`} variant="outline">
                  Claim your facility
                </PrimaryButton>
              </div>
              <div className="mt-8 flex flex-wrap gap-4 text-xs font-medium text-slate-500">
                <span className="flex items-center gap-1.5">
                  <ShieldCheck className="h-4 w-4 text-teal-600" /> Verified providers
                </span>
                <span className="flex items-center gap-1.5">
                  <ShieldCheck className="h-4 w-4 text-teal-600" /> Secure by design
                </span>
                <span className="flex items-center gap-1.5">
                  <Globe className="h-4 w-4 text-teal-600" /> Zimbabwe &amp; Africa
                </span>
              </div>
            </div>
            <div className="relative">
              <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-xl shadow-slate-200/60">
                <div className="grid grid-cols-2 gap-4">
                  <StatCard label="Appointments today" value="24" />
                  <StatCard label="Visibility" value="+38%" sub="This month" />
                </div>
                <div className="mt-4 flex flex-wrap gap-2">
                  {['MBChB Verified', 'HPCZ Aligned', 'MyHealth Connected', 'Multi-Facility', 'Voice Notes', 'Real-time Sync'].map(
                    (tag) => (
                      <span
                        key={tag}
                        className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700"
                      >
                        {tag}
                      </span>
                    ),
                  )}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Features grid */}
        <section id="features" className="border-t border-slate-100 bg-slate-50 py-20">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <div className="mx-auto max-w-2xl text-center">
              <p className="text-sm font-semibold uppercase tracking-wide text-teal-600">
                Why practitioners love MyPractice
              </p>
              <h2 className="mt-2 text-3xl font-bold text-slate-900">
                Built around the way you actually work
              </h2>
              <p className="mt-3 text-slate-600">
                Eight focused tools that give back your time and grow your patient base.
              </p>
            </div>
            <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
              {FEATURES.map(({ icon: Icon, title, description }) => (
                <div
                  key={title}
                  className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition-shadow hover:shadow-md"
                >
                  <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-xl bg-teal-100 text-teal-700">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="font-semibold text-slate-900">{title}</h3>
                  <p className="mt-2 text-sm text-slate-600">{description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Practice management */}
        <section className="py-20">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <div className="grid gap-12 lg:grid-cols-2 lg:items-center">
              <div>
                <p className="text-sm font-semibold text-teal-600">For modern healthcare professionals</p>
                <h2 className="mt-2 text-3xl font-bold text-slate-900">
                  Everything you need to manage your practice
                </h2>
                <ul className="mt-8 space-y-4">
                  {[
                    ['Professional Profile', 'Qualifications, registration, specialties, experience, languages and locations.'],
                    ['Availability Management', 'Update availability instantly. Patients only see open slots.'],
                    ['Appointment Management', 'Upcoming, completed, cancellations, rescheduling — all in one view.'],
                    ['Patient Encounters', 'Consultation notes, diagnoses, treatment plans, follow-ups.'],
                    ['Multi-Facility Support', 'Work across multiple facilities and locations seamlessly.'],
                    ['Mobile Dashboard', 'Monitor activity and performance wherever you are.'],
                  ].map(([title, body]) => (
                    <li key={title} className="flex gap-3">
                      <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-teal-600" />
                      <div>
                        <p className="font-semibold text-slate-900">{title}</p>
                        <p className="text-sm text-slate-600">{body}</p>
                      </div>
                    </li>
                  ))}
                </ul>
              </div>
              <div className="rounded-3xl bg-gradient-to-br from-teal-600 to-teal-800 p-8 text-white shadow-xl">
                <h3 className="text-xl font-bold">Get found by more patients</h3>
                <p className="mt-3 text-teal-100">
                  MyPractice helps patients discover healthcare professionals based on specialty,
                  location, availability and services offered.
                </p>
                <ul className="mt-6 space-y-2 text-sm text-teal-50">
                  {[
                    'Increased visibility',
                    'Better patient access',
                    'Improved appointment bookings',
                    'Stronger professional presence',
                    'Digital healthcare profile',
                  ].map((item) => (
                    <li key={item} className="flex items-center gap-2">
                      <CheckCircle2 className="h-4 w-4" /> {item}
                    </li>
                  ))}
                </ul>
                <Link
                  href={`${portal}/login`}
                  className="mt-8 inline-flex rounded-xl bg-white px-5 py-2.5 text-sm font-semibold text-teal-800 hover:bg-teal-50"
                >
                  Create your profile
                </Link>
              </div>
            </div>
          </div>
        </section>

        {/* Trust & productivity */}
        <section className="border-y border-slate-100 bg-slate-50 py-20">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <div className="grid gap-12 lg:grid-cols-2">
              <div>
                <h2 className="text-2xl font-bold text-slate-900">Verified healthcare professionals</h2>
                <p className="mt-3 text-slate-600">
                  MyPractice supports professional verification to help build patient trust and confidence.
                </p>
                <ul className="mt-6 space-y-2 text-sm text-slate-700">
                  {[
                    'Professional registration',
                    'Specialty credentials',
                    'Facility affiliations',
                    'Profile completion',
                    'Verification status',
                  ].map((item) => (
                    <li key={item} className="flex items-center gap-2">
                      <ShieldCheck className="h-4 w-4 text-teal-600" /> {item}
                    </li>
                  ))}
                </ul>
              </div>
              <div>
                <h2 className="text-2xl font-bold text-slate-900">Less admin. More patient care.</h2>
                <div className="mt-6 grid gap-4 sm:grid-cols-2">
                  {[
                    { icon: Mic, title: 'Voice Consultation Notes', body: 'Capture notes quickly using voice dictation.' },
                    { icon: ClipboardList, title: 'Smart Coding Assistance', body: 'Support for modern clinical coding workflows.' },
                    { icon: HeartPulse, title: 'Digital Records', body: 'Maintain structured patient encounter records.' },
                    { icon: Calendar, title: 'Follow-Up Tracking', body: 'Track care plans and follow-up appointments.' },
                  ].map(({ icon: Icon, title, body }) => (
                    <div key={title} className="rounded-xl border border-slate-200 bg-white p-4">
                      <Icon className="mb-2 h-5 w-5 text-teal-600" />
                      <p className="font-semibold text-slate-900">{title}</p>
                      <p className="mt-1 text-xs text-slate-600">{body}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Who it's for */}
        <section className="py-20">
          <div className="mx-auto max-w-6xl px-4 text-center sm:px-6">
            <h2 className="text-3xl font-bold text-slate-900">Healthcare professionals we support</h2>
            <div className="mt-10 flex flex-wrap justify-center gap-3">
              {SPECIALTIES.map((s) => (
                <span
                  key={s}
                  className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700"
                >
                  {s}
                </span>
              ))}
            </div>
            <p className="mx-auto mt-12 max-w-2xl text-lg text-slate-600">
              Built for healthcare professionals in Harare, Bulawayo and across Southern Africa — modernizing
              practice management while improving patient accessibility.
            </p>
            <div className="mt-8 flex flex-wrap justify-center gap-3">
              <PrimaryButton href={`${portal}/login`}>Join MyPractice</PrimaryButton>
              <PrimaryButton href={`${portal}/claim`} variant="outline">
                Claim your facility
              </PrimaryButton>
            </div>
          </div>
        </section>

        {/* How it works */}
        <section id="how-it-works" className="border-t border-slate-100 bg-slate-50 py-20">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <h2 className="text-center text-3xl font-bold text-slate-900">
              From download to thriving practice in 4 steps
            </h2>
            <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
              {STEPS.map(({ n, title, body }) => (
                <div key={n} className="rounded-2xl border border-slate-200 bg-white p-6">
                  <span className="text-3xl font-bold text-teal-200">{n}</span>
                  <h3 className="mt-3 font-semibold text-slate-900">{title}</h3>
                  <p className="mt-2 text-sm text-slate-600">{body}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Testimonials */}
        <section className="py-20">
          <div className="mx-auto max-w-6xl px-4 sm:px-6">
            <h2 className="text-center text-3xl font-bold text-slate-900">
              What healthcare professionals are saying
            </h2>
            <div className="mt-12 grid gap-6 md:grid-cols-3">
              {TESTIMONIALS.map(({ quote, role, city, initial }) => (
                <blockquote
                  key={role + city}
                  className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"
                >
                  <p className="text-slate-700">&ldquo;{quote}&rdquo;</p>
                  <footer className="mt-4 flex items-center gap-3">
                    <span className="flex h-10 w-10 items-center justify-center rounded-full bg-teal-100 font-bold text-teal-700">
                      {initial}
                    </span>
                    <div>
                      <p className="text-sm font-semibold text-slate-900">{role}</p>
                      <p className="text-xs text-slate-500">{city}</p>
                    </div>
                  </footer>
                </blockquote>
              ))}
            </div>
          </div>
        </section>

        {/* Ecosystem */}
        <section id="ecosystem" className="border-y border-slate-100 bg-gradient-to-b from-teal-50 to-white py-20">
          <div className="mx-auto max-w-6xl px-4 text-center sm:px-6">
            <h2 className="text-3xl font-bold text-slate-900">One ecosystem. Connected healthcare.</h2>
            <p className="mx-auto mt-3 max-w-2xl text-slate-600">
              MyPractice works hand-in-hand with the rest of the SmartHealth ecosystem.
            </p>
            <div className="mt-10 grid gap-4 sm:grid-cols-3">
              {[
                { name: 'MyHealth', sub: 'Patient App' },
                { name: 'MyPractice', sub: 'Provider App', active: true },
                { name: 'SmartHealth', sub: 'Facility Platform' },
              ].map(({ name, sub, active }) => (
                <div
                  key={name}
                  className={`rounded-2xl border p-6 ${
                    active
                      ? 'border-teal-300 bg-white shadow-md'
                      : 'border-slate-200 bg-white/80'
                  }`}
                >
                  <p className="text-lg font-bold text-slate-900">{name}</p>
                  <p className="text-sm text-slate-500">{sub}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* FAQ */}
        <section id="faq" className="py-20">
          <div className="mx-auto max-w-3xl px-4 sm:px-6">
            <h2 className="text-center text-3xl font-bold text-slate-900">Frequently asked questions</h2>
            <dl className="mt-10 space-y-6">
              {FAQ.map(({ q, a }) => (
                <div key={q} className="rounded-xl border border-slate-200 bg-white p-5">
                  <dt className="font-semibold text-slate-900">{q}</dt>
                  <dd className="mt-2 text-sm text-slate-600">{a}</dd>
                </div>
              ))}
            </dl>
          </div>
        </section>

        {/* Download CTA */}
        <section id="download" className="bg-slate-900 py-20 text-white">
          <div className="mx-auto max-w-6xl px-4 text-center sm:px-6">
            <h2 className="text-3xl font-bold">Take your practice everywhere</h2>
            <p className="mx-auto mt-4 max-w-xl text-slate-300">
              Join healthcare professionals using MyPractice to manage appointments, patients and
              professional growth.
            </p>
            <div className="mt-8 flex flex-wrap justify-center gap-4">
              <a
                href="#"
                className="inline-flex rounded-xl bg-white px-6 py-3 text-sm font-semibold text-slate-900 hover:bg-slate-100"
              >
                Download on the App Store
              </a>
              <a
                href="#"
                className="inline-flex rounded-xl border border-slate-600 px-6 py-3 text-sm font-semibold text-white hover:bg-slate-800"
              >
                Get it on Google Play
              </a>
            </div>
          </div>
        </section>
      </main>

      <footer className="border-t border-slate-200 bg-white py-12">
        <div className="mx-auto grid max-w-6xl gap-8 px-4 sm:grid-cols-2 lg:grid-cols-4 sm:px-6">
          <div>
            <p className="text-lg font-bold text-teal-700">MyPractice</p>
            <p className="text-xs text-slate-500">by SmartHealth</p>
            <p className="mt-3 text-sm text-slate-600">
              Your practice. Anywhere. Anytime. The practitioner companion for healthcare
              professionals across Zimbabwe and Africa.
            </p>
          </div>
          <div>
            <p className="font-semibold text-slate-900">Product</p>
            <ul className="mt-3 space-y-2 text-sm text-slate-600">
              <li><a href="#features" className="hover:text-teal-700">About MyPractice</a></li>
              <li><Link href={portal} className="hover:text-teal-700">SmartHealth Platform</Link></li>
              <li><a href="#download" className="hover:text-teal-700">Download</a></li>
              <li><a href="#faq" className="hover:text-teal-700">FAQ</a></li>
            </ul>
          </div>
          <div>
            <p className="font-semibold text-slate-900">Legal</p>
            <ul className="mt-3 space-y-2 text-sm text-slate-600">
              <li><a href="#" className="hover:text-teal-700">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-teal-700">Terms of Service</a></li>
              <li><a href="mailto:hello@smarthealth.africa" className="hover:text-teal-700">Contact Us</a></li>
            </ul>
          </div>
          <div>
            <p className="font-semibold text-slate-900">Contact</p>
            <ul className="mt-3 space-y-2 text-sm text-slate-600">
              <li>Harare, Zimbabwe</li>
              <li>
                <a href="mailto:hello@smarthealth.africa" className="hover:text-teal-700">
                  hello@smarthealth.africa
                </a>
              </li>
            </ul>
          </div>
        </div>
        <p className="mt-10 text-center text-xs text-slate-500">
          © {new Date().getFullYear()} SmartHealth Africa. All rights reserved. ·{' '}
          <a href="https://smarthealth.africa" className="hover:text-teal-700">
            SmartHealth.africa
          </a>
        </p>
      </footer>
    </>
  );
}

function StatCard({
  label,
  value,
  sub,
}: {
  label: string;
  value: string;
  sub?: string;
}) {
  return (
    <div className="rounded-2xl bg-slate-50 p-4">
      <p className="text-2xl font-bold text-teal-700">{value}</p>
      {sub && <p className="text-xs text-emerald-600">{sub}</p>}
      <p className="mt-1 text-xs text-slate-500">{label}</p>
    </div>
  );
}
