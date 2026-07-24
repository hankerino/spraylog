create policy companies_insert
on companies
for insert
with check (id = current_company_id());

create policy profiles_insert
on profiles
for insert
with check (company_id = current_company_id());

create policy customers_insert
on customers
for insert
with check (company_id = current_company_id());

create policy sites_insert
on sites
for insert
with check (company_id = current_company_id());

create policy applications_insert
on applications
for insert
with check (company_id = current_company_id());

create policy amendments_insert
on amendments
for insert
with check (company_id = current_company_id());
