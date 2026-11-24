/**
 * ACADEMY CRM — 24/7 DUAL RENDER KEEP-ALIVE SCRIPT
 * Pings both isolated Render services every 2.5 minutes so they NEVER go to sleep.
 * Values are populated during CRM DNA Onboarding (or via environment variables).
 */

const PING_INTERVAL_MS = 2.5 * 60 * 1000;

const BACKEND_URL = (process.env.BACKEND_URL || 'https://YOUR_BACKEND_SERVICE.onrender.com').replace(/\/+$/, '');
const OPENWA_BRIDGE_URL = (process.env.OPENWA_API_URL || 'https://YOUR_OPENWA_BRIDGE_SERVICE.onrender.com').replace(/\/+$/, '');
const OPENWA_API_KEY = process.env.OPENWA_API_KEY || 'YOUR_NEW_UNIQUE_OPENWA_MASTER_KEY';

const TARGETS = [
  { name: 'Account 1 — Dedicated CRM Backend', url: `${BACKEND_URL}/api/health` },
  { name: 'Account 2 — WhatsApp OpenWA Bridge Health', url: `${OPENWA_BRIDGE_URL}/health` },
  {
    name: 'OpenWA WhatsApp Session Keep-Alive',
    url: `${OPENWA_BRIDGE_URL}/api/sessions`,
    headers: { 'x-api-key': OPENWA_API_KEY }
  }
];

async function pingAll() {
  if (BACKEND_URL.includes('YOUR_BACKEND_SERVICE')) {
    console.warn('⚠️ Configure BACKEND_URL, OPENWA_API_URL, and OPENWA_API_KEY via CRM_DNA.md onboarding before running keepAlive.mjs.');
    return;
  }
  const timestamp = new Date().toLocaleTimeString();
  console.log(`\n[${timestamp}] 📡 Pinging Dual Render services...`);

  for (const target of TARGETS) {
    try {
      const start = Date.now();
      const res = await fetch(target.url, {
        headers: target.headers || {},
        signal: AbortSignal.timeout(30000)
      });
      const latency = Date.now() - start;
      console.log(`✅ [${res.status}] ${target.name} is AWAKE (${latency}ms)`);
    } catch (err) {
      console.warn(`⚠️ [FAIL] ${target.name}: ${err.message}`);
    }
  }
}

pingAll();
setInterval(pingAll, PING_INTERVAL_MS);
