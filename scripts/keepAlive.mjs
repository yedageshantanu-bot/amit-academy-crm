/**
 * AMIT ACADEMY RATNAGIRI — 24/7 DUAL RENDER KEEP-ALIVE SCRIPT
 * Pings both isolated Render services every 2.5 minutes so they NEVER go to sleep.
 */

const PING_INTERVAL_MS = 2.5 * 60 * 1000;

const BACKEND_URL = (process.env.BACKEND_URL || 'https://amit-academy-backend.onrender.com').replace(/\/+$/, '');
const OPENWA_BRIDGE_URL = (process.env.OPENWA_API_URL || 'https://amit-academy-openwa-bridge.onrender.com').replace(/\/+$/, '');
const OPENWA_API_KEY = process.env.OPENWA_API_KEY || '';

const TARGETS = [
  { name: 'Account 1 — Amit Academy CRM Backend', url: `${BACKEND_URL}/api/health` },
  { name: 'Account 2 — Amit Academy WhatsApp OpenWA Bridge', url: `${OPENWA_BRIDGE_URL}/health` },
  ...(OPENWA_API_KEY
    ? [
        {
          name: 'OpenWA WhatsApp Session Keep-Alive',
          url: `${OPENWA_BRIDGE_URL}/api/sessions`,
          headers: { 'x-api-key': OPENWA_API_KEY },
        },
      ]
    : []),
];

async function pingAll() {
  const timestamp = new Date().toLocaleTimeString();
  console.log(`\n[${timestamp}] Pinging Amit Academy Dual Render services...`);

  for (const target of TARGETS) {
    try {
      const start = Date.now();
      const res = await fetch(target.url, {
        headers: target.headers || {},
        signal: AbortSignal.timeout(30000),
      });
      const latency = Date.now() - start;
      console.log(`[${res.status}] ${target.name} is AWAKE (${latency}ms)`);
    } catch (err) {
      console.warn(`[FAIL] ${target.name}: ${err.message}`);
    }
  }
}

pingAll();
setInterval(pingAll, PING_INTERVAL_MS);
