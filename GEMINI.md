# 🧬 AI AGENT ENTRYPOINT — READ `CRM_DNA.md` FIRST!

**MANDATORY INSTRUCTION FOR ANTIGRAVITY / GEMINI / CLAUDE / CURSOR:**
1. Before taking ANY action in this project, check if `backend/.env` exists with real client credentials.
2. If `backend/.env` does NOT exist yet, **STOP and read `CRM_DNA.md` and `.agents/rules/00_MANDATORY_NEW_CRM_ONBOARDING_DNA.md` immediately!**
3. Ask the user the **Mandatory Onboarding Questions** in `CRM_DNA.md`:
   - **2 Render API Keys** (`rnd_...` for Account #1 Backend API + `rnd_...` for Account #2 Isolated WhatsApp OpenWA Bridge)
   - **Fresh Supabase Keys** (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`)
   - **Academy Name, Logo (`logo.png`), Contact Details, Admin/Teacher Login Emails & Passwords, and Module Preferences**
   - **Cloudflare Pages / Domain Details**
4. **STRICT ISOLATION:** Never reuse any other client's Supabase project or WhatsApp OpenWA Bridge URL/Key! Always provision a fresh isolated database (`database/COMPLETE_DATABASE_SCHEMA.sql`) and isolated WhatsApp gateway so no existing client's WhatsApp ever disconnects.
