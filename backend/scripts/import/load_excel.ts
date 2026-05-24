import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';
import XLSX from 'xlsx';
import type { RawSpreadsheetRow } from './types.js';
import { logger } from './logger.js';

/** Map normalized header keys to canonical field names. */
const HEADER_ALIASES: Record<string, string[]> = {
  practitionerName: [
    'practitioner name', 'name', 'doctor name', 'provider name', 'practitioner',
    'full name', 'doctor', 'physician name', 'healthcare provider',
  ],
  practitionerFirstName: [
    'practitioner first name', 'practitioner_first_name', 'first name', 'firstname',
  ],
  practitionerLastName: [
    'practitioner last name', 'practitioner_last_name', 'last name', 'lastname', 'surname',
  ],
  gender: ['gender', 'sex'],
  qualification: ['qualification', 'qualifications', 'degree'],
  facilityName: [
    'facility name', 'facility_name', 'facility', 'practice', 'hospital', 'clinic name',
    'workplace', 'institution', 'place of work', 'employer',
  ],
  registrationNumber: [
    'registration number', 'reg number', 'reg no', 'registration no',
    'license number', 'licence number', 'practitioner number',
  ],
  mdpczNumber: ['mdpcz number', 'mdpcz no', 'mdpcz', 'mdpcz registration'],
  specialty: ['specialty', 'speciality', 'specialization', 'specialisation', 'discipline'],
  profession: ['profession', 'professional category', 'cadre', 'type'],
  address: ['address', 'physical address', 'physical_address', 'street address', 'location address'],
  province: ['province', 'state', 'region'],
  city: ['city', 'physical city', 'physical_city', 'town', 'district', 'location'],
  phone: ['phone', 'phone number', 'telephone', 'mobile', 'cell', 'contact number'],
  phone2: ['phone 2', 'alternate phone', 'secondary phone', 'mobile 2'],
  email: ['email', 'email address', 'e-mail'],
  licenseStatus: ['license status', 'licence status', 'registration status', 'status'],
  practiceType: ['practice type', 'type of practice', 'practice'],
  facilityCategory: ['facility category', 'category', 'facility type'],
  ownershipType: ['ownership type', 'ownership', 'owner type'],
  gps: ['gps', 'coordinates', 'lat long', 'latitude longitude', 'location gps'],
  latitude: ['latitude', 'lat'],
  longitude: ['longitude', 'lng', 'lon'],
  source: ['source', 'data source', 'registry', 'origin'],
};

function normalizeHeader(header: unknown): string {
  return String(header ?? '')
    .trim()
    .toLowerCase()
    .replace(/[_\s]+/g, ' ')
    .replace(/[^\w\s&/-]/g, '');
}

function resolveCanonicalField(normalizedHeader: string): string | null {
  for (const [canonical, aliases] of Object.entries(HEADER_ALIASES)) {
    if (aliases.includes(normalizedHeader)) return canonical;
    if (normalizedHeader === canonical.toLowerCase()) return canonical;
  }
  return null;
}

function cellValue(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  const str = String(value).trim();
  return str === '' ? null : str;
}

export function loadExcel(filePath: string, sheetName?: string): RawSpreadsheetRow[] {
  const absolutePath = resolve(filePath);
  if (!existsSync(absolutePath)) {
    throw new Error(`Spreadsheet not found: ${absolutePath}`);
  }

  logger.info(`Loading spreadsheet: ${absolutePath}`);
  const buffer = readFileSync(absolutePath);
  const workbook = XLSX.read(buffer, { type: 'buffer', cellDates: true });
  const targetSheet = sheetName ?? workbook.SheetNames[0];
  if (!targetSheet) throw new Error('Workbook contains no sheets');

  const sheet = workbook.Sheets[targetSheet];
  if (!sheet) throw new Error(`Sheet not found: ${targetSheet}`);

  const matrix = XLSX.utils.sheet_to_json<unknown[]>(sheet, {
    header: 1,
    defval: null,
    raw: false,
  }) as unknown[][];

  if (matrix.length < 2) {
    throw new Error('Spreadsheet must contain a header row and at least one data row');
  }

  const headerRow = matrix[0] ?? [];
  const columnMap = new Map<number, string>();

  headerRow.forEach((header, index) => {
    const normalized = normalizeHeader(header);
    const canonical = resolveCanonicalField(normalized);
    if (canonical) {
      columnMap.set(index, canonical);
    } else if (normalized) {
      columnMap.set(index, normalized.replace(/\s+/g, '_'));
    }
  });

  logger.info(`Parsed headers from sheet "${targetSheet}"`, {
    columns: [...columnMap.values()],
    sheetCount: workbook.SheetNames.length,
  });

  const rows: RawSpreadsheetRow[] = [];

  for (let i = 1; i < matrix.length; i++) {
    const row = matrix[i];
    if (!row || row.every((cell) => cellValue(cell) === null)) continue;

    const raw: Record<string, unknown> = { _sheetRow: i + 1 };
    columnMap.forEach((field, colIndex) => {
      const value = cellValue(row[colIndex]);
      if (value !== null) {
        if (raw[field] !== undefined && raw[field] !== value) {
          raw[field] = `${raw[field]}; ${value}`;
        } else {
          raw[field] = value;
        }
      }
    });

    rows.push({ rowNumber: i + 1, raw });
  }

  logger.info(`Loaded ${rows.length} data rows`);
  return rows;
}
