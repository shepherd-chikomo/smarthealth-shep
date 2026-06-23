import Image from 'next/image';
import { Calendar, Users } from 'lucide-react';
import { FloatingStatCard, PhoneMockup } from '@/components/phone-mockup';

export function HeroVisual() {
  return (
    <div className="relative mx-auto w-full max-w-[520px] lg:max-w-none">
      <div className="relative min-h-[440px] overflow-hidden rounded-[2rem] shadow-xl shadow-slate-300/40 sm:min-h-[500px] lg:min-h-[540px]">
        <Image
          src="/hero-doctor.jpg"
          alt="Healthcare professional using MyPractice on mobile"
          fill
          priority
          sizes="(max-width: 1024px) 520px, 560px"
          className="object-cover object-[center_20%] brightness-[1.02] saturate-[1.05]"
        />
        <div className="absolute inset-0 bg-gradient-to-br from-blue-50/30 via-white/10 to-cyan-100/40" />
        <div className="absolute inset-0 bg-gradient-to-t from-white/20 via-transparent to-white/10" />

        <div className="absolute inset-y-0 right-0 flex w-[58%] items-center justify-center sm:w-[55%]">
          <PhoneMockup size="lg" className="relative z-10 translate-x-2 sm:translate-x-4" />
        </div>

        <FloatingStatCard
          icon={<Calendar size={18} />}
          title="24 appointments"
          subtitle="Today"
          className="left-3 top-6 z-20 sm:left-5 sm:top-8"
        />
        <FloatingStatCard
          icon={<Users size={18} />}
          title="+38% visibility"
          subtitle="This month"
          className="bottom-20 left-3 z-20 sm:bottom-24 sm:left-5"
        />
      </div>
    </div>
  );
}
