-- Label maximum TURF application rates (M4) — per-application maxima
-- verified against EPA PPLS label PDFs and manufacturer labels.
-- Annual caps live in notes; per-species annual tables (Barricade,
-- Prodiamine) are top-of-table values — verify per species before
-- encoding species-specific rules. Drive XLR8 annual cap is UNVERIFIED.

insert into product_rates (product_id, site_type, target_pest, max_rate_value, max_rate_unit, notes)
select p.id, 'turf', null, v.max_value, v.max_unit, v.notes
from (values
  ('62719-542',  0.73,  'oz_per_1000sqft', 'Annual cap 2.2 oz/1000/yr (6 pt/A/yr); NY lower'),
  ('100-834',    1.5,   'lb_per_acre',     'Annual cap per turf species table (top 1.5 lb/A/yr)'),
  ('101563-255', 1.0,   'oz_per_1000sqft', 'Repeat >= 7 days'),
  ('101563-86',  0.54,  'oz_per_1000sqft', 'Max 6 applications per year (turf)'),
  ('53883-90',   0.8,   'oz_per_1000sqft', 'Repeat if necessary'),
  ('101563-4',   0.9,   'oz_per_1000sqft', 'Rates from Bayer-era master label; same formulation'),
  ('100-1066',   0.23,  'oz_per_1000sqft', 'Annual cap 52.4 fl oz/A/yr'),
  ('53883-118',  1.0,   'oz_per_1000sqft', 'Repeat >= 7 days'),
  ('53883-189',  0.15,  'oz_per_1000sqft', 'Lawn rate; other use-sites differ'),
  ('53883-379',  1.1,   'oz_per_1000sqft', 'Annual cap per turf species Table 4 (top 48 fl oz/A/yr)'),
  ('7969-272',   1.45,  'oz_per_1000sqft', 'Annual cap UNVERIFIED (label image-only)'),
  ('100-1267',   0.18,  'oz_per_1000sqft', 'Annual cap 16 fl oz/A/yr; St. Augustine 4 fl oz/A/app'),
  ('2217-835',   1.5,   'oz_per_1000sqft', 'Max 2 broadcast treatments/season (>=30d), 12 pt/A/season'),
  ('2217-543',   1.5,   'oz_per_1000sqft', 'Max 2 broadcast apps/yr, 8 pt/A/season; sensitive turf 0.67/1000'),
  ('100-1481',   1.5,   'lb_per_acre',     'Max 6 lb/A or 4 applications per year; retreat >=12-16 wks')
) as v(epa, max_value, max_unit, notes)
join products p on p.epa_reg_no = v.epa
on conflict do nothing;
