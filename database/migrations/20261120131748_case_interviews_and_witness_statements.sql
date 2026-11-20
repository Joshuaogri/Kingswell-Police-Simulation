-- Case interview records, question-and-answer chronology and witness statements.
-- Source reconstructed from the applied Kingswell schema/function definitions.
create sequence game.case_interview_ref_seq;

create sequence game.case_interview_turn_ref_seq;

create sequence game.case_witness_statement_ref_seq;

create table game.case_interview_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  interview_id uuid NOT NULL,
  case_id uuid NOT NULL,
  event_type text NOT NULL,
  actor_personnel_id uuid NOT NULL,
  event_at_game_time timestamp with time zone NOT NULL,
  reason text,
  source_command_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

create table game.case_interview_turns (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  turn_ref text NOT NULL DEFAULT ('KNG-ITR-'::text || lpad((nextval('game.case_interview_turn_ref_seq'::regclass))::text, 7, '0'::text)),
  interview_id uuid NOT NULL,
  case_id uuid NOT NULL,
  turn_number integer NOT NULL,
  question_text text NOT NULL,
  answer_text text NOT NULL,
  recorded_by_personnel_id uuid NOT NULL,
  recorded_at_game_time timestamp with time zone NOT NULL,
  source_command_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

create table game.case_interviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  interview_ref text NOT NULL DEFAULT ('KNG-INT-'::text || lpad((nextval('game.case_interview_ref_seq'::regclass))::text, 7, '0'::text)),
  case_id uuid NOT NULL,
  interviewee_person_id uuid NOT NULL,
  interviewer_personnel_id uuid NOT NULL,
  method text NOT NULL,
  purpose text NOT NULL,
  location_description text,
  notes text,
  started_at_game_time timestamp with time zone NOT NULL,
  source_command_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

create table game.case_witness_statement_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  statement_id uuid NOT NULL,
  case_id uuid NOT NULL,
  event_type text NOT NULL,
  actor_personnel_id uuid NOT NULL,
  event_at_game_time timestamp with time zone NOT NULL,
  reason text,
  source_command_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

create table game.case_witness_statements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  statement_ref text NOT NULL DEFAULT ('KNG-WS-'::text || lpad((nextval('game.case_witness_statement_ref_seq'::regclass))::text, 7, '0'::text)),
  case_id uuid NOT NULL,
  interview_id uuid,
  witness_person_id uuid NOT NULL,
  statement_form text NOT NULL,
  statement_text text NOT NULL,
  supplements_statement_id uuid,
  recorded_by_personnel_id uuid NOT NULL,
  recorded_at_game_time timestamp with time zone NOT NULL,
  source_command_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

alter table game.case_interview_events add constraint case_interview_events_actor_personnel_id_fkey FOREIGN KEY (actor_personnel_id) REFERENCES game.police_personnel(id) ON DELETE RESTRICT;

alter table game.case_interview_events add constraint case_interview_events_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id) ON DELETE RESTRICT;

alter table game.case_interview_events add constraint case_interview_events_event_type_check CHECK ((event_type = ANY (ARRAY['interview_started'::text, 'interview_concluded'::text, 'interview_interrupted'::text])));

alter table game.case_interview_events add constraint case_interview_events_interview_id_fkey FOREIGN KEY (interview_id) REFERENCES game.case_interviews(id) ON DELETE RESTRICT;

alter table game.case_interview_events add constraint case_interview_events_pkey PRIMARY KEY (id);

alter table game.case_interview_events add constraint case_interview_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id) ON DELETE RESTRICT;

alter table game.case_interview_turns add constraint case_interview_turns_answer_text_check CHECK (((length(btrim(answer_text)) >= 1) AND (length(btrim(answer_text)) <= 12000)));

alter table game.case_interview_turns add constraint case_interview_turns_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id) ON DELETE RESTRICT;

