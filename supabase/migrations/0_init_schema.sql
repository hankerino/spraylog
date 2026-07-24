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
