import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  output: 'standalone',
  async rewrites() {
    return [
      {
        source: '/v1/:path*',
        destination: `${process.env.API_URL ?? 'http://localhost:3000'}/v1/:path*`,
      },
    ];
  },
};

export default nextConfig;