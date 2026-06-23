import { Inter } from 'next/font/google';
import type { Metadata } from 'next';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: 'MyHealth App — Your Health. Your Records. Your Control.',
  description:
    'MyHealth by SmartHealth Africa helps patients find healthcare providers, book appointments, and securely manage health records on their device.',
  openGraph: {
    title: 'MyHealth by SmartHealth',
    description: 'Take control of your healthcare journey.',
    siteName: 'MyHealth',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="antialiased">{children}</body>
    </html>
  );
}
