import Image from 'next/image';
import {
  Ambulance,
  Building2,
  Calendar,
  Check,
  Cloud,
  Download,
  Eye,
  FileText,
  FlaskConical,
  Globe,
  Heart,
  IdCard,
  Lock,
  MapPin,
  Pill,
  Search,
  Shield,
  ShieldCheck,
  Smartphone,
  Stethoscope,
  UserPlus,
  Users,
  WifiOff,
} from 'lucide-react';
import { ArrowLink, FeatureIconCard, SectionBadge } from '@/components/ui';
import { StoreBadges } from '@/components/store-badges';

const features = [
  {
    icon: Search,
    title: 'Find Healthcare Providers',
    description:
      'Locate doctors, clinics, hospitals, pharmacies, laboratories, ambulance services and specialists near you.',
  },
  {
    icon: Calendar,
    title: 'Book Appointments Easily',
    description: 'View provider availability and schedule appointments in seconds.',
  },
  {
    icon: FileText,
    title: 'Carry Your Health Information',
    description:
      'Allergies, medications, emergency contacts, blood group, chronic conditions and medical history — always with you.',
  },
  {
    icon: IdCard,
    title: 'SmartHealth Patient ID',
    description:
      'A unique Patient ID helps participating providers identify your records quickly and accurately.',
  },
  {
    icon: Shield,
    title: 'Emergency Information',
    description:
      'Access critical health information during emergencies — even from the lock screen.',
  },
  {
    icon: Building2,
    title: 'Healthcare Directory',
    description: 'Discover trusted healthcare facilities across Zimbabwe and Africa.',
  },
  {
    icon: Users,
    title: 'Family Profiles',
    description:
      'Manage healthcare for your spouse, children and dependents from one app.',
  },
  {
    icon: WifiOff,
    title: 'Offline First',
    description:
      'Core healthcare information remains available even when connectivity is limited.',
  },
];

const privacyCards = [
  {
    icon: Smartphone,
    title: 'Local Storage First',
    description: 'Your personal health information is primarily stored on your device.',
  },
  {
    icon: Eye,
    title: 'You Control Sharing',
    description: 'You choose what information is shared and with whom.',
  },
  {
    icon: Cloud,
    title: 'Backup Choices',
    description: 'Securely back up to Google Drive, iCloud, or local encrypted backups.',
  },
  {
    icon: ShieldCheck,
    title: 'No Selling Of Data',
    description: 'MyHealth never sells personal health information.',
  },
  {
    icon: Lock,
    title: 'Secure Encryption',
    description: 'Data is protected using modern encryption standards.',
  },
  {
    icon: Check,
    title: 'Transparent Permissions',
    description: 'We only request permissions necessary to provide healthcare services.',
  },
];

const commitments = [
  { icon: Shield, title: 'Privacy By Design', description: 'Privacy is built into every feature.' },
  {
    icon: Heart,
    title: 'Patient Ownership',
    description: 'Patients remain in control of their healthcare information.',
  },
  {
    icon: Globe,
    title: 'Accessibility',
    description: 'Healthcare information should be accessible when needed.',
  },
  {
    icon: Check,
    title: 'Simplicity',
    description: 'Healthcare technology should be easy for everyone.',
  },
  {
    icon: Lock,
    title: 'Security',
    description: 'Protecting patient information is non-negotiable.',
  },
  {
    icon: ShieldCheck,
    title: 'Trust',
    description: 'Healthcare relationships are built on trust and transparency.',
  },
];

const steps = [
  {
    n: '01',
    icon: Download,
    title: 'Download MyHealth',
    description: 'Install the app from the App Store or Google Play.',
  },
  {
    n: '02',
    icon: UserPlus,
    title: 'Create Your Profile',
    description: 'Add your essential health information securely on your device.',
  },
  {
    n: '03',
    icon: Search,
    title: 'Find Healthcare Providers',
    description: 'Search trusted clinics, hospitals and specialists nearby.',
  },
  {
    n: '04',
    icon: Calendar,
    title: 'Book & Manage Your Care',
    description: 'Schedule appointments and keep your healthcare on track.',
  },
];

const careTypes = [
  { name: 'Doctors & GPs', icon: Stethoscope },
  { name: 'Hospitals', icon: Building2 },
  { name: 'Pharmacies', icon: Pill },
  { name: 'Laboratories', icon: FlaskConical },
  { name: 'Ambulance', icon: Ambulance },
  { name: 'Specialists', icon: Heart },
];

