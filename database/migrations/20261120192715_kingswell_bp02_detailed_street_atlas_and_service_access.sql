-- BP-02 detailed Kingswell road atlas v0.3; additive, fictional local-grid data.
alter table game.roads add column if not exists official_name text, add column if not exists name_origin text not null default 'Kingswell Municipal Gazetteer', add column if not exists maintenance_class text not null default 'standard', add column if not exists map_version text not null default 'KNG-MAP-0.3';
alter table game.road_junctions add column if not exists control_type text not null default 'uncontrolled', add column if not exists signal_cycle_seconds integer, add column if not exists pedestrian_crossing boolean not null default false, add column if not exists tactile_crossing boolean not null default false, add column if not exists lighting_standard text not null default 'standard', add column if not exists grade_separation_m numeric(6,2) not null default 0, add column if not exists map_version text not null default 'KNG-MAP-0.3';
alter table game.road_segments add column if not exists geometry_local_m jsonb, add column if not exists carriageway_width_m numeric(6,2), add column if not exists lane_marking text not null default 'standard', add column if not exists median_type text not null default 'none', add column if not exists has_sidewalk boolean not null default true, add column if not exists has_cycle_lane boolean not null default false, add column if not exists has_street_lighting boolean not null default true, add column if not exists has_on_street_parking boolean not null default false, add column if not exists road_condition text not null default 'good', add column if not exists elevation_change_m numeric(7,2) not null default 0, add column if not exists geometry_source text not null default 'authored_fictional_local_grid', add column if not exists map_version text not null default 'KNG-MAP-0.3';

create table if not exists game.road_turn_restrictions (
 id uuid primary key default gen_random_uuid(),restriction_ref text not null unique,city_id uuid not null references game.cities(id),
 incoming_segment_id uuid not null references game.road_segments(id),via_junction_id uuid not null references game.road_junctions(id),
 outgoing_segment_id uuid not null references game.road_segments(id),restriction_kind text not null check(restriction_kind in ('prohibited','only')),
 turn_type text not null check(turn_type in ('no_left','no_right','no_u_turn','no_straight','only_left','only_right','only_straight','vehicle_specific')),
 vehicle_profiles text[] not null default array['public','police','emergency']::text[],valid_from timestamptz,valid_until timestamptz,
 active boolean not null default true,reason text not null,created_at timestamptz not null default now(),
 check(incoming_segment_id<>outgoing_segment_id or turn_type='no_u_turn'),check(valid_until is null or valid_from is null or valid_until>valid_from));
create index if not exists road_turn_restrictions_lookup_idx on game.road_turn_restrictions(incoming_segment_id,via_junction_id,active);

create table if not exists game.road_segment_traffic_profiles (
 id uuid primary key default gen_random_uuid(),profile_ref text not null unique,road_segment_id uuid not null references game.road_segments(id),
 profile_name text not null,day_of_week smallint[] not null,starts_at time not null,ends_at time not null,
 speed_multiplier numeric(5,3) not null check(speed_multiplier>0 and speed_multiplier<=2),
 fixed_delay_seconds integer not null default 0 check(fixed_delay_seconds>=0),
 applies_to text[] not null default array['public','police','emergency']::text[],active boolean not null default true,
 created_at timestamptz not null default now(),check(starts_at<>ends_at));
create index if not exists road_segment_traffic_profiles_lookup_idx on game.road_segment_traffic_profiles(road_segment_id,active,starts_at,ends_at);

create table if not exists game.road_segment_conditions (
 id uuid primary key default gen_random_uuid(),condition_ref text not null unique,road_segment_id uuid not null references game.road_segments(id),
 condition_type text not null check(condition_type in ('collision','roadworks','flooding','weather_hazard','public_event','police_cordon','bridge_lift','surface_damage','other')),
 severity text not null check(severity in ('low','moderate','high','critical')),description text not null,starts_at timestamptz not null,ends_at timestamptz,
 speed_multiplier numeric(5,3) not null default 1 check(speed_multiplier>0 and speed_multiplier<=2),delay_seconds integer not null default 0 check(delay_seconds>=0),
 is_closed boolean not null default false,closed_to_profiles text[] not null default array[]::text[],emergency_override boolean not null default false,
 source_type text not null default 'simulation',source_ref text,active boolean not null default true,created_at timestamptz not null default now(),
 check(ends_at is null or ends_at>starts_at));
create index if not exists road_segment_conditions_active_idx on game.road_segment_conditions(road_segment_id,active,starts_at,ends_at);

