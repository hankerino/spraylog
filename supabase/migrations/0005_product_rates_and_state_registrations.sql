-- M4: label maxima per product/site type + per-state registrations.
-- products, product_rates, product_state_registrations are readable by
-- all authenticated users and writable only by the service role (spec §2).

create table if not exists product_rates (
  id            uuid primary key default gen_random_uuid(),
  product_id    uuid not null references products(id) on delete cascade,
  site_type     text not null,           -- turf|ornamental|structural|right_of_way
  target_pest   text,
  max_rate_value numeric not null,
  max_rate_unit text not null,           -- oz_per_1000sqft|lb_per_acre|pct_solution
  notes         text
);

create table if not exists product_state_registrations (
  product_id    uuid not null references products(id) on delete cascade,
  state         text not null,
  status        text not null default 'active',  -- active|cancelled
  primary key (product_id, state)
);

alter table product_rates enable row level security;
alter table product_state_registrations enable row level security;

create policy product_rates_read on product_rates
  for select using (auth.role() = 'authenticated');

create policy product_state_registrations_read on product_state_registrations
  for select using (auth.role() = 'authenticated');