alter table game.case_interview_turns add constraint case_interview_turns_interview_id_fkey FOREIGN KEY (interview_id) REFERENCES game.case_interviews(id) ON DELETE RESTRICT;

alter table game.case_interview_turns add constraint case_interview_turns_interview_id_turn_number_key UNIQUE (interview_id, turn_number);

alter table game.case_interview_turns add constraint case_interview_turns_pkey PRIMARY KEY (id);

alter table game.case_interview_turns add constraint case_interview_turns_question_text_check CHECK (((length(btrim(question_text)) >= 1) AND (length(btrim(question_text)) <= 8000)));

alter table game.case_interview_turns add constraint case_interview_turns_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id) ON DELETE RESTRICT;

alter table game.case_interview_turns add constraint case_interview_turns_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id) ON DELETE RESTRICT;

alter table game.case_interview_turns add constraint case_interview_turns_turn_number_check CHECK ((turn_number > 0));

alter table game.case_interview_turns add constraint case_interview_turns_turn_ref_key UNIQUE (turn_ref);

alter table game.case_interviews add constraint case_interviews_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id) ON DELETE RESTRICT;

alter table game.case_interviews add constraint case_interviews_interview_ref_key UNIQUE (interview_ref);

alter table game.case_interviews add constraint case_interviews_interviewee_person_id_fkey FOREIGN KEY (interviewee_person_id) REFERENCES game.persons(id) ON DELETE RESTRICT;

alter table game.case_interviews add constraint case_interviews_interviewer_personnel_id_fkey FOREIGN KEY (interviewer_personnel_id) REFERENCES game.police_personnel(id) ON DELETE RESTRICT;

alter table game.case_interviews add constraint case_interviews_method_check CHECK (((length(btrim(method)) >= 2) AND (length(btrim(method)) <= 100)));

alter table game.case_interviews add constraint case_interviews_pkey PRIMARY KEY (id);

alter table game.case_interviews add constraint case_interviews_purpose_check CHECK (((length(btrim(purpose)) >= 3) AND (length(btrim(purpose)) <= 2000)));

alter table game.case_interviews add constraint case_interviews_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id) ON DELETE RESTRICT;

alter table game.case_witness_statement_events add constraint case_witness_statement_events_actor_personnel_id_fkey FOREIGN KEY (actor_personnel_id) REFERENCES game.police_personnel(id) ON DELETE RESTRICT;

alter table game.case_witness_statement_events add constraint case_witness_statement_events_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id) ON DELETE RESTRICT;

alter table game.case_witness_statement_events add constraint case_witness_statement_events_event_type_check CHECK ((event_type = ANY (ARRAY['statement_recorded'::text, 'statement_adopted'::text, 'statement_not_adopted'::text, 'signature_refused'::text])));

alter table game.case_witness_statement_events add constraint case_witness_statement_events_pkey PRIMARY KEY (id);

alter table game.case_witness_statement_events add constraint case_witness_statement_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id) ON DELETE RESTRICT;

alter table game.case_witness_statement_events add constraint case_witness_statement_events_statement_id_fkey FOREIGN KEY (statement_id) REFERENCES game.case_witness_statements(id) ON DELETE RESTRICT;

alter table game.case_witness_statements add constraint case_witness_statements_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id) ON DELETE RESTRICT;

alter table game.case_witness_statements add constraint case_witness_statements_check CHECK (((supplements_statement_id IS NULL) OR (supplements_statement_id <> id)));

alter table game.case_witness_statements add constraint case_witness_statements_interview_id_fkey FOREIGN KEY (interview_id) REFERENCES game.case_interviews(id) ON DELETE RESTRICT;

alter table game.case_witness_statements add constraint case_witness_statements_pkey PRIMARY KEY (id);

alter table game.case_witness_statements add constraint case_witness_statements_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id) ON DELETE RESTRICT;

alter table game.case_witness_statements add constraint case_witness_statements_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id) ON DELETE RESTRICT;

