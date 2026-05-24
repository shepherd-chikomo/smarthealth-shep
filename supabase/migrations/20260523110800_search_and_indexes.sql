-- SmartHealth: full-text search vectors, PostGIS backfill, index optimization

begin;

-- ---------------------------------------------------------------------------
-- Facilities search vector
-- ---------------------------------------------------------------------------

create or replace function public.facilities_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.description, ''),
    coalesce(new.city, '') || ' ' || coalesce(new.province::text, ''),
    coalesce(new.address_line1, '')
  );
  return new;
end;
$$;

create trigger facilities_search_vector_trg
  before insert or update of name, description, city, province, address_line1
  on public.facilities
  for each row execute function public.facilities_search_vector_update();

-- ---------------------------------------------------------------------------
-- Providers search vector
-- ---------------------------------------------------------------------------

create or replace function public.providers_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.specialty, ''),
    coalesce(new.about, ''),
    coalesce(new.mdpcz_number, '')
  );
  return new;
end;
$$;

create trigger providers_search_vector_trg
  before insert or update of name, specialty, about, mdpcz_number
  on public.providers
  for each row execute function public.providers_search_vector_update();

-- ---------------------------------------------------------------------------
-- Specialties search vector
-- ---------------------------------------------------------------------------

create or replace function public.specialties_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.category, ''),
    coalesce(new.description, ''),
    coalesce(new.icd_code, '')
  );
  return new;
end;
$$;

create trigger specialties_search_vector_trg
  before insert or update of name, category, description, icd_code
  on public.specialties
  for each row execute function public.specialties_search_vector_update();

-- ---------------------------------------------------------------------------
-- Consultations search vector
-- ---------------------------------------------------------------------------

create or replace function public.consultations_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    coalesce(new.chief_complaint, ''),
    coalesce(new.assessment, ''),
    coalesce(new.plan, ''),
    coalesce(new.examination_notes, '')
  );
  return new;
end;
$$;

create trigger consultations_search_vector_trg
  before insert or update
  on public.consultations
  for each row execute function public.consultations_search_vector_update();

-- ---------------------------------------------------------------------------
-- Diagnoses, products, suppliers, cities, emergency_services
-- ---------------------------------------------------------------------------

create or replace function public.diagnoses_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.description,
    coalesce(new.icd10_code, ''),
    coalesce(new.notes, ''),
    null
  );
  return new;
end;
$$;

create trigger diagnoses_search_vector_trg
  before insert or update on public.diagnoses
  for each row execute function public.diagnoses_search_vector_update();

create or replace function public.products_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.sku, ''),
    coalesce(new.description, ''),
    coalesce(new.category, '')
  );
  return new;
end;
$$;

create trigger products_search_vector_trg
  before insert or update on public.products
  for each row execute function public.products_search_vector_update();

create or replace function public.suppliers_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.contact_name, ''),
    coalesce(new.address, ''),
    null
  );
  return new;
end;
$$;

create trigger suppliers_search_vector_trg
  before insert or update on public.suppliers
  for each row execute function public.suppliers_search_vector_update();

create or replace function public.cities_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.province, ''),
    null,
    null
  );
  if new.latitude is not null and new.longitude is not null then
    new.location := extensions.st_setsrid(
      extensions.st_makepoint(new.longitude, new.latitude),
      4326
    )::extensions.geography;
  end if;
  return new;
end;
$$;

create trigger cities_search_vector_trg
  before insert or update on public.cities
  for each row execute function public.cities_search_vector_update();

create or replace function public.emergency_services_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.name,
    coalesce(new.city, '') || ' ' || coalesce(new.province::text, ''),
    coalesce(new.address, ''),
    coalesce(new.phone, '')
  );
  return new;
end;
$$;

create trigger emergency_services_search_vector_trg
  before insert or update on public.emergency_services
  for each row execute function public.emergency_services_search_vector_update();

create or replace function public.lab_results_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.test_name,
    coalesce(new.test_code, ''),
    coalesce(new.result_value, ''),
    coalesce(new.notes, '')
  );
  return new;
end;
$$;

create trigger lab_results_search_vector_trg
  before insert or update on public.lab_results
  for each row execute function public.lab_results_search_vector_update();

create or replace function public.allergies_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.allergen,
    coalesce(new.reaction, ''),
    coalesce(new.notes, ''),
    null
  );
  return new;
end;
$$;

create trigger allergies_search_vector_trg
  before insert or update on public.allergies
  for each row execute function public.allergies_search_vector_update();

create or replace function public.chronic_conditions_search_vector_update()
returns trigger language plpgsql as $$
begin
  new.search_vector := public.build_weighted_search_vector(
    new.condition_name,
    coalesce(new.icd10_code, ''),
    coalesce(new.notes, ''),
    null
  );
  return new;
end;
$$;

create trigger chronic_conditions_search_vector_trg
  before insert or update on public.chronic_conditions
  for each row execute function public.chronic_conditions_search_vector_update();

-- ---------------------------------------------------------------------------
-- Backfill existing rows
-- ---------------------------------------------------------------------------

update public.facilities set name = name where search_vector is null;
update public.providers set name = name where search_vector is null;
update public.specialties set name = name where search_vector is null;
update public.emergency_services set name = name where search_vector is null;

-- Backfill PostGIS locations
update public.facilities
set location = extensions.st_setsrid(
  extensions.st_makepoint(longitude, latitude), 4326
)::extensions.geography
where latitude is not null and longitude is not null and location is null;

-- Composite search function
create or replace function public.search_facilities(
  query text,
  province_filter public.zimbabwe_province default null,
  limit_count int default 20
)
returns setof public.facilities
language sql
stable
as $$
  select f.*
  from public.facilities f
  where f.deleted_at is null
    and f.is_active = true
    and f.moderation_status = 'approved'
    and (province_filter is null or f.province = province_filter)
    and (
      query is null
      or btrim(query) = ''
      or f.search_vector @@ plainto_tsquery('english', query)
      or f.name ilike '%' || query || '%'
    )
  order by
    case when query is not null and btrim(query) <> ''
      then ts_rank(f.search_vector, plainto_tsquery('english', query))
      else 0
    end desc,
    f.name
  limit limit_count;
$$;

create or replace function public.nearby_emergency_services(
  lat double precision,
  lng double precision,
  radius_km double precision default 50,
  limit_count int default 20
)
returns table (
  id uuid,
  name text,
  service_type public.emergency_service_type,
  phone text,
  city text,
  province public.zimbabwe_province,
  distance_km double precision
)
language sql
stable
as $$
  select
    es.id,
    es.name,
    es.service_type,
    es.phone,
    es.city,
    es.province,
    extensions.st_distance(
      es.location,
      extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326)::extensions.geography
    ) / 1000.0 as distance_km
  from public.emergency_services es
  where es.deleted_at is null
    and es.is_active = true
    and es.location is not null
    and extensions.st_dwithin(
      es.location,
      extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326)::extensions.geography,
      radius_km * 1000
    )
  order by distance_km
  limit limit_count;
$$;

commit;
