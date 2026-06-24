import { SiteHeader } from '@/components/site-header';
import { SiteFooter } from '@/components/site-footer';
import { FaqAccordion } from '@/components/faq-accordion';
import {
  AfricaSection,
  CertBar,
  DownloadSection,
  EcosystemSection,
  EssentialsSection,
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
        <CertBar />
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
        <FaqAccordion />
        <DownloadSection />
      </main>
      <SiteFooter />
    </>
  );
}
