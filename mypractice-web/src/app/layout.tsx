import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'MyPractice by SmartHealth — Your practice. Anywhere.',
  description:
    'Manage appointments, patients, availability and consultations from your phone. Built for healthcare professionals in Zimbabwe and Africa.',
  openGraph: {
    title: 'MyPractice by SmartHealth',
    description: 'Your entire practice in your pocket.',
    siteName: 'MyPractice',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
