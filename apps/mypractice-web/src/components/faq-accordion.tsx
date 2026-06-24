'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { SectionBadge } from '@/components/ui';

const faqs = [
  {
    q: 'Is MyPractice free?',
    a: 'Basic professional profiles are free. Advanced features may be available through participating SmartHealth facilities.',
  },
  {
    q: 'Who can register?',
    a: 'Licensed healthcare professionals and facility administrators across supported specialties.',
  },
  {
    q: 'Can I manage multiple facilities?',
    a: 'Yes — MyPractice supports multi-facility workflows from a single provider profile.',
  },
  {
    q: 'Is patient information secure?',
    a: 'Yes. The platform uses encryption, secure authentication and consent-gated data sharing.',
  },
  {
    q: 'Can I update my availability?',
    a: 'Update availability instantly from the app; patients only see open slots.',
  },
  {
    q: 'Can patients find me through MyPractice?',
    a: 'Yes — verified profiles are discoverable through the MyHealth patient app.',
  },
];

export function FaqAccordion() {
  const [open, setOpen] = useState(0);

  return (
    <section id="faq" className="section-pad bg-slate-50">
      <div className="text-center">
        <SectionBadge>FAQ</SectionBadge>
        <h2 className="section-title mt-4">Frequently asked questions</h2>
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