const testimonials = [
  {
    quote:
      'MyHealth makes it easy to keep our family health information organised and ready when we need it.',
    who: 'Parent',
    where: 'Harare',
    initial: 'P',
  },
  {
    quote:
      'I can find clinics near me and book appointments without long phone calls.',
    who: 'Patient',
    where: 'Bulawayo',
    initial: 'T',
  },
  {
    quote:
      'Knowing my emergency information is on my phone gives me peace of mind when travelling.',
    who: 'Traveller',
    where: 'Southern Africa',
    initial: 'S',
  },
];

export function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-sky-50 via-white to-teal-50">
      <div className="section-pad grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
        <div>
          <div className="badge-pill mb-6">Powered by SmartHealth Africa</div>
          <h1 className="text-4xl font-bold leading-[1.1] tracking-tight text-slate-900 sm:text-5xl lg:text-[3.25rem]">
            Take Control of Your{' '}
            <span className="text-[#0ea5e9]">Healthcare Journey</span>
          </h1>
          <p className="mt-5 text-lg leading-relaxed text-slate-600">
            MyHealth helps you find healthcare providers, manage appointments, store your health
            profile securely on your device, and access healthcare services wherever you are.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <ArrowLink href="#download">Download for Android</ArrowLink>
            <a href="#download" className="btn-secondary">
              Download for iPhone
            </a>
          </div>
          <div className="mt-4 flex flex-wrap gap-3">
            <a href="#features" className="btn-secondary">
              <MapPin size={16} /> Find Healthcare Providers
            </a>
            <a href="#privacy" className="btn-secondary">
              <Shield size={16} /> How We Protect Privacy
            </a>
          </div>
          <div className="mt-6">
            <StoreBadges />
          </div>
          <div className="mt-8 flex flex-wrap gap-6 text-sm text-slate-600">
            <span className="flex items-center gap-2">
              <ShieldCheck size={16} className="text-[#0d9488]" /> Privacy-first
            </span>
            <span className="flex items-center gap-2">
              <WifiOff size={16} className="text-[#0d9488]" /> Works offline
            </span>
            <span className="flex items-center gap-2">
              <Check size={16} className="text-[#0d9488]" /> Free for patients
            </span>
          </div>
        </div>
        <div className="relative mx-auto w-full max-w-lg">
          <Image
            src="/images/hero-family.jpg"
            alt="A diverse African family using the MyHealth app together"
            width={1920}
            height={1080}
            priority
            className="h-auto w-full rounded-[2rem] shadow-xl shadow-slate-300/40"
          />
        </div>
      </div>
    </section>
  );
}

export function FeaturesSection() {
  return (
    <section id="features" className="section-pad">
      <div className="text-center">
        <SectionBadge>Why patients love MyHealth</SectionBadge>
        <h2 className="section-title mt-4">Everything you need to manage your healthcare</h2>
        <p className="section-desc mx-auto">
          Designed for the way real families and travellers access care across Africa.
        </p>
      </div>
      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {features.map((f) => (
          <FeatureIconCard key={f.title} {...f} />
        ))}
      </div>
    </section>
  );
}

