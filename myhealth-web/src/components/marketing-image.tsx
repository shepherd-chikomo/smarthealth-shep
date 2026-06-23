import Image from 'next/image';

type MarketingImageProps = {
  src: string;
  alt: string;
  className?: string;
  priority?: boolean;
  width?: number;
  height?: number;
};

export function MarketingImage({
  src,
  alt,
  className = '',
  priority = false,
  width,
  height,
}: MarketingImageProps) {
  if (width && height) {
    return (
      <Image
        src={src}
        alt={alt}
        width={width}
        height={height}
        priority={priority}
        className={className}
      />
    );
  }

  return (
    <Image
      src={src}
      alt={alt}
      fill
      priority={priority}
      sizes="(max-width: 768px) 100vw, 50vw"
      className={className}
    />
  );
}
