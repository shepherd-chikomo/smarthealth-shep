import { SiteHeader } from '@/components/site-header';
import { SiteFooter } from '@/components/site-footer';
import { FaqAccordion } from '@/components/faq-accordion';
import {
  AfricaSection,
  CommitmentsSection,
  DirectorySection,
  DownloadSection,
  FeaturesSection,
  HeroSection,
  HowItWorksSection,
  PrivacySection,
  TestimonialsSection,
} from '@/components/landing-sections';

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main>
        <HeroSection />
        <FeaturesSection />
        <PrivacySection />
        <CommitmentsSection />
        <HowItWorksSection />
        <DirectorySection />
        <AfricaSection />
        <TestimonialsSection />
        <FaqAccordion />
        <DownloadSection />
      </main>
      <SiteFooter />
    </>
  );
}
