# SprayLog — Architecture Specification v1.0

**Audience:** development agents. Read fully before writing code.
**Product:** voice-first pesticide application recordkeeping for small US applicators (lawn care, turf, pest control).
**Stack:** Flutter/Dart client, Supabase (Postgres + Auth + Edge Functions + Storage) backend.
**UX brief:** deliberately plain. Function over polish. Visual design will be reworked later with Kimi K.3 — do not invest in animation, custom theming, or bespoke components now. Use Material 3 defaults.

---

## 0. Non-negotiable rules

These are correctness requirements, not preferences. Violating any of them is a blocking defect.

1. **The LLM never originates a regulated value.** It proposes candidate fields from a transcript. EPA registration numbers, product identity, and legal maximum rates are resolved exclusively by deterministic lookup against the `products` table. If a spoken product name does not match above the confidence threshold, the flow stops and the user picks from a list.
2. **No secret keys in the Flutter client.** Only `SUPABASE_URL` and `SUPABASE_ANON_KEY` ship in the app. Every third-party API key lives in Supabase Edge Function secrets.
3. **Applications are immutable once signed.** Corrections insert into `amendments`. Never `UPDATE` a signed row. Never `DELETE`.
4. **Offline is the default.** Every write path must work with no network and sync later. Techs work in basements, crawlspaces, and rural properties.
5. **Tenant isolation is enforced by RLS in Postgres**, not by client-side filtering. Assume the client is hostile.
6. **No compliance guarantee anywhere in copy.** The product creates and retains records; the licensee remains responsible for accuracy.

---

## 1. Repository layout

```
spraylog/
├── app/                          # Flutter client (iOS, Android, Web)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── config/           # env reading, feature flags
│   │   │   ├── db/               # drift schema, DAOs, migrations
│   │   │   ├── sync/             # outbox queue, conflict policy
│   │   │   ├── result.dart       # Result<T, E> type, no exceptions across layers
│   │   │   └── errors.dart
│   │   ├── data/
│   │   │   ├── models/           # freezed models, json_serializable
│   │   │   ├── repositories/     # one per aggregate, local-first
│   │   │   └── remote/           # supabase client wrappers
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── record/           # voice capture + confirm (the core loop)
│   │   │   ├── history/
│   │   │   ├── customers/
│   │   │   ├── products/
│   │   │   ├── billing/
│   │   │   └── settings/
│   │   └── app.dart              # router, theme, providers
│   └── test/
├── supabase/
│   ├── migrations/               # numbered SQL, forward-only
│   ├── functions/                # Deno edge functions
│   │   ├── extract-application/
│   │   ├── validate-application/
│   │   ├── fetch-weather/
│   │   ├── send-notice/
│   │   ├── generate-export/
│   │   └── revenuecat-webhook/
│   └── seed/                     # product catalogue seed data
└── docs/
```

**Conventions**

| Item | Rule |
|---|---|
| State management | Riverpod (`flutter_riverpod`), code-generated providers |
| Local DB | `drift` over SQLite |
| Models | `freezed` + `json_serializable` |
| Routing | `go_router`, declarative, deep-link ready |
| Errors | `Result<T, AppError>`; no exceptions crossing layer boundaries |
| Naming | snake_case in Postgres and JSON, camelCase in Dart, mapped at the model boundary |
| Time | Store UTC everywhere; render in the company's local timezone |
| IDs | UUID v4 generated client-side so offline records have stable identity |

---

## 2. Data model

Forward-only migrations in `supabase/migrations/`. Every tenant-scoped table carries `company_id` and has RLS enabled.