export function PrivacySection() {
  return (
    <section id="privacy" className="border-y border-slate-100 bg-slate-50">
      <div className="section-pad">
        <div className="grid items-center gap-12 lg:grid-cols-2">
          <div>
            <SectionBadge>Privacy-first healthcare</SectionBadge>
            <h2 className="section-title mt-4">
              Your medical information belongs to <span className="text-[#0ea5e9]">you</span>.
            </h2>
            <p className="section-desc">
              Unlike many healthcare apps, MyHealth is designed with privacy at its core — so you
              stay in control of what&apos;s shared, with whom, and when.
            </p>
          </div>
          <div className="flex justify-center">
            <Image
              src="/images/phone-mockup.png"
              alt="MyHealth app interface on a smartphone"
              width={1024}
              height={1536}
              className="h-auto w-full max-w-xs drop-shadow-2xl"
            />
          </div>
        </div>
        <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {privacyCards.map(({ icon: Icon, title, description }) => (
            <div key={title} className="card">
              <Icon size={22} className="text-[#0ea5e9]" />
              <h3 className="mt-3 font-bold text-slate-900">{title}</h3>
              <p className="mt-2 text-sm text-slate-600">{description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function CommitmentsSection() {
  return (
    <section className="section-pad">
      <div className="text-center">
        <SectionBadge>Our principles</SectionBadge>
        <h2 className="section-title mt-4">Six commitments behind every feature</h2>
      </div>
      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {commitments.map((f) => (
          <FeatureIconCard key={f.title} {...f} teal />
        ))}
      </div>
    </section>
  );
}

export function HowItWorksSection() {
  return (
    <section id="how-it-works" className="border-y border-slate-100 bg-white">
      <div className="section-pad">
        <div className="text-center">
          <SectionBadge>How it works</SectionBadge>
          <h2 className="section-title mt-4">Get started in four simple steps</h2>
        </div>
        <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {steps.map((s) => (
            <div key={s.n} className="card relative overflow-hidden">
              <span className="absolute right-4 top-4 text-4xl font-bold text-slate-100">{s.n}</span>
              <div className="icon-box">
                <s.icon size={20} />
              </div>
              <h3 className="mt-4 font-bold text-slate-900">{s.title}</h3>
              <p className="mt-2 text-sm text-slate-600">{s.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export function DirectorySection() {
  return (
    <section className="section-pad bg-gradient-to-b from-slate-50 to-white">
      <div className="text-center">
        <SectionBadge>Healthcare directory</SectionBadge>
        <h2 className="section-title mt-4">Every kind of care, in one directory</h2>
      </div>
      <div className="mt-10 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {careTypes.map(({ name, icon: Icon }) => (
          <div key={name} className="card flex items-center gap-3 !py-4">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-sky-50 text-[#0ea5e9]">
              <Icon size={18} />
            </div>
            <span className="text-sm font-semibold text-slate-800">{name}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

export function AfricaSection() {
  const points = [
    'Built for low-bandwidth environments',
    'Works on Android & iPhone, online or offline',
    'Local providers, locally relevant care',
  ];
  return (
    <section className="relative min-h-[360px] overflow-hidden">
      <div className="absolute inset-0">
        <Image
          src="/images/africa-healthcare.jpg"
          alt="Modern healthcare facility in Zimbabwe"
          fill
          className="object-cover"
          sizes="100vw"
        />
      </div>
      <div className="absolute inset-0 bg-gradient-to-r from-[#0c4a6e]/95 via-[#0ea5e9]/85 to-teal-600/60" />
      <div className="section-pad relative text-center text-white lg:text-left">
        <div className="badge-pill !border-white/20 !bg-white/10 !text-white">Designed for Africa</div>
        <h2 className="section-title mt-4 !text-white">
          Healthcare designed for African communities
        </h2>
        <p className="section-desc !text-sky-100">
          MyHealth is built to support healthcare access in Zimbabwe and across Africa — providing
          simple, reliable tools that help patients connect with healthcare providers and manage
          their healthcare journey.
        </p>
        <ul className="mt-6 space-y-2">
          {points.map((p) => (
            <li key={p} className="flex items-center justify-center gap-2 text-sky-50 lg:justify-start">
              <Check size={16} className="shrink-0 text-teal-300" />
              {p}
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}

export function TestimonialsSection() {
  return (
    <section className="border-y border-slate-100 bg-slate-50">
      <div className="section-pad">
        <div className="text-center">
          <SectionBadge>Loved by patients</SectionBadge>
          <h2 className="section-title mt-4">Trusted across families and communities</h2>
        </div>
        <div className="mt-12 grid gap-6 lg:grid-cols-3">
          {testimonials.map((t) => (
            <blockquote key={t.who} className="card">
              <span className="text-3xl font-serif text-[#0ea5e9]">&ldquo;</span>
              <p className="mt-2 text-slate-700">{t.quote}</p>
              <footer className="mt-6 flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[#0ea5e9] text-sm font-bold text-white">
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

export function DownloadSection() {
  return (
    <section id="download" className="section-pad bg-gradient-to-br from-sky-50 to-white">
      <div className="grid items-center gap-12 lg:grid-cols-2">
        <div>
          <SectionBadge>Get started today</SectionBadge>
          <h2 className="section-title mt-4">Start managing your healthcare smarter today.</h2>
          <p className="section-desc">
            Download MyHealth for free and take control of your healthcare journey.
          </p>
          <div className="mt-8">
            <StoreBadges />
          </div>
          <p className="mt-4 text-sm text-slate-500">Store links coming soon.</p>
          <div className="mt-6 flex flex-wrap gap-3">
            <ArrowLink href="#download">Download for Android</ArrowLink>
            <a href="#download" className="btn-secondary">
              Download for iPhone
            </a>
          </div>
        </div>
        <div className="flex justify-center">
          <Image
            src="/images/phone-mockup.png"
            alt="MyHealth app screens"
            width={1024}
            height={1536}
            className="h-auto w-full max-w-xs drop-shadow-2xl"
          />
        </div>
      </div>
    </section>
  );
}
