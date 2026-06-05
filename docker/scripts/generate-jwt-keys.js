const crypto = require('crypto');

const secret = process.env.JWT_SECRET;
if (!secret) {
  console.error('ERROR: JWT_SECRET missing inside container');
  process.exit(1);
}

function b64url(obj) {
  return Buffer.from(JSON.stringify(obj)).toString('base64url');
}

function sign(role) {
  const header = b64url({ alg: 'HS256', typ: 'JWT' });
  const now = Math.floor(Date.now() / 1000);
  const payload = b64url({
    role,
    iss: 'supabase',
    iat: now,
    exp: now + 60 * 60 * 24 * 365 * 10,
  });
  const data = header + '.' + payload;
  const sig = crypto.createHmac('sha256', secret).update(data).digest('base64url');
  return data + '.' + sig;
}

console.log('ANON_KEY=' + sign('anon'));
console.log('SERVICE_ROLE_KEY=' + sign('service_role'));
