
with centres(code,x,y) as (values
('KDW-01',2200,9000),('KDW-02',3800,11200),('KNA-01',6800,13700),('KNA-02',8800,12200),
('KCI-01',8500,8200),('KCI-02',10800,10000),('KCB-01',11800,10500),('KCB-02',14000,8200),
('KED-01',3600,14500),('KED-02',5600,12800),('KST-01',9000,4800),('KST-02',11000,6200),
('KMA-01',14000,7200),('KMA-02',16000,5600),('KIN-01',16500,11500),('KIN-02',18500,13200),
('KLG-01',16500,8200),('KLG-02',18500,6200),('KPT-01',15500,3500),('KPT-02',18500,1800),
('KAS-01',2200,3500),('KAS-02',4500,1500),('KMX-01',8500,3000),('KMX-02',6500,1200)
)
insert into game.roads(city_id,district_id,code,name,road_type)
select c.id,d.id,'KNG-L-'||replace(n.code,'-',''),h.name||' Local Street','local'
from centres n join game.neighbourhoods h on h.code=n.code join game.districts d on d.id=h.district_id
join game.cities c on c.id=d.city_id and c.code='KNG'
where not exists(select 1 from game.roads r where r.city_id=c.id and r.code='KNG-L-'||replace(n.code,'-',''));

insert into game.roads(city_id,district_id,code,name,road_type)
select c.id,d.id,v.code,v.name,'primary'
from (values ('KNG-BR01','East River Bridge North','KMX'),('KNG-BR02','Riverside Bridge','KMX'),('KNG-BR03','Harbour River Bridge','KPT')) v(code,name,dc)
join game.cities c on c.code='KNG' join game.districts d on d.city_id=c.id and d.code=v.dc
where not exists(select 1 from game.roads r where r.city_id=c.id and r.code=v.code);

with centres(code,x,y) as (values
('KDW-01',2200,9000),('KDW-02',3800,11200),('KNA-01',6800,13700),('KNA-02',8800,12200),
('KCI-01',8500,8200),('KCI-02',10800,10000),('KCB-01',11800,10500),('KCB-02',14000,8200),
('KED-01',3600,14500),('KED-02',5600,12800),('KST-01',9000,4800),('KST-02',11000,6200),
('KMA-01',14000,7200),('KMA-02',16000,5600),('KIN-01',16500,11500),('KIN-02',18500,13200),
('KLG-01',16500,8200),('KLG-02',18500,6200),('KPT-01',15500,3500),('KPT-02',18500,1800),
('KAS-01',2200,3500),('KAS-02',4500,1500),('KMX-01',8500,3000),('KMX-02',6500,1200)
), nodes as (
select c.id city_id,n.code||s.suffix junction_code,n.code||' '||s.label junction_name,n.x+s.dx x_m,n.y+s.dy y_m
from centres n cross join lateral (values ('A','Northwest',-250,250),('B','Northeast',250,250),('C','Southeast',250,-250),('D','Southwest',-250,-250)) s(suffix,label,dx,dy)
join game.neighbourhoods h on h.code=n.code join game.districts d on d.id=h.district_id
join game.cities c on c.id=d.city_id and c.code='KNG'
)
insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type,access_profile)
select city_id,junction_code,junction_name,x_m,y_m,'local_intersection','public' from nodes n
where not exists(select 1 from game.road_junctions j where j.city_id=n.city_id and j.junction_code=n.junction_code);

