-- Include facility address in typo-tolerant text search (e.g. estate / suburb names).

create or replace function public.search_text_matches(
  p_query text,
  p_provider_vector tsvector,
  p_facility_vector tsvector,
  p_provider_name text,
  p_provider_specialty text,
  p_facility_name text,
  p_facility_city text,
  p_facility_address text default null
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
    or coalesce(p_facility_address, '') ilike '%' || v_q || '%'
    or similarity(p_provider_name, v_q) > 0.25
    or similarity(coalesce(p_provider_specialty, ''), v_q) > 0.25
    or similarity(p_facility_name, v_q) > 0.25
    or similarity(p_facility_city, v_q) > 0.25
    or similarity(coalesce(p_facility_address, ''), v_q) > 0.25
  );
end;
$$;
