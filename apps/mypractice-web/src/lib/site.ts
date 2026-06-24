export const site = {
  name: 'MyPractice',
  tagline: 'Your Entire Practice In Your Pocket',
  description:
    'Manage appointments, patients, availability, consultations, performance and professional visibility from anywhere with MyPractice.',
  portalUrl: process.env.NEXT_PUBLIC_PORTAL_URL ?? 'https://dev.smarthealth.co.zw',
  contactEmail: 'hello@smarthealth.africa',
  whatsappUrl: 'https://wa.me/263719339276',
  year: new Date().getFullYear(),
} as const;

export const portalLoginUrl = `${site.portalUrl}/login`;
export const portalClaimUrl = `${site.portalUrl}/claim`;
