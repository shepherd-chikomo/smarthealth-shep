'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { SectionBadge } from '@/components/ui';

const faqs = [
  {
    q: 'Is MyHealth free?',
    a: 'Yes. MyHealth is free for patients.',
  },
  {
    q: 'Who can use MyHealth?',
    a: 'Anyone looking to manage their healthcare information and connect with healthcare providers.',
  },
  {
    q: 'Is my health information secure?',
    a: 'Yes. MyHealth uses modern security measures and privacy-first principles.',
  },
  {
    q: 'Can I use MyHealth offline?',
    a: 'Many core features remain available without an internet connection.',
  },
  {
    q: 'Can I back up my information?',
    a: 'Yes. Backup options include Google Drive, iCloud, and local encrypted backups.',
  },
  {
    q: 'Does MyHealth replace my doctor?',
    a: 'No. MyHealth helps you manage healthcare information and connect with healthcare providers; it does not replace professional medical advice.',
  },
];

export function FaqAccordion() {
  const [open, setOpen] = useState(0);

  return (
    <section id="faq" className="section-pad bg-slate-50">
      <div className="text-center">
        <SectionBadge>FAQ</SectionBadge>
        <h2 className="section-title mt-4">Questions, answered</h2>
        <p className="section-desc mx-auto">
          Can&apos;t find what you&apos;re looking for? Reach out via WhatsApp or email.
        </p>
      </div>
      <div className="mx-auto mt-10 max-w-3xl overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-sm">
        {faqs.map((item, i) => {
          const isOpen = open === i;
          return (
            <div key={item.q} className="border-b border-slate-100 last:border-b-0">
              <button
                type="button"
                className="flex w-full items-center justify-between gap-4 px-6 py-5 text-left"
                onClick={() => setOpen(isOpen ? -1 : i)}
              >
                <span className="font-semibold text-slate-900">{item.q}</span>
                <ChevronDown
                  size={18}
                  className={`shrink-0 text-slate-400 transition ${isOpen ? 'rotate-180' : ''}`}
                />
              </button>
              {isOpen && (
                <p className="px-6 pb-5 text-sm leading-relaxed text-slate-600">{item.a}</p>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