-- Add a named rear service lane in each of the 24 neighbourhoods, with two connected segments.
insert into game.roads(city_id,district_id,code,name,road_type,official_name,maintenance_class,map_version)
select d.city_id,d.id,'KNG-SL-'||replace(n.code,'-',''),n.name||' Rear Service Lane','service',n.name||' Rear Service Lane','local_service','KNG-MAP-0.3'
from game.neighbourhoods n join game.districts d on d.id=n.district_id
where d.city_id=(select id from game.cities where code='KNG')
and not exists(select 1 from game.roads r where r.city_id=d.city_id and r.code='KNG-SL-'||replace(n.code,'-',''));
insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type,access_profile,control_type,pedestrian_crossing,map_version)
select d.city_id,n.code||'-SL01',n.name||' Service Lane Midpoint',
 round((a.x_m+b.x_m)/2.0)::integer,round((a.y_m+b.y_m)/2.0+65)::integer,
 'service_lane_access','public','uncontrolled',true,'KNG-MAP-0.3'
from game.neighbourhoods n join game.districts d on d.id=n.district_id
join game.road_junctions a on a.city_id=d.city_id and a.junction_code=n.code||'A'
join game.road_junctions b on b.city_id=d.city_id and b.junction_code=n.code||'B'
where d.city_id=(select id from game.cities where code='KNG')
on conflict(city_id,junction_code) do nothing;
with n as (
 select d.city_id,n.code,n.name,r.id road_id,a.id a_id,b.id b_id,m.id mid_id
 from game.neighbourhoods n join game.districts d on d.id=n.district_id
 join game.roads r on r.city_id=d.city_id and r.code='KNG-SL-'||replace(n.code,'-','')
 join game.road_junctions a on a.city_id=d.city_id and a.junction_code=n.code||'A'
 join game.road_junctions b on b.city_id=d.city_id and b.junction_code=n.code||'B'
 join game.road_junctions m on m.city_id=d.city_id and m.junction_code=n.code||'-SL01'
 where d.city_id=(select id from game.cities where code='KNG')
), edges as (
 select n.*, 'SL-'||replace(code,'-','')||'-01' seg_code,a_id from_junction,mid_id to_junction from n
 union all
 select n.*, 'SL-'||replace(code,'-','')||'-02',mid_id,a_id from n where false
), all_edges as (
 select n.city_id,n.road_id,'SL-'||replace(n.code,'-','')||'-01' seg_code,n.a_id from_junction,n.mid_id to_junction from n
 union all
 select n.city_id,n.road_id,'SL-'||replace(n.code,'-','')||'-02',n.mid_id,n.b_id from n
)
insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
select e.city_id,e.road_id,e.seg_code,e.from_junction,e.to_junction,
 greatest(1,round(sqrt((a.x_m-b.x_m)::numeric^2+(a.y_m-b.y_m)::numeric^2))::integer),
 'service_lane',1,15,'two_way','sealed','at_grade','public'
from all_edges e join game.road_junctions a on a.id=e.from_junction join game.road_junctions b on b.id=e.to_junction
where not exists(select 1 from game.road_segments s where s.city_id=e.city_id and s.segment_code=e.seg_code);

-- One-way clockwise neighbourhood loops; collector links and service lanes remain two-way.
update game.road_segments set directionality='one_way_forward' where segment_code ~ '^N-[A-Z]{3}[0-9]{2}-0[1-4]$';

update game.road_segments s set carriageway_width_m=case when road_class='primary' then greatest(12,lanes_each_direction*3.4*2) when road_class='local_collector' then 8.5 when road_class='service_lane' then 5.5 else 6.5 end,
 lane_marking=case when road_class='primary' then 'divided_centre_and_lane_lines' when road_class='local_collector' then 'centre_line' when road_class='service_lane' then 'shared_low_speed' else 'edge_markings' end,
 median_type=case when road_class='primary' and lanes_each_direction>=2 then 'raised_or_painted' else 'none' end,
 has_sidewalk=road_class<>'service_lane',has_cycle_lane=road_class in ('primary','local_collector') and segment_length_m>250,
 has_street_lighting=true,has_on_street_parking=road_class in ('local','service_lane'),road_condition='good',map_version='KNG-MAP-0.3';

with e as (
 select s.id,s.segment_code,s.crossing_type,a.x_m x1,a.y_m y1,b.x_m x2,b.y_m y2
 from game.road_segments s join game.road_junctions a on a.id=s.from_junction_id join game.road_junctions b on b.id=s.to_junction_id
 where s.city_id=(select id from game.cities where code='KNG')
), b as (
 select *,case when crossing_type='bridge' then 0 else (mod(abs(hashtext(segment_code)),9)-4)*9 end::numeric off_m,
 greatest(1,sqrt((x2-x1)::numeric^2+(y2-y1)::numeric^2)) len from e
), m as (
 select *, (x1+x2)/2.0+(-(y2-y1)/len)*off_m mx,(y1+y2)/2.0+((x2-x1)/len)*off_m my from b
)
update game.road_segments s set geometry_local_m=jsonb_build_array(jsonb_build_array(m.x1,m.y1),
 jsonb_build_array(round(m.x1+(m.mx-m.x1)/3.0)::integer,round(m.y1+(m.my-m.y1)/3.0)::integer),
 jsonb_build_array(round(m.x1+2*(m.mx-m.x1)/3.0)::integer,round(m.y1+2*(m.my-m.y1)/3.0)::integer),
 jsonb_build_array(m.x2,m.y2)),geometry_source='authored_fictional_local_grid',map_version='KNG-MAP-0.3' from m where m.id=s.id;

