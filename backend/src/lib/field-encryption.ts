import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import { env } from '../config.js';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12;
const TAG_LENGTH = 16;

function deriveKey(secret: string): Buffer {
  return createHash('sha256').update(secret).digest();
}

function getEncryptionKey(): Buffer | null {
  if (!env.FIELD_ENCRYPTION_KEY) return null;
  return deriveKey(env.FIELD_ENCRYPTION_KEY);
}

export function encryptField(plaintext: string): string {
  const key = getEncryptionKey();
  if (!key) return plaintext;

  const iv = randomBytes(IV_LENGTH);
  const cipher = createCipheriv(ALGORITHM, key, iv);
  const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
  const tag = cipher.getAuthTag();

  return `enc:${Buffer.concat([iv, tag, encrypted]).toString('base64url')}`;
}

export function decryptField(ciphertext: string): string {
  if (!ciphertext.startsWith('enc:')) return ciphertext;

  const key = getEncryptionKey();
  if (!key) throw new Error('FIELD_ENCRYPTION_KEY required to decrypt');

  const data = Buffer.from(ciphertext.slice(4), 'base64url');
  const iv = data.subarray(0, IV_LENGTH);
  const tag = data.subarray(IV_LENGTH, IV_LENGTH + TAG_LENGTH);
  const encrypted = data.subarray(IV_LENGTH + TAG_LENGTH);

  const decipher = createDecipheriv(ALGORITHM, key, iv);
  decipher.setAuthTag(tag);
  return Buffer.concat([decipher.update(encrypted), decipher.final()]).toString('utf8');
}

export function isEncrypted(value: string): boolean {
  return value.startsWith('enc:');
}
