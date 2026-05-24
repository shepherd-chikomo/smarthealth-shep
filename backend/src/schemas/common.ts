import { z } from 'zod';

export { paginationQuerySchema } from '../lib/pagination.js';

export const successMessageSchema = z.object({
  message: z.string(),
});

export const authTokensSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
  expiresIn: z.number(),
  tokenType: z.literal('Bearer').default('Bearer'),
});

export const otpContextSchema = z.enum(['staff', 'mobile', 'recovery']);

export const otpChannelSchema = z.enum(['email', 'phone']);

export const otpSendBodySchema = z.object({
  context: otpContextSchema.optional(),
  email: z.string().email().optional(),
  phone: z.string().min(9).max(20).optional(),
  channel: otpChannelSchema.optional(),
});

export const otpVerifyBodySchema = z.object({
  context: otpContextSchema.optional(),
  email: z.string().email().optional(),
  phone: z.string().min(9).max(20).optional(),
  otp: z.string().length(6),
  channel: otpChannelSchema,
});

export const otpSendResponseSchema = z.object({
  message: z.string(),
  channel: z.enum(['email', 'sms']),
  destination: z.string(),
});

export const otpVerifyResponseSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
  expiresIn: z.number(),
  tokenType: z.literal('Bearer'),
  user: z.object({
    id: z.string().uuid(),
    phone: z.string().optional(),
    email: z.string().optional(),
  }),
});

export type OtpSendBody = z.infer<typeof otpSendBodySchema>;
export type OtpVerifyBody = z.infer<typeof otpVerifyBodySchema>;

/** @deprecated phone-only — use otpSendBodySchema */
export const legacyOtpSendBodySchema = z.object({
  phone: z.string().min(9).max(20),
});

/** @deprecated phone-only — use otpVerifyBodySchema */
export const legacyOtpVerifyBodySchema = z.object({
  phone: z.string().min(9).max(20),
  otp: z.string().length(6),
});

export const refreshBodySchema = z.object({
  refreshToken: z.string().min(1),
});

