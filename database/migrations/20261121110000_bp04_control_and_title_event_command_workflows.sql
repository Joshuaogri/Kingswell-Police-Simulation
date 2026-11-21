-- BP-04 control-interest and property-title event capture.
-- Reuses authoritative records, existing command audit/idempotency and actor validation.
-- Unknown source facts remain null; no records are seeded or inferred.

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
    '^agreement event ([^[:space:]]+) ([^[:space:]]+) (proposed|executed|commenced|varied|rent_reviewed|break_notice_served|renewal_offered|renewed|expired|terminated|surrendered|dispute_opened|dispute_resolved|assigned|subletting_consented|counterparty_changed|corrected|other) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) "([^"]{1,200})" "([^"]+)" by ([^[:space:]]+)$','i');
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

  -- Organisation control-interest capture; unknown facts remain SQL null.
  m := regexp_match(t,
    '^organisation control ([^[:space:]]+) (person|organisation) ([^[:space:]]+) (beneficial_owner|shareholder|director|partner|controlling_person|franchise_operator|other) (unknown|[0-9]+([.][0-9]+)?) (unknown|[0-9]+([.][0-9]+)?) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) "([^"]*)" "([^"]*)" by ([^[:space:]]+),'i');
  if m is not null then
    return jsonb_build_object('command_type','organisation_control_record',
      'payload',jsonb_build_object(
        'organisation_ref',m[1],'holder_type',lower(m[2]),'holder_ref',m[3],
        'control_type',lower(m[4]),
        'ownership_share_pct',case when lower(m[5])='unknown' then null else m[5] end,
        'voting_share_pct',case when lower(m[7])='unknown' then null else m[7] end,
        'valid_from',case when lower(m[9])='unknown' then null else m[9] end,
        'valid_to',case when lower(m[10])='unknown' then null else m[10] end,
        'source_reference',nullif(m[11],''),'source_description',nullif(m[12],''),
        'actor_ref',m[13]));
  end if;

  -- Property title event capture. Use the literal unknown token for absent facts.
  m := regexp_match(t,
    '^property title event ([^[:space:]]+) ([^[:space:]]+) (initial_registration|transfer|sale|gift|inheritance|court_order|subdivision|amalgamation|title_correction|restriction_registered|restriction_discharged|caveat_registered|caveat_removed|lease_registered|lease_discharged|mortgage_registered|mortgage_discharged|other) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (draft|lodged|recorded|rejected|withdrawn|unknown) (unknown|person|organisation) (unknown|[^[:space:]]+) (unknown|person|organisation) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) (unknown|[0-9]+([.][0-9]+)?) "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" by ([^[:space:]]+),'i');
  if m is not null then
    return jsonb_build_object('command_type','property_title_event_record',
      'payload',jsonb_build_object(
        'property_ref',m[1],'event_ref',m[2],'event_type',lower(m[3]),
        'occurred_on',case when lower(m[4])='unknown' then null else m[4] end,
        'recorded_on',case when lower(m[5])='unknown' then null else m[5] end,
        'registration_status',lower(m[6]),
        'transferor_type',lower(m[7]),
        'transferor_ref',case when lower(m[7])='unknown' or lower(m[8])='unknown' then null else m[8] end,
        'transferee_type',lower(m[9]),
        'transferee_ref',case when lower(m[9])='unknown' or lower(m[10])='unknown' then null else m[10] end,
        'interest_transferred',case when lower(m[11])='unknown' then null else m[11] end,
        'share_transferred_pct',case when lower(m[12])='unknown' then null else m[12] end,
        'prior_title_reference',nullif(m[14],''),'resulting_title_reference',nullif(m[15],''),
        'instrument_type',nullif(m[16],''),'instrument_reference',nullif(m[17],''),
        'source_reference',nullif(m[18],''),'source_description',nullif(m[19],''),
        'actor_ref',m[20]));
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
  v_org game.organisations%rowtype;
  v_holder_person game.persons%rowtype;
  v_holder_org game.organisations%rowtype;
  v_control game.organisation_control_interests%rowtype;
  v_property game.properties%rowtype;
  v_transferor_person game.persons%rowtype;
  v_transferor_org game.organisations%rowtype;
  v_transferee_person game.persons%rowtype;
  v_transferee_org game.organisations%rowtype;
  v_title game.property_title_events%rowtype;
  v_ownership numeric;
  v_voting numeric;
  v_share numeric;
  v_valid_from date;
  v_valid_to date;
  v_occurred date;
  v_recorded date;
begin
  select * into v_personnel
  from game.police_personnel
  where id=p_actor_id and employment_status in ('active','seconded');

  if v_personnel.id is null or v_personnel.personnel_ref<>payload->>'actor_ref' then
    return jsonb_build_object('ok',false,'code','actor_mismatch');
  end if;


  if p_type='organisation_control_record' then
    select * into v_org from game.organisations where organisation_ref=payload->>'organisation_ref';
    if v_org.id is null then return jsonb_build_object('ok',false,'code','organisation_not_found'); end if;
    if payload->>'holder_type'='person' then
      select * into v_holder_person from game.persons where person_ref=payload->>'holder_ref';
      if v_holder_person.id is null then return jsonb_build_object('ok',false,'code','control_holder_not_found'); end if;
    elsif payload->>'holder_type'='organisation' then
      select * into v_holder_org from game.organisations where organisation_ref=payload->>'holder_ref';
      if v_holder_org.id is null then return jsonb_build_object('ok',false,'code','control_holder_not_found'); end if;
      if v_holder_org.id=v_org.id then return jsonb_build_object('ok',false,'code','self_control_not_allowed'); end if;
    else
      return jsonb_build_object('ok',false,'code','invalid_control_holder_type');
    end if;
    begin
      v_ownership:=nullif(payload->>'ownership_share_pct','')::numeric;
      v_voting:=nullif(payload->>'voting_share_pct','')::numeric;
      v_valid_from:=nullif(payload->>'valid_from','')::date;
      v_valid_to:=nullif(payload->>'valid_to','')::date;
    exception when others then
      return jsonb_build_object('ok',false,'code','invalid_control_value');
    end;
    if (v_ownership is not null and (v_ownership<=0 or v_ownership>100))
       or (v_voting is not null and (v_voting<0 or v_voting>100))
       or (v_valid_from is not null and v_valid_to is not null and v_valid_to<v_valid_from) then
      return jsonb_build_object('ok',false,'code','invalid_control_value');
    end if;
    select * into v_control from game.organisation_control_interests
    where organisation_id=v_org.id
      and holder_person_id is not distinct from case when payload->>'holder_type'='person' then v_holder_person.id else null end
      and holder_organisation_id is not distinct from case when payload->>'holder_type'='organisation' then v_holder_org.id else null end
      and control_type=lower(payload->>'control_type')
      and ownership_share_pct is not distinct from v_ownership
      and voting_share_pct is not distinct from v_voting
      and valid_from is not distinct from v_valid_from
      and valid_to is not distinct from v_valid_to
      and source_reference is not distinct from nullif(payload->>'source_reference','')
      and source_description is not distinct from nullif(payload->>'source_description','')
    limit 1;
    if v_control.id is not null then
      return jsonb_build_object('ok',true,'record_type','organisation_control_interest',
        'duplicate',true,'record',to_jsonb(v_control));
    end if;
    begin
      insert into game.organisation_control_interests(
        organisation_id,holder_person_id,holder_organisation_id,control_type,
        ownership_share_pct,voting_share_pct,valid_from,valid_to,
        source_reference,source_description,control_details
      ) values (
        v_org.id,
        case when payload->>'holder_type'='person' then v_holder_person.id else null end,
        case when payload->>'holder_type'='organisation' then v_holder_org.id else null end,
        lower(payload->>'control_type'),v_ownership,v_voting,v_valid_from,v_valid_to,
        nullif(payload->>'source_reference',''),nullif(payload->>'source_description',''),'{}'::jsonb
      ) returning * into v_control;
    exception when unique_violation then
      return jsonb_build_object('ok',false,'code','current_control_interest_conflict',
        'message','A current interest for this organisation, holder and control type already exists with different details.');
    end;
    return jsonb_build_object('ok',true,'record_type','organisation_control_interest',
      'record',to_jsonb(v_control));
  elsif p_type='property_title_event_record' then
    select * into v_property from game.properties where property_ref=payload->>'property_ref';
    if v_property.id is null then return jsonb_build_object('ok',false,'code','property_not_found'); end if;
    if coalesce(length(btrim(payload->>'event_ref')),0) not between 4 and 100 then
      return jsonb_build_object('ok',false,'code','invalid_title_event_ref');
    end if;
    begin
      v_occurred:=nullif(payload->>'occurred_on','')::date;
      v_recorded:=nullif(payload->>'recorded_on','')::date;
      v_share:=nullif(payload->>'share_transferred_pct','')::numeric;
    exception when others then
      return jsonb_build_object('ok',false,'code','invalid_title_event_value');
    end;
    if v_share is not null and (v_share<=0 or v_share>100) then
      return jsonb_build_object('ok',false,'code','invalid_title_event_value');
    end if;
    if payload->>'transferor_type'='person' then
      select * into v_transferor_person from game.persons where person_ref=payload->>'transferor_ref';
      if v_transferor_person.id is null then return jsonb_build_object('ok',false,'code','title_event_transferor_not_found'); end if;
    elsif payload->>'transferor_type'='organisation' then
      select * into v_transferor_org from game.organisations where organisation_ref=payload->>'transferor_ref';
      if v_transferor_org.id is null then return jsonb_build_object('ok',false,'code','title_event_transferor_not_found'); end if;
    elsif payload->>'transferor_type'<>'unknown' then
      return jsonb_build_object('ok',false,'code','invalid_transferor_type');
    end if;
    if payload->>'transferee_type'='person' then
      select * into v_transferee_person from game.persons where person_ref=payload->>'transferee_ref';
      if v_transferee_person.id is null then return jsonb_build_object('ok',false,'code','title_event_transferee_not_found'); end if;
    elsif payload->>'transferee_type'='organisation' then
      select * into v_transferee_org from game.organisations where organisation_ref=payload->>'transferee_ref';
      if v_transferee_org.id is null then return jsonb_build_object('ok',false,'code','title_event_transferee_not_found'); end if;
    elsif payload->>'transferee_type'<>'unknown' then
      return jsonb_build_object('ok',false,'code','invalid_transferee_type');
    end if;
    insert into game.property_title_events(
      event_ref,property_id,event_type,occurred_on,recorded_on,
      prior_title_reference,resulting_title_reference,instrument_type,instrument_reference,
      transferor_person_id,transferor_organisation_id,transferee_person_id,transferee_organisation_id,
      interest_transferred,share_transferred_pct,registration_status,
      source_reference,source_description,event_details
    ) values (
      btrim(payload->>'event_ref'),v_property.id,lower(payload->>'event_type'),v_occurred,v_recorded,
      nullif(payload->>'prior_title_reference',''),nullif(payload->>'resulting_title_reference',''),
      nullif(payload->>'instrument_type',''),nullif(payload->>'instrument_reference',''),
      v_transferor_person.id,v_transferor_org.id,v_transferee_person.id,v_transferee_org.id,
      nullif(payload->>'interest_transferred',''),v_share,lower(payload->>'registration_status'),
      nullif(payload->>'source_reference',''),nullif(payload->>'source_description',''),
      coalesce(payload->'event_details','{}'::jsonb)
    ) on conflict(event_ref) do nothing;
    if not found then
      select * into v_title from game.property_title_events where event_ref=btrim(payload->>'event_ref');
      if v_title.property_id=v_property.id
        and v_title.event_type=lower(payload->>'event_type')
        and v_title.occurred_on is not distinct from v_occurred
        and v_title.recorded_on is not distinct from v_recorded
        and v_title.prior_title_reference is not distinct from nullif(payload->>'prior_title_reference','')
        and v_title.resulting_title_reference is not distinct from nullif(payload->>'resulting_title_reference','')
        and v_title.instrument_type is not distinct from nullif(payload->>'instrument_type','')
        and v_title.instrument_reference is not distinct from nullif(payload->>'instrument_reference','')
        and v_title.transferor_person_id is not distinct from v_transferor_person.id
        and v_title.transferor_organisation_id is not distinct from v_transferor_org.id
        and v_title.transferee_person_id is not distinct from v_transferee_person.id
        and v_title.transferee_organisation_id is not distinct from v_transferee_org.id
        and v_title.interest_transferred is not distinct from nullif(payload->>'interest_transferred','')
        and v_title.share_transferred_pct is not distinct from v_share
        and v_title.registration_status=lower(payload->>'registration_status')
        and v_title.source_reference is not distinct from nullif(payload->>'source_reference','')
        and v_title.source_description is not distinct from nullif(payload->>'source_description','') then
        return jsonb_build_object('ok',true,'record_type','property_title_event',
          'event_ref',v_title.event_ref,'duplicate',true,'event',to_jsonb(v_title));
      end if;
      return jsonb_build_object('ok',false,'code','title_event_ref_conflict',
        'message','That event reference already identifies a different title event.');
    end if;
    select * into v_title from game.property_title_events where event_ref=btrim(payload->>'event_ref');
    return jsonb_build_object('ok',true,'record_type','property_title_event',
      'event_ref',v_title.event_ref,'event',to_jsonb(v_title));
  elsif p_type='agreement_event_record' then
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
      coalesce(nullif(btrim(payload->>'source_description'),''),'Source details not supplied.'),
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
  p_session_id uuid default null,
  p_actor_personnel_id uuid default null
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
           'agreement_event_record','organisation_control_record','property_title_event_record')
       ) x),true);
  end if;

  if typ not in (
    'property_get_record','property_neighbourhood_map','property_city_summary',
    'business_get_record','business_directory','agreement_event_record','organisation_control_record','property_title_event_record'
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

revoke all on function game.interpret_property_command(text) from public,anon,authenticated;
revoke all on function game.execute_property_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
revoke all on function game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
