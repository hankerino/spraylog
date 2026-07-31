-- Onboarding: create a company and the owner's profile atomically.
-- Needed because the companies RLS insert policy checks
-- id = current_company_id(), which is null before the first profile exists.
create or replace function create_company_and_profile(
  company_name text,
  company_operating_states text[] default '{}',
  profile_full_name text default '',
  profile_license_number text default null,
  profile_license_state text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_company_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  insert into companies (name, operating_states, trial_ends_at)
  values (company_name, company_operating_states, now() + interval '14 days')
  returning id into new_company_id;

  insert into profiles (id, company_id, full_name, role, license_number, license_state)
  values (auth.uid(), new_company_id, profile_full_name, 'owner', profile_license_number, profile_license_state);

  return new_company_id;
end;
$$;
