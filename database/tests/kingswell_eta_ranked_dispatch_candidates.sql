begin;
do $test$
declare
 v_clock timestamptz:='2026-11-20 12:00:00+00';
 v_facility uuid; v_station uuid; v_property uuid; v_destination uuid;
 v_person1 uuid; v_person2 uuid; v_unit1 uuid; v_unit2 uuid; v_pp1 uuid; v_pp2 uuid;
 v_roster1 uuid; v_roster2 uuid; v_incident uuid; v_first record; v_second record;
begin
 if exists(select 1 from game.police_units) or exists(select 1 from game.incidents) then raise exception 'ETA ranking test requires empty units and incidents'; end if;
 update game.simulation_state set current_game_time=v_clock,time_paused=true where id=1;
 select id into v_facility from game.police_facilities where status='active' order by facility_ref limit 1;
 select id from game.police_stations where station_ref='KNG-STA-HQ' into v_station;
 select p.id,ap.id into v_property,v_destination from game.properties p
 join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
 join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
 where p.status='active' and p.id<>(select property_id from game.police_facilities where id=v_facility)
 order by p.property_ref limit 1;
 insert into game.persons(person_ref,given_name,family_name,person_status,occupation) values
 ('KNG-TEST-ETA-PERSON-01','ETA','One','active','Police officer'),
 ('KNG-TEST-ETA-PERSON-02','ETA','Two','active','Police officer');
 select id into v_person1 from game.persons where person_ref='KNG-TEST-ETA-PERSON-01';
 select id into v_person2 from game.persons where person_ref='KNG-TEST-ETA-PERSON-02';
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,station_id)
 values('KNG-TEST-ETA-UNIT-01','Farther Unit','patrol','active',v_facility,v_station) returning id into v_unit1;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,station_id,current_access_point_id)
 values('KNG-TEST-ETA-UNIT-02','At Scene Unit','patrol','active',v_facility,v_station,v_destination) returning id into v_unit2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,current_station_id,employment_status,joined_on)
 values('KNG-TEST-ETA-OFFICER-01',v_person1,'KNG-TEST-ETA-SN-01',v_unit1,v_station,'active','2024-01-01') returning id into v_pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,current_station_id,employment_status,joined_on)
 values('KNG-TEST-ETA-OFFICER-02',v_person2,'KNG-TEST-ETA-SN-02',v_unit2,v_station,'active','2024-01-01') returning id into v_pp2;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-TEST-ETA-ROSTER-01',v_unit1,'ETA test',v_clock-interval '1 hour',v_clock+interval '8 hours','active') returning id into v_roster1;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-TEST-ETA-ROSTER-02',v_unit2,'ETA test',v_clock-interval '1 hour',v_clock+interval '8 hours','active') returning id into v_roster2;
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,assigned_station_id,starts_at,ends_at,status) values
 (v_roster1,v_pp1,'patrol officer',v_station,v_clock-interval '1 hour',v_clock+interval '8 hours','on_duty'),
 (v_roster2,v_pp2,'patrol officer',v_station,v_clock-interval '1 hour',v_clock+interval '8 hours','on_duty');
 insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary,details)
 values('KNG-TEST-ETA-INCIDENT-01',v_clock,v_property,'ETA ranking test',3,'new','ETA ranking','{"fixture":true}') returning id into v_incident;
 select * into v_first from game.get_dispatch_candidates_ranked('KNG-TEST-ETA-INCIDENT-01') limit 1;
 select * into v_second from game.get_dispatch_candidates_ranked('KNG-TEST-ETA-INCIDENT-01') offset 1 limit 1;
 if v_first.unit_ref<>'KNG-TEST-ETA-UNIT-02' then raise exception 'Nearest ETA unit not ranked first: %',row_to_json(v_first); end if;
 if v_first.estimated_arrival_at is null or v_second.estimated_arrival_at is null
   or v_first.estimated_arrival_at>v_second.estimated_arrival_at then raise exception 'Candidates not ETA ordered'; end if;
end
$test$;
rollback;