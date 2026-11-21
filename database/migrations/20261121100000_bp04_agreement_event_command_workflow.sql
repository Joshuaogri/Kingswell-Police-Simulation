-- BP-04: add an append-only site-agreement event command to the existing property command chain.
-- This records evidenced lifecycle events; it deliberately does not invent or rewrite agreement terms.

create or replace function game.interpret_property_command(p_command_text text)
returns jsonb
language plpgsql
immutable
set search_path to 'pg_catalog','game'
as $function$
declare
  t text := btrim(coalesce(p_command_text,''));
  m text[];
begin
  m := regexp_match(t,
    '^property record ([^[:space:]]+) by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','property_get_record',
      'payload',jsonb_build_object('property_ref',m[1],'actor_ref',m[2]));
  end if;
  m := regexp_match(t,
    '^property map ([^[:space:]]+) by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','property_neighbourhood_map',
      'payload',jsonb_build_object('neighbourhood_code',upper(m[1]),'actor_ref',m[2]));
  end if;
  m := regexp_match(t,
    '^property summary by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','property_city_summary',
      'payload',jsonb_build_object('actor_ref',m[1]));
  end if;
  m := regexp_match(t,
    '^business record ([^[:space:]]+) by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','business_get_record',
      'payload',jsonb_build_object('business_number',m[1],'actor_ref',m[2]));
  end if;
  m := regexp_match(t,
    '^business directory by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','business_directory',
      'payload',jsonb_build_object('actor_ref',m[1],'limit',500));
  end if;
  m := regexp_match(t,
    '^business directory sector ([a-z_]+) by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','business_directory',
      'payload',jsonb_build_object('sector',lower(m[1]),'actor_ref',m[2],'limit',500));
  end if;
  m := regexp_match(t,
    '^business directory district ([A-Z0-9-]+) by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','business_directory',
      'payload',jsonb_build_object('district_code',upper(m[1]),'actor_ref',m[2],'limit',500));
  end if;
  m := regexp_match(t,
    '^business directory search "([^"]+)" by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object('command_type','business_directory',
      'payload',jsonb_build_object('search',m[1],'actor_ref',m[2],'limit',500));
  end if;

  -- Example:
  -- agreement event AGR-0001 EVT-0001 varied 2026-11-20 "Rent review agreed" "Parties signed the documented variation." by KNG-0001
  -- Use unknown when the event date is not established by the source record.
  m := regexp_match(t,
    '^agreement event ([^[:space:]]+) ([^[:space:]]+) ([a-z_]+) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) "([^"]{1,200})" "([^"]{1,2000})" by ([^[:space:]]+)$','i');
  if m is not null then
    return jsonb_build_object(
      'command_type','agreement_event_record',
      'payload',jsonb_build_object(
        'agreement_ref',m[1],
        'event_ref',m[2],
        'event_type',lower(m[3]),
        'occurred_on',case when lower(m[4])='unknown' then null else m[4] end,
        'subject',m[5],
        'description',m[6],
        'actor_ref',m[7],
        'event_details','{}'::jsonb
      )
    );
  end if;

  return null;
end;
$function$;

create or replace function game.execute_property_command(
  p_command_id uuid,
  p_type text,
  payload jsonb,
  p_actor_id uuid
)
returns jsonb
language plpgsql
volatile
set search_path to 'pg_catalog','game'
as $function$
declare
  v_personnel game.police_personnel%rowtype;
  v_agreement game.organisation_site_agreements%rowtype;
  v_existing game.organisation_site_agreement_events%rowtype;
  v_data jsonb;
  v_occurred_on date;
  v_event_type text;
