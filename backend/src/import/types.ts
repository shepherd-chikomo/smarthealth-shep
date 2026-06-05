export type ImportSource = 'MDPCZ' | 'HPA' | 'MANUAL' | 'MIXED';
export type DedupConfidence = 'HIGH' | 'MEDIUM' | 'LOW';
export type VerifiedSource = 'MDPCZ' | 'HPA' | 'MANUAL';
export type VerifiedStatus = 'pending' | 'verified' | 'rejected';

export interface RawSpreadsheetRow {
  rowNumber: number;
  raw: Record<string, unknown>;
}

export interface ParsedName {
  title: string | null;
  firstName: string;
  middleName: string | null;
  lastName: string;
  fullName: string;
}

export interface NormalizedProvider {
  rowNumber: number;
  rowHash: string;
  source: VerifiedSource;
  name: ParsedName;
  facilityName: string | null;
  registrationNumber: string | null;
  mdpczNumber: string | null;
  specialtyRaw: string | null;
  specialtyNormalized: string | null;
  specialtySlug: string | null;
  profession: string | null;
  address: string | null;
  province: string | null;
  city: string | null;
  phone: string | null;
  email: string | null;
  licenseStatus: string | null;
  practiceType: string | null;
  facilityCategory: string | null;
  ownershipType: string | null;
  latitude: number | null;
  longitude: number | null;
  gpsRaw: string | null;
  slug: string | null;
  searchKeywords: string[];
  validationErrors: string[];
  warnings: string[];
}

export interface NormalizedFacility {
  key: string;
  name: string;
  slug: string;
  facilityType: string;
  address: string | null;
  province: string | null;
  city: string | null;
  phone: string | null;
  email: string | null;
  facilityCategory: string | null;
  ownershipType: string | null;
  latitude: number | null;
  longitude: number | null;
  formattedAddress: string | null;
  searchKeywords: string[];
  sourceRows: number[];
}

export interface DedupMatch<T> {
  source: T;
  target: T;
  confidence: DedupConfidence;
  score: number;
  reason: string;
}

export type GeocodeQuality =
  | 'address'
  | 'name'
  | 'city_only'
  | 'city_centre'
  | 'manual';

export type GeocodeProvider = 'nominatim' | 'google';

export type GoogleGeocodeStrategy =
  | 'places_text'
  | 'geocoding_structured'
  | 'geocoding_freeform';

export interface GeocodeResult {
  latitude: number;
  longitude: number;
  formattedAddress: string;
  fromCache: boolean;
  quality?: GeocodeQuality;
  provider?: GeocodeProvider;
  googleStrategy?: GoogleGeocodeStrategy;
}

export interface ImportOptions {
  dryRun: boolean;
  reset: boolean;
  skipGeocoding: boolean;
  sourceFile: string;
  filePath: string;
  sourceType: ImportSource;
  batchId?: string;
  startedBy?: string;
}

export interface ImportReport {
  batchId: string;
  sourceFile: string;
  dryRun: boolean;
  startedAt: string;
  completedAt: string;
  totalRows: number;
  imported: number;
  failed: number;
  duplicatesMerged: number;
  facilitiesCreated: number;
  providersCreated: number;
  linksCreated: number;
  specialtiesUnmatched: string[];
  missingCities: string[];
  unmatchedSpecialtyCount: number;
  geocodedCount: number;
  failedRows: FailedRowReport[];
  duplicateReviews: DedupReviewReport[];
}

export interface FailedRowReport {
  rowNumber: number;
  errorCode: string;
  errorMessage: string;
  raw: Record<string, unknown>;
}

export interface DedupReviewReport {
  entityType: string;
  sourceName: string;
  targetName: string;
  confidence: DedupConfidence;
  reason: string;
  score: number;
}

export interface CityRecord {
  id: string;
  name: string;
  province: string | null;
  latitude: number | null;
  longitude: number | null;
}

export interface SpecialtyRecord {
  id: string;
  name: string;
  slug: string;
}

export interface FacilityRecord {
  id: string;
  name: string;
  slug: string;
  city: string;
  province: string;
  phone: string | null;
  address_line1: string | null;
  import_row_hash: string | null;
}

export interface ProviderRecord {
  id: string;
  name: string;
  slug: string | null;
  registration_number: string | null;
  mdpcz_number: string | null;
  phone: string | null;
  specialty: string | null;
  facility_id: string;
  import_row_hash: string | null;
}