```sql
-- ---------- tenancy ----------
create table companies (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  operating_states  text[] not null default '{}',   -- ['FL','TX']
  timezone          text not null default 'America/New_York',
  plan              text not null default 'trial',  -- trial|solo|crew|multistate
  plan_status       text not null default 'trialing',
  trial_ends_at     timestamptz,
  created_at        timestamptz not null default now()
);

create table profiles (                              -- 1:1 with auth.users
  id                uuid primary key references auth.users(id) on delete cascade,
  company_id        uuid not null references companies(id) on delete cascade,
  full_name         text not null,
  role              text not null default 'applicator', -- owner|admin|applicator
  license_number    text,
  license_state     text,
  license_categories text[] default '{}',
  license_expires_at date,
  created_at        timestamptz not null default now()
);

-- ---------- customers & sites ----------
create table customers (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  name          text not null,
  phone         text,
  email         text,
  notify_via    text not null default 'sms',   -- sms|email|none
  notify_consent_at timestamptz,
  archived      boolean not null default false,
  created_at    timestamptz not null default now()
);

create table sites (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  customer_id   uuid not null references customers(id) on delete cascade,
  label         text not null,                 -- 'Front lawn', 'Kitchen perimeter'
  address       text,
  state         text not null,
  lat           double precision,
  lng           double precision,
  area_value    numeric,
  area_unit     text default 'sqft',           -- sqft|acre|linear_ft
  sensitive_flags text[] default '{}',         -- well|pond|school|beehive|pets|edible_garden
  created_at    timestamptz not null default now()
);

-- ---------- product catalogue (global, not tenant-scoped) ----------
create table products (
  id                 uuid primary key default gen_random_uuid(),
  epa_reg_no         text not null unique,
  brand_name         text not null,
  brand_aliases      text[] default '{}',      -- drives fuzzy voice matching
  registrant         text,
  formulation        text,                     -- EC|SC|WG|G|RTU
  signal_word        text,                     -- CAUTION|WARNING|DANGER
  active_ingredients jsonb not null,           -- [{name, pct}]
  rei_hours          numeric,
  phi_days           numeric,
  restricted_use     boolean not null default false,
  label_url          text,
  updated_at         timestamptz not null default now()
);

create table product_rates (                    -- label maxima, per site type
  id            uuid primary key default gen_random_uuid(),
  product_id    uuid not null references products(id) on delete cascade,
  site_type     text not null,                 -- turf|ornamental|structural|right_of_way
  target_pest   text,
  max_rate_value numeric not null,
  max_rate_unit text not null,                 -- oz_per_1000sqft|lb_per_acre|pct_solution
  notes         text
);

create table product_state_registrations (
  product_id    uuid not null references products(id) on delete cascade,
  state         text not null,
  status        text not null default 'active', -- active|cancelled
  primary key (product_id, state)
);

-- ---------- the record ----------
create table applications (
  id                uuid primary key,           -- client-generated
  company_id        uuid not null references companies(id) on delete cascade,
  applicator_id     uuid not null references profiles(id),
  customer_id       uuid references customers(id),
  site_id           uuid references sites(id),
  state             text not null,

  applied_at        timestamptz not null,       -- specific time of day is required
  product_id        uuid not null references products(id),
  epa_reg_no        text not null,              -- denormalised: frozen at time of record
  brand_name        text not null,
  rate_value        numeric not null,
  rate_unit         text not null,
  total_amount_value numeric,
  total_amount_unit text,
  area_value        numeric not null,
  area_unit         text not null,
  target_pest       text,
  application_method text,                      -- broadcast|spot|perimeter|drench|granular

  lat               double precision,
  lng               double precision,
  temp_f            numeric,
  wind_mph          numeric,
  wind_direction    text,
  weather_source    text,

  transcript        text,
  extraction_model  text,
  extraction_confidence numeric,
  rate_flag         text,                       -- null|over_label|unregistered_in_state
  override_reason   text,

  signed_at         timestamptz,
  signed_by         uuid references profiles(id),
  prev_hash         text,
  record_hash       text,                       -- sha256 over canonical payload + prev_hash

  created_at        timestamptz not null default now()
);

create index on applications (company_id, applied_at desc);
create index on applications (company_id, applicator_id, applied_at desc);

create table amendments (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  application_id uuid not null references applications(id),
  field_name     text not null,
  old_value      text,
  new_value      text,
  reason         text not null,
  author_id      uuid not null references profiles(id),
  created_at     timestamptz not null default now()
);

create table application_photos (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  application_id uuid not null references applications(id) on delete cascade,
  storage_path   text not null,
  lat            double precision,
  lng            double precision,
  taken_at       timestamptz not null
);

create table notices (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  application_id uuid not null references applications(id),
  channel        text not null,               -- sms|email
  destination    text not null,
  body           text not null,
  sent_at        timestamptz,
  delivery_status text,
  provider_id    text
);

create table exports (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  requested_by   uuid not null references profiles(id),
  state          text not null,
  template_key   text not null,
  range_start    date not null,
  range_end      date not null,
  format         text not null,               -- pdf|csv
  storage_path   text,
  created_at     timestamptz not null default now()
);

create table audit_log (
  id          bigserial primary key,
  company_id  uuid,
  actor_id    uuid,
  action      text not null,
  entity      text not null,
  entity_id   text,
  metadata    jsonb,
  created_at  timestamptz not null default now()
);
```

