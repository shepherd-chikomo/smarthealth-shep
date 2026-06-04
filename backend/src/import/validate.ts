import type { NormalizedProvider } from './types.js';

const MDPCZ_PATTERN = /^[A-Z0-9][A-Z0-9-]{2,20}$/;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ZW_PHONE_PATTERN = /^\+263[0-9]{9}$/;

const VALID_PROVINCES = new Set([
  'Bulawayo',
  'Harare',
  'Manicaland',
  'Mashonaland Central',
  'Mashonaland East',
  'Mashonaland West',
  'Masvingo',
  'Matabeleland North',
  'Matabeleland South',
  'Midlands',
]);

export interface ValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

export function validatePhone(phone: string | null): ValidationResult {
  if (!phone) return { valid: true, errors: [], warnings: [] };
  if (ZW_PHONE_PATTERN.test(phone)) return { valid: true, errors: [], warnings: [] };
  return {
    valid: false,
    errors: [`Invalid Zimbabwe phone number: ${phone} (expected E.164 +263XXXXXXXXX)`],
    warnings: [],
  };
}

export function validateEmail(email: string | null): ValidationResult {
  if (!email) return { valid: true, errors: [], warnings: [] };
  if (EMAIL_PATTERN.test(email)) return { valid: true, errors: [], warnings: [] };
  return { valid: false, errors: [`Invalid email: ${email}`], warnings: [] };
}

export function validateRegistrationNumber(reg: string | null): ValidationResult {
  if (!reg) return { valid: true, errors: [], warnings: ['Missing registration number'] };
  if (MDPCZ_PATTERN.test(reg)) return { valid: true, errors: [], warnings: [] };
  return {
    valid: false,
    errors: [`Invalid registration number format: ${reg}`],
    warnings: [],
  };
}

export function validateProvince(province: string | null): ValidationResult {
  if (!province) {
    return { valid: true, errors: [], warnings: ['Missing province — will infer from city if possible'] };
  }
  if (VALID_PROVINCES.has(province)) return { valid: true, errors: [], warnings: [] };
  return {
    valid: false,
    errors: [`Unknown province: ${province}`],
    warnings: [],
  };
}

export function validateProvider(provider: NormalizedProvider): ValidationResult {
  const errors: string[] = [...provider.validationErrors];
  const warnings: string[] = [...provider.warnings];

  if (!provider.name.fullName || provider.name.fullName === 'Unknown Provider') {
    errors.push('Provider name is required');
  }

  const phoneResult = validatePhone(provider.phone);
  errors.push(...phoneResult.errors);
  warnings.push(...phoneResult.warnings);

  const emailResult = validateEmail(provider.email);
  errors.push(...emailResult.errors);

  const regResult = validateRegistrationNumber(provider.registrationNumber ?? provider.mdpczNumber);
  if (!regResult.valid) warnings.push(...regResult.errors);
  else warnings.push(...regResult.warnings);

  const provinceResult = validateProvince(provider.province);
  errors.push(...provinceResult.errors);
  warnings.push(...provinceResult.warnings);

  if (provider.latitude !== null && (provider.latitude < -25 || provider.latitude > -15)) {
    warnings.push(`Latitude ${provider.latitude} outside typical Zimbabwe range`);
  }
  if (provider.longitude !== null && (provider.longitude < 25 || provider.longitude > 34)) {
    warnings.push(`Longitude ${provider.longitude} outside typical Zimbabwe range`);
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

export function isCriticalError(errors: string[]): boolean {
  return errors.some((e) =>
    e.includes('Provider name is required') ||
    e.includes('Invalid email') ||
    e.includes('Unknown province'),
  );
}
