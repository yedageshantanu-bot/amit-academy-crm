# 🧬 CRM_DNA.md — MASTER ONBOARDING & AUTONOMOUS PROVISIONING BLUEPRINT

> **FOR AI AGENTS (ANTIGRAVITY / CURSOR / CLAUDE CODE):**
> Whenever the user opens this repository to launch a new CRM for a new client/academy, **STOP before writing or deploying anything** and check whether `backend/.env` and `frontend/.env` are configured for the new client.
> If they are NOT configured yet, **immediately greet the user and ask the Mandatory Onboarding Questions below** (grouped cleanly so the user can answer easily). Once the user provides the answers, execute the **Automated End-to-End Provisioning Pipeline** without breaking or touching any other client's CRM!

---

## 🛡️ GOLDEN ISOLATION GUARANTEE (NEVER VIOLATE)
1. **100% Isolated WhatsApp Gateway:** Every client CRM MUST run its own dedicated WhatsApp OpenWA/Baileys Bridge on its own Render Account #2 with a freshly generated `OPENWA_API_KEY` and its own fresh Supabase project.
2. **NEVER Reuse Keys/URLs:** NEVER connect to `litnduotmypvhnorjnwa.supabase.co`, `gurukul-openwa-bridge-a0m4.onrender.com`, or `gurukul-sports-backend-ll86.onrender.com`. Doing so would hijack or disconnect an existing live client's WhatsApp session!

---

## 📋 MANDATORY INTERACTIVE ONBOARDING QUESTIONS (ASK USER FIRST)

When starting work on this cloned CRM, ask the user for these **4 quick blocks of inputs** (in Hinglish/English as preferred by the user):

### Block 1️⃣ — Dual Render Cloud API Keys (1,500 Free Hrs/Month Zero-Downtime Setup)
Ask the user:
1. **Render Account #1 API Key (`rnd_...`)** *(Dedicated 750 hrs/month for Main CRM Backend Express API)* + GitHub repo URL (or ask if we should create/push to a new GitHub repo).
2. **Render Account #2 API Key (`rnd_...`)** *(Dedicated 750 hrs/month for Isolated WhatsApp OpenWA/Baileys Bridge — deploys `https://github.com/rmyndharis/OpenWA` Docker service)*.

### Block 2️⃣ — Fresh Supabase Database Keys (Isolated Cloud PostgreSQL)
Ask the user to create a **brand-new Supabase project** and share:
1. **`SUPABASE_URL`** *(e.g. `https://abcdefghijklm.supabase.co`)*
2. **`SUPABASE_ANON_KEY`** *(Public anon JWT key)*
3. **`SUPABASE_SERVICE_ROLE_KEY`** *(Secret service_role JWT key)*
4. *(Optional)* **Supabase Personal Access Token (`sbp_...`) or DB Password** — if provided, run `database/COMPLETE_DATABASE_SCHEMA.sql` automatically via CLI/API; otherwise give the user the 1-click copy-paste instruction for Supabase SQL Editor!

### Block 3️⃣ — Brand Identity, Logo & Login Credentials
Ask the user:
1. **Academy / Institute / Business Name** *(e.g. "Apex Sports Academy" / "Shree Coaching Classes")* & **Short Tagline**
2. **Logo Image** *(Ask user to drop/attach their logo file so you can replace `frontend/public/logo.png`, `icon-192.png`, `icon-512.png`, and `favicon.svg`)*
3. **Contact Details** *(Official Phone/WhatsApp, Email, Full Address, City/State, Website/Domain)*
4. **Admin & Teacher Login Credentials** to seed:
   - Admin Email & Password *(e.g. `admin@clientdomain.in` / `Admin@2026!`)*
   - Default Coach/Teacher Name, Email & Password
5. **Feature Modules Customization** *(Ask: Do you want all modules kept as-is — Students, Batches, Attendance + WhatsApp Alerts, Fees/Receipts, Announcements + Scheduled Broadcasts, Team Messaging, Ranks/Certificates, Tournaments, Publications — or hide/rename any sport-specific tabs for this niche?)*

### Block 4️⃣ — Frontend Hosting (Cloudflare Pages / Custom Domain)
Ask the user:
1. **Cloudflare API Token & Account ID** *(or desired project slug like `new-client-crm.pages.dev`, or custom domain)*.

---

