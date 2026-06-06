import { randomUUID } from 'node:crypto';
import { env } from '../config.js';
import { ValidationError } from './errors.js';

const ALLOWED_LOGO_MIME = new Set(['image/png', 'image/jpeg', 'image/webp']);
const MAX_LOGO_BYTES = 2 * 1024 * 1024;

function publicAssetBaseUrl(): string {
  return (env.SUPABASE_PUBLIC_URL ?? env.SUPABASE_URL).replace(/\/$/, '');
}

export function buildPublicStorageUrl(bucket: string, path: string | null | undefined): string | null {
  if (!path || path.trim() === '') return null;
  const normalized = path.replace(/^\//, '');
  return `${publicAssetBaseUrl()}/storage/v1/object/public/${bucket}/${normalized}`;
}

export function buildFacilityLogoUrl(logoPath: string | null | undefined): string | null {
  return buildPublicStorageUrl('facility-assets', logoPath);
}

export function buildProviderImageUrl(imagePath: string | null | undefined): string | null {
  return buildPublicStorageUrl('provider-images', imagePath);
}

export function buildMedicalAidLogoUrl(logoPath: string | null | undefined): string | null {
  return buildPublicStorageUrl('facility-assets', logoPath);
}

function extensionForMime(mime: string): string {
  switch (mime) {
    case 'image/png':
      return 'png';
    case 'image/webp':
      return 'webp';
    default:
      return 'jpg';
  }
}

export async function uploadFacilityLogo(
  facilityId: string,
  buffer: Buffer,
  mimeType: string,
): Promise<string> {
  if (!ALLOWED_LOGO_MIME.has(mimeType)) {
    throw new ValidationError('Logo must be PNG, JPG, or WEBP');
  }
  if (buffer.length > MAX_LOGO_BYTES) {
    throw new ValidationError('Logo must be 2 MB or smaller');
  }

  const ext = extensionForMime(mimeType);
  const objectPath = `${facilityId}/logo/${randomUUID()}.${ext}`;
  const url = `${env.SUPABASE_URL.replace(/\/$/, '')}/storage/v1/object/facility-assets/${objectPath}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': mimeType,
      'x-upsert': 'true',
    },
    body: buffer,
  });

  if (!response.ok) {
    const detail = await response.text().catch(() => '');
    throw new ValidationError(`Logo upload failed: ${detail || response.statusText}`);
  }

  return objectPath;
}

export async function deleteStorageObject(bucket: string, objectPath: string): Promise<void> {
  const url = `${env.SUPABASE_URL.replace(/\/$/, '')}/storage/v1/object/${bucket}/${objectPath}`;
  await fetch(url, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}` },
  }).catch(() => undefined);
}
