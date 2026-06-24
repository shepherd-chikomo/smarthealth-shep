import type { Metadata } from 'next';
import { LandingPage } from '@/components/marketing/landing-page';

export const metadata: Metadata = {
  title: 'MyPractice — Your Entire Practice In Your Pocket | SmartHealth',
  description:
    'Manage appointments, patients, availability, consultations and professional visibility with MyPractice by SmartHealth Africa.',
};

export default function MarketingPage() {
  return <LandingPage />;
}
