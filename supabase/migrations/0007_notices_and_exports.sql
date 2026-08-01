-- M5: customer notices + data exports (spec §2).

create table if not exists notices (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  application_id uuid not null references applications(id),
  channel        text not null,               -- sms|email
  destination    text not null,
  body           text not null,
  sent_at        timestamptz,
  delivery_status text,
  provider_id    text,
  created_at     timestamptz not null default now()
);

create table if not exists exports (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  requested_by   uuid not null references profiles(id),
  state          text not null,
  template_key   text not null,               -- fl|tx|ca|generic
  range_start    date not null,
  range_end      date not null,
  format         text not null,               -- csv|pdf
  storage_path   text,
  created_at     timestamptz not null default now()
);

alter table notices enable row level security;
alter table exports enable row level security;

create policy notices_read on notices
  for select using (company_id = current_company_id());
create policy notices_insert on notices
  for insert with check (company_id = current_company_id());

create policy exports_read on exports
  for select using (company_id = current_company_id());
create policy exports_insert on exports
  for insert with check (company_id = current_company_id());

-- Export files live in a private 'exports' bucket; signed URLs for reads.
insert into storage.buckets (id, name, public)
values ('exports', 'exports', false)
on conflict (id) do nothing;
