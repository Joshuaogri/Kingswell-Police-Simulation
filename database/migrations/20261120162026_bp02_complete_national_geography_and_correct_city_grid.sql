
alter table game.regions
  add column if not exists region_order smallint,
  add column if not exists relative_position text,
  add column if not exists geographic_description text,
  add column if not exists is_capital_region boolean not null default false;

alter table game.cities
  add column if not exists grid_width_m integer,
  add column if not exists grid_height_m integer,
  add column if not exists map_orientation text,
  add column if not exists coastal_edge text,
  add column if not exists major_waterway_description text,
  add column if not exists map_version text;

alter table game.world_countries
  add column if not exists geographic_profile text,
  add column if not exists capital_city_id uuid;

do $$
begin
  if not exists (
    select 1 from pg_constraint c
    join pg_class t on t.oid=c.conrelid
    join pg_namespace n on n.oid=t.relnamespace
    where n.nspname='game' and t.relname='world_countries'
      and c.conname='world_countries_capital_city_id_fkey'
  ) then
    alter table game.world_countries
      add constraint world_countries_capital_city_id_fkey
      foreign key (capital_city_id) references game.cities(id) on delete set null;
  end if;
  if not exists (
    select 1 from pg_constraint c
    join pg_class t on t.oid=c.conrelid
    join pg_namespace n on n.oid=t.relnamespace
    where n.nspname='game' and t.relname='regions'
      and c.conname='regions_region_order_positive'
  ) then
    alter table game.regions
      add constraint regions_region_order_positive
      check (region_order is null or region_order > 0);
  end if;
  if not exists (
    select 1 from pg_constraint c
    join pg_class t on t.oid=c.conrelid
    join pg_namespace n on n.oid=t.relnamespace
    where n.nspname='game' and t.relname='cities'
      and c.conname='cities_grid_dimensions_positive'
  ) then
    alter table game.cities
      add constraint cities_grid_dimensions_positive
      check ((grid_width_m is null or grid_width_m > 0)
         and (grid_height_m is null or grid_height_m > 0));
  end if;
end $$;

create unique index if not exists regions_country_order_uidx
  on game.regions(country_id, region_order) where region_order is not null;
create unique index if not exists regions_one_capital_per_country_uidx
  on game.regions(country_id) where is_capital_region;
create index if not exists world_countries_capital_city_fk_idx
  on game.world_countries(capital_city_id);

-- Correct the initial district envelope seed: the source values were stored as
-- millimetres in columns explicitly defined and consumed as metres.
update game.district_map_areas
set min_x_m = min_x_m / 1000,
    max_x_m = max_x_m / 1000,
    min_y_m = min_y_m / 1000,
    max_y_m = max_y_m / 1000
where map_version = 'KNG-MAP-0.1'
  and min_x_m >= 1000000 and max_x_m >= 1000000
  and min_y_m >= 1000000 and max_y_m >= 1000000
  and min_x_m % 1000 = 0 and max_x_m % 1000 = 0
  and min_y_m % 1000 = 0 and max_y_m % 1000 = 0;

update game.regions
set region_order = 1,
    relative_position = 'South-central coast; centred on Kingswell and the harbour near the eastern river mouth.',
    geographic_description = 'The national capital region. Contains Kingswell, the principal national administrative, commercial, financial, transport, industrial and maritime centre.',
    is_capital_region = true
where code = 'CAP'
  and country_id = (select id from game.world_countries where code='AST');

insert into game.regions(country_id,code,name,region_order,relative_position,geographic_description,is_capital_region)
select c.id, v.code, v.name, v.region_order, v.relative_position, v.geographic_description, false
from game.world_countries c
cross join (values
 ('NTH','Northreach Region',2,'Northern interior','Northern uplands, highland settlements and the upper headwater country.'),
 ('WST','Westmere Region',3,'Western country','Western lake districts, agricultural plains and market towns.'),
 ('CTR','Highplain Region',4,'Central interior','Central plateau, inland farming basins and the principal east-west overland corridor.'),
 ('EST','Eastmarch Region',5,'Eastern country','Eastern river basin, borderland crossings and regional transport corridors.'),
 ('IRV','Ironvale Region',6,'North-east uplands','North-eastern uplands, mineral workings and industrial towns.'),
 ('SCO','South Coast Region',7,'Southern coast west of the capital region','Coastal communities, fishing towns and maritime settlements along the western southern shore.'),
 ('OIS','Outer Isles Region',8,'Offshore south and east','Offshore island groups, smaller ports and maritime communities.')
) as v(code,name,region_order,relative_position,geographic_description)
where c.code='AST'
on conflict (country_id,code) do update
set name=excluded.name,
    region_order=excluded.region_order,
    relative_position=excluded.relative_position,
    geographic_description=excluded.geographic_description,
    is_capital_region=false;

update game.cities
set grid_width_m=20000,
    grid_height_m=16000,
    map_orientation='north_up',
    coastal_edge='south',
    major_waterway_description='A navigable river enters the city from the north-east and runs to the harbour basin in the south-east; three explicit bridge crossings connect the banks.',
    map_version='KNG-MAP-0.1'
where code='KNG';

update game.world_countries c
set geographic_profile='A fictional coastal sovereign country with northern uplands, western lake and agricultural country, a central plateau, an eastern river basin, a southern maritime edge and offshore island groups. Kingswell occupies the southern coast near the eastern river mouth and is the national capital and principal administrative, commercial, financial, transport, industrial and port centre.',
    capital_city_id=city.id
from game.cities city
where c.code='AST' and city.code='KNG';

alter table game.regions enable row level security;
alter table game.cities enable row level security;
alter table game.world_countries enable row level security;
