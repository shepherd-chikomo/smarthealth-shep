import Link from 'next/link';
import { Facebook, Instagram, Linkedin, Mail, MapPin, Stethoscope } from 'lucide-react';
import { site } from '@/lib/site';

function XIcon({ size = 16 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
  );
}

export function SiteFooter() {
  return (
    <footer className="bg-[#0f172a] text-slate-300">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-14 sm:px-6 lg:grid-cols-4 lg:px-8">
        <div className="lg:col-span-1">
          <div className="flex items-center gap-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-[#2563eb] text-white">
              <Stethoscope size={20} />
            </span>
            <div>
              <div className="font-bold text-white">{site.name}</div>
              <div className="text-[10px] font-semibold tracking-widest text-slate-400">
                BY SMARTHEALTH
              </div>
            </div>
          </div>
          <p className="mt-4 text-sm leading-relaxed text-slate-400">
            Your practice. Anywhere. Anytime. The practitioner companion app for healthcare
            professionals across Zimbabwe and Africa.
          </p>
          <div className="mt-5 flex gap-2">
            {[Facebook, Instagram, Linkedin].map((Icon, i) => (
              <a
                key={i}
                href="#"
                className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-800 text-slate-400 transition hover:bg-slate-700 hover:text-white"
              >
                <Icon size={16} />
              </a>
            ))}
            <a
              href="#"
              className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-800 text-slate-400 transition hover:bg-slate-700 hover:text-white"
            >
              <XIcon />
            </a>
          </div>
        </div>
        <div>
          <h3 className="text-sm font-semibold text-white">Product</h3>
          <ul className="mt-4 space-y-2.5 text-sm text-slate-400">
            <li><a href="#features" className="hover:text-white">About MyPractice</a></li>
            <li><a href={site.portalUrl} className="hover:text-white">SmartHealth Platform</a></li>
            <li><a href="#download" className="hover:text-white">Download</a></li>
            <li><a href="#faq" className="hover:text-white">FAQ</a></li>
          </ul>
        </div>
        <div>
          <h3 className="text-sm font-semibold text-white">Legal</h3>
          <ul className="mt-4 space-y-2.5 text-sm text-slate-400">
            <li><a href="#" className="hover:text-white">Privacy Policy</a></li>
            <li><a href="#" className="hover:text-white">Terms of Service</a></li>
            <li><a href={`mailto:${site.contactEmail}`} className="hover:text-white">Contact Us</a></li>
          </ul>
        </div>
        <div>
          <h3 className="text-sm font-semibold text-white">Contact</h3>
          <ul className="mt-4 space-y-3 text-sm text-slate-400">
            <li className="flex items-center gap-2">
              <MapPin size={16} className="shrink-0 text-slate-500" />
              Harare, Zimbabwe
            </li>
            <li className="flex items-center gap-2">
              <Mail size={16} className="shrink-0 text-slate-500" />
              <a href={`mailto:${site.contactEmail}`} className="hover:text-white">
                {site.contactEmail}
              </a>
            </li>
          </ul>
          <a
            href="https://wa.me/"
            className="mt-5 inline-flex items-center gap-2 rounded-full bg-[#0d9488] px-5 py-2.5 text-sm font-semibold text-white hover:bg-teal-600"
          >
            WhatsApp us
          </a>
        </div>
      </div>
      <div className="border-t border-slate-800">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-2 px-4 py-6 text-xs text-slate-500 sm:flex-row sm:px-6 lg:px-8">
          <span>© {site.year} SmartHealth Africa. All rights reserved.</span>
          <Link href="https://smarthealth.africa" className="hover:text-slate-300">
            SmartHealth.africa
          </Link>
        </div>
      </div>
    </footer>
  );
}