alter table game.case_witness_statements add constraint case_witness_statements_statement_form_check CHECK ((statement_form = ANY (ARRAY['written_signed'::text, 'written_unsigned'::text, 'officer_recorded'::text, 'dictated'::text, 'recorded_media'::text])));

alter table game.case_witness_statements add constraint case_witness_statements_statement_ref_key UNIQUE (statement_ref);

alter table game.case_witness_statements add constraint case_witness_statements_statement_text_check CHECK (((length(btrim(statement_text)) >= 3) AND (length(btrim(statement_text)) <= 30000)));

alter table game.case_witness_statements add constraint case_witness_statements_supplements_statement_id_fkey FOREIGN KEY (supplements_statement_id) REFERENCES game.case_witness_statements(id) ON DELETE RESTRICT;

alter table game.case_witness_statements add constraint case_witness_statements_witness_person_id_fkey FOREIGN KEY (witness_person_id) REFERENCES game.persons(id) ON DELETE RESTRICT;

CREATE INDEX case_interview_events_interview_time_idx ON game.case_interview_events USING btree (interview_id, event_at_game_time);

CREATE INDEX case_interview_turns_case_idx ON game.case_interview_turns USING btree (case_id, recorded_at_game_time);

CREATE INDEX case_interview_turns_interview_idx ON game.case_interview_turns USING btree (interview_id, turn_number);

CREATE INDEX case_interviews_case_time_idx ON game.case_interviews USING btree (case_id, started_at_game_time DESC);

CREATE INDEX case_interviews_interviewer_time_idx ON game.case_interviews USING btree (interviewer_personnel_id, started_at_game_time DESC);

CREATE INDEX case_interviews_person_time_idx ON game.case_interviews USING btree (interviewee_person_id, started_at_game_time DESC);

CREATE INDEX case_witness_statement_events_statement_idx ON game.case_witness_statement_events USING btree (statement_id, event_at_game_time);

CREATE INDEX case_witness_statements_case_time_idx ON game.case_witness_statements USING btree (case_id, recorded_at_game_time DESC);

CREATE INDEX case_witness_statements_interview_idx ON game.case_witness_statements USING btree (interview_id) WHERE (interview_id IS NOT NULL);

CREATE INDEX case_witness_statements_witness_idx ON game.case_witness_statements USING btree (witness_person_id, recorded_at_game_time DESC);

alter table game.case_interview_events enable row level security;

alter table game.case_interview_turns enable row level security;

alter table game.case_interviews enable row level security;

alter table game.case_witness_statement_events enable row level security;

alter table game.case_witness_statements enable row level security;

CREATE TRIGGER case_interview_events_append_only BEFORE DELETE OR UPDATE ON game.case_interview_events FOR EACH ROW EXECUTE FUNCTION game.reject_case_investigation_history_mutation();

CREATE TRIGGER case_interview_turns_append_only BEFORE DELETE OR UPDATE ON game.case_interview_turns FOR EACH ROW EXECUTE FUNCTION game.reject_case_investigation_history_mutation();

CREATE TRIGGER case_interviews_append_only BEFORE DELETE OR UPDATE ON game.case_interviews FOR EACH ROW EXECUTE FUNCTION game.reject_case_investigation_history_mutation();

CREATE TRIGGER case_witness_statement_events_append_only BEFORE DELETE OR UPDATE ON game.case_witness_statement_events FOR EACH ROW EXECUTE FUNCTION game.reject_case_investigation_history_mutation();

CREATE TRIGGER case_witness_statements_append_only BEFORE DELETE OR UPDATE ON game.case_witness_statements FOR EACH ROW EXECUTE FUNCTION game.reject_case_investigation_history_mutation();