with vertices as (
 select s.id,p.ord,(p.value->>0)::numeric x,(p.value->>1)::numeric y,
 lag((p.value->>0)::numeric) over(partition by s.id order by p.ord) px,
 lag((p.value->>1)::numeric) over(partition by s.id order by p.ord) py
 from game.road_segments s cross join lateral jsonb_array_elements(s.geometry_local_m) with ordinality p(value,ord)
), lengths as (select id,sum(sqrt((x-px)^2+(y-py)^2)) metres from vertices where px is not null group by id)
update game.road_segments s set segment_length_m=greatest(1,round(l.metres)::integer) from lengths l where l.id=s.id;

insert into game.property_access_points(access_ref,property_id,building_id,road_segment_id,nearest_junction_id,access_type,x_m,y_m,access_profile,is_primary)
select p.property_ref||'-SEC',p.id,b.id,p.frontage_segment_id,
 case when sqrt((j1.x_m-p.x_m)::numeric^2+(j1.y_m-p.y_m)::numeric^2)<=sqrt((j2.x_m-p.x_m)::numeric^2+(j2.y_m-p.y_m)::numeric^2) then j1.id else j2.id end,
 case when p.land_use in ('industrial','logistics','port_and_maritime','aviation') then 'rear_loading_and_service_entrance' when p.property_type='residential_highrise' then 'secondary_garage_and_service_entrance' else 'rear_service_entrance' end,
 p.x_m+12,p.y_m+8,coalesce(ap.access_profile,'public'),false
from game.properties p left join game.buildings b on b.property_id=p.id join game.road_segments s on s.id=p.frontage_segment_id
join game.road_junctions j1 on j1.id=s.from_junction_id join game.road_junctions j2 on j2.id=s.to_junction_id
left join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
where p.city_id=(select id from game.cities where code='KNG') and p.land_use<>'residential'
and not exists(select 1 from game.property_access_points x where x.access_ref=p.property_ref||'-SEC')
on conflict do nothing;

insert into game.road_segment_traffic_profiles(profile_ref,road_segment_id,profile_name,day_of_week,starts_at,ends_at,speed_multiplier,fixed_delay_seconds)
select 'KNG-TRAFFIC-AM-'||s.segment_code,s.id,'Weekday morning peak',array[1,2,3,4,5]::smallint[],time '07:00',time '09:30',
case when s.road_class in ('primary','local_collector') then .58 else .72 end,case when s.road_class='primary' then 35 else 15 end
from game.road_segments s where s.city_id=(select id from game.cities where code='KNG') on conflict(profile_ref) do nothing;
insert into game.road_segment_traffic_profiles(profile_ref,road_segment_id,profile_name,day_of_week,starts_at,ends_at,speed_multiplier,fixed_delay_seconds)
select 'KNG-TRAFFIC-PM-'||s.segment_code,s.id,'Weekday evening peak',array[1,2,3,4,5]::smallint[],time '16:00',time '19:00',
case when s.road_class in ('primary','local_collector') then .52 else .68 end,case when s.road_class='primary' then 45 else 18 end
from game.road_segments s where s.city_id=(select id from game.cities where code='KNG') on conflict(profile_ref) do nothing;

update game.road_junctions set control_type=case when junction_code in ('J001','J002','J003','J004','J005','J006','J007','J008') then 'signalised' else 'priority_or_uncontrolled' end,
 signal_cycle_seconds=case when junction_code in ('J001','J002','J003','J004','J005','J006','J007','J008') then 90 else null end,
 pedestrian_crossing=true,tactile_crossing=true,lighting_standard='LED_standard',map_version='KNG-MAP-0.3'
where city_id=(select id from game.cities where code='KNG');

alter table game.road_turn_restrictions enable row level security;
alter table game.road_segment_traffic_profiles enable row level security;
alter table game.road_segment_conditions enable row level security;
revoke all on game.road_turn_restrictions,game.road_segment_traffic_profiles,game.road_segment_conditions from public,anon,authenticated;
grant all on game.road_turn_restrictions,game.road_segment_traffic_profiles,game.road_segment_conditions to service_role;
