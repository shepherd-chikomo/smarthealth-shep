import { MarketingImage } from '@/components/marketing-image';

/** Hero visual extracted from the Lovable mockup screenshot. */
export function HeroVisual() {
  return (
    <div className="relative mx-auto w-full max-w-[520px] lg:max-w-none">
      <MarketingImage
        src="/images/hero-visual.jpg"
        alt="Healthcare professional using the MyPractice mobile app"
        width={512}
        height={382}
        priority
        className="h-auto w-full rounded-[2rem] shadow-xl shadow-slate-300/40"
      />
    </div>
  );
}
