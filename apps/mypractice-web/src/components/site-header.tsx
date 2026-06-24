'use client';

import { useState } from 'react';
import { Menu, X } from 'lucide-react';
import { BrandLogo } from '@/components/brand-logo';
import { portalLoginUrl } from '@/lib/site';

const nav = [
  { href: '#features', label: 'Features' },
  { href: '#how-it-works', label: 'How it works' },
  { href: '#ecosystem', label: 'Ecosystem' },
  { href: '#faq', label: 'FAQ' },
];

export function SiteHeader() {
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 border-b border-slate-100 bg-white/95 backdrop-blur-md">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
        <BrandLogo size={44} />

        <nav className="hidden items-center gap-8 md:flex">
          {nav.map((item) => (
            <a
              key={item.href}
              href={item.href}
              className="text-sm font-medium text-slate-600 transition hover:text-[#2563eb]"
            >
              {item.label}
            </a>
          ))}
        </nav>

        <div className="hidden items-center gap-4 md:flex">
          <a
            href={portalLoginUrl}
            className="text-sm font-semibold text-slate-700 hover:text-[#2563eb]"
          >
            Join
          </a>
          <a href="#download" className="btn-primary">
            Download <span aria-hidden>→</span>
          </a>
        </div>

        <button
          type="button"
          className="rounded-lg p-2 text-slate-600 md:hidden"
          onClick={() => setOpen(!open)}
          aria-label="Toggle menu"
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {open && (
        <div className="border-t border-slate-100 bg-white px-4 py-4 md:hidden">
          <div className="flex flex-col gap-3">
            {nav.map((item) => (
              <a
                key={item.href}
                href={item.href}
                className="text-sm font-medium text-slate-700"
                onClick={() => setOpen(false)}
              >
                {item.label}
              </a>
            ))}
            <a href={portalLoginUrl} className="btn-secondary w-full">
              Join
            </a>
            <a href="#download" className="btn-primary w-full" onClick={() => setOpen(false)}>
              Download →
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
