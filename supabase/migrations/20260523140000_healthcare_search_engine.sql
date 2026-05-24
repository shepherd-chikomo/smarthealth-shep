-- SmartHealth: healthcare search engine — trigram indexes, ranking helpers, search functions

begin;

-- ---------------------------------------------------------------------------
-- Trigram indexes for fuzzy / typo-tolerant matching
-- ---------------------------------------------------------------------------

create index if not exists facilities_name_trgm_idx
  on public.facilities using gin (name gin_trgm_ops);

create index if not exists facilities_city_trgm_idx
  on public.facilities using gin (city gin_trgm_ops);

create index if not exists facilities_specialty_trgm_idx
  on public.specialties using gin (name gin_trgm_ops);

create index if not exists emergency_services_name_trgm_idx
  on public.emergency_services using gin (name gin_trgm_ops);

-- Composite GIN for provider + facility combined search performance
create index if not exists providers_search_vector_gin
  on public.providers using gin (search_vector);

create index if not exists facilities_search_vector_gin
  on public.facilities using gin (search_vector);

-- ---------------------------------------------------------------------------
-- Open-now helper (Africa/Harare timezone)
-- ---------------------------------------------------------------------------

create or replace function public.is_facility_open_now(p_facility_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.facility_operating_hours h
    where h.facility_id = p_facility_id
      and h.day_of_week = extract(dow from timezone('Africa/Harare', now()))::smallint
      and (
        h.is_24_hours = true
        or (
          h.is_closed = false
          and h.opens_at is not null
          and h.closes_at is not null
          and (timezone('Africa/Harare', now()))::time between h.opens_at and h.closes_at
        )
      )
  );
$$;

-- ---------------------------------------------------------------------------
-- Active queue helper
-- ---------------------------------------------------------------------------

create or replace function public.facility_has_active_queue(p_facility_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.queue_sessions qs
    where qs.facility_id = p_facility_id
      and qs.is_active = true
      and qs.session_date = (timezone('Africa/Harare', now()))::date
  );
$$;

-- ---------------------------------------------------------------------------
-- Facility profile completeness (0.0 – 1.0)
-- ---------------------------------------------------------------------------

create or replace function public.facility_completeness_score(p_facility_id uuid)
returns numeric
language sql
stable
as $$
  select (
    case when f.description is not null and length(btrim(f.description)) > 20 then 1 else 0 end +
    case when f.phone is not null and btrim(f.phone) <> '' then 1 else 0 end +
    case when f.latitude is not null and f.longitude is not null then 1 else 0 end +
    case when f.logo_path is not null then 1 else 0 end +
    case when f.is_verified then 1 else 0 end +
    case when f.email is not null then 1 else 0 end
  )::numeric / 6.0
  from public.facilities f
  where f.id = p_facility_id;
$$;

-- ---------------------------------------------------------------------------
-- Text match with FTS + trigram typo tolerance
-- ---------------------------------------------------------------------------

create or replace function public.search_text_matches(
  p_query text,
  p_provider_vector tsvector,
  p_facility_vector tsvector,
  p_provider_name text,
  p_provider_specialty text,
  p_facility_name text,
  p_facility_city text
)
returns boolean
language plpgsql
immutable
as $$
declare
  v_q text := btrim(coalesce(p_query, ''));
  v_tsquery tsquery;
begin
  if v_q = '' then
    return true;
  end if;

  begin
    v_tsquery := websearch_to_tsquery('english', v_q);
  exception when others then
    v_tsquery := plainto_tsquery('english', v_q);
  end;

  return (
    (p_provider_vector is not null and p_provider_vector @@ v_tsquery)
    or (p_facility_vector is not null and p_facility_vector @@ v_tsquery)
    or p_provider_name ilike '%' || v_q || '%'
    or coalesce(p_provider_specialty, '') ilike '%' || v_q || '%'
    or p_facility_name ilike '%' || v_q || '%'
    or p_facility_city ilike '%' || v_q || '%'
    or similarity(p_provider_name, v_q) > 0.25
    or similarity(coalesce(p_provider_specialty, ''), v_q) > 0.25
    or similarity(p_facility_name, v_q) > 0.25
    or similarity(p_facility_city, v_q) > 0.25
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Composite provider search rank
-- Priority: specialty > open now > verified > nearby > queue > rating >
--           availability > completeness > text relevance > trigram
-- ---------------------------------------------------------------------------

create or replace function public.compute_provider_search_rank(
  p_query text,
  p_specialty_id uuid,
  p_provider_specialty_id uuid,
  p_provider_specialty text,
  p_is_open_now boolean,
  p_provider_verified boolean,
  p_facility_verified boolean,
  p_distance_km double precision,
  p_has_queue boolean,
  p_avg_rating numeric,
  p_is_accepting_bookings boolean,
  p_completeness numeric,
  p_provider_vector tsvector,
  p_facility_vector tsvector,
  p_provider_name text
)
returns numeric
language plpgsql
stable
as $$
declare
  v_q text := btrim(coalesce(p_query, ''));
  v_tsquery tsquery;
  v_text_rank numeric := 0;
  v_trigram numeric := 0;
  v_specialty numeric := 0;
begin
  if v_q <> '' then
    begin
      v_tsquery := websearch_to_tsquery('english', v_q);
    exception when others then
      v_tsquery := plainto_tsquery('english', v_q);
    end;
    v_text_rank := greatest(
      coalesce(ts_rank_cd(p_provider_vector, v_tsquery), 0),
      coalesce(ts_rank_cd(p_facility_vector, v_tsquery), 0)
    );
    v_trigram := greatest(
      similarity(p_provider_name, v_q),
      similarity(coalesce(p_provider_specialty, ''), v_q)
    );
    if lower(coalesce(p_provider_specialty, '')) = lower(v_q) then
      v_specialty := 1000;
    end if;
  end if;

  if p_specialty_id is not null and p_provider_specialty_id = p_specialty_id then
    v_specialty := greatest(v_specialty, 1000);
  end if;

  return
    v_specialty
    + case when p_is_open_now then 500 else 0 end
    + case
        when p_provider_verified and p_facility_verified then 200
        when p_provider_verified or p_facility_verified then 100
        else 0
      end
    + case
        when p_distance_km is not null then greatest(0, 150 - p_distance_km * 5)
        else 0
      end
    + case when p_has_queue then 100 else 0 end
    + coalesce(p_avg_rating, 0) * 10
    + case when p_is_accepting_bookings then 30 else 0 end
    + coalesce(p_completeness, 0) * 20
    + v_text_rank * 10
    + v_trigram * 5;
end;
$$;

commit;
