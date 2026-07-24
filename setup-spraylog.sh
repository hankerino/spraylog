#!/bin/bash
set -e

echo "🌱 SprayLog Repository Setup"

mkdir -p app/lib/core
mkdir -p app/lib/data/{models,repositories,remote}
mkdir -p app/lib/features/{auth,record,history,customers,products,billing,settings}
mkdir -p supabase/{migrations,functions,seed}
mkdir -p docs .github/workflows

cat > .gitignore << 'EOF'
build/
.dart_tool/
.flutter-plugins
.packages
*.iml
.idea/
.vscode/
.env
.env.local
*.lock
.env.server
supabase/.branches/
supabase/.temp/
.DS_Store
**/*.key
**/*.pem
Thumbs.db
EOF

cat > README.md << 'EOF'
# SprayLog

Voice-first pesticide application recordkeeping for small US applicators.

## Stack
- Flutter/Dart (mobile & web)
- Supabase backend
- Riverpod state management
- Drift local database

See docs/ARCHITECTURE.md for full specification.
EOF

cat > app/pubspec.yaml << 'EOF'
name: spraylog
description: Voice-first pesticide application recordkeeping.
publish_to: 'none'

environment:
  sdk: ^3.0.0
  flutter: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  drift: ^2.13.0
  sqlite3_flutter_libs: ^0.5.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  go_router: ^10.2.0
  supabase_flutter: ^1.10.0
  uuid: ^4.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
  freezed: ^2.4.1
  json_serializable: ^6.7.1
  mocktail: ^1.0.0
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
EOF

cat > app/.env.example << 'EOF'
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
REVENUECAT_PUBLIC_SDK_KEY_IOS=appl_xxxxxxxx
REVENUECAT_PUBLIC_SDK_KEY_ANDROID=goog_xxxxxxxx
SENTRY_DSN=https://xxxx@sentry.io/xxxx
ENVIRONMENT=development
EOF

cat > supabase/.env.example << 'EOF'
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
ANTHROPIC_API_KEY=sk-ant-xxxxxxxx
DEEPGRAM_API_KEY=xxxxxxxx
WEATHER_API_KEY=xxxxxxxx
TWILIO_ACCOUNT_SID=ACxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_FROM_NUMBER=+15550000000
RESEND_API_KEY=re_xxxxxxxx
REVENUECAT_WEBHOOK_SECRET=xxxxxxxx
STRIPE_SECRET_KEY=sk_live_xxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxx
EOF

cat > app/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';

void main() => runApp(const SprayLogApp());

class SprayLogApp extends StatelessWidget {
  const SprayLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SprayLog',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.green),
      home: const Scaffold(body: Center(child: Text('SprayLog - Coming soon'))),
    );
  }
}
EOF

cat > app/lib/core/result.dart << 'EOF'
sealed class Result<T, E> {
  const Result();
  factory Result.success(T value) => Success(value);
  factory Result.error(E error) => Error(error);

  Result<U, E> map<U>(U Function(T) f) => switch (this) {
    Success(value: final v) => Result.success(f(v)),
    Error(error: final e) => Result.error(e),
  };

  T unwrap() => switch (this) {
    Success(value: final v) => v,
    Error(error: final e) => throw e,
  };

  T? getOrNull() => switch (this) {
    Success(value: final v) => v,
    Error() => null,
  };
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

final class Error<T, E> extends Result<T, E> {
  final E error;
  const Error(this.error);
}
EOF

cat > app/lib/core/errors.dart << 'EOF'
sealed class AppError implements Exception {
  final String message;
  final Exception? cause;
  AppError(this.message, {this.cause});
  @override
  String toString() => message;
}

final class AuthError extends AppError { AuthError(super.message, {super.cause}); }
final class ValidationError extends AppError { ValidationError(super.message, {super.cause}); }
final class SyncError extends AppError { SyncError(super.message, {super.cause}); }
final class NetworkError extends AppError { NetworkError(super.message, {super.cause}); }
final class NotFoundError extends AppError { NotFoundError(super.message, {super.cause}); }
final class PermissionError extends AppError { PermissionError(super.message, {super.cause}); }
EOF

cat > supabase/migrations/0_init_schema.sql << 'EOF'
-- SprayLog schema
create table if not exists companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  operating_states text[] default '{}',
  timezone text default 'America/New_York',
  plan text default 'trial',
  plan_status text default 'trialing',
  trial_ends_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  company_id uuid references companies(id) on delete cascade,
  full_name text not null,
  role text default 'applicator',
  license_number text,
  license_state text,
  license_expires_at date,
  created_at timestamptz default now()
);

create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade,
  name text not null,
  phone text,
  email text,
  notify_via text default 'sms',
  archived boolean default false,
  created_at timestamptz default now()
);

create table if not exists sites (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade,
  customer_id uuid references customers(id) on delete cascade,
  label text not null,
  state text not null,
  lat double precision,
  lng double precision,
  created_at timestamptz default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  epa_reg_no text unique,
  brand_name text not null,
  brand_aliases text[],
  signal_word text,
  active_ingredients jsonb,
  rei_hours numeric,
  phi_days numeric,
  restricted_use boolean default false,
  updated_at timestamptz default now()
);

create table if not exists applications (
  id uuid primary key,
  company_id uuid references companies(id) on delete cascade,
  applicator_id uuid references profiles(id),
  customer_id uuid references customers(id),
  site_id uuid references sites(id),
  state text,
  applied_at timestamptz not null,
  product_id uuid references products(id),
  epa_reg_no text,
  brand_name text,
  rate_value numeric,
  rate_unit text,
  area_value numeric,
  area_unit text,
  signed_at timestamptz,
  signed_by uuid references profiles(id),
  record_hash text,
  prev_hash text,
  created_at timestamptz default now()
);

create index idx_applications_company_applied_at on applications(company_id, applied_at desc);

create table if not exists amendments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete cascade,
  application_id uuid references applications(id),
  field_name text,
  old_value text,
  new_value text,
  reason text,
  author_id uuid references profiles(id),
  created_at timestamptz default now()
);

create function prevent_update_signed_application() returns trigger as $$
begin
  if old.signed_at is not null then
    raise exception 'Cannot update signed application %', old.id;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_prevent_update_signed_application before update on applications
  for each row execute function prevent_update_signed_application();

alter table companies enable row level security;
alter table profiles enable row level security;
alter table customers enable row level security;
alter table sites enable row level security;
alter table applications enable row level security;
alter table products enable row level security;

create function current_company_id() returns uuid as $$
  select company_id from profiles where id = auth.uid()
$$ language sql;

create policy companies_read on companies for select using (id = current_company_id());
create policy profiles_read on profiles for select using (company_id = current_company_id());
create policy customers_read on customers for select using (company_id = current_company_id());
create policy sites_read on sites for select using (company_id = current_company_id());
create policy applications_read on applications for select using (company_id = current_company_id());
create policy products_read on products for select using (true);
EOF

cat > docs/ARCHITECTURE.md << 'EOF'
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
EOF

touch supabase/migrations/.gitkeep supabase/functions/.gitkeep supabase/seed/.gitkeep
touch app/lib/data/{models,repositories,remote}/.gitkeep
touch app/lib/features/{auth,record,history,customers,products,billing,settings}/.gitkeep
touch app/test/.gitkeep

echo "✅ SprayLog scaffold complete!"
