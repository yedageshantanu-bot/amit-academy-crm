# 🏆 Full-Stack Academy CRM + Automated WhatsApp Starter Kit (With DNA Onboarding)

This ZIP is a **100% isolated, production-ready clone** of the complete Academy CRM & ERP platform — including Frontend (React + Vite + Tailwind + PWA), Backend (Express + TypeScript), Complete 30-Table Supabase PostgreSQL Schema, PDF Receipt/Report/Certificate Generators, and Dual-Render 24/7 WhatsApp Automation Architecture.

> **🛡️ Zero-Interference Guarantee:** All live keys, session folders, and URLs from previous clients have been completely stripped. Running or deploying this starter kit will **NEVER** touch or disconnect any existing client's WhatsApp or database!

---

## ⚡ Quick Start (With Antigravity AI Onboarding)

1. **Unzip** this folder into a brand-new client directory (e.g., `Desktop/NEW_CLIENT_ACADEMY_CRM`).
2. **Open** that folder in **Antigravity** and simply type:
   ```text
   bro start crm setup
   ```
3. Antigravity will automatically read **`CRM_DNA.md`** and ask you for:
   - **1️⃣ Two Render API Keys (`rnd_...`)** — Render Account #1 (Main Backend API, 750 free hrs) + Render Account #2 (Isolated WhatsApp OpenWA Bridge, 750 free hrs)
   - **2️⃣ Fresh Supabase Keys** — `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
   - **3️⃣ Logo & Brand Details** — New Academy Name, Logo image, Address/Phone, Admin & Teacher login credentials
   - **4️⃣ Cloudflare Pages / Domain** — For instant HTTPS frontend deployment

Once you reply with those details, the AI agent automatically runs `database/COMPLETE_DATABASE_SCHEMA.sql`, rebrands the entire UI + PDFs + PWA icons, deploys both isolated Render services + Cloudflare Pages, and sets up 24/7 Keep-Alive!

---

## 📂 Folder Structure

- `CRM_DNA.md` — **Master Onboarding Questionnaire & Automated Provisioning Blueprint**
- `.agents/rules/00_MANDATORY_NEW_CRM_ONBOARDING_DNA.md` — Auto-triggered AI onboarding rule
- `.agents/skills/new-crm-onboarding/SKILL.md` — Step-by-step automated setup skill
- `database/COMPLETE_DATABASE_SCHEMA.sql` — Complete 30-table idempotent Supabase PostgreSQL schema
- `frontend/` — Full React + TypeScript + Tailwind + PWA Admin, Teacher & Student Portals
- `backend/` — Full Node.js + Express + TypeScript API, WhatsApp Queue, Watchdog & PDF Services
- `scripts/` — `keepAlive.mjs` (24/7 Dual-Render pinger) & `deploy-pages.sh` (Cloudflare Pages deployer)
