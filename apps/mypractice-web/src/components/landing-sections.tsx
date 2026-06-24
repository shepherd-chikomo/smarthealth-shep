import Link from 'next/link';
import {
  BarChart3,
  Brain,
  Building2,
  Calendar,
  Check,
  Code2,
  Eye,
  FileText,
  FolderHeart,
  Globe,
  Heart,
  Key,
  LineChart,
  ListChecks,
  Lock,
  MapPin,
  Mic,
  Pill,
  Scale,
  Shield,
  ShieldCheck,
  Smartphone,
  Stethoscope,
  TrendingUp,
  UserCheck,
  UserPlus,
  Users,
  Bell,
  Download,
  HeartPulse,
  ClipboardList,
} from 'lucide-react';
import { portalClaimUrl, portalLoginUrl } from '@/lib/site';
import { ArrowLink, FeatureIconCard, SectionBadge } from '@/components/ui';
import { HeroVisual } from '@/components/hero-visual';
import { MarketingImage } from '@/components/marketing-image';
import { StoreBadges } from '@/components/store-badges';

const certs = [
  'MBCHB VERIFIED',
  'HPCZ ALIGNED',
  'MYHEALTH CONNECTED',
  'MULTI-FACILITY',
  'VOICE NOTES',
  'REAL-TIME SYNC',
];

const whyFeatures = [
  { icon: Calendar, title: 'Manage Your Schedule', description: 'Control your availability and appointments in real time.' },
  { icon: TrendingUp, title: 'Grow Your Practice', description: 'Increase visibility and help patients find your services.' },
  { icon: FolderHeart, title: 'Manage Patients', description: 'Access patient encounters, notes and consultation history.' },
  { icon: Smartphone, title: 'Practice Anywhere', description: 'Stay connected to your practice from your phone.' },
  { icon: ClipboardList, title: 'Clinical Documentation', description: 'Record consultations quickly and efficiently.' },
  { icon: UserCheck, title: 'Provider Profile', description: 'Create a professional healthcare profile patients can discover.' },
  { icon: Building2, title: 'Facility Management', description: 'Claim and manage healthcare facility listings.' },
  { icon: BarChart3, title: 'Analytics & Performance', description: 'Track appointments, patient volume and practice performance.' },
];

export function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-blue-50 via-white to-cyan-50">
      <div className="section-pad grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
        <div>
          <div className="badge-pill mb-6">Powered by SmartHealth Africa</div>
          <h1 className="text-4xl font-bold leading-[1.1] tracking-tight text-slate-900 sm:text-5xl lg:text-[3.25rem]">
            Your Entire Practice{' '}
            <span className="text-[#2563eb]">In Your Pocket</span>
          </h1>
          <p className="mt-5 text-lg leading-relaxed text-slate-600">
            Manage appointments, patients, availability, consultations, performance and
            professional visibility from anywhere with MyPractice.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <ArrowLink href={portalLoginUrl}>Join MyPractice</ArrowLink>
            <a href={portalClaimUrl} className="btn-secondary">
              Claim your facility
            </a>
          </div>
          <div className="mt-6">
            <StoreBadges />
          </div>
          <div className="mt-8 flex flex-wrap gap-6 text-sm text-slate-600">
            <span className="flex items-center gap-2">
              <ShieldCheck size={16} className="text-emerald-500" /> Verified providers
            </span>
            <span className="flex items-center gap-2">
              <Lock size={16} className="text-[#2563eb]" /> Secure by design
            </span>
            <span className="flex items-center gap-2">
              <MapPin size={16} className="text-emerald-500" /> Zimbabwe &amp; Africa
            </span>
          </div>
        </div>

        <HeroVisual />
      </div>
    </section>
  );
}

