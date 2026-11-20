-- Kingswell BP-02 complete neighbourhood road network seed.
-- Applied Supabase migration version: 20261120110935.
-- Fictional local-grid metres; additive network extension; no real-world geodata.
do $$
declare
 n record; s record; v_city uuid; v_district uuid; v_neighbourhood uuid;
 v_road uuid; v_a uuid; v_b uuid; v_nearest uuid; v_road_code text;
 v_len integer;
begin
 select id into v_city from game.cities where code='KNG';
 for n in select * from (values
 ('KDW-01',2200,9000),('KDW-02',3800,11200),('KNA-01',6800,13700),('KNA-02',8800,12200),
 ('KCI-01',8500,8200),('KCI-02',10800,10000),('KCB-01',11800,10500),('KCB-02',14000,8200),
 ('KED-01',3600,14500),('KED-02',5600,12800),('KST-01',9000,4800),('KST-02',11000,6200),
 ('KMA-01',14000,7200),('KMA-02',16000,5600),('KIN-01',16500,11500),('KIN-02',18500,13200),
 ('KLG-01',16500,8200),('KLG-02',18500,6200),('KPT-01',15500,3500),('KPT-02',18500,1800),
 ('KAS-01',2200,3500),('KAS-02',4500,1500),('KMX-01',8500,3000),('KMX-02',6500,1200)
 ) as v(code,x,y) loop
  select id,district_id into v_neighbourhood,v_district from game.neighbourhoods where code=n.code;
  v_road_code:='KNG-L-'||replace(n.code,'-','');
  if not exists(select 1 from game.roads where city_id=v_city and roads.code=v_road_code) then
   insert into game.roads(city_id,district_id,code,name,road_type)
   values(v_city,v_district,v_road_code,(select name from game.neighbourhoods where id=v_neighbourhood)||' Local Street','local');
  end if;
  select id into v_road from game.roads where city_id=v_city and roads.code=v_road_code;
  for s in select * from (values
   ('A','Northwest',-250,250),('B','Northeast',250,250),('C','Southeast',250,-250),('D','Southwest',-250,-250)
  ) as q(suffix,label,dx,dy) loop
   insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type,access_profile)
   values(v_city,n.code||s.suffix,n.code||' '||s.label,n.x+s.dx,n.y+s.dy,'local_intersection','public')
   on conflict(city_id,junction_code) do nothing;
  end loop;
  for s in select * from (values ('A','B','01'),('B','C','02'),('C','D','03'),('D','A','04')) as q(fs,ts,sq) loop
   select id into v_a from game.road_junctions where city_id=v_city and junction_code=n.code||s.fs;
   select id into v_b from game.road_junctions where city_id=v_city and junction_code=n.code||s.ts;
   select greatest(1,round(sqrt((ja.x_m-jb.x_m)::numeric^2+(ja.y_m-jb.y_m)::numeric^2))::integer)
    into v_len from game.road_junctions ja,game.road_junctions jb where ja.id=v_a and jb.id=v_b;
   if not exists(select 1 from game.road_segments where city_id=v_city and segment_code='N-'||replace(n.code,'-','')||'-'||s.sq) then
    insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,
     road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
    values(v_city,v_road,'N-'||replace(n.code,'-','')||'-'||s.sq,v_a,v_b,v_len,'local',1,20,'two_way','sealed','at_grade','public');
   end if;
  end loop;
  select id into v_a from game.road_junctions where city_id=v_city and junction_code=n.code||'A';
  select j.id into v_nearest from game.road_junctions j where j.city_id=v_city and j.junction_code like 'J%'
   order by (j.x_m-(n.x-250))::bigint*(j.x_m-(n.x-250))::bigint+(j.y_m-(n.y+250))::bigint*(j.y_m-(n.y+250))::bigint limit 1;
  select greatest(1,round(sqrt((ja.x_m-jb.x_m)::numeric^2+(ja.y_m-jb.y_m)::numeric^2))::integer)
   into v_len from game.road_junctions ja,game.road_junctions jb where ja.id=v_a and jb.id=v_nearest;
  if not exists(select 1 from game.road_segments where city_id=v_city and segment_code='N-'||replace(n.code,'-','')||'-05') then
   insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,
    road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
   values(v_city,v_road,'N-'||replace(n.code,'-','')||'-05',v_a,v_nearest,v_len,'local_collector',1,30,'two_way','sealed','at_grade','public');
  end if;
 end loop;
 for n in select * from (values
 ('RB01',11600,12600,10500,'KNG-BR01','KMX','East River Bridge North'),
 ('RB02',11600,12600,6500,'KNG-BR02','KMX','Riverside Bridge'),
 ('RB03',11600,12600,2800,'KNG-BR03','KPT','Harbour River Bridge')
 ) as v(code,wx,ex,y,road_code,district_code,road_name) loop
  select id into v_district from game.districts where city_id=v_city and code=n.district_code;
  if not exists(select 1 from game.roads where city_id=v_city and code=n.road_code) then
   insert into game.roads(city_id,district_id,code,name,road_type) values(v_city,v_district,n.road_code,n.road_name,'primary');
  end if;
  select id into v_road from game.roads where city_id=v_city and code=n.road_code;
  insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type,access_profile)
  values(v_city,n.code||'-W',n.code||' West Bank',n.wx,n.y,'bridge_approach','public'),
        (v_city,n.code||'-E',n.code||' East Bank',n.ex,n.y,'bridge_approach','public')
  on conflict(city_id,junction_code) do nothing;
  for s in select * from (values ('W',n.wx),('E',n.ex)) as q(side,bx) loop
   select id into v_a from game.road_junctions where city_id=v_city and junction_code=n.code||'-'||s.side;
   select id into v_nearest from game.road_junctions j where j.city_id=v_city and j.junction_code like 'J%'
    order by (j.x_m-s.bx)::bigint*(j.x_m-s.bx)::bigint+(j.y_m-n.y)::bigint*(j.y_m-n.y)::bigint limit 1;
   select greatest(1,round(sqrt((ja.x_m-jb.x_m)::numeric^2+(ja.y_m-jb.y_m)::numeric^2))::integer)
    into v_len from game.road_junctions ja,game.road_junctions jb where ja.id=v_a and jb.id=v_nearest;
   if not exists(select 1 from game.road_segments where city_id=v_city and segment_code='RIVER-'||n.code||'-'||case when s.side='W' then 'WEST' else 'EAST' end) then
    insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,
     road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
    values(v_city,v_road,'RIVER-'||n.code||'-'||s.side,v_a,v_nearest,v_len,'primary',2,50,'two_way','sealed','at_grade','public');
   end if;
  end loop;
  select id into v_a from game.road_junctions where city_id=v_city and junction_code=n.code||'-W';
  select id into v_b from game.road_junctions where city_id=v_city and junction_code=n.code||'-E';
  if not exists(select 1 from game.road_segments where city_id=v_city and segment_code='RIVER-'||n.code||'-BRIDGE') then
   insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,
    road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
   values(v_city,v_road,'RIVER-'||n.code||'-BRIDGE',v_a,v_b,n.ex-n.wx,'primary',2,50,'two_way','sealed','bridge','public');
  end if;
 end loop;
end $;

update game.road_segments s set access_profile='public_emergency_freight'
from game.roads r where r.id=s.road_id and r.code in ('KNG-R008','KNG-R009');
