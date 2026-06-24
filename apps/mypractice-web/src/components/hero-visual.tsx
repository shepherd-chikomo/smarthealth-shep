import Image from 'next/image';
import { Calendar, TrendingUp } from 'lucide-react';
import { FloatingStatCard } from '@/components/phone-mockup';
import { MarketingImage } from '@/components/marketing-image';

/** Hero: doctor photo + overlapping phone mockup + floating stat pills (Lovable layout). */
export function HeroVisual() {
  return (
    <div className="relative mx-auto w-full max-w-[540px] lg:max-w-none">
      <MarketingImage
        src="/images/hero-visual.jpg"
        alt="Healthcare professional using the MyPractice mobile app"
        width={1024}
        height={768}
        priority
        className="h-auto w-full rounded-[2rem] shadow-xl shadow-slate-300/40"
      />

      <Image
        src="/images/phone-mockup.png"
        alt="MyPractice app dashboard on a smartphone"
        width={1024}
        height={1536}
        priority
        className="absolute -right-2 bottom-4 z-20 h-auto w-[46%] max-w-[220px] drop-shadow-2xl sm:-right-4 sm:bottom-6 sm:max-w-[240px] lg:-right-6 lg:bottom-8 lg:w-[44%] lg:max-w-[260px] xl:max-w-[280px]"
      />

      <FloatingStatCard
        icon={<Calendar size={20} className="text-emerald-600" />}
        iconClassName="bg-emerald-50"
        title="24 appointments"
        subtitle="Today"
        className="left-2 top-6 z-30 sm:left-4 sm:top-8"
      />

      <FloatingStatCard
        icon={<TrendingUp size={20} className="text-[#2563eb]" />}
        iconClassName="bg-blue-50"
        title="+38% visibility"
        subtitle="This month"
        className="bottom-16 left-4 z-30 sm:bottom-20 sm:left-8 lg:bottom-24"
      />
    </div>
  );
}
