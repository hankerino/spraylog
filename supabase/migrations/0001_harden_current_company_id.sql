drop function if exists current_company_id();

create or replace function current_company_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select company_id
  from profiles
  where id = auth.uid()
$$;
