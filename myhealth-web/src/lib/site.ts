export const site = {
  name: 'MyHealth',
  tagline: 'Your Health. Your Records. Your Control.',
  description:
    'MyHealth helps you find healthcare providers, manage appointments, store your health profile securely on your device, and access healthcare services wherever you are.',
  apiUrl: process.env.NEXT_PUBLIC_API_URL ?? 'https://dev.smarthealth.co.zw',
  contactEmail: 'hello@smarthealth.africa',
  whatsappUrl: 'https://wa.me/',
  year: new Date().getFullYear(),
} as const;
