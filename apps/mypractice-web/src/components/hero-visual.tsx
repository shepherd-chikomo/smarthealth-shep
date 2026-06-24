import { MarketingImage } from '@/components/marketing-image';

export function HeroVisual() {
  return (
    <div className="relative mx-auto w-full max-w-[540px] lg:max-w-none">
      <MarketingImage
        src="/images/hero-visual.png"
        alt="Healthcare professional managing practice appointments and patients with MyPractice"
        width={1536}
        height={1024}
        priority
        className="h-auto w-full rounded-[2rem] shadow-xl shadow-slate-300/40"
      />
    </div>
  );
}
