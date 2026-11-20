-- Kingswell BP-02 complete neighbourhood road network.
-- Additive, idempotent seed migration; local-grid metres; no real-world geodata.
-- The 24 neighbourhood street loops each attach to the existing arterial graph.
do $$
declare n record; s record; c uuid; d uuid; h uuid; r uuid; a uuid; b uuid; nearest uuid;
        code text; x integer; y integer; seq text; len integer;
begin
 select id into c from game.cities where code='KNG';
 for n in select * from (values
 ('KDW-01',2200,9000),('KDW-02',3800,11200),('KNA-01',6800,13700),('KNA-02',8800,12200),
 ('KCI-01',8500,8200),('KCI-02',10800,10000),('KCB-01',11800,10500),('KCB-02',14000,8200),
 ('KED-01',3600,14500),('KED-02',5600,12800),('KST-01',9000,4800),('KST-02',11000,6200),
 ('KMA-01',14000,7200),('KMA-02',16000,5600),('KIN-01',16500,11500),('KIN-02',18500,13200),
 ('KLG-01',16500,8200),('KLG-02',18500,6200),('KPT-01',15500,3500),('KPT-02',18500,1800),
 ('KAS-01',2200,3500),('KAS-02',4500,1500),('KMX-01',8500,3000),('KMX-02',6500,1200)
 ) v(code,x,y) loop
  select id into h from game.neighbourhoods where code=n.code;
  select district_id into d from game.neighbourhoods where id=h;
  code:='KNG-L-'||replace(n.code,'-','');
  insert into game.roads(city_id,district_id,code,name,road_type)
  select c,d,code,(select name from game.neighbourhoods where id=h)||' Local Street','local'
  where not exists(select 1 from game.roads where city_id=c and roads.code=code);
  for s in select * from (values ('A','Northwest',-250,250),('B','Northeast',250,250),('C','Southeast',250,-250),('D','Southwest',-250,-250)) v(suffix,label,dx,dy) loop
   insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type)
   values(c,n.code||s.suffix,n.code||' '||s.label,n.x+s.dx,n.y+s.dy,'local_intersection')
   on conflict(city_id,junction_code) do nothing;
  end loop;
  select id into r from game.roads where city_id=c and roads.code=code;
  for s in select * from (values ('A','B','01'),('B','C','02'),('C','D','03'),('D','A','04')) v(fs,ts,sq) loop
   select id,x_m,y_m into a,x,y from game.road_junctions where city_id=c and junction_code=n.code||s.fs;
   select id into b from game.road_junctions where city_id=c and junction_code=n.code||s.ts;
   select x_m,y_m into strict x,y from game.road_junctions where id=a;
   select greatest(1,round(sqrt((ja.x_m-jb.x_m)::numeric^2+(ja.y_m-jb.y_m)::numeric^2))::integer)
    into len from game.road_junctions ja,game.road_junctions jb where ja.id=a and jb.id=b;
   insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph)
   values(c,r,'N-'||replace(n.code,'-','')||'-'||s.sq,a,b,len,'local',1,20)
   on conflict(city_id,segment_code) do nothing;
  end loop;
  select id into a from game.road_junctions where city_id=c and junction_code=n.code||'A';
  select j.id into nearest from game.road_junctions j where j.city_id=c and j.junction_code like 'J%'
  order by (j.x_m-(n.x-250))::bigint*(j.x_m-(n.x-250))::bigint+(j.y_m-(n.y+250))::bigint*(j.y_m-(n.y+250))::bigint limit 1;
  select x_m,y_m into x,y from game.road_junctions where id=a;
  select greatest(1,round(sqrt((ja.x_m-jb.x_m)::numeric^2+(ja.y_m-jb.y_m)::numeric^2))::integer)
   into len from game.road_junctions ja,game.road_junctions jb where ja.id=a and jb.id=nearest;
  insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph)
  values(c,r,'N-'||replace(n.code,'-','')||'-05',a,nearest,len,'local_collector',1,30)
  on conflict(city_id,segment_code) do nothing;
 end loop;
 -- Three explicit bridge structures, each with a west/east bank and approach links.
 for n in select * from (values ('RB01',11600,12600,10500,'KNG-BR01','KMX','East River Bridge North'),
 ('RB02',11600,12600,6500,'KNG-BR02','KMX','Riverside Bridge'),
 ('RB03',11600,12600,2800,'KNG-BR03','KPT','Harbour River Bridge')) v(code,wx,ex,y,road_code,dc,rname) loop
  select id into d from game.districts where city_id=c and districts.code=n.dc;
  insert into game.roads(city_id,district_id,code,name,road_type)
  values(c,d,n.road_code,n.rname,'primary') on conflict do nothing;
  insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type)
  values(c,n.code||'-W',n.code||' West Bank',n.wx,n.y,'bridge_approach'),
        (c,n.code||'-E',n.code||' East Bank',n.ex,n.y,'bridge_approach')
  on conflict(city_id,junction_code) do nothing;
  select id into r from game.roads where city_id=c and roads.code=n.road_code;
  for s in select * from (values ('W',n.wx),('E',n.ex)) v(side,bx) loop
   select id into a from game.road_junctions where city_id=c and junction_code=n.code||'-'||s.side;
   select id into nearest from game.road_junctions j where j.city_id=c and j.junction_code like 'J%'
   order by (j.x_m-s.bx)::bigint*(j.x_m-s.bx)::bigint+(j.y_m-n.y)::bigint*(j.y_m-n.y)::bigint limit 1;
   select greatest(1,round(sqrt((ja.x_m-jb.x_m)::numeric^2+(ja.y_m-jb.y_m)::numeric^2))::integer)
    into len from game.road_junctions ja,game.road_junctions jb where ja.id=a and jb.id=nearest;
   insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph)
   values(c,r,'RIVER-'||n.code||'-'||s.side,a,nearest,len,'primary',2,50)
   on conflict(city_id,segment_code) do nothing;
  end loop;
  select id into a from game.road_junctions where city_id=c and junction_code=n.code||'-W';
  select id into b from game.road_junctions where city_id=c and junction_code=n.code||'-E';
  insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph,crossing_type)
  values(c,r,'RIVER-'||n.code||'-BRIDGE',a,b,n.ex-n.wx,'primary',2,50,'bridge')
  on conflict(city_id,segment_code) do nothing;
 end loop;
end $$;