## ⚙️ AUTOMATED PROVISIONING PIPELINE (WHAT THE AGENT EXECUTES AFTER ANSWERS)

Once the user answers the questions above, execute these steps in order:

### Step 1: Generate Unique Secrets & Write `.env` Files
- Generate a fresh random 48-char secret for `OPENWA_API_KEY` (e.g., `<client_slug>_openwa_secret_2026_<random_hex>`).
- Populate `backend/.env`, `frontend/.env`, `render.yaml`, `scripts/keepAlive.mjs`, `scripts/deploy-pages.sh`, and `.agents/rules/PROTECT_CLIENT_SUPABASE.md`.

### Step 2: Initialize Complete Database Schema & Auth Users on Fresh Supabase
- Execute `database/COMPLETE_DATABASE_SCHEMA.sql` (creates all **30 tables**, indexes, RLS policies, default WhatsApp settings & message templates).
- Insert the client's `academy_settings` row (Academy Name, Logo `/logo.png`, Phone, Email, Address, Website).
- Create initial Admin and Teacher users via `supabase.auth.admin.createUser({ email_confirm: true })` and insert matching rows into `public.profiles` and `public.teachers`.

### Step 3: Rebrand Frontend, PWA & PDF Generators
- Replace `frontend/public/logo.png`, `icon-192.png`, `icon-512.png`, `favicon.svg`.
- Update Academy Name & metadata in:
  - `frontend/index.html` (`<title>`, `apple-mobile-web-app-title`, splash loader text)
  - `frontend/public/manifest.webmanifest` (`name`, `short_name`)
  - PDF Receipt / Progress Report / Certificate headers (`frontend/functions/api/[[path]].ts`, `frontend/src/utils/certificatePdfGenerator.ts`, `backend/src/services/tournament.service.ts`, `backend/src/services/publication.service.ts`).

### Step 4: Provision Dual Render Services (Account #1 + Account #2)
1. **Using Render Account #2 API Key (`rnd_...`):**
   - Create Docker Web Service `<client-slug>-openwa-bridge` from `https://github.com/rmyndharis/OpenWA` (`main` branch).
   - Set Env Vars:
     - `PORT=2785`
     - `ENGINE_TYPE=baileys`
     - `DATABASE_TYPE=sqlite`
     - `AUTO_START_SESSIONS=true`
     - `STORAGE_TYPE=local`
     - `API_MASTER_KEY=<generated_unique_openwa_secret>`
     - `CORS_ORIGIN=*`
   - Capture live Bridge URL: `https://<client-slug>-openwa-bridge-xxxx.onrender.com`.
2. **Using Render Account #1 API Key (`rnd_...`):**
   - Push clean client repo to client's NEW GitHub repository.
   - Create Node Web Service `<client-slug>-backend` (`rootDir: backend`, `buildCommand: npm install --include=dev && npm run build`, `startCommand: npm start`).
   - Set Env Vars: `NODE_ENV=production`, `PORT=10000`, `APP_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `WHATSAPP_PROVIDER=openwa`, `OPENWA_API_URL`, `OPENWA_API_KEY`, `WHATSAPP_LINKED_DEVICE_URL`, `WHATSAPP_LINKED_DEVICE_TOKEN`, `WHATSAPP_DAILY_LIMIT=100`.
   - Capture live Backend URL: `https://<client-slug>-backend-xxxx.onrender.com`.

### Step 5: Build & Deploy Frontend to Cloudflare Pages + Configure 24/7 Keep-Alive
- Set `VITE_API_BASE_URL=https://<client-slug>-backend-xxxx.onrender.com`, `VITE_SUPABASE_URL`, and `VITE_SUPABASE_ANON_KEY` in `frontend/.env`.
- Run `npm install && npm run build` in `frontend/` and deploy `dist/` via Wrangler to Cloudflare Pages (`<client-slug>.pages.dev`).
- Update `APP_URL` on Render Account #1 and `ALLOWED_ORIGINS` on Render Account #2 with the live `.pages.dev` URL.
- Update `scripts/keepAlive.mjs` and provide the 2 exact UptimeRobot 5-minute health URLs:
  - Monitor 1: `https://<client-slug>-backend-xxxx.onrender.com/api/health`
  - Monitor 2: `https://<client-slug>-openwa-bridge-xxxx.onrender.com/health`
- Verify `/api/health`, login flow, and WhatsApp QR pairing screen, then deliver the final Hindi Audio Report!