begin
  select * into v_personnel
  from game.police_personnel
  where id=p_actor_id and employment_status in ('active','seconded');

  if v_personnel.id is null or v_personnel.personnel_ref<>payload->>'actor_ref' then
    return jsonb_build_object('ok',false,'code','actor_mismatch');
  end if;

  if p_type='agreement_event_record' then
    if coalesce(length(btrim(payload->>'event_ref')),0) not between 4 and 100
       or coalesce(length(btrim(payload->>'agreement_ref')),0) not between 1 and 100
       or coalesce(length(btrim(payload->>'subject')),0) not between 1 and 200
       or coalesce(length(btrim(payload->>'description')),0) not between 1 and 2000
       or jsonb_typeof(coalesce(payload->'event_details','{}'::jsonb))<>'object' then
      return jsonb_build_object('ok',false,'code','invalid_agreement_event',
        'message','Event reference, agreement reference, subject, description and object event details are required.');
    end if;

    v_event_type:=lower(btrim(payload->>'event_type'));
    if v_event_type not in (
      'proposed','executed','commenced','varied','rent_reviewed','break_notice_served',
      'renewal_offered','renewed','expired','terminated','surrendered','dispute_opened',
      'dispute_resolved','assigned','subletting_consented','counterparty_changed','corrected','other'
    ) then
      return jsonb_build_object('ok',false,'code','invalid_agreement_event_type');
    end if;

    select * into v_agreement
    from game.organisation_site_agreements
    where agreement_ref=payload->>'agreement_ref';
    if v_agreement.id is null then
      return jsonb_build_object('ok',false,'code','agreement_not_found',
        'agreement_ref',payload->>'agreement_ref');
    end if;

    if nullif(payload->>'occurred_on','') is null then
      v_occurred_on:=null;
    else
      begin
        v_occurred_on:=(payload->>'occurred_on')::date;
      exception when others then
        return jsonb_build_object('ok',false,'code','invalid_event_date');
      end;
    end if;

    insert into game.organisation_site_agreement_events(
      event_ref,agreement_id,event_type,occurred_on,recorded_on,
      subject,description,actor_person_id,source_reference,
      source_description,event_details
    )
    values(
      btrim(payload->>'event_ref'),v_agreement.id,v_event_type,v_occurred_on,
      current_date,btrim(payload->>'subject'),btrim(payload->>'description'),
      v_personnel.person_id,nullif(btrim(payload->>'source_reference'),''),
      coalesce(nullif(btrim(payload->>'source_description'),''),'Recorded through the Kingswell agreement-event command.'),
      coalesce(payload->'event_details','{}'::jsonb)
    )
    on conflict(event_ref) do nothing;

    if not found then
      select * into v_existing
      from game.organisation_site_agreement_events
      where event_ref=btrim(payload->>'event_ref');
      if v_existing.agreement_id=v_agreement.id
         and v_existing.event_type=v_event_type
         and v_existing.occurred_on is not distinct from v_occurred_on
         and v_existing.subject=btrim(payload->>'subject')
         and v_existing.description=btrim(payload->>'description')
         and v_existing.actor_person_id=v_personnel.person_id
         and v_existing.source_reference is not distinct from nullif(btrim(payload->>'source_reference'),'') then
        return jsonb_build_object('ok',true,'record_type','agreement_event',
          'event_ref',v_existing.event_ref,'duplicate',true,'event',to_jsonb(v_existing));
      end if;
      return jsonb_build_object('ok',false,'code','event_ref_conflict',
        'message','That event reference already identifies a different recorded event.');
    end if;

    select * into v_existing
    from game.organisation_site_agreement_events
    where event_ref=btrim(payload->>'event_ref');

    return jsonb_build_object('ok',true,'record_type','agreement_event',
      'event_ref',v_existing.event_ref,'event',to_jsonb(v_existing));
  elsif p_type='property_get_record' then
    v_data:=game.get_property_record(payload->>'property_ref');
    if v_data is null then return jsonb_build_object('ok',false,'code','property_not_found','property_ref',payload->>'property_ref'); end if;
    return jsonb_build_object('ok',true,'record_type','property','record',v_data);
  elsif p_type='property_neighbourhood_map' then
    v_data:=game.get_neighbourhood_property_map(payload->>'neighbourhood_code');
    if v_data is null then return jsonb_build_object('ok',false,'code','neighbourhood_not_found','neighbourhood_code',payload->>'neighbourhood_code'); end if;
    return jsonb_build_object('ok',true,'record_type','neighbourhood_property_map','map',v_data);
  elsif p_type='property_city_summary' then
    v_data:=game.get_city_property_summary('KNG');
    return jsonb_build_object('ok',true,'record_type','city_property_summary','summary',v_data);
  elsif p_type='business_get_record' then
    v_data:=game.get_business_record(payload->>'business_number');
    if v_data is null then return jsonb_build_object('ok',false,'code','business_not_found','business_number',payload->>'business_number'); end if;
    return jsonb_build_object('ok',true,'record_type','business','record',v_data);
  elsif p_type='business_directory' then
    select coalesce(jsonb_agg(to_jsonb(x)),'[]'::jsonb) into v_data
    from game.list_business_directory(payload->>'sector',payload->>'district_code',payload->>'search',coalesce((payload->>'limit')::integer,100)) x;
    return jsonb_build_object('ok',true,'record_type','business_directory','count',jsonb_array_length(v_data),'businesses',v_data);
  end if;
  return jsonb_build_object('ok',false,'code','unsupported_property_command');
