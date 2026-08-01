-- M6: server-side plan enforcement for recording (spec §6).
-- Recording is blocked when the company's plan is lapsed or the trial
-- expired — history/export stay readable (only INSERT is gated).
-- Seat limits are checked in add_applicator (RPC) below.

create or replace function enforce_recording_plan()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  c record;
begin
  select plan_status, trial_ends_at into c
  from companies where id = new.company_id;

  if c is null then
    raise exception 'company_not_found';
  end if;

  if c.plan_status = 'active' then
    return new;
  end if;

  if c.plan_status = 'trialing'
     and (c.trial_ends_at is null or c.trial_ends_at > now()) then
    return new;
  end if;

  raise exception 'plan_lapsed: recording disabled (history and export remain available)';
end;
$$;

drop trigger if exists trg_enforce_recording_plan on applications;
create trigger trg_enforce_recording_plan
  before insert on applications
  for each row execute function enforce_recording_plan();

-- Add an applicator to a company, enforcing the plan's seat count.
-- Exceeding seats blocks ADDING — never recording (spec §6).
create or replace function plan_seats(plan_name text)
returns int
language sql
immutable
as $$
  select case plan_name
    when 'solo' then 3
    when 'crew' then 10
    when 'multi' then 999999
    else 3  -- trial default: 3 applicators, 1 state
  end;
$$;

create or replace function add_applicator(
  target_user_id uuid,
  new_full_name text,
  new_license_number text default null,
  new_license_state text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller_company uuid;
  seat_count int;
  member_count int;
  current_plan text;
begin
  caller_company := current_company_id();
  if caller_company is null then
    raise exception 'not authenticated';
  end if;

  select plan into current_plan from companies where id = caller_company;

  select count(*) into member_count
  from profiles where company_id = caller_company;

  seat_count := plan_seats(coalesce(current_plan, 'trial'));
  if member_count >= seat_count then
    raise exception 'seat_limit: plan % allows % applicators', current_plan, seat_count;
  end if;

  insert into profiles (id, company_id, full_name, role, license_number, license_state)
  values (target_user_id, caller_company, new_full_name, 'applicator', new_license_number, new_license_state)
  returning id into target_user_id;

  return target_user_id;
end;
$$;
