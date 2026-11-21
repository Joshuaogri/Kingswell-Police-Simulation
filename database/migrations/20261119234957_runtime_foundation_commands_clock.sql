-- Kingswell runtime foundation: command intake, idempotency, clock and event audit.
-- The fictional calendar start is intentionally unconfigured; no canon date is invented.

alter table game.simulation_state
  alter column current_game_time drop not null;

insert into game.simulation_state
  (id, world_name, current_game_time, time_paused, time_scale)
values
  (1, 'Kingswell', null, true, 1)
on conflict (id) do nothing;

create table game.game_commands (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text not null unique,
  session_id uuid,
  actor_personnel_id uuid references game.police_personnel(id),
  command_text text not null,
  command_type text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'received'
    check (status in ('received','completed','rejected','failed')),
  result jsonb,
  rejection_reason text,
  received_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint game_commands_text_length check (char_length(command_text) between 1 and 4000),
  constraint game_commands_payload_object check (jsonb_typeof(payload) = 'object'),
  constraint game_commands_idempotency_length check (char_length(idempotency_key) between 8 and 200)
);

create index idx_game_commands_session_received
  on game.game_commands(session_id, received_at desc);
create index idx_game_commands_actor_received
  on game.game_commands(actor_personnel_id, received_at desc);

create table game.game_clock_history (
  id bigint generated always as identity primary key,
  command_id uuid not null unique references game.game_commands(id),
  previous_game_time timestamptz,
  resulting_game_time timestamptz not null,
  advancement_minutes integer not null default 0,
  reason text not null,
  recorded_at timestamptz not null default now()
);

alter table game.game_commands enable row level security;
alter table game.game_clock_history enable row level security;

create or replace function game.submit_command(
  p_command_text text,
  p_command_type text,
  p_payload jsonb default '{}'::jsonb,
  p_idempotency_key text default null,
  p_session_id uuid default null,
  p_actor_personnel_id uuid default null
) returns jsonb
language plpgsql
security invoker
set search_path = pg_catalog, game
as $function$
declare
  v_command game.game_commands%rowtype;
  v_clock game.simulation_state%rowtype;
  v_new_time timestamptz;
  v_minutes integer;
  v_start_text text;
  v_result jsonb;