export function CertBar() {
  return (
    <div className="border-y border-slate-100 bg-slate-50/80 py-4">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-center gap-x-6 gap-y-2 px-4 text-[11px] font-semibold tracking-wide text-slate-600 sm:gap-x-8 sm:text-xs">
        {certs.map((c) => (
          <span key={c} className="flex items-center gap-1.5">
            <Check size={14} className="text-emerald-500" />
            {c}
          </span>
        ))}
      </div>
    </div>
  );
}

export function FeaturesSection() {
  return (
    <section id="features" className="section-pad">
      <div className="text-center">
        <SectionBadge>Why practitioners love MyPractice</SectionBadge>
        <h2 className="section-title mt-4">Built around the way you actually work</h2>
        <p className="section-desc mx-auto">
          Eight focused tools that give back your time and grow your patient base.
        </p>
      </div>
      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {whyFeatures.map((f) => (
          <FeatureIconCard key={f.title} {...f} />
        ))}
      </div>
    </section>
  );
}

const essentials = [
  'Qualifications, registration, specialties, experience, languages and locations.',
  'Update availability instantly. Patients only see open slots.',
  'Upcoming, completed, cancellations, rescheduling — all in one view.',
  'Consultation notes, diagnoses, treatment plans, follow-ups.',
  'Work across multiple facilities and locations seamlessly.',
  'Monitor activity and performance wherever you are.',
];

const essentialTitles = [
  'Professional Profile',
  'Availability Management',
  'Appointment Management',
  'Patient Encounters',
  'Multi-Facility Support',
  'Mobile Dashboard',
];