CREATE OR REPLACE FUNCTION game.get_case_interview_transcript(p_interview_ref text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_interview game.case_interviews%rowtype; v_turns jsonb; v_events jsonb; v_statements jsonb;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref);
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('turn_ref',t.turn_ref,'turn_number',t.turn_number,'question',t.question_text,'answer',t.answer_text,'recorded_by',pp.personnel_ref,'game_time',t.recorded_at_game_time) order by t.turn_number),'[]'::jsonb)
 into v_turns from game.case_interview_turns t join game.police_personnel pp on pp.id=t.recorded_by_personnel_id where t.interview_id=v_interview.id;
 select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'actor',pp.personnel_ref,'reason',e.reason,'game_time',e.event_at_game_time) order by e.event_at_game_time,e.created_at),'[]'::jsonb)
 into v_events from game.case_interview_events e join game.police_personnel pp on pp.id=e.actor_personnel_id where e.interview_id=v_interview.id;
 select coalesce(jsonb_agg(jsonb_build_object('statement_ref',s.statement_ref,'form',s.statement_form,'text',s.statement_text,'witness',p.person_ref,'supplements',parent.statement_ref,'status',(select case se.event_type when 'statement_adopted' then 'adopted' when 'statement_not_adopted' then 'not_adopted' when 'signature_refused' then 'refused_to_sign' else 'draft' end from game.case_witness_statement_events se where se.statement_id=s.id order by se.event_at_game_time desc,se.created_at desc limit 1)) order by s.recorded_at_game_time,s.statement_ref),'[]'::jsonb)
 into v_statements from game.case_witness_statements s join game.persons p on p.id=s.witness_person_id left join game.case_witness_statements parent on parent.id=s.supplements_statement_id where s.interview_id=v_interview.id;
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'turn_count',jsonb_array_length(v_turns),'turns',v_turns,'events',v_events,'statements',v_statements);
end $function$



CREATE OR REPLACE FUNCTION game.get_case_interviews(p_case_ref text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_case game.cases%rowtype; v_rows jsonb;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('interview_ref',i.interview_ref,'interviewee',p.person_ref,'interviewee_name',concat_ws(' ',p.given_name,p.family_name),'interviewer',pp.personnel_ref,'method',i.method,'purpose',i.purpose,'location',i.location_description,'started_at',i.started_at_game_time,'status',(select case e.event_type when 'interview_concluded' then 'concluded' when 'interview_interrupted' then 'interrupted' else 'in_progress' end from game.case_interview_events e where e.interview_id=i.id order by e.event_at_game_time desc,e.created_at desc limit 1),'turn_count',(select count(*) from game.case_interview_turns t where t.interview_id=i.id),'statement_count',(select count(*) from game.case_witness_statements s where s.interview_id=i.id)) order by i.started_at_game_time,i.interview_ref),'[]'::jsonb)
 into v_rows from game.case_interviews i join game.persons p on p.id=i.interviewee_person_id join game.police_personnel pp on pp.id=i.interviewer_personnel_id where i.case_id=v_case.id;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'count',jsonb_array_length(v_rows),'interviews',v_rows);
end $function$



CREATE OR REPLACE FUNCTION game.get_case_witness_statements(p_case_ref text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_case game.cases%rowtype; v_rows jsonb;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('statement_ref',s.statement_ref,'witness',p.person_ref,'witness_name',concat_ws(' ',p.given_name,p.family_name),'form',s.statement_form,'text',s.statement_text,'interview_ref',i.interview_ref,'supplements',parent.statement_ref,'recorded_by',pp.personnel_ref,'game_time',s.recorded_at_game_time,'status',(select case e.event_type when 'statement_adopted' then 'adopted' when 'statement_not_adopted' then 'not_adopted' when 'signature_refused' then 'refused_to_sign' else 'draft' end from game.case_witness_statement_events e where e.statement_id=s.id order by e.event_at_game_time desc,e.created_at desc limit 1)) order by s.recorded_at_game_time,s.statement_ref),'[]'::jsonb)
 into v_rows from game.case_witness_statements s join game.persons p on p.id=s.witness_person_id join game.police_personnel pp on pp.id=s.recorded_by_personnel_id left join game.case_interviews i on i.id=s.interview_id left join game.case_witness_statements parent on parent.id=s.supplements_statement_id where s.case_id=v_case.id;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'count',jsonb_array_length(v_rows),'statements',v_rows);