begin
  if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then
    raise exception 'Command text must contain between 1 and 4000 characters';
  end if;
  if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
    raise exception 'A unique idempotency key between 8 and 200 characters is required';
  end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'Command payload must be a JSON object';
  end if;

  insert into game.game_commands
    (idempotency_key, session_id, actor_personnel_id, command_text, command_type, payload)
  values
    (p_idempotency_key, p_session_id, p_actor_personnel_id, p_command_text, lower(btrim(p_command_type)), p_payload)
  on conflict (idempotency_key) do nothing;

  if not found then
    select * into v_command from game.game_commands
      where idempotency_key = p_idempotency_key for update;
    if v_command.command_text <> p_command_text
       or v_command.command_type <> lower(btrim(p_command_type))
       or v_command.payload <> p_payload then
      return jsonb_build_object(
        'ok', false, 'code', 'idempotency_conflict',
        'message', 'This command key was already used for a different command.',
        'command_id', v_command.id
      );
    end if;
    return coalesce(v_command.result, jsonb_build_object(
      'ok', v_command.status = 'completed',
      'status', v_command.status,
      'command_id', v_command.id,
      'message', 'Previously received command; no duplicate action was executed.'
    )) || jsonb_build_object('duplicate', true);
  end if;

  select * into v_command from game.game_commands
    where idempotency_key = p_idempotency_key for update;

  if v_command.command_type = 'help' then
    v_result := jsonb_build_object(
      'ok', true, 'status', 'completed', 'command_id', v_command.id,
      'available_commands', jsonb_build_array('help','status','initialize_clock','advance_time'),
      'note', 'Domain actions will be registered as their owning game systems are implemented.'
    );

  elsif v_command.command_type = 'status' then
    select * into v_clock from game.simulation_state where id = 1;
    v_result := jsonb_build_object(
      'ok', true, 'status', 'completed', 'command_id', v_command.id,
      'world', coalesce(v_clock.world_name, 'Kingswell'),
      'clock_initialized', v_clock.current_game_time is not null,
      'game_time', v_clock.current_game_time,
      'time_paused', coalesce(v_clock.time_paused, true),
      'time_scale', coalesce(v_clock.time_scale, 1)
    );

  elsif v_command.command_type = 'initialize_clock' then
    v_start_text := p_payload ->> 'start_at';
    if v_start_text is null or not pg_input_is_valid(v_start_text, 'timestamptz') then
      update game.game_commands set status='rejected',
        rejection_reason='Provide a valid explicit fictional start_at timestamp.',
        result=jsonb_build_object('ok',false,'code','invalid_start_time',
          'message','The fictional game clock needs an explicitly chosen start date and time.')
        where id=v_command.id;
      update game.game_commands set completed_at=now() where id=v_command.id;
      return (select result from game.game_commands where id=v_command.id);
    end if;

    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is not null then
      update game.game_commands set status='rejected',
        rejection_reason='The authoritative game clock is already initialized.',
        result=jsonb_build_object('ok',false,'code','clock_already_initialized',
          'message','The game clock is already initialized; use a controlled clock correction workflow.')
        where id=v_command.id;
      update game.game_commands set completed_at=now() where id=v_command.id;
      return (select result from game.game_commands where id=v_command.id);
    end if;

    v_new_time := v_start_text::timestamptz;
    update game.simulation_state
      set current_game_time=v_new_time, time_paused=true, updated_at=now()
      where id=1;
    insert into game.game_clock_history
      (command_id, previous_game_time, resulting_game_time, advancement_minutes, reason)
    values (v_command.id, null, v_new_time, 0, 'Explicit initial fictional clock configuration');
    insert into game.game_events
      (event_key, game_time, actor_personnel_id, entity_type, event_data)
    values ('runtime.clock.initialized', v_new_time, p_actor_personnel_id, 'simulation_clock',
      jsonb_build_object('command_id',v_command.id,'resulting_game_time',v_new_time));
    v_result := jsonb_build_object(
      'ok',true,'status','completed','command_id',v_command.id,
      'clock_initialized',true,'game_time',v_new_time,'time_paused',true
    );

  elsif v_command.command_type = 'advance_time' then
    if jsonb_typeof(p_payload -> 'minutes') <> 'number' then
      update game.game_commands set status='rejected',
        rejection_reason='A positive integer minutes value is required.',
        result=jsonb_build_object('ok',false,'code','invalid_duration',
          'message','Provide minutes as a positive whole number (maximum 1440 per command).')
        where id=v_command.id;
      update game.game_commands set completed_at=now() where id=v_command.id;
      return (select result from game.game_commands where id=v_command.id);
    end if;
    v_minutes := (p_payload ->> 'minutes')::integer;
    if v_minutes < 1 or v_minutes > 1440 then
      update game.game_commands set status='rejected',
        rejection_reason='Requested duration is outside the allowed 1–1440 minute range.',
        result=jsonb_build_object('ok',false,'code','duration_out_of_range',
          'message','Time advancement must be between 1 and 1440 minutes per command.')
        where id=v_command.id;
      update game.game_commands set completed_at=now() where id=v_command.id;
      return (select result from game.game_commands where id=v_command.id);
    end if;

    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      update game.game_commands set status='rejected',
        rejection_reason='The fictional game clock has not been initialized.',
        result=jsonb_build_object('ok',false,'code','clock_not_initialized',
          'message','The game clock has no configured fictional start date and time yet.')
        where id=v_command.id;
      update game.game_commands set completed_at=now() where id=v_command.id;
      return (select result from game.game_commands where id=v_command.id);
    end if;

    v_new_time := v_clock.current_game_time + make_interval(mins => v_minutes);
    update game.simulation_state set current_game_time=v_new_time, updated_at=now() where id=1;
    insert into game.game_clock_history
      (command_id, previous_game_time, resulting_game_time, advancement_minutes, reason)
    values (v_command.id, v_clock.current_game_time, v_new_time, v_minutes,
      coalesce(nullif(p_payload ->> 'reason',''), 'Explicit player time-advance command'));
    insert into game.game_events
      (event_key, game_time, actor_personnel_id, entity_type, event_data)
    values ('runtime.clock.advanced', v_new_time, p_actor_personnel_id, 'simulation_clock',
      jsonb_build_object('command_id',v_command.id,'previous_game_time',v_clock.current_game_time,
        'resulting_game_time',v_new_time,'minutes',v_minutes,
        'reason',coalesce(nullif(p_payload ->> 'reason',''),'Explicit player time-advance command')));
    v_result := jsonb_build_object(
      'ok',true,'status','completed','command_id',v_command.id,
      'previous_game_time',v_clock.current_game_time,'game_time',v_new_time,
      'advanced_minutes',v_minutes,'time_paused',v_clock.time_paused
    );

  else
    v_result := jsonb_build_object(
      'ok',false,'code','unknown_command',
      'message','This command is not registered in the runtime yet.',
      'command_type',v_command.command_type
    );
    update game.game_commands set status='rejected',
      rejection_reason='Command type is not registered.', result=v_result,
      completed_at=now() where id=v_command.id;
    return v_result || jsonb_build_object('command_id',v_command.id);
  end if;

  update game.game_commands set status='completed', result=v_result, completed_at=now()
    where id=v_command.id;
  return v_result;
end;
$function$;

revoke all on function game.submit_command(text,text,jsonb,text,uuid,uuid) from public, anon, authenticated;
