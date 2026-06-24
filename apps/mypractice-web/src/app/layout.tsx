import { Inter } from 'next/font/google';
import type { Metadata } from 'next';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: 'MyPractice by SmartHealth — Your practice. Anywhere.',
  description:
    'Manage appointments, patients, availability and consultations from your phone. Built for healthcare professionals in Zimbabwe and Africa.',
  icons: {
    icon: '/mypractice-icon.png',
    apple: '/mypractice-icon.png',
  },
  openGraph: {
    title: 'MyPractice by SmartHealth',
    description: 'Your entire practice in your pocket.',
    siteName: 'MyPractice',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="antialiased">{children}</body>
    </html>
  );
}