export function EssentialsSection() {
  return (
    <section className="border-y border-slate-100 bg-white">
      <div className="section-pad">
        <div className="text-center">
          <SectionBadge>For modern healthcare professionals</SectionBadge>
          <h2 className="section-title mt-4">Everything you need to manage your practice</h2>
        </div>
        <div className="mt-12 grid items-center gap-12 lg:grid-cols-2">
          <div className="flex justify-center">
            <MarketingImage
              src="/images/phone-mockup.png"
              alt="MyPractice mobile dashboard showing appointments, patients and tasks"
              width={369}
              height={518}
              className="h-auto w-full max-w-sm"
            />
          </div>
          <div className="space-y-4">
            {essentialTitles.map((title, i) => (
              <div key={title} className="card flex gap-4 !p-4">
                <div className="icon-box-teal shrink-0 !h-9 !w-9">
                  <Check size={18} />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900">{title}</h3>
                  <p className="mt-1 text-sm text-slate-600">{essentials[i]}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
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
          <SectionBadge>Practice growth &amp; visibility</SectionBadge>
          <h2 className="section-title mt-4">Get found by more patients</h2>
          <p className="section-desc">
            MyPractice helps patients discover healthcare professionals based on specialty,
            location, availability and services offered.
          </p>
          <ul className="mt-6 space-y-3">
            {points.map((p) => (
              <li key={p} className="flex items-center gap-3 text-slate-700">
                <span className="flex h-6 w-6 items-center justify-center rounded-full bg-[#2563eb] text-white">
                  <Check size={14} />
                </span>
                {p}
              </li>
            ))}
          </ul>
          <div className="mt-8">
            <ArrowLink href={portalLoginUrl}>Create your profile</ArrowLink>
          </div>
        </div>
        <MarketingImage
          src="/images/growth-team.jpg"
          alt="Healthcare professionals discoverable across the MyHealth patient app"
          width={800}
          height={600}
          className="h-auto w-full rounded-3xl shadow-xl"
        />
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
    <section className="border-y border-slate-100 bg-slate-50">
      <div className="section-pad text-center">
        <SectionBadge>Trust &amp; verification</SectionBadge>
        <h2 className="section-title mt-4">Verified healthcare professionals</h2>
        <p className="section-desc mx-auto">
          MyPractice supports professional verification to help build patient trust and confidence.
        </p>
        <div className="mx-auto mt-10 flex max-w-4xl flex-wrap justify-center gap-3">
          {items.map((item) => (
            <div
              key={item}
              className="flex items-center gap-2 rounded-full border border-slate-200 bg-white px-5 py-2.5 text-sm font-medium text-slate-800 shadow-sm"
            >
              <Check size={16} className="text-[#2563eb]" />
              {item}
            </div>
          ))}
        </div>
        <div className="card mx-auto mt-10 flex max-w-md items-center gap-4 border-blue-100 bg-white p-6 shadow-md">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-[#2563eb] text-white">
            <Shield size={32} />
          </div>
          <div className="text-left">
            <p className="text-xs font-bold uppercase tracking-wider text-emerald-600">
              SmartHealth Verified
            </p>
            <p className="text-lg font-bold text-slate-900">Trust badge for your profile</p>
          </div>
        </div>
      </div>
    </section>
  );
}

const productivity = [
  { icon: Mic, title: 'Voice Consultation Notes', description: 'Capture notes quickly using voice dictation.' },
  { icon: Code2, title: 'Smart Coding Assistance', description: 'Support for modern clinical coding workflows.' },
  { icon: FileText, title: 'Digital Records', description: 'Maintain structured patient encounter records.' },
  { icon: ListChecks, title: 'Follow-Up Tracking', description: 'Track patient care plans and follow-up appointments.' },
  { icon: Shield, title: 'Secure Access', description: 'Protected healthcare data access.' },
  { icon: Bell, title: 'Mobile Notifications', description: 'Alerts for appointments and schedule changes.' },
];

export function ProductivitySection() {
  return (
    <section className="section-pad bg-gradient-to-b from-slate-50 to-white">
      <div className="text-center">
        <SectionBadge>Clinical productivity</SectionBadge>
        <h2 className="section-title mt-4">Less admin. More patient care.</h2>
      </div>
      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {productivity.map((f) => (
          <FeatureIconCard key={f.title} {...f} teal />
        ))}
      </div>
    </section>
  );
}

const privacyItems = [
  { icon: Shield, title: 'Secure by Design', desc: 'Security is incorporated throughout the platform.' },
  { icon: Key, title: 'Practitioner Control', desc: 'Healthcare professionals control profiles and availability.' },
  { icon: Eye, title: 'Patient Privacy', desc: 'Respect for patient confidentiality is central to design.' },
  { icon: Scale, title: 'Transparent Practices', desc: 'Clear and transparent handling of information.' },
  { icon: Lock, title: 'Modern Standards', desc: 'Encryption and secure authentication.' },
];

export function PrivacySection() {
  return (
    <section className="section-pad">
      <div className="text-center">
        <SectionBadge>Privacy &amp; professional responsibility</SectionBadge>
        <h2 className="section-title mt-4">
          Built with privacy and professional standards in mind
        </h2>
      </div>
      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-5">
        {privacyItems.map(({ icon: Icon, title, desc }) => (
          <div key={title} className="card text-center lg:text-left">
            <Icon size={22} className="mx-auto text-[#2563eb] lg:mx-0" />
            <h3 className="mt-3 font-bold text-slate-900">{title}</h3>
            <p className="mt-2 text-sm text-slate-600">{desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

const professions: { name: string; icon: typeof Stethoscope }[] = [
  { name: 'Doctors', icon: Stethoscope },
  { name: 'Specialists', icon: HeartPulse },
  { name: 'Dentists', icon: Heart },
  { name: 'Physiotherapists', icon: LineChart },
  { name: 'Occupational Therapists', icon: ListChecks },
  { name: 'Psychologists', icon: Brain },
  { name: 'Pharmacists', icon: Pill },
  { name: 'Nurses', icon: UserPlus },
  { name: 'Midwives', icon: Heart },
  { name: 'Optometrists', icon: Eye },
  { name: 'Nutritionists', icon: Heart },
  { name: 'Allied Health', icon: Users },
  { name: 'Administrators', icon: Building2 },
];

export function WhoSection() {
  return (
    <section className="border-t border-slate-100 bg-slate-50">
      <div className="section-pad">
        <div className="text-center">
          <SectionBadge>Who it&apos;s for</SectionBadge>
          <h2 className="section-title mt-4">Healthcare professionals we support</h2>
        </div>
        <div className="mt-10 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
          {professions.map(({ name, icon: Icon }) => (
            <div key={name} className="card flex items-center gap-3 !py-4">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-teal-50 text-[#0d9488]">
                <Icon size={18} />
              </div>
              <span className="text-sm font-semibold text-slate-800">{name}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function AfricaSection() {
  return (
    <section className="relative min-h-[320px] overflow-hidden sm:min-h-[380px]">
      <div className="absolute inset-0">
        <MarketingImage
          src="/images/africa-hero.jpg"
          alt="Healthcare professionals across Zimbabwe and Africa"
          className="object-cover"
        />
      </div>
      <div className="absolute inset-0 bg-gradient-to-r from-[#1e40af]/95 via-[#2563eb]/80 to-teal-600/50" />
      <div className="section-pad relative text-center text-white">
        <div className="badge-pill !border-white/20 !bg-white/10 !text-white">
          <Globe size={14} /> Designed for Africa
        </div>
        <h2 className="mt-6 text-3xl font-bold sm:text-4xl lg:text-5xl">
          Built for healthcare professionals in Zimbabwe and Africa
        </h2>
        <p className="mx-auto mt-5 max-w-2xl text-lg text-blue-100">
          MyPractice helps healthcare professionals in Harare, Bulawayo and across Southern Africa
          modernize practice management while improving patient accessibility and healthcare
          delivery.
        </p>
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <a
            href={portalLoginUrl}
            className="inline-flex items-center gap-2 rounded-full bg-white px-6 py-3 text-sm font-semibold text-[#1d4ed8] shadow-lg hover:bg-blue-50"
          >
            Join MyPractice <span>→</span>
          </a>
          <a
            href={portalClaimUrl}
            className="inline-flex items-center gap-2 rounded-full border-2 border-white/80 px-6 py-3 text-sm font-semibold text-white hover:bg-white/10"
          >
            Claim your facility
          </a>
        </div>
      </div>
    </section>
  );
}

const steps = [
  { n: '01', icon: Download, title: 'Download MyPractice', desc: 'Available on Google Play and the App Store.' },
  { n: '02', icon: UserPlus, title: 'Create your profile', desc: 'Add qualifications, specialties and locations.' },
  { n: '03', icon: ShieldCheck, title: 'Verify credentials', desc: 'Submit your registration for verification.' },
  { n: '04', icon: LineChart, title: 'Manage & grow', desc: 'Run your schedule and expand patient reach.' },
];

export function HowItWorksSection() {
  return (
    <section id="how-it-works" className="section-pad">
      <div className="text-center">
        <SectionBadge>How it works</SectionBadge>
        <h2 className="section-title mt-4">From download to thriving practice in 4 steps</h2>
      </div>
      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {steps.map((s) => (
          <div key={s.n} className="card relative overflow-hidden">
            <span className="absolute right-4 top-4 text-4xl font-bold text-slate-100">{s.n}</span>
            <div className="icon-box">
              <s.icon size={20} />
            </div>
            <h3 className="mt-4 font-bold text-slate-900">{s.title}</h3>
            <p className="mt-2 text-sm text-slate-600">{s.desc}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

const testimonials = [
  { quote: 'MyPractice simplified appointment management and improved patient engagement.', who: 'General Practitioner', where: 'Harare', initial: 'G' },
  { quote: 'The mobile dashboard helps me stay connected to my practice wherever I am.', who: 'Specialist Physician', where: 'Bulawayo', initial: 'S' },
  { quote: 'Our providers now manage schedules more efficiently than ever before.', who: 'Clinic Owner', where: 'Avondale', initial: 'C' },
];

export function TestimonialsSection() {
  return (
    <section className="border-y border-slate-100 bg-slate-50">
      <div className="section-pad">
        <div className="text-center">
          <SectionBadge>Loved by practitioners</SectionBadge>
          <h2 className="section-title mt-4">What healthcare professionals are saying</h2>
        </div>
        <div className="mt-12 grid gap-6 lg:grid-cols-3">
          {testimonials.map((t) => (
            <blockquote key={t.who} className="card">
              <span className="text-3xl font-serif text-[#2563eb]">&ldquo;</span>
              <p className="mt-2 text-slate-700">{t.quote}</p>
              <footer className="mt-6 flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[#2563eb] text-sm font-bold text-white">
                  {t.initial}
                </div>
                <div>
                  <div className="text-sm font-semibold text-slate-900">{t.who}</div>
                  <div className="text-xs text-slate-500">{t.where}</div>
                </div>
              </footer>
            </blockquote>
          ))}
        </div>
      </div>
    </section>
  );
}

export function EcosystemSection() {
  const apps = [
    { name: 'MyHealth', role: 'Patient App', icon: Heart, color: 'bg-teal-500' },
    { name: 'MyPractice', role: 'Provider App', icon: Stethoscope, color: 'bg-[#2563eb]' },
    { name: 'SmartHealth', role: 'Facility Platform', icon: Building2, color: 'bg-slate-800' },
  ];
  return (
    <section id="ecosystem" className="section-pad">
      <div className="text-center">
        <SectionBadge>Part of something bigger</SectionBadge>
        <h2 className="section-title mt-4">One ecosystem. Connected healthcare.</h2>
        <p className="section-desc mx-auto">
          MyPractice works hand-in-hand with the rest of the SmartHealth ecosystem.
        </p>
      </div>
      <div className="card mx-auto mt-10 max-w-4xl bg-gradient-to-br from-blue-50/80 to-white p-8">
        <div className="grid gap-6 lg:grid-cols-[1fr_1fr] lg:items-center">
          <div className="card flex items-center gap-4 !shadow-md">
            <div className="flex h-14 w-14 items-center justify-center rounded-full bg-teal-500 text-white">
              <Heart size={24} />
            </div>
            <div>
              <div className="font-bold text-slate-900">MyHealth</div>
              <div className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                Patient App
              </div>
            </div>
          </div>
          <div className="space-y-4">
            {apps.slice(1).map((a) => (
              <div key={a.name} className="card flex items-center gap-4 !shadow-md">
                <div className={`flex h-14 w-14 items-center justify-center rounded-full text-white ${a.color}`}>
                  <a.icon size={24} />
                </div>
                <div>
                  <div className="font-bold text-slate-900">{a.name}</div>
                  <div className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                    {a.role}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="mt-8 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {[
            'Better patient access',
            'Improved provider visibility',
            'Connected healthcare experiences',
            'Modern healthcare delivery',
          ].map((b) => (
            <div key={b} className="flex items-center gap-2 rounded-xl bg-white px-4 py-3 text-sm text-slate-700 shadow-sm">
              <Check size={16} className="shrink-0 text-emerald-500" />
              {b}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function DownloadSection() {
  return (
    <section id="download" className="section-pad bg-gradient-to-br from-blue-50 to-white">
      <div className="grid items-center gap-12 lg:grid-cols-2">
        <div>
          <SectionBadge>Take it everywhere</SectionBadge>
          <h2 className="section-title mt-4">Take your practice everywhere</h2>
          <p className="section-desc">
            Join healthcare professionals using MyPractice to manage appointments, patients and
            professional growth.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <StoreBadges />
          </div>
          <div className="mt-6">
            <ArrowLink href={portalLoginUrl}>Get started on the web</ArrowLink>
          </div>
        </div>
        <div className="flex justify-center">
          <MarketingImage
            src="/images/phone-mockup.png"
            alt="MyPractice app on mobile"
            width={369}
            height={518}
            className="h-auto w-full max-w-sm"
          />
        </div>
      </div>
    </section>
  );
}
