-- NOTE: no DROP here — create-or-replace preserves the dependent RLS
-- policies, while a plain drop fails with 2BP01 on a live schema.
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
