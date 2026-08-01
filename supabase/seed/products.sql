-- SprayLog starter product catalogue (M4).
--
-- EPA registration numbers verified against EPA PPLS label PDFs and
-- manufacturer pages (see docs/architecture_v1.md §2). Where a product
-- family changed registrant, the CURRENT active number is used; legacy
-- numbers live in brand_aliases so voice matching still resolves them.
--
-- State registrations below default to active in FL/TX/CA except where a
-- cancellation is documented (Sevin SL). Per-state verification is a
-- production follow-up — do not treat these defaults as legal advice.

insert into products (id, epa_reg_no, brand_name, brand_aliases, signal_word, active_ingredients, rei_hours, restricted_use) values
  (gen_random_uuid(), '62719-542', 'Dimension 2EW', '{Dimension,Dimension EW,dithiopyr pre-emergent,dimension two e w}', 'Warning', '[{"name":"dithiopyr","pct":24}]', null, false),
  (gen_random_uuid(), '100-834', 'Barricade 65WG', '{Barricade,prodiamine 65,Endurance,Resolute 65WG}', 'Caution', '[{"name":"prodiamine","pct":65}]', null, false),
  (gen_random_uuid(), '101563-255', 'Talstar P', '{Talstar,Talstar Pro,Talstar One,Talstar TC,279-3206}', 'Caution', '[{"name":"bifenthrin","pct":7.9}]', null, false),
  (gen_random_uuid(), '101563-86', 'Tempo SC Ultra', '{Tempo,Tempo Ultra,Tempo SC,432-1363}', 'Caution', '[{"name":"beta-cyfluthrin","pct":11.8}]', null, false),
  (gen_random_uuid(), '432-1227', 'Sevin SL', '{Sevin,Sevin carbaryl,carbaryl spray}', 'Caution', '[{"name":"carbaryl","pct":43}]', 12, false),
  (gen_random_uuid(), '71995-29', 'Roundup Weed & Grass Killer Concentrate Plus', '{Roundup Concentrate Plus,Roundup W&G,Roundup concentrate,71995-26}', 'Caution', '[{"name":"glyphosate IPA","pct":18},{"name":"diquat dibromide","pct":0.73}]', null, false),
  (gen_random_uuid(), '524-696', 'Ranger Pro', '{Ranger Pro,Ranger,glyphosate 41%,generic Roundup Pro,524-517}', 'Caution', '[{"name":"glyphosate IPA","pct":41}]', null, false),
  (gen_random_uuid(), '9688-277-8845', 'Spectracide Triazicide Concentrate', '{Triazicide,Spectracide Triazicide,Triazicide lawn killer}', 'Caution', '[{"name":"gamma-cyhalothrin","pct":0.08}]', null, false),
  (gen_random_uuid(), '239-2717', 'Ortho Home Defense RTU', '{Home Defense,Ortho Home Defense Max,Ortho bug spray,279-9534-239}', 'Caution', '[{"name":"bifenthrin","pct":0.05},{"name":"zeta-cypermethrin","pct":0.01}]', null, false),
  (gen_random_uuid(), '53883-90', 'Permethrin SFR 36.8%', '{Permethrin SFR,CSI permethrin,Permethrin 36.8}', 'Caution', '[{"name":"permethrin","pct":36.8}]', null, false),
  (gen_random_uuid(), '101563-4', 'Suspend SC', '{Suspend,Suspend SC,K-Othrine SC,432-763}', 'Caution', '[{"name":"deltamethrin","pct":4.75}]', null, false),
  (gen_random_uuid(), '100-1066', 'Demand CS', '{Demand,Demand CS,lambda-cy CS}', 'Caution', '[{"name":"lambda-cyhalothrin","pct":9.7}]', null, false),
  (gen_random_uuid(), '53883-118', 'Bifen I/T', '{Bifen,Bifen IT,generic Talstar}', 'Caution', '[{"name":"bifenthrin","pct":7.9}]', null, false),
  (gen_random_uuid(), '53883-189', 'Bifen XTS', '{Bifen XTS,XTS bifenthrin,Bifen 2 lb}', 'Warning', '[{"name":"bifenthrin","pct":25.1}]', null, false),
  (gen_random_uuid(), '53883-379', 'Quali-Pro Prodiamine 4L', '{Prodiamine 4L,Quali-Pro prodiamine,liquid Barricade}', 'Caution', '[{"name":"prodiamine","pct":40.8}]', null, false),
  (gen_random_uuid(), '101563-284', 'Dismiss Turf Herbicide', '{Dismiss,Dismiss 4F,sulfentrazone turf,279-3188}', 'Caution', '[{"name":"sulfentrazone","pct":39.6}]', null, false),
  (gen_random_uuid(), '7969-272', 'Drive XLR8', '{Drive,Drive XLR8,quinclorac}', 'Caution', '[{"name":"quinclorac","pct":18.92}]', null, false),
  (gen_random_uuid(), '100-1267', 'Tenacity', '{Tenacity,mesotrione,Tenacity turf herbicide}', 'Caution', '[{"name":"mesotrione","pct":40}]', null, false),
  (gen_random_uuid(), '2217-835', 'Speedzone Southern', '{Speedzone,Speed Zone Southern,Speedzone St. Augustine formula}', 'Caution', '[{"name":"2,4-D 2EHE","pct":10.49},{"name":"MCPP-p","pct":2.66},{"name":"dicamba","pct":0.67},{"name":"carfentrazone","pct":0.54}]', null, false),
  (gen_random_uuid(), '2217-543', 'Trimec Classic', '{Trimec,Trimec Classic,three-way broadleaf}', 'Danger', '[{"name":"2,4-D DMA","pct":25.93},{"name":"MCPP-p DMA","pct":6.93},{"name":"dicamba DMA","pct":2.76}]', null, false),
  (gen_random_uuid(), '100-1481', 'Advion Fire Ant Bait', '{Advion,Advion fire ant,DuPont Advion}', 'Caution', '[{"name":"indoxacarb","pct":0.04}]', null, false)
on conflict (epa_reg_no) do nothing;

-- State registrations: default active in FL/TX/CA for all seeded products
-- except Sevin SL (carbaryl registration cancelled 2024-02-23).
insert into product_state_registrations (product_id, state, status)
select p.id, s.state,
  case when p.epa_reg_no = '432-1227' then 'cancelled' else 'active' end
from products p
cross join (values ('FL'), ('TX'), ('CA')) as s(state)
on conflict (product_id, state) do nothing;
