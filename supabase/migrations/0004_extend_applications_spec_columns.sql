-- Extend applications to the full spec columns (M2 core loop payload).
alter table applications
  add column if not exists total_amount_value numeric,
  add column if not exists total_amount_unit text,
  add column if not exists target_pest text,
  add column if not exists application_method text,
  add column if not exists lat double precision,
  add column if not exists lng double precision,
  add column if not exists temp_f numeric,
  add column if not exists wind_mph numeric,
  add column if not exists wind_direction text,
  add column if not exists weather_source text,
  add column if not exists transcript text,
  add column if not exists extraction_model text,
  add column if not exists extraction_confidence numeric,
  add column if not exists rate_flag text,
  add column if not exists override_reason text;
