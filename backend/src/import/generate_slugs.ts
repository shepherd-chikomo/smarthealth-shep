import type { NormalizedFacility, NormalizedProvider } from './types.js';
import { collapseWhitespace } from './normalize_data.js';

function slugify(value: string): string {
  return collapseWhitespace(value)
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80);
}

export function generateProviderSlug(provider: NormalizedProvider): string {
  const parts = [
    provider.name.title?.toLowerCase().replace(/\./g, '') ?? 'dr',
    provider.name.firstName,
    provider.name.lastName,
  ].filter(Boolean);

  let base = slugify(parts.join('-'));
  if (provider.specialtySlug) {
    base = `${base}-${provider.specialtySlug}`;
  }
  return base;
}

export function generateFacilitySlug(facility: NormalizedFacility): string {
  const parts = [facility.name];
  if (facility.city) parts.push(facility.city);
  return slugify(parts.join('-'));
}

export function ensureUniqueSlug(base: string, used: Set<string>): string {
  let slug = base || 'unknown';
  if (!used.has(slug)) {
    used.add(slug);
    return slug;
  }
  let counter = 2;
  while (used.has(`${slug}-${counter}`)) counter++;
  const unique = `${slug}-${counter}`;
  used.add(unique);
  return unique;
}

export function buildProviderSearchKeywords(provider: NormalizedProvider): string[] {
  const keywords = new Set<string>();

  keywords.add(provider.name.fullName.toLowerCase());
  if (provider.name.firstName) keywords.add(provider.name.firstName.toLowerCase());
  if (provider.name.lastName) keywords.add(provider.name.lastName.toLowerCase());
  if (provider.specialtyNormalized) keywords.add(provider.specialtyNormalized.toLowerCase());
  if (provider.specialtyRaw) keywords.add(provider.specialtyRaw.toLowerCase());
  if (provider.profession) keywords.add(provider.profession.toLowerCase());
  if (provider.facilityName) keywords.add(provider.facilityName.toLowerCase());
  if (provider.city) keywords.add(provider.city.toLowerCase());
  if (provider.registrationNumber) keywords.add(provider.registrationNumber.toLowerCase());
  if (provider.mdpczNumber) keywords.add(provider.mdpczNumber.toLowerCase());

  return [...keywords].filter(Boolean);
}

export function buildFacilitySearchKeywords(facility: NormalizedFacility): string[] {
  const keywords = new Set<string>();
  keywords.add(facility.name.toLowerCase());
  if (facility.city) keywords.add(facility.city.toLowerCase());
  if (facility.address) keywords.add(facility.address.toLowerCase());
  if (facility.facilityCategory) keywords.add(facility.facilityCategory.toLowerCase());
  if (facility.phone) keywords.add(facility.phone);
  return [...keywords].filter(Boolean);
}

export function assignSlugsAndKeywords(
  providers: NormalizedProvider[],
  facilities: NormalizedFacility[],
  existingProviderSlugs: Set<string>,
  existingFacilitySlugs: Set<string>,
): void {
  const usedProviderSlugs = new Set(existingProviderSlugs);
  const usedFacilitySlugs = new Set(existingFacilitySlugs);

  for (const facility of facilities) {
    facility.slug = ensureUniqueSlug(generateFacilitySlug(facility), usedFacilitySlugs);
    facility.searchKeywords = buildFacilitySearchKeywords(facility);
  }

  for (const provider of providers) {
    provider.slug = ensureUniqueSlug(generateProviderSlug(provider), usedProviderSlugs);
    provider.searchKeywords = buildProviderSearchKeywords(provider);
  }
}

export { slugify };
