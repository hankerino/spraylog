# SprayLog Architecture

See README.md for overview.

## Non-negotiable Rules

1. LLM never originates regulated values - use deterministic catalogue lookup
2. No secrets in Flutter client - only SUPABASE_URL and SUPABASE_ANON_KEY
3. Applications immutable once signed - use amendments table
4. Offline-first - all writes work without network
5. Tenant isolation via RLS, not client filtering
6. No compliance guarantees in copy

## Build Order

M1: Skeleton (auth, onboarding, RLS, drift)
M2: Core loop (record → confirm → sign → sync)
M3: Voice (STT, extraction)
M4: Catalogue & validation
M5: Notices, history, export
M6: Billing
