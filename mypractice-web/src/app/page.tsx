import Link from 'next/link';
import { site } from '@/lib/site';
import { SiteHeader } from '@/components/site-header';
import {
  AfricaSection,
  DownloadSection,
  EcosystemSection,
  EssentialsSection,
  FaqSection,
  FeaturesSection,
  GrowthSection,
  HeroSection,
  HowItWorksSection,
  PrivacySection,
  ProductivitySection,
  TestimonialsSection,
  TrustSection,
  WhoSection,
} from '@/components/landing-sections';

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main>
        <HeroSection />
        <FeaturesSection />
        <EssentialsSection />
        <GrowthSection />
        <TrustSection />
        <ProductivitySection />
        <PrivacySection />
        <WhoSection />
        <AfricaSection />
        <HowItWorksSection />
        <TestimonialsSection />
        <EcosystemSection />
        <FaqSection />
        <DownloadSection />
      </main>
      <footer className="border-t border-slate-200 bg-slate-900 text-slate-300">
        <div className="mx-auto grid max-w-6xl gap-10 px-4 py-14 sm:px-6 lg:grid-cols-4 lg:px-8">
          <div className="lg:col-span-2">
            <div className="text-lg font-bold text-white">{site.name}</div>
            <p className="mt-1 text-sm text-teal-400">by SmartHealth</p>
            <p className="mt-4 max-w-md text-sm">
              Your practice. Anywhere. Anytime. The practitioner companion app for healthcare
              professionals across Zimbabwe and Africa.
            </p>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-white">Product</h3>
            <ul className="mt-3 space-y-2 text-sm">
              <li><a href="#features" className="hover:text-white">About MyPractice</a></li>
              <li><a href={site.portalUrl} className="hover:text-white">SmartHealth Platform</a></li>
              <li><a href="#download" className="hover:text-white">Download</a></li>
              <li><a href="#faq" className="hover:text-white">FAQ</a></li>
            </ul>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-white">Contact</h3>
            <ul className="mt-3 space-y-2 text-sm">
              <li>Harare, Zimbabwe</li>
              <li>
                <a href={`mailto:${site.contactEmail}`} className="hover:text-white">
                  {site.contactEmail}
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="border-t border-slate-800 py-6 text-center text-xs text-slate-500">
          © {site.year} SmartHealth Africa. All rights reserved. ·{' '}
          <Link href="https://smarthealth.africa" className="hover:text-slate-300">
            SmartHealth.africa
          </Link>
        </div>
      </footer>
    </>
  );
}
