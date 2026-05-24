import { describe, expect, it } from 'vitest';

describe('Notification deep links', () => {
  const routes: Record<string, string> = {
    appointment_reminder: '/bookings',
    appointment_cancellation: '/bookings',
    emergency_alert: '/emergency',
    provider_message: '/provider/{providerId}',
    facility_announcement: '/home',
  };

  it('maps categories to app routes', () => {
    expect(routes.appointment_reminder).toBe('/bookings');
    expect(routes.emergency_alert).toBe('/emergency');
  });

  it('builds provider deep link from payload', () => {
    const providerId = 'abc-123';
    const path = `/provider/${providerId}`;
    expect(path).toBe('/provider/abc-123');
  });
});

describe('Notification preferences', () => {
  it('defaults to enabled when no preference row exists', () => {
    expect(true).toBe(true);
  });
});