### RLS pattern

Apply to every tenant-scoped table. `products`, `product_rates`, and `product_state_registrations` are readable by all authenticated users and writable only by the service role.

```sql
alter table applications enable row level security;

create or replace function current_company_id() returns uuid
language sql stable security definer as $$
  select company_id from profiles where id = auth.uid()
$$;

create policy tenant_read on applications
  for select using (company_id = current_company_id());

create policy tenant_insert on applications
  for insert with check (company_id = current_company_id());

-- deliberately no UPDATE or DELETE policy: signed records are immutable
```

Add a trigger that rejects any `UPDATE` where `signed_at is not null`, so a future policy mistake cannot silently permit edits.

---

## 3. The core loop

This is the only screen flow that matters. Optimise it and measure it. **Target: under 30 seconds from tapping record to a signed record.**

```
Home ──▶ [hold mic] ──▶ on-device STT ──▶ transcript
                                            │
                                            ▼
                              POST extract-application (edge fn)
                                            │  candidate fields JSON
                                            ▼
                              deterministic resolve + validate
                              (product match, rate check, state check)
                                            │
                                            ▼
                                   Confirm screen (single page)
                                   auto-filled: GPS, time, applicator,
                                   customer/site, weather
                                            │
                                     [tap any field to fix]
                                            ▼
                                    Sign ──▶ hash ──▶ local write
                                            │
                                      outbox sync ──▶ Supabase
                                            │
                                            ▼
                                    send-notice (edge fn)
```

**Degradation rules**

- No network at extraction time → store the raw transcript, mark `pending_extraction`, and present a manual entry form pre-filled with anything the on-device parser could infer. Re-run extraction on sync.
- Confidence below `0.75` on product match → force a picker. Never guess.
- Rate above label maximum → hard block with an override path that requires a typed reason, stored in `override_reason`.
- Product not registered in the site's state → same treatment.

### Extraction contract

Edge function `extract-application` calls the Anthropic API with `temperature: 0` and a strict schema. It returns **candidates only**.

```json
{
  "spoken_product": "dimension two E W",
  "rate_value": 1.5,
  "rate_unit": "oz_per_1000sqft",
  "area_value": 6500,
  "area_unit": "sqft",
  "target_pest": "crabgrass",
  "application_method": "broadcast",
  "site_hint": "front and back lawn",
  "temp_f": 74,
  "wind_mph": 5,
  "wind_direction": "W",
  "confidence": 0.91,
  "unparsed_remainder": ""
}
```

The function must **not** return `epa_reg_no`, `product_id`, or any legality judgement. Resolution happens in `validate-application` against the catalogue.

---

## 4. Screens

Keep every screen to one job. Material 3 defaults, no custom theme yet.

