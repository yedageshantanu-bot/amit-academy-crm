# ⚠️ MANDATORY RULE: PROTECT CLIENT PRODUCTION SUPABASE & WHATSAPP ISOLATION

## Target Instance (Amit Academy, Ratnagiri):
- **Project URL:** `https://wizoagboghswaykexgsd.supabase.co`
- **Client Organization:** `Amit Academy, Ratnagiri`

## STRICT INSTRUCTIONS FOR ALL AGENTS:
1. **100% ISOLATION FROM OTHER CLIENTS:** NEVER connect to or reuse any other client's Supabase project (`litnduotmypvhnorjnwa` is STRICTLY FORBIDDEN) or any other client's WhatsApp OpenWA Bridge (`gurukul-openwa-bridge-a0m4.onrender.com` is STRICTLY FORBIDDEN). Connecting to an existing client's bridge or database will disconnect their live WhatsApp session!
2. **NEVER DROP, TRUNCATE, OR OVERWRITE** production tables, functions, or data once live unless explicitly authorized by the user.
3. Any migration or schema change MUST be non-destructive (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`).
