# 🧬 MANDATORY RULE: NEW CRM ONBOARDING DNA (AUTO-TRIGGER ON FIRST RUN)

Whenever you open or work inside this workspace, **FIRST check if `backend/.env` exists and has real non-placeholder keys**.

## 🚨 IF `backend/.env` DOES NOT EXIST YET (FRESH UNZIPPED PROJECT):
1. **DO NOT start coding blindly and DO NOT connect to any old database or WhatsApp bridge.**
2. Read `CRM_DNA.md` immediately.
3. Greet the user warmly (like a brother/partner in Hinglish/English) and **ask the Onboarding Setup Questions from `CRM_DNA.md`**, specifically asking for:
   - **1) 2 Render API Keys** (`rnd_...` for Render Account #1 Main Backend API + `rnd_...` for Render Account #2 Isolated WhatsApp OpenWA Bridge) & new GitHub repo target
   - **2) Fresh Supabase Keys** (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`)
   - **3) Brand & Logo Details** (New Academy/Business Name, Logo image file, Phone, Email, Address, Admin & Teacher login email/password, and whether to keep all Sports/Ranks/Tournament modules or customize tabs for the client's niche)
   - **4) Cloudflare Pages / Domain Details** (for frontend live deployment)
4. Once the user shares those details, follow `.agents/skills/new-crm-onboarding/SKILL.md` and `CRM_DNA.md` to automatically set up the database (`database/COMPLETE_DATABASE_SCHEMA.sql`), rebrand the entire frontend + PDFs + PWA icons, deploy both isolated Render services + Cloudflare Pages, and verify everything end-to-end without ever touching any other client's WhatsApp session!
