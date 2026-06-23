'use client';

import Link from 'next/link';
import { useState } from 'react';
import { Heart, Menu, X } from 'lucide-react';
import { site } from '@/lib/site';

const nav = [
  { href: '#features', label: 'Features' },
  { href: '#privacy', label: 'Privacy' },
  { href: '#how-it-works', label: 'How it works' },
  { href: '#faq', label: 'FAQ' },
];

export function SiteHeader() {
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 border-b border-slate-100 bg-white/95 backdrop-blur-md">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-3">
          <span className="flex h-10 w-10 items-center justify-center rounded-full bg-[#0ea5e9] text-white shadow-md shadow-sky-500/30">
            <Heart size={20} fill="currentColor" />
          </span>
          <div className="text-base font-bold text-slate-900">{site.name}</div>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {nav.map((item) => (
            <a
              key={item.href}
              href={item.href}
              className="text-sm font-medium text-slate-600 transition hover:text-[#0ea5e9]"
            >
              {item.label}
            </a>
          ))}
        </nav>

        <div className="hidden md:block">
          <a href="#download" className="btn-primary">
            Get the App
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
            <a href="#download" className="btn-primary w-full" onClick={() => setOpen(false)}>
              Get the App
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