| Route | Screen | Contents |
|---|---|---|
| `/auth` | Sign in | Email + password, magic link fallback |
| `/onboarding` | Company setup | Company name, operating states, first applicator licence |
| `/` | Home | Big record button, today's records, sync status chip, offline banner |
| `/record` | Capture | Hold-to-talk, live transcript, cancel, manual entry link |
| `/record/confirm` | Confirm | All fields in one scroll, tap-to-edit, flags in red, Sign button |
| `/history` | History | Filter by date, applicator, customer, product. Infinite list |
| `/history/:id` | Record detail | Read-only, amendments list, photos, notice status, Amend button |
| `/customers` | Customers | List, search, add. Nested sites |
| `/settings` | Settings | Applicators + licences with expiry warnings, states, plan, export data |
| `/export` | Export | Date range, state, format, generate. Web-first, mobile allowed |

**Office web view** is the same Flutter codebase compiled for web with `/history` and `/export` as the primary routes. Do not build a separate frontend.

---

## 5. Sync

Local-first with an outbox. Records never wait on the network.

- All writes go to drift first, then enqueue into `outbox(id, entity, op, payload, attempts, next_attempt_at)`.
- A background isolate drains the outbox with exponential backoff, capped at 15 minutes.
- Conflict policy: signed applications are append-only, so there are no update conflicts by construction. Customers and sites use last-write-wins on `updated_at`.
- Catalogue tables pull down on login and refresh weekly, scoped to `companies.operating_states`. Ship a seeded subset with the app binary so first-run works offline.
- Surface sync state honestly in the UI: a count of unsynced records, never a silent failure.

---

## 6. Subscriptions

**Mobile must use native in-app purchase.** Use RevenueCat to wrap App Store and Play Billing. Web/office checkout uses Stripe. RevenueCat is the source of truth; a webhook writes entitlement state to `companies.plan` and `companies.plan_status`.

| Plan | Product ID | Price | Applicators | States | Notes |
|---|---|---|---|---|---|
| Trial | — | free, 14 days | 3 | 1 | No card required |
| Solo | `spraylog_solo_monthly` | $99/mo | 3 | 1 | |
| Crew | `spraylog_crew_monthly` | $199/mo | 10 | 2 | Adds web office view |
| Multi-state | `spraylog_multi_monthly` | $349/mo | unlimited | all | Adds API access |
| Annual variants | `..._annual` | 20% off | — | — | Same entitlements |

**Gating rules**

- Entitlement is checked server-side in edge functions, never only in the client.
- Exceeding the applicator seat count blocks **adding a new applicator**. It never blocks recording.
- Lapsed subscription → the app becomes read-only: history, export, and data download stay fully available forever. Recording is disabled. **Never withhold a customer's compliance records.** This is both an ethical requirement and a sales argument.
- Data export must work regardless of plan state, including after cancellation.

---

## 7. Environment configuration

### Flutter client — `--dart-define` only, never a bundled `.env`

```bash
# app/.env.example  (values passed via --dart-define-from-file)
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
REVENUECAT_PUBLIC_SDK_KEY_IOS=appl_xxxxxxxx
REVENUECAT_PUBLIC_SDK_KEY_ANDROID=goog_xxxxxxxx
SENTRY_DSN=https://xxxx@sentry.io/xxxx
ENVIRONMENT=development          # development|staging|production
```

Read with `String.fromEnvironment` in `core/config/env.dart`. Fail fast at startup if any required key is empty.

### Supabase Edge Function secrets — server only

```bash
# set via: supabase secrets set --env-file supabase/.env.server
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...        # never leaves the server
ANTHROPIC_API_KEY=sk-ant-xxxxxxxx            # extraction only
ANTHROPIC_MODEL=claude-haiku-4-5-20251001
DEEPGRAM_API_KEY=xxxxxxxx                    # cloud STT fallback
WEATHER_API_KEY=xxxxxxxx                     # observation lookup by lat/lng
TWILIO_ACCOUNT_SID=ACxxxxxxxx                # customer SMS notices
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_FROM_NUMBER=+15550000000
RESEND_API_KEY=re_xxxxxxxx                   # email notices
REVENUECAT_WEBHOOK_SECRET=xxxxxxxx
STRIPE_SECRET_KEY=sk_live_xxxxxxxx           # web checkout only
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxx
EXTRACTION_CONFIDENCE_THRESHOLD=0.75
```