end;
$function$;

create or replace function game.execute_text_command_before_runtime_chain_repair(
  p_command_text text,
  p_idempotency_key text,
  p_session_id uuid,
  p_actor_personnel_id uuid
)
returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
  i jsonb;
  typ text;
  d jsonb;
  cmd game.game_commands%rowtype;
  res jsonb;
  actor game.police_personnel%rowtype;
begin
  i:=game.interpret_text_command(p_command_text);
  typ:=i->>'command_type';
  d:=coalesce(i->'payload','{}'::jsonb);

  if typ='help' then
    res:=game.execute_text_command_before_property(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
    return jsonb_set(res,'{available_commands}',
      (select coalesce(jsonb_agg(distinct x),'[]'::jsonb)
       from jsonb_array_elements_text(
         coalesce(res->'available_commands','[]'::jsonb)||
         jsonb_build_array('property_get_record','property_neighbourhood_map',
           'property_city_summary','business_get_record','business_directory',
           'agreement_event_record')
       ) x),true);
  end if;

  if typ not in (
    'property_get_record','property_neighbourhood_map','property_city_summary',
    'business_get_record','business_directory','agreement_event_record'
  ) then
    return game.execute_text_command_before_property(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
  end if;

  if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
    raise exception 'A unique idempotency key is required';
  end if;

  insert into game.game_commands(
    idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload
  )
  values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d)
  on conflict(idempotency_key) do nothing;

  if not found then
    select * into cmd from game.game_commands
    where idempotency_key=p_idempotency_key for update;
    if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then
      return jsonb_build_object('ok',false,'code','idempotency_conflict');
    end if;
    return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||
      jsonb_build_object('duplicate',true);
  end if;

  select * into cmd from game.game_commands
  where idempotency_key=p_idempotency_key for update;

  select * into actor from game.police_personnel
  where personnel_ref=d->>'actor_ref'
    and employment_status in ('active','seconded');

  if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then
    res:=jsonb_build_object('ok',false,'code','actor_mismatch');
  else
    res:=game.execute_property_command(cmd.id,typ,d,actor.id);
  end if;

  if coalesce((res->>'ok')::boolean,false) then
    res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
    update game.game_commands set status='completed',result=res,completed_at=now()
    where id=cmd.id;
  else
    update game.game_commands set status='rejected',result=res,
      rejection_reason=coalesce(res->>'message',res->>'code','Property command rejected'),
      completed_at=now()
    where id=cmd.id;
    res:=res||jsonb_build_object('command_id',cmd.id);
  end if;
  return res;
end;
$function$;
