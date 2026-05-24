import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { extractBearerToken, getAuthenticatedUser, verifyAccessToken } from '../lib/auth.js';
import { AppError } from '../lib/errors.js';
import { getRequestContext } from '../lib/request-context.js';
import { assertNotLocked, recordLoginAttempt } from '../lib/login-attempts.js';
import {
  registerRefreshToken,
  revokeAllUserTokens,
  revokeRefreshToken,
  validateRefreshToken,
} from '../lib/refresh-token-registry.js';
import { logSecurityEvent } from '../lib/security-events.js';
import { logLoginAudit } from '../lib/audit-log.js';
import {
  lockoutIdentifier,
  resolveOtpSend,
  resolveOtpVerify,
} from '../lib/otp-policy.js';
import {
  logout,
  refreshTokens,
  sendEmailOtp,
  sendPhoneOtp,
  ensureAuthUserEmail,
  verifyEmailOtp,
  verifyPhoneOtp,
} from '../lib/supabase-auth.js';
import {
  initiateAccountRecovery,
  verifyAccountRecovery,
} from '../services/account-recovery.service.js';
import {
  authTokensSchema,
  otpSendBodySchema,
  otpSendResponseSchema,
  otpVerifyBodySchema,
  otpVerifyResponseSchema,
  refreshBodySchema,
  successMessageSchema,
} from '../schemas/common.js';

