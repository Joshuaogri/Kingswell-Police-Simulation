begin;

do $$
declare
  v_property_ref text;
  v_record jsonb;
  v_key text;
begin
  select property_ref into v_property_ref
  from game.properties
  order by property_ref
  limit 1;

  if v_property_ref is null then
    raise exception 'Expected seeded property fixture.';
  end if;

  v_record:=game.get_property_record(v_property_ref);
  foreach v_key in array array[
    'title_events','physical_assets','asset_maintenance_events','site_agreements','record_coverage'
  ] loop
    if not (v_record ? v_key) then
      raise exception 'Property dossier is missing %',v_key;
    end if;
  end loop;

  if jsonb_typeof(v_record->'title_events')<>'array'
     or jsonb_typeof(v_record->'physical_assets')<>'array'
     or jsonb_typeof(v_record->'asset_maintenance_events')<>'array'
     or jsonb_typeof(v_record->'site_agreements')<>'array' then
    raise exception 'Property history sections must be arrays.';
  end if;

  if (v_record->'record_coverage'->>'unknown_values_are_not_inferred')::boolean is distinct from true then
    raise exception 'Property dossier must preserve unknown information.';
  end if;
end;
$$;

rollback;
