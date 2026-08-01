-- M4: application photos (spec §2). Rows are tenant-scoped; files live in
-- the 'application-photos' storage bucket under <company_id>/<application_id>/.

create table if not exists application_photos (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  application_id uuid not null references applications(id) on delete cascade,
  storage_path   text not null,
  lat            double precision,
  lng            double precision,
  taken_at       timestamptz not null default now()
);

alter table application_photos enable row level security;

create policy application_photos_read on application_photos
  for select using (company_id = current_company_id());

create policy application_photos_insert on application_photos
  for insert with check (company_id = current_company_id());

-- Bucket for photo files (private; signed URLs for reads).
insert into storage.buckets (id, name, public)
values ('application-photos', 'application-photos', false)
on conflict (id) do nothing;
