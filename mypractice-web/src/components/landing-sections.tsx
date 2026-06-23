import {
  BarChart3,
  Building2,
  Calendar,
  FileText,
  Mic,
  Shield,
  Smartphone,
  Stethoscope,
  UserCircle,
  Users,
} from 'lucide-react';
import { portalClaimUrl, portalLoginUrl } from '@/lib/site';

const badges = ['Verified providers', 'Secure by design', 'Zimbabwe & Africa'];

const stats = [
  { label: '24 appointments', sub: 'Today' },
  { label: '+38% visibility', sub: 'This month' },
];

const pills = ['MBChB Verified', 'HPCZ Aligned', 'MyHealth Connected', 'Multi-Facility', 'Voice Notes', 'Real-time Sync'];

export function HeroSection() {
  return (
    <section className="relative overflow-hidden border-b border-slate-200/80 bg-gradient-to-b from-teal-50/80 to-white">
      <div className="section-pad grid items-center gap-12 lg:grid-cols-2">
        <div>
          <p className="section-label">Powered by SmartHealth Africa</p>
          <h1 className="mt-3 text-4xl font-bold tracking-tight text-slate-900 sm:text-5xl lg:text-[3.25rem] lg:leading-tight">
            Your Entire Practice{' '}
            <span className="text-teal-600">In Your Pocket</span>
          </h1>
          <p className="mt-5 text-lg text-slate-600">
            Manage appointments, patients, availability, consultations, performance and
            professional visibility from anywhere with MyPractice.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <a href={portalLoginUrl} className="btn-primary">
              Join MyPractice
            </a>
            <a href={portalClaimUrl} className="btn-secondary">
              Claim your facility
            </a>
          </div>
          <div className="mt-6 flex flex-wrap gap-3 text-sm text-slate-500">
            {badges.map((b) => (
              <span key={b} className="rounded-full border border-slate-200 bg-white px-3 py-1">
                {b}
              </span>
            ))}
          </div>
        </div>

        <div className="relative">
          <div className="card mx-auto max-w-md space-y-4 p-6 shadow-lg shadow-teal-900/5">
            <div className="grid grid-cols-2 gap-3">
              {stats.map((s) => (
                <div key={s.label} className="rounded-xl bg-slate-50 p-4">
                  <div className="text-2xl font-bold text-slate-900">{s.label.split(' ')[0]}</div>
                  <div className="text-xs font-medium text-slate-500">{s.label.split(' ').slice(1).join(' ')}</div>
                  <div className="mt-1 text-xs text-teal-600">{s.sub}</div>
                </div>
              ))}
            </div>
            <div className="flex flex-wrap gap-2">
              {pills.map((p) => (
                <span
                  key={p}
                  className="rounded-lg bg-teal-50 px-2.5 py-1 text-xs font-medium text-teal-800"
                >
                  {p}
                </span>
              ))}
            </div>
            <div className="rounded-xl border border-dashed border-teal-200 bg-teal-50/50 p-4 text-center text-sm text-teal-800">
              Mobile dashboard preview — appointments, queue &amp; patients at a glance
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

const whyFeatures = [
  { icon: Calendar, title: 'Manage Your Schedule', desc: 'Control your availability and appointments in real time.' },
  { icon: BarChart3, title: 'Grow Your Practice', desc: 'Increase visibility and help patients find your services.' },
  { icon: Users, title: 'Manage Patients', desc: 'Access patient encounters, notes and consultation history.' },
  { icon: Smartphone, title: 'Practice Anywhere', desc: 'Stay connected to your practice from your phone.' },
  { icon: FileText, title: 'Clinical Documentation', desc: 'Record consultations quickly and efficiently.' },
  { icon: UserCircle, title: 'Provider Profile', desc: 'Create a professional healthcare profile patients can discover.' },
  { icon: Building2, title: 'Facility Management', desc: 'Claim and manage healthcare facility listings.' },
  { icon: Stethoscope, title: 'Analytics & Performance', desc: 'Track appointments, patient volume and practice performance.' },
];

export function FeaturesSection() {
  return (
  <section id="features" className="section-pad">
    <p className="section-label text-center">Why practitioners love MyPractice</p>
    <h2 className="section-title text-center">Built around the way you actually work</h2>
    <p className="section-desc mx-auto text-center">
      Eight focused tools that give back your time and grow your patient base.
    </p>
    <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
      {whyFeatures.map(({ icon: Icon, title, desc }) => (
        <div key={title} className="card hover:border-teal-200 hover:shadow-md transition">
          <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-xl bg-teal-100 text-teal-700">
            <Icon size={20} />
          </div>
          <h3 className="font-semibold text-slate-900">{title}</h3>
          <p className="mt-2 text-sm text-slate-600">{desc}</p>
        </div>
      ))}
    </div>
  </section>
  );
}

const essentials = [
  'Professional Profile — qualifications, registration, specialties, experience, languages and locations.',
  'Availability Management — update availability instantly. Patients only see open slots.',
  'Appointment Management — upcoming, completed, cancellations, rescheduling — all in one view.',
  'Patient Encounters — consultation notes, diagnoses, treatment plans, follow-ups.',
  'Multi-Facility Support — work across multiple facilities and locations seamlessly.',
  'Mobile Dashboard — monitor activity and performance wherever you are.',
];

export function EssentialsSection() {
  return (
    <section className="border-y border-slate-200/80 bg-white">
      <div className="section-pad grid gap-12 lg:grid-cols-2 lg:items-center">
        <div>
          <p className="section-label">For modern healthcare professionals</p>
          <h2 className="section-title">Everything you need to manage your practice</h2>
        </div>
        <ul className="space-y-4">
          {essentials.map((item) => (
            <li key={item} className="flex gap-3 text-slate-700">
              <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-teal-500" />
              <span>{item}</span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}

export function GrowthSection() {
  const points = [
    'Increased visibility',
    'Better patient access',
    'Improved appointment bookings',
    'Stronger professional presence',
    'Digital healthcare profile',
  ];
  return (
    <section className="section-pad">
      <div className="grid gap-10 lg:grid-cols-2 lg:items-center">
        <div>
          <p className="section-label">Practice growth &amp; visibility</p>
          <h2 className="section-title">Get found by more patients</h2>
          <p className="section-desc">
            MyPractice helps patients discover healthcare professionals based on specialty,
            location, availability and services offered.
          </p>
          <ul className="mt-6 space-y-2">
            {points.map((p) => (
              <li key={p} className="flex items-center gap-2 text-slate-700">
                <span className="text-teal-600">✓</span> {p}
              </li>
            ))}
          </ul>
          <a href={portalLoginUrl} className="btn-primary mt-8">
            Create your profile
          </a>
        </div>
        <div className="card bg-gradient-to-br from-teal-600 to-teal-800 p-8 text-white">
          <p className="text-sm font-medium text-teal-100">Featured</p>
          <h3 className="mt-2 text-2xl font-bold">Discoverable across the MyHealth patient app</h3>
          <p className="mt-3 text-teal-50">
            Patients search by specialty, location and availability — your profile puts you in
            front of the right people at the right time.
          </p>
        </div>
      </div>
    </section>
  );
}

export function TrustSection() {
  const items = [
    'Professional registration',
    'Specialty credentials',
    'Facility affiliations',
    'Profile completion',
    'Verification status',
  ];
  return (
    <section className="border-y border-slate-200/80 bg-slate-50">
      <div className="section-pad grid gap-10 lg:grid-cols-2 lg:items-center">
        <div>
          <p className="section-label">Trust &amp; verification</p>
          <h2 className="section-title">Verified healthcare professionals</h2>
          <p className="section-desc">
            MyPractice supports professional verification to help build patient trust and
            confidence.
          </p>
          <ul className="mt-6 space-y-2">
            {items.map((i) => (
              <li key={i} className="flex items-center gap-2 text-slate-700">
                <Shield size={16} className="text-teal-600" /> {i}
              </li>
            ))}
          </ul>
        </div>
        <div className="card flex items-center gap-4 border-teal-200 bg-teal-50/50">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-teal-600 text-white">
            <Shield size={28} />
          </div>
          <div>
            <div className="font-bold text-slate-900">SmartHealth Verified</div>
            <div className="text-sm text-slate-600">Trust badge for your profile</div>
          </div>
        </div>
      </div>
    </section>
  );
}

const productivity = [
  { icon: Mic, title: 'Voice Consultation Notes', desc: 'Capture notes quickly using voice dictation.' },
  { icon: FileText, title: 'Smart Coding Assistance', desc: 'Support for modern clinical coding workflows.' },
  { icon: Users, title: 'Digital Records', desc: 'Maintain structured patient encounter records.' },
  { icon: Calendar, title: 'Follow-Up Tracking', desc: 'Track patient care plans and follow-up appointments.' },
  { icon: Shield, title: 'Secure Access', desc: 'Protected healthcare data access.' },
  { icon: Smartphone, title: 'Mobile Notifications', desc: 'Alerts for appointments and schedule changes.' },
];

export function ProductivitySection() {
  return (
    <section className="section-pad">
      <p className="section-label text-center">Clinical productivity</p>
      <h2 className="section-title text-center">Less admin. More patient care.</h2>
      <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {productivity.map(({ icon: Icon, title, desc }) => (
          <div key={title} className="card">
            <Icon className="text-teal-600" size={22} />
            <h3 className="mt-3 font-semibold text-slate-900">{title}</h3>
            <p className="mt-2 text-sm text-slate-600">{desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

export function PrivacySection() {
  const items = [
    { title: 'Secure by Design', desc: 'Security is incorporated throughout the platform.' },
    { title: 'Practitioner Control', desc: 'Healthcare professionals control profiles and availability.' },
    { title: 'Patient Privacy', desc: 'Respect for patient confidentiality is central to design.' },
    { title: 'Transparent Practices', desc: 'Clear and transparent handling of information.' },
    { title: 'Modern Standards', desc: 'Encryption and secure authentication.' },
  ];
  return (
    <section className="border-y border-slate-200/80 bg-white">
      <div className="section-pad">
        <p className="section-label text-center">Privacy &amp; professional responsibility</p>
        <h2 className="section-title text-center">
          Built with privacy and professional standards in mind
        </h2>
        <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((item) => (
            <div key={item.title} className="card">
              <h3 className="font-semibold text-slate-900">{item.title}</h3>
              <p className="mt-2 text-sm text-slate-600">{item.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

const professions = [
  'Doctors', 'Specialists', 'Dentists', 'Physiotherapists', 'Occupational Therapists',
  'Psychologists', 'Pharmacists', 'Nurses', 'Midwives', 'Optometrists', 'Nutritionists',
  'Allied Health', 'Administrators',
];

export function WhoSection() {
  return (
    <section className="section-pad">
      <p className="section-label text-center">Who it&apos;s for</p>
      <h2 className="section-title text-center">Healthcare professionals we support</h2>
      <div className="mt-10 flex flex-wrap justify-center gap-2">
        {professions.map((p) => (
          <span
            key={p}
            className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700"
          >
            {p}
          </span>
        ))}
      </div>
    </section>
  );
}

export function AfricaSection() {
  return (
    <section className="border-y border-slate-200/80 bg-teal-900 text-white">
      <div className="section-pad text-center">
        <p className="text-sm font-semibold uppercase tracking-wider text-teal-300">
          Designed for Africa
        </p>
        <h2 className="mt-2 text-3xl font-bold sm:text-4xl">
          Built for healthcare professionals in Zimbabwe and Africa
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-lg text-teal-100">
          MyPractice helps healthcare professionals in Harare, Bulawayo and across Southern
          Africa modernize practice management while improving patient accessibility and
          healthcare delivery.
        </p>
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <a href={portalLoginUrl} className="rounded-xl bg-white px-5 py-2.5 text-sm font-semibold text-teal-900 hover:bg-teal-50">
            Join MyPractice
          </a>
          <a href={portalClaimUrl} className="rounded-xl border border-teal-400 px-5 py-2.5 text-sm font-semibold text-white hover:bg-teal-800">
            Claim your facility
          </a>
        </div>
      </div>
    </section>
  );
}

const steps = [
  { n: '01', title: 'Download MyPractice', desc: 'Available on Google Play and the App Store.' },
  { n: '02', title: 'Create your profile', desc: 'Add qualifications, specialties and locations.' },
  { n: '03', title: 'Verify credentials', desc: 'Submit your registration for verification.' },
  { n: '04', title: 'Manage & grow', desc: 'Run your schedule and expand patient reach.' },
];

export function HowItWorksSection() {
  return (
    <section id="how-it-works" className="section-pad">
      <p className="section-label text-center">How it works</p>
      <h2 className="section-title text-center">
        From download to thriving practice in 4 steps
      </h2>
      <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {steps.map((s) => (
          <div key={s.n} className="card relative pt-10">
            <span className="absolute left-6 top-6 text-3xl font-bold text-teal-100">{s.n}</span>
            <h3 className="font-semibold text-slate-900">{s.title}</h3>
            <p className="mt-2 text-sm text-slate-600">{s.desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

const testimonials = [
  { quote: 'MyPractice simplified appointment management and improved patient engagement.', who: 'General Practitioner', where: 'Harare' },
  { quote: 'The mobile dashboard helps me stay connected to my practice wherever I am.', who: 'Specialist Physician', where: 'Bulawayo' },
  { quote: 'Our providers now manage schedules more efficiently than ever before.', who: 'Clinic Owner', where: 'Avondale' },
];

export function TestimonialsSection() {
  return (
    <section className="border-y border-slate-200/80 bg-slate-50">
      <div className="section-pad">
        <p className="section-label text-center">Loved by practitioners</p>
        <h2 className="section-title text-center">What healthcare professionals are saying</h2>
        <div className="mt-12 grid gap-6 lg:grid-cols-3">
          {testimonials.map((t) => (
            <blockquote key={t.who} className="card">
              <p className="text-slate-700">&ldquo;{t.quote}&rdquo;</p>
              <footer className="mt-4 text-sm font-medium text-slate-900">{t.who}</footer>
              <div className="text-xs text-slate-500">{t.where}</div>
            </blockquote>
          ))}
        </div>
      </div>
    </section>
  );
}

export function EcosystemSection() {
  const apps = [
    { name: 'MyHealth', role: 'Patient App' },
    { name: 'MyPractice', role: 'Provider App' },
    { name: 'SmartHealth', role: 'Facility Platform' },
  ];
  const benefits = [
    'Better patient access',
    'Improved provider visibility',
    'Connected healthcare experiences',
    'Modern healthcare delivery',
  ];
  return (
    <section id="ecosystem" className="section-pad">
      <p className="section-label text-center">Part of something bigger</p>
      <h2 className="section-title text-center">One ecosystem. Connected healthcare.</h2>
      <p className="section-desc mx-auto text-center">
        MyPractice works hand-in-hand with the rest of the SmartHealth ecosystem.
      </p>
      <div className="mt-10 grid gap-4 sm:grid-cols-3">
        {apps.map((a) => (
          <div key={a.name} className="card text-center">
            <div className="text-lg font-bold text-slate-900">{a.name}</div>
            <div className="text-sm text-teal-600">{a.role}</div>
          </div>
        ))}
      </div>
      <ul className="mt-8 flex flex-wrap justify-center gap-4 text-sm text-slate-600">
        {benefits.map((b) => (
          <li key={b} className="flex items-center gap-2">
            <span className="text-teal-600">•</span> {b}
          </li>
        ))}
      </ul>
    </section>
  );
}

const faqs = [
  { q: 'Is MyPractice free?', a: 'Basic professional profiles are free. Advanced features may be available through participating SmartHealth facilities.' },
  { q: 'Who can register?', a: 'Licensed healthcare professionals and facility administrators across supported specialties.' },
  { q: 'Can I manage multiple facilities?', a: 'Yes — MyPractice supports multi-facility workflows from a single provider profile.' },
  { q: 'Is patient information secure?', a: 'Yes. The platform uses encryption, secure authentication and consent-gated data sharing.' },
  { q: 'Can I update my availability?', a: 'Update availability instantly from the app; patients only see open slots.' },
  { q: 'Can patients find me through MyPractice?', a: 'Yes — verified profiles are discoverable through the MyHealth patient app.' },
];

export function FaqSection() {
  return (
    <section id="faq" className="border-t border-slate-200/80 bg-white">
      <div className="section-pad">
        <p className="section-label text-center">FAQ</p>
        <h2 className="section-title text-center">Frequently asked questions</h2>
        <div className="mx-auto mt-12 max-w-3xl divide-y divide-slate-200">
          {faqs.map((f) => (
            <details key={f.q} className="group py-4">
              <summary className="cursor-pointer list-none font-semibold text-slate-900 marker:content-none">
                {f.q}
              </summary>
              <p className="mt-2 text-slate-600">{f.a}</p>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}

export function DownloadSection() {
  return (
    <section id="download" className="section-pad bg-gradient-to-b from-teal-50 to-white">
      <div className="mx-auto max-w-3xl text-center">
        <p className="section-label">Take it everywhere</p>
        <h2 className="section-title">Take your practice everywhere</h2>
        <p className="section-desc mx-auto">
          Join healthcare professionals using MyPractice to manage appointments, patients and
          professional growth.
        </p>
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <span className="btn-secondary cursor-default opacity-80">Download on the App Store</span>
          <span className="btn-secondary cursor-default opacity-80">Get it on Google Play</span>
        </div>
        <p className="mt-4 text-sm text-slate-500">Store links coming soon — join via the portal today.</p>
        <a href={portalLoginUrl} className="btn-primary mt-6 inline-flex">
          Get started on the web
        </a>
      </div>
    </section>
  );
}