end $function$



CREATE OR REPLACE FUNCTION game.record_case_interview_turn(p_interview_ref text, p_question text, p_answer text, p_actor_ref text, p_command_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_interview game.case_interviews%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_number integer; v_turn game.case_interview_turns%rowtype;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
 if exists(select 1 from game.case_interview_events e where e.interview_id=v_interview.id and e.event_type in ('interview_concluded','interview_interrupted')) then
 return jsonb_build_object('ok',false,'code','interview_ended','message','No further questions can be added to a concluded or interrupted interview.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or v_actor.id<>v_interview.interviewer_personnel_id then return jsonb_build_object('ok',false,'code','interviewer_mismatch','message','Only the recorded interviewer may add question-and-answer turns.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording interview turns.'); end if;
 if length(btrim(coalesce(p_question,''))) not between 1 and 8000 or length(btrim(coalesce(p_answer,''))) not between 1 and 12000 then return jsonb_build_object('ok',false,'code','invalid_turn','message','Question or answer is outside the permitted length.'); end if;
 select coalesce(max(turn_number),0)+1 into v_number from game.case_interview_turns where interview_id=v_interview.id;
 insert into game.case_interview_turns(interview_id,case_id,turn_number,question_text,answer_text,recorded_by_personnel_id,recorded_at_game_time,source_command_id)
 values(v_interview.id,v_interview.case_id,v_number,btrim(p_question),btrim(p_answer),v_actor.id,v_clock,p_command_id) returning * into v_turn;
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'turn_ref',v_turn.turn_ref,'turn_number',v_number,'game_time',v_clock,'message','Interview question and answer recorded.');
end $function$



CREATE OR REPLACE FUNCTION game.record_case_witness_statement(p_case_ref text, p_interview_ref text, p_person_ref text, p_form text, p_statement_text text, p_supplements_ref text, p_actor_ref text, p_command_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_case game.cases%rowtype; v_interview game.case_interviews%rowtype; v_person game.persons%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_parent game.case_witness_statements%rowtype; v_statement game.case_witness_statements%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed case cannot receive a new witness statement.'); end if;
 select * into v_person from game.persons where person_ref=btrim(p_person_ref) and person_status='active';
 if not found then return jsonb_build_object('ok',false,'code','witness_not_found','message','Witness must resolve to an existing active person.'); end if;
 if p_interview_ref is not null then
  select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref) and case_id=v_case.id and interviewee_person_id=v_person.id;
  if not found then return jsonb_build_object('ok',false,'code','interview_mismatch','message','Interview must belong to this case and this witness.'); end if;
 end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The recording officer must be active or seconded.'); end if;
 if v_case.lead_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active') then
 return jsonb_build_object('ok',false,'code','not_assigned','message','The recording officer must be the case lead or hold an active case assignment.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording a statement.'); end if;
 if p_form not in ('written_signed','written_unsigned','officer_recorded','dictated','recorded_media') or length(btrim(coalesce(p_statement_text,''))) not between 3 and 30000 then
 return jsonb_build_object('ok',false,'code','invalid_statement','message','Statement form or statement text is invalid.'); end if;
 if p_supplements_ref is not null then
  select * into v_parent from game.case_witness_statements where statement_ref=btrim(p_supplements_ref) and case_id=v_case.id and witness_person_id=v_person.id;
  if not found then return jsonb_build_object('ok',false,'code','parent_statement_mismatch','message','A supplementary statement must reference an existing statement by this witness in this case.'); end if;
 end if;
 insert into game.case_witness_statements(case_id,interview_id,witness_person_id,statement_form,statement_text,supplements_statement_id,recorded_by_personnel_id,recorded_at_game_time,source_command_id)
 values(v_case.id,v_interview.id,v_person.id,p_form,btrim(p_statement_text),v_parent.id,v_actor.id,v_clock,p_command_id) returning * into v_statement;
 insert into game.case_witness_statement_events(statement_id,case_id,event_type,actor_personnel_id,event_at_game_time,source_command_id)
 values(v_statement.id,v_case.id,'statement_recorded',v_actor.id,v_clock,p_command_id);
 return jsonb_build_object('ok',true,'statement_ref',v_statement.statement_ref,'case_ref',v_case.case_ref,'witness',v_person.person_ref,'status','draft','supplements',p_supplements_ref,'game_time',v_clock,'message','Witness statement recorded as a draft. It has not been marked as adopted by the witness.');
end $function$



CREATE OR REPLACE FUNCTION game.set_case_interview_status(p_interview_ref text, p_status text, p_reason text, p_actor_ref text, p_command_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_interview game.case_interviews%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_type text;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
 if exists(select 1 from game.case_interview_events e where e.interview_id=v_interview.id and e.event_type in ('interview_concluded','interview_interrupted')) then return jsonb_build_object('ok',false,'code','interview_ended','message','Interview already has a terminal event.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or v_actor.id<>v_interview.interviewer_personnel_id then return jsonb_build_object('ok',false,'code','interviewer_mismatch','message','Only the recorded interviewer may conclude or interrupt the interview.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before updating interview history.'); end if;
 if p_status not in ('concluded','interrupted') or length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_interview_status','message','Choose concluded or interrupted and provide a reason.'); end if;
 v_type:=case p_status when 'concluded' then 'interview_concluded' else 'interview_interrupted' end;
 insert into game.case_interview_events(interview_id,case_id,event_type,actor_personnel_id,event_at_game_time,reason,source_command_id)
 values(v_interview.id,v_interview.case_id,v_type,v_actor.id,v_clock,btrim(p_reason),p_command_id);
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'status',p_status,'game_time',v_clock,'message','Interview status recorded.');
end $function$



CREATE OR REPLACE FUNCTION game.set_case_witness_statement_status(p_statement_ref text, p_status text, p_reason text, p_actor_ref text, p_command_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_statement game.case_witness_statements%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_type text;
begin
 select * into v_statement from game.case_witness_statements where statement_ref=btrim(p_statement_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','statement_not_found','message','Statement reference not found.'); end if;
 if exists(select 1 from game.case_witness_statement_events e where e.statement_id=v_statement.id and e.event_type<>'statement_recorded') then return jsonb_build_object('ok',false,'code','statement_status_final','message','Statement adoption status has already been recorded and cannot be overwritten.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 if v_statement.case_id not in (select a.case_id from game.case_assignments a where a.personnel_id=v_actor.id and a.status='active') and v_actor.id<>(select c.lead_personnel_id from game.cases c where c.id=v_statement.case_id) then
 return jsonb_build_object('ok',false,'code','not_assigned','message','The acting officer must be the case lead or hold an active case assignment.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before updating statement status.'); end if;
 if p_status not in ('adopted','not_adopted','refused_to_sign') or length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_statement_status','message','Choose adopted, not_adopted or refused_to_sign and provide a reason.'); end if;
 v_type:=case p_status when 'adopted' then 'statement_adopted' when 'not_adopted' then 'statement_not_adopted' else 'signature_refused' end;
 insert into game.case_witness_statement_events(statement_id,case_id,event_type,actor_personnel_id,event_at_game_time,reason,source_command_id)
 values(v_statement.id,v_statement.case_id,v_type,v_actor.id,v_clock,btrim(p_reason),p_command_id);
 return jsonb_build_object('ok',true,'statement_ref',v_statement.statement_ref,'status',p_status,'game_time',v_clock,'message','Witness statement status recorded as a separate event; statement text remains unchanged.');
end $function$



CREATE OR REPLACE FUNCTION game.start_case_interview(p_case_ref text, p_person_ref text, p_method text, p_purpose text, p_location text, p_notes text, p_actor_ref text, p_command_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_case game.cases%rowtype; v_person game.persons%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_interview game.case_interviews%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed case cannot receive a new interview.'); end if;
 select * into v_person from game.persons where person_ref=btrim(p_person_ref) and person_status='active';
 if not found then return jsonb_build_object('ok',false,'code','interviewee_unavailable','message','The interviewee must resolve to an existing active person.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','interviewer_unavailable','message','The interviewer must be active or seconded.'); end if;
 if v_case.lead_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active') then
 return jsonb_build_object('ok',false,'code','not_assigned','message','The interviewer must be the case lead or hold an active case assignment.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording an interview.'); end if;
 if length(btrim(coalesce(p_method,''))) not between 2 and 100 or length(btrim(coalesce(p_purpose,''))) not between 3 and 2000 then
 return jsonb_build_object('ok',false,'code','invalid_interview','message','Interview method or purpose is outside the permitted length.'); end if;
 insert into game.case_interviews(case_id,interviewee_person_id,interviewer_personnel_id,method,purpose,location_description,notes,started_at_game_time,source_command_id)
 values(v_case.id,v_person.id,v_actor.id,btrim(p_method),btrim(p_purpose),nullif(btrim(p_location),''),nullif(btrim(p_notes),''),v_clock,p_command_id) returning * into v_interview;
 insert into game.case_interview_events(interview_id,case_id,event_type,actor_personnel_id,event_at_game_time,source_command_id)
 values(v_interview.id,v_case.id,'interview_started',v_actor.id,v_clock,p_command_id);
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'case_ref',v_case.case_ref,'interviewee',v_person.person_ref,'interviewer',v_actor.personnel_ref,'game_time',v_clock,'message','Interview record opened.');
end $function$



alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_interviews;
CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case interview record ([^[:space:]]+) with ([^[:space:]]+) by ([^[:space:]]+) method ([^[:space:]]+) purpose "([^"]+)"(?: location "([^"]*)")?(?: notes "([^"]*)")?$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','start_case_interview','payload',jsonb_build_object('case_ref',m[1],'person_ref',m[2],'actor_ref',m[3],'method',m[4],'purpose',m[5],'location',m[6],'notes',m[7])); end if;
 m:=regexp_match(t,'^case interview turn ([^[:space:]]+) by ([^[:space:]]+) question "([^"]+)" answer "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_case_interview_turn','payload',jsonb_build_object('interview_ref',m[1],'actor_ref',m[2],'question',m[3],'answer',m[4])); end if;
 m:=regexp_match(t,'^case interview status ([^[:space:]]+) set (concluded|interrupted) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','set_case_interview_status','payload',jsonb_build_object('interview_ref',m[1],'status',lower(m[2]),'reason',m[3],'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case witness statement record ([^[:space:]]+) for ([^[:space:]]+) form (written_signed|written_unsigned|officer_recorded|dictated|recorded_media) text "([^"]+)"(?: supplements ([^[:space:]]+))? by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_case_witness_statement','payload',jsonb_build_object('case_ref',m[1],'person_ref',m[2],'form',lower(m[3]),'statement_text',m[4],'supplements_ref',m[5],'actor_ref',m[6])); end if;
 m:=regexp_match(t,'^case witness statement status ([^[:space:]]+) set (adopted|not_adopted|refused_to_sign) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','set_case_witness_statement_status','payload',jsonb_build_object('statement_ref',m[1],'status',lower(m[2]),'reason',m[3],'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case interviews ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_interviews','payload',jsonb_build_object('case_ref',m[1])); end if;
 m:=regexp_match(t,'^case interview transcript ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_interview_transcript','payload',jsonb_build_object('interview_ref',m[1])); end if;
 m:=regexp_match(t,'^case witness statements ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_witness_statements','payload',jsonb_build_object('case_ref',m[1])); end if;
 return game.interpret_text_command_before_case_interviews(p_command_text);
end $function$

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_interviews;
CREATE OR REPLACE FUNCTION game.execute_text_command(p_command_text text, p_idempotency_key text, p_session_id uuid DEFAULT NULL::uuid, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype; v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('start_case_interview','record_case_interview_turn','set_case_interview_status','record_case_witness_statement','set_case_witness_statement_status','list_case_interviews','get_case_interview_transcript','list_case_witness_statements') then
  v_result:=game.execute_text_command_before_case_interviews(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if v_type='help' and coalesce((v_result->>'ok')::boolean,false) then return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('start_case_interview','record_case_interview_turn','set_case_interview_status','record_case_witness_statement','set_case_witness_statement_status','list_case_interviews','get_case_interview_transcript','list_case_witness_statements')); end if;
  return v_result;
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type in ('start_case_interview','record_case_interview_turn','set_case_interview_status','record_case_witness_statement','set_case_witness_statement_status') then
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  elsif v_type='start_case_interview' then v_result:=game.start_case_interview(v_payload->>'case_ref',v_payload->>'person_ref',v_payload->>'method',v_payload->>'purpose',v_payload->>'location',v_payload->>'notes',v_payload->>'actor_ref',v_cmd.id);
  elsif v_type='record_case_interview_turn' then v_result:=game.record_case_interview_turn(v_payload->>'interview_ref',v_payload->>'question',v_payload->>'answer',v_payload->>'actor_ref',v_cmd.id);
  elsif v_type='set_case_interview_status' then v_result:=game.set_case_interview_status(v_payload->>'interview_ref',v_payload->>'status',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  elsif v_type='record_case_witness_statement' then v_result:=game.record_case_witness_statement(v_payload->>'case_ref',null,v_payload->>'person_ref',v_payload->>'form',v_payload->>'statement_text',v_payload->>'supplements_ref',v_payload->>'actor_ref',v_cmd.id);
  else v_result:=game.set_case_witness_statement_status(v_payload->>'statement_ref',v_payload->>'status',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id); end if;
 else
  if v_type='list_case_interviews' then v_result:=game.get_case_interviews(v_payload->>'case_ref');
  elsif v_type='get_case_interview_transcript' then v_result:=game.get_case_interview_transcript(v_payload->>'interview_ref');
  else v_result:=game.get_case_witness_statements(v_payload->>'case_ref'); end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Interview or witness statement command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $function$


revoke all on game.case_interviews,game.case_interview_events,game.case_interview_turns,game.case_witness_statements,game.case_witness_statement_events from public,anon,authenticated;
grant select,insert on game.case_interviews,game.case_interview_events,game.case_interview_turns,game.case_witness_statements,game.case_witness_statement_events to service_role;
grant usage,select on sequence game.case_interview_ref_seq,game.case_interview_turn_ref_seq,game.case_witness_statement_ref_seq to service_role;
revoke all on function game.start_case_interview(text,text,text,text,text,text,text,uuid),game.record_case_interview_turn(text,text,text,text,uuid),game.record_case_witness_statement(text,text,text,text,text,text,text,uuid),game.set_case_interview_status(text,text,text,text,uuid),game.set_case_witness_statement_status(text,text,text,text,uuid),game.get_case_interviews(text),game.get_case_interview_transcript(text),game.get_case_witness_statements(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.start_case_interview(text,text,text,text,text,text,text,uuid),game.record_case_interview_turn(text,text,text,text,uuid),game.record_case_witness_statement(text,text,text,text,text,text,text,uuid),game.set_case_interview_status(text,text,text,text,uuid),game.set_case_witness_statement_status(text,text,text,text,uuid),game.get_case_interviews(text),game.get_case_interview_transcript(text),game.get_case_witness_statements(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
