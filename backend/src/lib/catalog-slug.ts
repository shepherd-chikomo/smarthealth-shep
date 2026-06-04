/** Normalizes free-text catalog values to stable filter IDs (e.g. "HIV/AIDS" → "hiv_aids"). */
export function toCatalogSlug(raw: string): string {
  return raw
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '');
}