export const patientProfileSchema = z.object({
  id: z.string().uuid(),
  firstName: z.string().nullable(),
  lastName: z.string().nullable(),
  displayName: z.string().nullable(),
  phone: z.string().nullable(),
  email: z.string().nullable(),
  dateOfBirth: z.string().nullable(),
  gender: z.string().nullable(),
  preferredLanguage: z.string(),
  timezone: z.string(),
  avatarPath: z.string().nullable(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const updatePatientProfileSchema = z.object({
  firstName: z.string().min(1).max(100).optional(),
  lastName: z.string().min(1).max(100).optional(),
  phone: z.string().optional(),
  email: z.string().email().optional(),
  dateOfBirth: z.string().date().optional(),
  gender: z.enum(['male', 'female', 'other', 'prefer_not_to_say']).optional(),
  preferredLanguage: z.string().min(2).max(5).optional(),
  timezone: z.string().optional(),
});

export const familyMemberSchema = z.object({
  id: z.string().uuid(),
  firstName: z.string(),
  lastName: z.string().nullable(),
  relationship: z.string(),
  dateOfBirth: z.string().nullable(),
  gender: z.string().nullable(),
  medicalConditions: z.array(z.string()),
  allergies: z.string().nullable(),
  isPrimaryAccountHolder: z.boolean(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const createFamilyMemberSchema = z.object({
  firstName: z.string().min(1).max(100),
  lastName: z.string().max(100).optional(),
  relationship: z.enum([
    'self',
    'spouse',
    'child',
    'parent',
    'sibling',
    'grandparent',
    'grandchild',
    'guardian',
    'other',
  ]),
  dateOfBirth: z.string().date().optional(),
  gender: z.enum(['male', 'female', 'other', 'prefer_not_to_say']).optional(),
  medicalConditions: z.array(z.string()).optional(),
  allergies: z.string().optional(),
});

export const updateFamilyMemberSchema = createFamilyMemberSchema.partial();

export const providerSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  categoryId: z.string().nullable(),
  specialty: z.string().nullable(),
  specialtyId: z.string().uuid().nullable(),
  facilityName: z.string().nullable(),
  facilityId: z.string().uuid(),
  address: z.string().nullable(),
  phone: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  distanceKm: z.number().nullable().optional(),
  imageUrl: z.string().nullable(),
  heroImageUrl: z.string().nullable(),
  isVerified: z.boolean(),
  isAcceptingBookings: z.boolean(),
  mdpczNumber: z.string().nullable(),
  about: z.string().nullable(),
  services: z.array(z.string()),
  conditions: z.array(z.string()),
  ageGroups: z.array(z.string()),
  averageRating: z.number().nullable().optional(),
  reviewCount: z.number().optional(),
});

export const facilitySchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  slug: z.string(),
  facilityType: z.string(),
  description: z.string().nullable(),
  addressLine1: z.string().nullable(),
  city: z.string(),
  province: z.string(),
  phone: z.string().nullable(),
  email: z.string().nullable(),
  website: z.string().nullable(),
  latitude: z.number().nullable(),
  longitude: z.number().nullable(),
  distanceKm: z.number().nullable().optional(),
  isVerified: z.boolean(),
  logoPath: z.string().nullable(),
});

export const appointmentSchema = z.object({
  id: z.string().uuid(),
  referenceNumber: z.string(),
  facilityId: z.string().uuid(),
  providerId: z.string().uuid(),
  patientId: z.string().uuid(),
  familyMemberId: z.string().uuid().nullable(),
  scheduledAt: z.string(),
  durationMinutes: z.number(),
  status: z.string(),
  notes: z.string().nullable(),
  cancellationReason: z.string().nullable(),
  providerName: z.string().nullable().optional(),
  facilityName: z.string().nullable().optional(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const createAppointmentSchema = z.object({
  facilityId: z.string().uuid(),
  providerId: z.string().uuid(),
  familyMemberId: z.string().uuid().optional(),
  scheduledAt: z.string().datetime(),
  durationMinutes: z.number().int().min(15).max(240).default(30),
  notes: z.string().max(1000).optional(),
});

export const updateAppointmentSchema = z.object({
  scheduledAt: z.string().datetime().optional(),
  durationMinutes: z.number().int().min(15).max(240).optional(),
  status: z
    .enum(['pending', 'confirmed', 'checked_in', 'in_progress', 'completed', 'cancelled', 'no_show'])
    .optional(),
  notes: z.string().max(1000).optional(),
  cancellationReason: z.string().max(500).optional(),
});

export const reviewSchema = z.object({
  id: z.string().uuid(),
  providerId: z.string().uuid(),
  patientId: z.string().uuid(),
  rating: z.number().int().min(1).max(5),
  title: z.string().nullable(),
  comment: z.string().nullable(),
  isVerifiedVisit: z.boolean(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const createReviewSchema = z.object({
  providerId: z.string().uuid(),
  rating: z.number().int().min(1).max(5),
  title: z.string().max(200).optional(),
  comment: z.string().max(2000).optional(),
  appointmentId: z.string().uuid().optional(),
});

export const emergencyServiceSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  serviceType: z.string(),
  phone: z.string(),
  alternatePhone: z.string().nullable(),
  address: z.string().nullable(),
  city: z.string(),
  province: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  distanceKm: z.number().nullable().optional(),
  is24Hours: z.boolean(),
});

export const notificationSchema = z.object({
  id: z.string().uuid(),
  title: z.string(),
  body: z.string(),
  channel: z.string(),
  status: z.string(),
  category: z.string().optional(),
  actionUrl: z.string().nullable(),
  payload: z.record(z.unknown()).optional(),
  readAt: z.string().nullable(),
  createdAt: z.string(),
});

export const paymentInitiateSchema = z.object({
  appointmentId: z.string().uuid().optional(),
  invoiceId: z.string().uuid().optional(),
  amountCents: z.number().int().positive(),
  currencyCode: z.string().length(3).default('USD'),
  paymentMethod: z.enum(['cash', 'card', 'mobile_money', 'bank_transfer', 'insurance', 'other']),
});

export const paymentStatusSchema = z.object({
  id: z.string().uuid(),
  status: z.string(),
  amountCents: z.number(),
  currencyCode: z.string(),
  referenceNumber: z.string().nullable(),
  paidAt: z.string().nullable(),
  createdAt: z.string(),
});

export const paginationMetaSchema = z.object({
  page: z.number(),
  limit: z.number(),
  total: z.number(),
  totalPages: z.number(),
  hasNext: z.boolean(),
  hasPrev: z.boolean(),
});

export const geoQuerySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lon: z.coerce.number().min(-180).max(180),
  radiusKm: z.coerce.number().min(0.1).max(500).default(25),
});

export const searchQuerySchema = z.object({
  q: z.string().optional(),
  categoryId: z.string().optional(),
  specialtyId: z.string().uuid().optional(),
  specialties: z.string().optional(),
  conditions: z.string().optional(),
  ageGroups: z.string().optional(),
  lat: z.coerce.number().min(-90).max(90).optional(),
  lon: z.coerce.number().min(-180).max(180).optional(),
  radiusKm: z.coerce.number().min(0.1).max(500).optional(),
  isVerified: z.coerce.boolean().optional(),
  province: z.string().optional(),
  city: z.string().optional(),
  facilityType: z.string().optional(),
});

export const healthcareSearchQuerySchema = z.object({
  openNow: z.coerce.boolean().optional(),
  hasQueue: z.coerce.boolean().optional(),
  city: z.string().optional(),
  province: z.string().optional(),
  facilityId: z.string().uuid().optional(),
});

export const appointmentFilterSchema = z.object({
  status: z.string().optional(),
  providerId: z.string().uuid().optional(),
  facilityId: z.string().uuid().optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
});

export const notificationFilterSchema = z.object({
  unreadOnly: z.coerce.boolean().optional(),
  channel: z.string().optional(),
  category: z.string().optional(),
});

export const idParamSchema = z.object({
  id: z.string().uuid(),
});

export const consentTypeSchema = z.enum([
  'data_processing',
  'telehealth',
  'marketing',
  'research',
  'third_party_sharing',
  'emergency_contact',
]);

export const grantConsentSchema = z.object({
  consentType: consentTypeSchema,
  version: z.string().min(1).max(20),
  metadata: z.record(z.unknown()).optional(),
});

export const consentRecordSchema = z.object({
  id: z.string().uuid(),
  consentType: consentTypeSchema,
  version: z.string(),
  grantedAt: z.string(),
  withdrawnAt: z.string().nullable(),
  metadata: z.record(z.unknown()),
});

export const providerIdParamSchema = z.object({
  id: z.string().uuid(),
});
