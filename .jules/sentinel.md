## 2026-06-29 - [Secrets & Supply Chain Security]
**Vulnerability:** Hardcoded Supabase credentials and use of 'latest' Docker tag.
**Learning:** Hardcoded credentials in `src/lib/supabase.ts` were used as fallbacks, posing a leak risk. The 'latest' Docker tag introduced supply chain risk and potential for non-deterministic builds. Absolute binary paths in `start.sh` caused deployment failures on Render.
**Prevention:** 1. Enforce environment variable usage with runtime checks. 2. Pin Docker images by sha256 digest. 3. Use system PATH for binaries in container entrypoints to ensure compatibility across image versions.
