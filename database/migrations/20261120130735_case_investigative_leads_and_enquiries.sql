-- Investigative leads and enquiry records for Kingswell.
create sequence if not exists game.case_lead_ref_seq;
create sequence if not exists game.case_enquiry_ref_seq;

create table game.case_leads (
 id uuid primary key default gen_random_uuid(),
 lead_ref text not null unique default ('KNG-LD-' || lpad(nextval('game.case_lead_ref_seq')::text,7,'0')),
 case_id uuid not null references game.cases(id) on delete restrict,
 title text not null check (length(btrim(title)) between 3 and 240),
 description text not null check (length(btrim(description)) between 3 and 8000),
 source_type text not null check (source_type in ('officer_observation','witness_information','patrol_intelligence','evidence','forensic_result','interview','surveillance','document','other')),
 source_reference text,
 assigned_personnel_id uuid references game.police_personnel(id) on delete restrict,
 status text not null default 'open' check (status in ('open','under_enquiry','resolved','closed','disproved')),
 priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
 confidence text not null default 'unassessed' check (confidence in ('unassessed','low','moderate','high')),
 assessment_reason text,
 created_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 updated_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 created_at_game_time timestamptz not null,
 updated_at_game_time timestamptz not null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index case_leads_case_status_idx on game.case_leads(case_id,status,priority);
create index case_leads_assignee_idx on game.case_leads(assigned_personnel_id,status);

create table game.case_lead_events (
 id uuid primary key default gen_random_uuid(),
 lead_id uuid not null references game.case_leads(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 event_type text not null check (event_type in ('lead_created','lead_assigned','lead_reassigned','lead_assessed','lead_status_changed')),
 actor_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 event_at_game_time timestamptz not null,
 event_data jsonb not null default '{}'::jsonb,
 source_command_id uuid references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now()
);
create index case_lead_events_lead_time_idx on game.case_lead_events(lead_id,event_at_game_time);

create table game.case_enquiries (
 id uuid primary key default gen_random_uuid(),
 enquiry_ref text not null unique default ('KNG-ENQ-' || lpad(nextval('game.case_enquiry_ref_seq')::text,7,'0')),
 lead_id uuid not null references game.case_leads(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 conducted_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 method text not null check (length(btrim(method)) between 2 and 100),
 action text not null check (length(btrim(action)) between 3 and 4000),
 result text not null check (length(btrim(result)) between 2 and 8000),
 outcome text not null check (outcome in ('information_obtained','no_information','corroborated','contradicted','inconclusive','unable_to_complete','referral_required')),
 source_reference text,
 conducted_at_game_time timestamptz not null,
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 created_at timestamptz not null default now()
);
create index case_enquiries_lead_time_idx on game.case_enquiries(lead_id,conducted_at_game_time desc);
create index case_enquiries_case_time_idx on game.case_enquiries(case_id,conducted_at_game_time desc);

create table game.case_enquiry_events (
 id uuid primary key default gen_random_uuid(),
 enquiry_id uuid not null references game.case_enquiries(id) on delete restrict,
 lead_id uuid not null references game.case_leads(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 event_type text not null check (event_type='enquiry_recorded'),
 actor_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 event_at_game_time timestamptz not null,
 event_data jsonb not null default '{}'::jsonb,
 source_command_id uuid references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now()
);

alter table game.case_leads enable row level security;
alter table game.case_lead_events enable row level security;
alter table game.case_enquiries enable row level security;
alter table game.case_enquiry_events enable row level security;
revoke all on game.case_leads,game.case_lead_events,game.case_enquiries,game.case_enquiry_events from public,anon,authenticated;
grant select,insert,update on game.case_leads to service_role;
grant select,insert on game.case_lead_events,game.case_enquiries,game.case_enquiry_events to service_role;
grant usage,select on sequence game.case_lead_ref_seq,game.case_enquiry_ref_seq to service_role;

create or replace function game.reject_case_investigation_history_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $$ begin raise exception 'Case investigation history is append-only'; end $$;
create trigger case_lead_events_append_only before update or delete on game.case_lead_events
for each row execute function game.reject_case_investigation_history_mutation();
create trigger case_enquiry_events_append_only before update or delete on game.case_enquiry_events
for each row execute function game.reject_case_investigation_history_mutation();
create trigger case_enquiries_append_only before update or delete on game.case_enquiries
for each row execute function game.reject_case_investigation_history_mutation();

create or replace function game.create_case_lead(
 p_case_ref text,p_title text,p_description text,p_source_type text,p_source_reference text,
 p_actor_ref text,p_command_id uuid
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_lead game.case_leads%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 if v_case.status in ('closed','archived') then return jsonb_build_object('ok',false,'code','case_closed','message','A lead cannot be added to a closed case.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording investigative work.'); end if;
 if length(btrim(coalesce(p_title,''))) not between 3 and 240 or length(btrim(coalesce(p_description,''))) not between 3 and 8000 then
  return jsonb_build_object('ok',false,'code','invalid_lead','message','Lead title or description is outside the permitted length.');
 end if;
 if p_source_type not in ('officer_observation','witness_information','patrol_intelligence','evidence','forensic_result','interview','surveillance','document','other') then
  return jsonb_build_object('ok',false,'code','invalid_source_type','message','Unsupported lead source type.');
 end if;
 insert into game.case_leads(case_id,title,description,source_type,source_reference,created_by_personnel_id,updated_by_personnel_id,created_at_game_time,updated_at_game_time)
 values(v_case.id,btrim(p_title),btrim(p_description),p_source_type,nullif(btrim(p_source_reference),''),v_actor.id,v_actor.id,v_clock,v_clock) returning * into v_lead;
 insert into game.case_lead_events(lead_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_lead.id,v_case.id,'lead_created',v_actor.id,v_clock,jsonb_build_object('source_type',p_source_type,'source_reference',p_source_reference,'title',p_title),p_command_id);
 return jsonb_build_object('ok',true,'lead_ref',v_lead.lead_ref,'case_ref',v_case.case_ref,'status',v_lead.status,'priority',v_lead.priority,'game_time',v_clock,'message','Investigative lead created.');
end $$;

create or replace function game.assign_case_lead(p_lead_ref text,p_personnel_ref text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_lead game.case_leads%rowtype; v_assignee game.police_personnel%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_old uuid;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 if v_lead.status in ('resolved','closed','disproved') then return jsonb_build_object('ok',false,'code','lead_inactive','message','A resolved, closed or disproved lead cannot be reassigned.'); end if;
 select * into v_assignee from game.police_personnel where personnel_ref=btrim(p_personnel_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','assignee_unavailable','message','The assigned officer must be active or seconded.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording investigative work.'); end if;
 v_old:=v_lead.assigned_personnel_id;
 update game.case_leads set assigned_personnel_id=v_assignee.id,updated_by_personnel_id=v_actor.id,updated_at_game_time=v_clock,updated_at=now() where id=v_lead.id;
 insert into game.case_lead_events(lead_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_lead.id,v_lead.case_id,case when v_old is null then 'lead_assigned' else 'lead_reassigned' end,v_actor.id,v_clock,
 jsonb_build_object('previous_personnel_id',v_old,'assigned_personnel_id',v_assignee.id,'assigned_personnel_ref',v_assignee.personnel_ref),p_command_id);
 return jsonb_build_object('ok',true,'lead_ref',v_lead.lead_ref,'assigned_to',v_assignee.personnel_ref,'game_time',v_clock,'message','Lead responsibility assigned.');
end $$;

create or replace function game.assess_case_lead(p_lead_ref text,p_status text,p_priority text,p_confidence text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_lead game.case_leads%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 if p_status not in ('open','under_enquiry','resolved','closed','disproved') or p_priority not in ('low','normal','high','urgent') or p_confidence not in ('unassessed','low','moderate','high') or length(btrim(coalesce(p_reason,'')))<3 then
 return jsonb_build_object('ok',false,'code','invalid_assessment','message','Status, priority, confidence or assessment reason is invalid.');
 end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording investigative work.'); end if;
 if v_lead.status in ('closed','disproved') and p_status not in ('closed','disproved') then return jsonb_build_object('ok',false,'code','lead_terminal','message','A closed or disproved lead cannot be reopened through assessment.'); end if;
 update game.case_leads set status=p_status,priority=p_priority,confidence=p_confidence,assessment_reason=btrim(p_reason),updated_by_personnel_id=v_actor.id,updated_at_game_time=v_clock,updated_at=now() where id=v_lead.id;
 insert into game.case_lead_events(lead_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_lead.id,v_lead.case_id,case when v_lead.status<>p_status then 'lead_status_changed' else 'lead_assessed' end,v_actor.id,v_clock,
 jsonb_build_object('previous_status',v_lead.status,'status',p_status,'priority',p_priority,'confidence',p_confidence,'reason',btrim(p_reason)),p_command_id);
 return jsonb_build_object('ok',true,'lead_ref',v_lead.lead_ref,'status',p_status,'priority',p_priority,'confidence',p_confidence,'game_time',v_clock,'message','Lead assessment recorded.');
end $$;

create or replace function game.record_case_enquiry(
 p_lead_ref text,p_personnel_ref text,p_method text,p_action text,p_result text,p_outcome text,p_source_reference text,p_actor_ref text,p_command_id uuid
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_lead game.case_leads%rowtype; v_conductor game.police_personnel%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_enq game.case_enquiries%rowtype;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 if v_lead.status in ('resolved','closed','disproved') then return jsonb_build_object('ok',false,'code','lead_inactive','message','An enquiry cannot be added to a terminal lead.'); end if;
 select * into v_conductor from game.police_personnel where personnel_ref=btrim(p_personnel_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','personnel_unavailable','message','The officer conducting the enquiry must be active or seconded.'); end if;
 if v_lead.assigned_personnel_id is not null and v_lead.assigned_personnel_id<>v_conductor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_lead.case_id and a.personnel_id=v_conductor.id and a.status='active') then
  return jsonb_build_object('ok',false,'code','not_assigned','message','The officer must own the lead or hold an active assignment to its case.');
 end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The recording officer must be active or seconded.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording investigative work.'); end if;
 if length(btrim(coalesce(p_method,''))) not between 2 and 100 or length(btrim(coalesce(p_action,''))) not between 3 and 4000 or length(btrim(coalesce(p_result,''))) not between 2 and 8000 or p_outcome not in ('information_obtained','no_information','corroborated','contradicted','inconclusive','unable_to_complete','referral_required') then
 return jsonb_build_object('ok',false,'code','invalid_enquiry','message','Enquiry method, action, result or outcome is invalid.');
 end if;
 insert into game.case_enquiries(lead_id,case_id,conducted_by_personnel_id,method,action,result,outcome,source_reference,conducted_at_game_time,recorded_by_personnel_id)
 values(v_lead.id,v_lead.case_id,v_conductor.id,btrim(p_method),btrim(p_action),btrim(p_result),p_outcome,nullif(btrim(p_source_reference),''),v_clock,v_actor.id) returning * into v_enq;
 insert into game.case_enquiry_events(enquiry_id,lead_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_enq.id,v_lead.id,v_lead.case_id,'enquiry_recorded',v_actor.id,v_clock,
 jsonb_build_object('enquiry_ref',v_enq.enquiry_ref,'conducted_by',v_conductor.personnel_ref,'method',p_method,'action',p_action,'outcome',p_outcome),p_command_id);
 update game.case_leads set status='under_enquiry',updated_by_personnel_id=v_actor.id,updated_at_game_time=v_clock,updated_at=now() where id=v_lead.id and status='open';
 return jsonb_build_object('ok',true,'enquiry_ref',v_enq.enquiry_ref,'lead_ref',v_lead.lead_ref,'outcome',p_outcome,'game_time',v_clock,'message','Enquiry recorded in the case history.');
end $$;

create or replace function game.get_case_leads(p_case_ref text,p_lead_ref text default null)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_rows jsonb;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('lead_ref',l.lead_ref,'title',l.title,'description',l.description,'source_type',l.source_type,'source_reference',l.source_reference,'assigned_to',pp.personnel_ref,'status',l.status,'priority',l.priority,'confidence',l.confidence,'assessment_reason',l.assessment_reason,'created_at_game_time',l.created_at_game_time,'updated_at_game_time',l.updated_at_game_time,'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'actor',ap.personnel_ref,'game_time',e.event_at_game_time,'data',e.event_data) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_lead_events e join game.police_personnel ap on ap.id=e.actor_personnel_id where e.lead_id=l.id),'enquiry_count',(select count(*) from game.case_enquiries q where q.lead_id=l.id)) order by l.created_at_game_time,l.lead_ref),'[]'::jsonb)
 into v_rows from game.case_leads l left join game.police_personnel pp on pp.id=l.assigned_personnel_id where l.case_id=v_case.id and (p_lead_ref is null or l.lead_ref=btrim(p_lead_ref));
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'count',jsonb_array_length(v_rows),'leads',v_rows);
end $$;

create or replace function game.get_case_enquiries(p_lead_ref text)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game'
as $$
declare v_lead game.case_leads%rowtype; v_rows jsonb;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref);
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('enquiry_ref',q.enquiry_ref,'conducted_by',cp.personnel_ref,'recorded_by',rp.personnel_ref,'method',q.method,'action',q.action,'result',q.result,'outcome',q.outcome,'source_reference',q.source_reference,'game_time',q.conducted_at_game_time) order by q.conducted_at_game_time,q.enquiry_ref),'[]'::jsonb)
 into v_rows from game.case_enquiries q join game.police_personnel cp on cp.id=q.conducted_by_personnel_id join game.police_personnel rp on rp.id=q.recorded_by_personnel_id where q.lead_id=v_lead.id;
 return jsonb_build_object('ok',true,'lead_ref',v_lead.lead_ref,'count',jsonb_array_length(v_rows),'enquiries',v_rows);
end $$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_leads;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case lead create ([^[:space:]]+) "([^"]+)" "([^"]+)" source (officer_observation|witness_information|patrol_intelligence|evidence|forensic_result|interview|surveillance|document|other) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','create_case_lead','payload',jsonb_build_object('case_ref',m[1],'title',m[2],'description',m[3],'source_type',lower(m[4]),'actor_ref',m[5])); end if;
 m:=regexp_match(t,'^case lead assign ([^[:space:]]+) to ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assign_case_lead','payload',jsonb_build_object('lead_ref',m[1],'personnel_ref',m[2],'actor_ref',m[3])); end if;
 m:=regexp_match(t,'^case lead assess ([^[:space:]]+) status (open|under_enquiry|resolved|closed|disproved) priority (low|normal|high|urgent) confidence (unassessed|low|moderate|high) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assess_case_lead','payload',jsonb_build_object('lead_ref',m[1],'status',lower(m[2]),'priority',lower(m[3]),'confidence',lower(m[4]),'reason',m[5],'actor_ref',m[6])); end if;
 m:=regexp_match(t,'^case enquiry record ([^[:space:]]+) by ([^[:space:]]+) method ([^[:space:]]+) action "([^"]+)" result "([^"]+)" outcome (information_obtained|no_information|corroborated|contradicted|inconclusive|unable_to_complete|referral_required) recorded_by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_case_enquiry','payload',jsonb_build_object('lead_ref',m[1],'personnel_ref',m[2],'method',m[3],'action',m[4],'result',m[5],'outcome',lower(m[6]),'actor_ref',m[7])); end if;
 m:=regexp_match(t,'^case leads ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_leads','payload',jsonb_build_object('case_ref',m[1])); end if;
 m:=regexp_match(t,'^case enquiries ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_enquiries','payload',jsonb_build_object('lead_ref',m[1])); end if;
 return game.interpret_text_command_before_case_leads(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_leads;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype; v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('create_case_lead','assign_case_lead','assess_case_lead','record_case_enquiry','list_case_leads','list_case_enquiries') then
  v_result:=game.execute_text_command_before_case_leads(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if v_type='help' and coalesce((v_result->>'ok')::boolean,false) then
   return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('create_case_lead','assign_case_lead','assess_case_lead','record_case_enquiry','list_case_leads','list_case_enquiries'));
  end if;
  return v_result;
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type in ('create_case_lead','assign_case_lead','assess_case_lead','record_case_enquiry') then
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
   v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  elsif v_type='create_case_lead' then
   v_result:=game.create_case_lead(v_payload->>'case_ref',v_payload->>'title',v_payload->>'description',v_payload->>'source_type',null,v_payload->>'actor_ref',v_cmd.id);
  elsif v_type='assign_case_lead' then
   v_result:=game.assign_case_lead(v_payload->>'lead_ref',v_payload->>'personnel_ref',v_payload->>'actor_ref',v_cmd.id);
  elsif v_type='assess_case_lead' then
   v_result:=game.assess_case_lead(v_payload->>'lead_ref',v_payload->>'status',v_payload->>'priority',v_payload->>'confidence',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  else
   v_result:=game.record_case_enquiry(v_payload->>'lead_ref',v_payload->>'personnel_ref',v_payload->>'method',v_payload->>'action',v_payload->>'result',v_payload->>'outcome',null,v_payload->>'actor_ref',v_cmd.id);
  end if;
 else
  if v_type='list_case_leads' then
   v_result:=game.get_case_leads(v_payload->>'case_ref',null);
  else
   v_result:=game.get_case_enquiries(v_payload->>'lead_ref');
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Investigative lead command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;

revoke all on function game.create_case_lead(text,text,text,text,text,text,uuid),game.assign_case_lead(text,text,text,uuid),game.assess_case_lead(text,text,text,text,text,text,uuid),game.record_case_enquiry(text,text,text,text,text,text,text,text,uuid),game.get_case_leads(text,text),game.get_case_enquiries(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.create_case_lead(text,text,text,text,text,text,uuid),game.assign_case_lead(text,text,text,uuid),game.assess_case_lead(text,text,text,text,text,text,uuid),game.record_case_enquiry(text,text,text,text,text,text,text,text,uuid),game.get_case_leads(text,text),game.get_case_enquiries(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