export const authRoutes: FastifyPluginAsyncZod = async (app) => {
  app.post(
    '/auth/otp/send',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Send OTP via email or SMS',
        body: otpSendBodySchema,
        response: { 200: otpSendResponseSchema },
      },
      config: { rateLimit: { max: 5, timeWindow: '1 minute' } },
    },
    async (request) => {
      const context = getRequestContext(request);
      const resolved = await resolveOtpSend({
        ...request.body,
        context: request.body.context ?? 'mobile',
      });
      const attemptKey = lockoutIdentifier(resolved.channel, resolved.identifier);
      await assertNotLocked(attemptKey, 'otp_send', context);

      if (resolved.channel === 'email') {
        if (resolved.authUserId) {
          await ensureAuthUserEmail(resolved.authUserId, resolved.identifier);
        }
        await sendEmailOtp(resolved.identifier, resolved.createUser);
      } else {
        await sendPhoneOtp(resolved.identifier, resolved.createUser);
      }

      await recordLoginAttempt(attemptKey, 'otp_send', true, context);
      return {
        message: 'OTP sent successfully',
        channel: resolved.channel,
        destination: resolved.maskedDestination,
      };
    },
  );

  app.post(
    '/auth/otp/verify',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Verify OTP and receive JWT tokens',
        body: otpVerifyBodySchema,
        response: { 200: otpVerifyResponseSchema },
      },
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
    },
    async (request) => {
      const { otp, channel, context: otpContext } = request.body;
      const context = getRequestContext(request);
      const resolved = await resolveOtpVerify({
        context: otpContext ?? 'mobile',
        email: request.body.email,
        phone: request.body.phone,
        channel,
      });
      const attemptKey = lockoutIdentifier(resolved.channel, resolved.identifier);
      await assertNotLocked(attemptKey, 'otp_verify', context);

      try {
        const result =
          resolved.channel === 'email'
            ? await verifyEmailOtp(resolved.identifier, otp)
            : await verifyPhoneOtp(resolved.identifier, otp);

        await registerRefreshToken(
          result.user.id,
          result.refreshToken,
          context,
          result.expiresIn * 7,
        );
        await recordLoginAttempt(attemptKey, 'otp_verify', true, context);
        await logSecurityEvent({
          userId: result.user.id,
          eventType: 'auth_success',
          action: 'otp_verify',
          outcome: 'allowed',
          context,
        });
        await logLoginAudit(result.user.id, 'login.otp_verify.success', 'allowed', context, {
          channel: resolved.channel,
          identifier: resolved.channel === 'email' ? resolved.identifier : `${resolved.identifier.slice(0, 6)}****`,
        });
        return {
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          expiresIn: result.expiresIn,
          tokenType: 'Bearer' as const,
          user: result.user,
        };
      } catch (error) {
        await recordLoginAttempt(attemptKey, 'otp_verify', false, context);
        await logSecurityEvent({
          eventType: 'auth_failure',
          action: 'otp_verify',
          outcome: 'denied',
          context,
          details: { channel: resolved.channel },
        });
        throw error;
      }
    },
  );

  app.post(
    '/auth/refresh',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Refresh access token with rotation',
        body: refreshBodySchema,
        response: { 200: authTokensSchema },
      },
      config: { rateLimit: { max: 20, timeWindow: '1 minute' } },
    },
    async (request) => {
      const { refreshToken } = request.body;
      const context = getRequestContext(request);
      const attemptKey = refreshToken.slice(0, 16);
      await assertNotLocked(attemptKey, 'refresh', context);

      const preValidation = await validateRefreshToken(refreshToken);
      if (preValidation.isReuse) {
        await logSecurityEvent({
          userId: preValidation.userId,
          eventType: 'token_reuse',
          action: 'refresh',
          outcome: 'denied',
          context,
        });
        await recordLoginAttempt(attemptKey, 'refresh', false, context);
        throw new AppError(
          401,
          'TOKEN_REUSE_DETECTED',
          'Session invalidated due to token reuse',
        );
      }

      const result = await refreshTokens(refreshToken);
      const userId = preValidation.userId ?? verifyAccessToken(result.accessToken).id;

      if (preValidation.isValid) {
        await revokeRefreshToken(refreshToken);
      }
      await registerRefreshToken(userId, result.refreshToken, context, result.expiresIn * 7);

      await recordLoginAttempt(attemptKey, 'refresh', true, context);
      return {
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresIn: result.expiresIn,
        tokenType: 'Bearer' as const,
      };
    },
  );

  app.post(
    '/auth/logout',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Logout and invalidate session',
        security: [{ bearerAuth: [] }],
        body: refreshBodySchema.optional(),
        response: { 200: successMessageSchema },
      },
      config: { rateLimit: { max: 30, timeWindow: '1 minute' } },
    },
    async (request) => {
      const token = extractBearerToken(request);
      const context = getRequestContext(request);
      let userId: string | undefined;
      try {
        userId = getAuthenticatedUser(request).id;
      } catch {
        // Token may already be expired during logout
      }

      if (request.body?.refreshToken) {
        await revokeRefreshToken(request.body.refreshToken);
      } else if (userId) {
        await revokeAllUserTokens(userId);
      }

      await logSecurityEvent({
        userId,
        eventType: 'logout',
        action: 'logout',
        outcome: 'allowed',
        context,
      });

      return logout(token);
    },
  );

  app.post(
    '/auth/recovery/initiate',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Initiate account recovery via email or phone OTP',
        body: otpSendBodySchema,
        response: { 200: otpSendResponseSchema },
      },
      config: { rateLimit: { max: 3, timeWindow: '1 minute' } },
    },
    async (request) =>
      initiateAccountRecovery(
        { ...request.body, context: 'recovery' },
        getRequestContext(request),
      ),
  );

  app.post(
    '/auth/recovery/verify',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Complete account recovery and receive new tokens',
        body: otpVerifyBodySchema,
        response: { 200: otpVerifyResponseSchema },
      },
      config: { rateLimit: { max: 5, timeWindow: '1 minute' } },
    },
    async (request) => {
      const context = getRequestContext(request);
      const result = await verifyAccountRecovery(request.body, context);
      await registerRefreshToken(
        result.user.id,
        result.refreshToken,
        context,
        result.expiresIn * 7,
      );
      return {
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresIn: result.expiresIn,
        tokenType: 'Bearer' as const,
        user: result.user,
      };
    },
  );
};