Commit `.env.example` files with placeholder values. Never commit real keys. Add `**/.env`, `**/.env.server` to `.gitignore`.

---

## 8. Edge functions

| Function | Input | Responsibility |
|---|---|---|
| `extract-application` | `{transcript, company_id}` | LLM call, strict schema, candidates only. No regulated values. |
| `validate-application` | candidate JSON + `site_id` | Fuzzy-match product, attach `epa_reg_no`, check rate against `product_rates`, check state registration, return flags |
| `fetch-weather` | `{lat, lng, at}` | Observation lookup, cached 15 min by rounded coordinate |
| `send-notice` | `{application_id}` | Render notice, send via Twilio or Resend, write `notices` row |
| `generate-export` | `{state, range, format}` | Render state template, write to Storage, return signed URL |
| `revenuecat-webhook` | RC event | Verify signature, update `companies.plan` and `plan_status` |

All functions verify the caller's JWT and resolve `company_id` from `profiles`, never from the request body.

---

## 9. Build order

Each milestone ends with a demo and passing tests. Do not start the next until the previous is green.

**M1 — Skeleton (target: week 1)**
Auth, onboarding, tenancy, RLS policies, drift schema, outbox scaffold, CI running `flutter analyze` and `flutter test`.
*Done when:* two users in different companies cannot see each other's rows, proven by an integration test against a real Supabase instance.

**M2 — Core loop, manual entry only (week 2)**
Record → confirm → sign → local persist → sync. No voice yet. Hash chain implemented.
*Done when:* an application created in airplane mode syncs correctly on reconnect and its hash verifies.

**M3 — Voice (week 3)**
On-device STT, `extract-application`, confirm screen prefill, confidence gating, manual fallback everywhere.
*Done when:* a 100-utterance fixture set achieves ≥95% field accuracy on product, rate, and area. Commit the fixture set as a regression suite.

**M4 — Catalogue and validation (weeks 4–5)**
Seed products from EPA label data, fuzzy matcher, `product_rates` for the top 200 products, state registration checks, rate flags and overrides, weather, photos.
*Done when:* an over-label rate is blocked and requires a typed reason, and an out-of-state product is flagged.

**M5 — Notices, history, export (weeks 6–7)**
Customer notices, history and detail screens, amendments, export engine with Florida, Texas, and California templates.
*Done when:* a date-range export produces a paginated, inspection-ready PDF for each of the three states.

**M6 — Billing (week 8)**
RevenueCat integration, plan gating, trial, lapse-to-read-only, data export at any plan state.
*Done when:* an expired subscription blocks recording, still permits export, and never hides history.

---

## 10. Testing requirements

- **Unit:** hash chain, rate conversion (`oz_per_1000sqft` ↔ `lb_per_acre`), fuzzy product matching, offline queue backoff.
- **Fixture regression:** the 100 recorded utterances from M3. Run on every commit touching extraction. Accuracy regressions block merge.
- **Integration:** RLS isolation, sync-after-offline, immutability trigger, entitlement gating.
- **Golden:** confirm screen at three text scales — techs use large accessibility fonts with gloves on.
- **Manual QA per release:** record one application in airplane mode on a physical device, kill the app mid-entry, reopen, confirm no data loss.

---

## 11. Deferred — do not build

Scheduling, routing, invoicing, payments to the applicator, CRM, estimates, chemical inventory, payroll, route optimisation, custom design system. Each turns a two-week sale into a three-month migration. Integrations with existing field service tools come after 50 paying customers, not before
