/**
 * Cloudflare Worker holding the two secrets that must never ship inside the
 * app, and doing nothing else:
 *
 *   POST /  or /push   relay a push notification to FCM
 *   POST /delete       delete one Cloudinary asset
 *
 * Both APIs require a signed request (service account for FCM, api_secret for
 * Cloudinary); a key inside an APK/IPA can be extracted by anyone.
 *
 * Secrets to set (wrangler secret put <NAME>):
 *   FIREBASE_PROJECT_ID     e.g. tr397-gpscam
 *   FIREBASE_CLIENT_EMAIL   from the service-account JSON
 *   FIREBASE_PRIVATE_KEY    from the service-account JSON (keep the \n escapes)
 *   FIREBASE_WEB_API_KEY    Project settings > General > Web API Key
 *   CLOUDINARY_CLOUD_NAME   e.g. hyqcgkdz
 *   CLOUDINARY_API_KEY      Cloudinary dashboard
 *   CLOUDINARY_API_SECRET   Cloudinary dashboard
 */

const FCM_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

function base64url(input) {
  const bytes = typeof input === 'string' ? new TextEncoder().encode(input) : new Uint8Array(input);
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function importPrivateKey(pem) {
  const body = pem
    .replace(/\\n/g, '\n')
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '');
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

/** Exchange the service account for a short-lived FCM access token. */
async function getAccessToken(env) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claim = base64url(
    JSON.stringify({
      iss: env.FIREBASE_CLIENT_EMAIL,
      scope: FCM_SCOPE,
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
    }),
  );

  const key = await importPrivateKey(env.FIREBASE_PRIVATE_KEY);
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(`${header}.${claim}`),
  );
  const jwt = `${header}.${claim}.${base64url(signature)}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  const json = await response.json();
  if (!json.access_token) throw new Error(`token exchange failed: ${JSON.stringify(json)}`);
  return json.access_token;
}

/** Resolve a Firebase ID token to a uid, or null when it is not valid. */
async function uidFromIdToken(idToken, env) {
  if (!idToken) return null;
  try {
    const response = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${env.FIREBASE_WEB_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idToken }),
      },
    );
    if (!response.ok) return null;
    const json = await response.json();
    return json.users?.[0]?.localId ?? null;
  } catch {
    return null;
  }
}

async function sha1Hex(input) {
  const digest = await crypto.subtle.digest('SHA-1', new TextEncoder().encode(input));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

/**
 * The app only ever uploads to `shared_media/<uid>/<mediaId>` (media) or
 * `avatars/<uid>` (profile picture). Deriving ownership from the public_id
 * means the Worker trusts nothing the client says about who owns what.
 */
function ownsPublicId(publicId, uid) {
  return publicId.startsWith(`shared_media/${uid}/`) || publicId === `avatars/${uid}`;
}

async function handlePush(payload, env) {
  const tokens = Array.isArray(payload.tokens) ? payload.tokens.slice(0, 20) : [];
  if (tokens.length === 0) return new Response('no tokens', { status: 400 });

  const accessToken = await getAccessToken(env);
  const endpoint = `https://fcm.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/messages:send`;

  // FCM v1 sends to one token per call.
  const results = await Promise.all(
    tokens.map((token) =>
      fetch(endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token,
            notification: {
              title: payload.title ?? 'New location',
              body: payload.body ?? '',
            },
            data: payload.data ?? {},
            android: { priority: 'HIGH' },
            apns: { payload: { aps: { sound: 'default' } } },
          },
        }),
      }).then((r) => r.status),
    ),
  );

  return Response.json({ sent: results.filter((s) => s === 200).length, statuses: results });
}

async function handleDelete(request, payload, env) {
  const authHeader = request.headers.get('Authorization') ?? '';
  const idToken = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

  const uid = await uidFromIdToken(idToken, env);
  if (!uid) return new Response('unauthorized', { status: 401 });

  const publicId = payload.publicId;
  if (typeof publicId !== 'string' || publicId.length === 0) {
    return new Response('publicId required', { status: 400 });
  }
  if (!ownsPublicId(publicId, uid)) {
    return new Response('forbidden', { status: 403 });
  }

  const resourceType = payload.resourceType === 'video' ? 'video' : 'image';
  const timestamp = Math.floor(Date.now() / 1000);
  // Cloudinary signs the alphabetically sorted params plus the api_secret.
  const signature = await sha1Hex(
    `public_id=${publicId}&timestamp=${timestamp}${env.CLOUDINARY_API_SECRET}`,
  );

  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${env.CLOUDINARY_CLOUD_NAME}/${resourceType}/destroy`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        public_id: publicId,
        api_key: env.CLOUDINARY_API_KEY,
        timestamp: `${timestamp}`,
        signature,
      }),
    },
  );

  const result = await response.json();
  // Cloudinary answers 200 with {result: "not found"} for an unknown id.
  return Response.json({ result: result.result ?? 'unknown' }, { status: response.ok ? 200 : 502 });
}

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('POST only', { status: 405 });
    }

    let payload;
    try {
      payload = await request.json();
    } catch {
      return new Response('invalid json', { status: 400 });
    }

    const path = new URL(request.url).pathname.replace(/\/$/, '');
    if (path === '/delete') return handleDelete(request, payload, env);
    if (path === '' || path === '/push') return handlePush(payload, env);
    return new Response('not found', { status: 404 });
  },
};