with centres(code,x,y) as (values
('KDW-01',2200,9000),('KDW-02',3800,11200),('KNA-01',6800,13700),('KNA-02',8800,12200),
('KCI-01',8500,8200),('KCI-02',10800,10000),('KCB-01',11800,10500),('KCB-02',14000,8200),
('KED-01',3600,14500),('KED-02',5600,12800),('KST-01',9000,4800),('KST-02',11000,6200),
('KMA-01',14000,7200),('KMA-02',16000,5600),('KIN-01',16500,11500),('KIN-02',18500,13200),
('KLG-01',16500,8200),('KLG-02',18500,6200),('KPT-01',15500,3500),('KPT-02',18500,1800),
('KAS-01',2200,3500),('KAS-02',4500,1500),('KMX-01',8500,3000),('KMX-02',6500,1200)
), edges as (
select c.id city_id,n.code,'KNG-L-'||replace(n.code,'-','') road_code,n.code||e.fs from_code,n.code||e.ts to_code,
case e.fs when 'A' then '01' when 'B' then '02' when 'C' then '03' else '04' end seq
from centres n join game.neighbourhoods h on h.code=n.code join game.districts d on d.id=h.district_id
join game.cities c on c.id=d.city_id and c.code='KNG'
cross join (values ('A','B'),('B','C'),('C','D'),('D','A')) e(fs,ts)
union all
select c.id,n.code,'KNG-L-'||replace(n.code,'-',''),n.code||'A',near.junction_code,'05'
from centres n join game.neighbourhoods h on h.code=n.code join game.districts d on d.id=h.district_id
join game.cities c on c.id=d.city_id and c.code='KNG'
cross join lateral (select j.junction_code from game.road_junctions j where j.city_id=c.id and j.junction_code like 'J%'
order by (j.x_m-(n.x-250))::bigint*(j.x_m-(n.x-250))::bigint+(j.y_m-(n.y+250))::bigint*(j.y_m-(n.y+250))::bigint limit 1) near
)
insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,
lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
select e.city_id,r.id,'N-'||replace(e.code,'-','')||'-'||e.seq,a.id,b.id,
greatest(1,round(sqrt((a.x_m-b.x_m)::numeric^2+(a.y_m-b.y_m)::numeric^2))::integer),
case when e.seq='05' then 'local_collector' else 'local' end,1,case when e.seq='05' then 30 else 20 end,
'two_way','sealed','at_grade','public'
from edges e join game.roads r on r.city_id=e.city_id and r.code=e.road_code
join game.road_junctions a on a.city_id=e.city_id and a.junction_code=e.from_code
join game.road_junctions b on b.city_id=e.city_id and b.junction_code=e.to_code
where not exists(select 1 from game.road_segments s where s.city_id=e.city_id and s.segment_code='N-'||replace(e.code,'-','')||'-'||e.seq);

with bridges(code,wx,ex,y,road_code) as (values ('RB01',11600,12600,10500,'KNG-BR01'),('RB02',11600,12600,6500,'KNG-BR02'),('RB03',11600,12600,2800,'KNG-BR03')),
banks as (
select c.id city_id,b.code||'-W' junction_code,b.code||' West Bank' junction_name,b.wx x_m,b.y y_m from bridges b cross join game.cities c where c.code='KNG'
union all select c.id,b.code||'-E',b.code||' East Bank',b.ex,b.y from bridges b cross join game.cities c where c.code='KNG'
)
insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type,access_profile)
select city_id,junction_code,junction_name,x_m,y_m,'bridge_approach','public' from banks b
where not exists(select 1 from game.road_junctions j where j.city_id=b.city_id and j.junction_code=b.junction_code);

with bridges(code,wx,ex,y,road_code) as (values ('RB01',11600,12600,10500,'KNG-BR01'),('RB02',11600,12600,6500,'KNG-BR02'),('RB03',11600,12600,2800,'KNG-BR03')),
legs as (
select c.id city_id,b.code,b.road_code,b.code||'-W' f,b.code||'-E' t,'BRIDGE' leg from bridges b cross join game.cities c where c.code='KNG'
union all
select c.id,b.code,b.road_code,b.code||'-W',near.junction_code,'WEST' from bridges b cross join game.cities c
cross join lateral (select j.junction_code from game.road_junctions j where j.city_id=c.id and j.junction_code like 'J%'
order by (j.x_m-b.wx)::bigint*(j.x_m-b.wx)::bigint+(j.y_m-b.y)::bigint*(j.y_m-b.y)::bigint limit 1) near where c.code='KNG'
union all
select c.id,b.code,b.road_code,b.code||'-E',near.junction_code,'EAST' from bridges b cross join game.cities c
cross join lateral (select j.junction_code from game.road_junctions j where j.city_id=c.id and j.junction_code like 'J%'
order by (j.x_m-b.ex)::bigint*(j.x_m-b.ex)::bigint+(j.y_m-b.y)::bigint*(j.y_m-b.y)::bigint limit 1) near where c.code='KNG'
)
insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,
lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
select l.city_id,r.id,'RIVER-'||l.code||'-'||l.leg,a.id,b.id,
greatest(1,round(sqrt((a.x_m-b.x_m)::numeric^2+(a.y_m-b.y_m)::numeric^2))::integer),
'primary',2,50,'two_way','sealed',case when l.leg='BRIDGE' then 'bridge' else 'at_grade' end,'public'
from legs l join game.roads r on r.city_id=l.city_id and r.code=l.road_code
join game.road_junctions a on a.city_id=l.city_id and a.junction_code=l.f
join game.road_junctions b on b.city_id=l.city_id and b.junction_code=l.t
where not exists(select 1 from game.road_segments s where s.city_id=l.city_id and s.segment_code='RIVER-'||l.code||'-'||l.leg);

update game.road_segments s set access_profile='public_emergency_freight'
from game.roads r where r.id=s.road_id and r.code in ('KNG-R008','KNG-R009');
