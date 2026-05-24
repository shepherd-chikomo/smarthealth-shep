import { describe, expect, it } from 'vitest';
import jwt from 'jsonwebtoken';
import {
  buildPaginationMeta,
  paginationOffset,
  parseSort,
} from '../src/lib/pagination.js';
import { verifyAccessToken } from '../src/lib/auth.js';
import { AppError, toErrorResponse } from '../src/lib/errors.js';
import { lockoutIdentifier, maskEmail, maskPhone } from '../src/lib/otp-policy.js';

describe('pagination', () => {
  it('builds meta correctly', () => {
    const meta = buildPaginationMeta(2, 10, 25);
    expect(meta.page).toBe(2);
    expect(meta.totalPages).toBe(3);
    expect(meta.hasNext).toBe(true);
    expect(meta.hasPrev).toBe(true);
  });

  it('computes offset', () => {
    expect(paginationOffset(1, 20)).toBe(0);
    expect(paginationOffset(3, 20)).toBe(40);
  });

  it('parses sort columns', () => {
    const asc = parseSort('name', { name: 'p.name' }, 'name');
    expect(asc.column).toBe('p.name');
    expect(asc.order).toBe('DESC');

    const desc = parseSort('-rating', { rating: 'avg_rating' }, 'name');
    expect(desc.column).toBe('avg_rating');
    expect(desc.order).toBe('DESC');
  });
});

describe('JWT auth', () => {
  const secret = 'test-jwt-secret-for-unit-tests-only';

  it('verifies valid token', () => {
    const token = jwt.sign(
      { sub: '550e8400-e29b-41d4-a716-446655440000', user_role: 'patient' },
      secret,
    );

    const user = verifyAccessToken(token);
    expect(user.id).toBe('550e8400-e29b-41d4-a716-446655440000');
    expect(user.role).toBe('patient');
  });

  it('rejects invalid token', () => {
    expect(() => verifyAccessToken('invalid.token.here')).toThrow();
  });
});

describe('errors', () => {
  it('formats error response', () => {
    const error = new AppError(404, 'NOT_FOUND', 'Resource not found');
    const response = toErrorResponse(error, 'req-123');
    expect(response.error.code).toBe('NOT_FOUND');
    expect(response.error.requestId).toBe('req-123');
  });
});

describe('otp policy helpers', () => {
  it('masks email local part', () => {
    expect(maskEmail('admin@smarthealth.co.zw')).toBe('a***@smarthealth.co.zw');
  });

  it('masks phone middle digits', () => {
    expect(maskPhone('+263771234567')).toBe('+263***567');
  });

  it('builds lockout identifiers per channel', () => {
    expect(lockoutIdentifier('email', 'user@example.com')).toBe('email:user@example.com');
    expect(lockoutIdentifier('sms', '+263771234567')).toBe('sms:+263771234567');
  });
});
