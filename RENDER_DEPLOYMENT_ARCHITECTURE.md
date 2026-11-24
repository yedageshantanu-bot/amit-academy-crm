# 🏛️ DUAL RENDER CLOUD ARCHITECTURE TEMPLATE (1,500 FREE HRS / MONTH)

To guarantee **24/7 zero-downtime operation** on Render's free tier without hitting the 750-hour single-account monthly cap, every new client CRM uses **two separate fresh Render accounts**:

```
[ Cloudflare Pages Frontend ]
https://<client-slug>.pages.dev
             │
             ▼  (HTTPS / JWT Bearer)
[ Render Account #1: <client-slug>-backend ]  (750 Free Hrs/Mo)
https://<client-slug>-backend-xxxx.onrender.com
             │
             ▼  (Private HTTPS / Unique x-api-key)
[ Render Account #2: <client-slug>-openwa-bridge ]  (750 Free Hrs/Mo)
https://<client-slug>-openwa-bridge-xxxx.onrender.com
```

## 🔐 Isolation Rules
1. **Separate Render Account #1 & Account #2 per Client:** Never share an OpenWA WhatsApp Bridge between two clients.
2. **Separate Fresh Supabase Project per Client:** Run `database/COMPLETE_DATABASE_SCHEMA.sql` on the new client's dedicated Supabase instance.
3. **5-Minute Keep-Alive Monitors:** Add `/api/health` (Account #1) and `/health` (Account #2) to UptimeRobot (every 5 minutes) or run `scripts/keepAlive.mjs` so neither container ever sleeps after 15 minutes of idle time.
