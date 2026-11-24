---
name: new-crm-onboarding
description: Mandatory onboarding and automated deployment workflow when setting up a new client CRM from this starter template. Interviews the user for 2 Render API keys, fresh Supabase keys, Logo & Academy branding, and deploys the isolated full-stack CRM + WhatsApp bridge end-to-end.
---

# 🚀 New Client CRM Onboarding Skill

## When to Use
Use this skill immediately whenever `backend/.env` is missing or contains `YOUR_PROJECT_REF`, or whenever the user says "setup new CRM", "start onboarding", "naya client CRM banana hai", etc.

## Step-by-Step Procedure

### Phase 1: Interactive Intake Interview
Read `CRM_DNA.md` and ask the user for:
1. **Render Account #1 API Key (`rnd_...`)** — Main Backend API (750 free hrs/mo)
2. **Render Account #2 API Key (`rnd_...`)** — Isolated WhatsApp OpenWA Bridge (750 free hrs/mo)
3. **Fresh Supabase Credentials** — `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
4. **Branding & Assets** — Academy/Institute Name, Logo file (`logo.png`), Phone, Email, Address, Admin Email/Password, Teacher Name/Email/Password, and module preferences (Sports/Martial Arts vs General Coaching/Gym).
5. **Cloudflare Pages / GitHub** — New GitHub repo name & Cloudflare Account ID / API Token (if deploying live immediately).

### Phase 2: Strict Isolation Check
- Verify the provided `SUPABASE_URL` is a **brand-new** project (NEVER `litnduotmypvhnorjnwa.supabase.co`).
- Generate a brand-new cryptographic secret for `OPENWA_API_KEY` so the WhatsApp bridge is 100% isolated.

### Phase 3: Database & Auth Provisioning
1. Run `database/COMPLETE_DATABASE_SCHEMA.sql` against the new Supabase project.
2. Seed `public.academy_settings` with the new client's name, phone, email, address, website, and `/logo.png`.
3. Create the Admin & Teacher accounts via Supabase Auth Admin API (`email_confirm: true`) and link them in `public.profiles` and `public.teachers`.

### Phase 4: Full Rebranding
1. Copy the client's logo into `frontend/public/logo.png`, `frontend/public/icon-192.png`, `frontend/public/icon-512.png`, and `frontend/public/favicon.svg`.
2. Replace "Gurukul Sports Academy" across `frontend/index.html`, `frontend/public/manifest.webmanifest`, `frontend/src/**`, `frontend/functions/api/[[path]].ts`, and `backend/src/**` with the new client's Academy Name!

### Phase 5: Dual-Render + Cloudflare Deployment & Verification
1. Provision `<slug>-openwa-bridge` on Render Account #2 (`https://github.com/rmyndharis/OpenWA`, port `2785`, `ENGINE_TYPE=baileys`, `API_MASTER_KEY=<secret>`).
2. Provision `<slug>-backend` on Render Account #1 pointing to the new Supabase + Account #2 Bridge URL.
3. Build `frontend` with `VITE_API_BASE_URL`, `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` and deploy to Cloudflare Pages.
4. Update `scripts/keepAlive.mjs` and give the user the 2 UptimeRobot `/health` monitor URLs + Hindi Audio Status Report!
