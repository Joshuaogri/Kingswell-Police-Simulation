-- Cover every foreign key introduced by police geography and the existing landmark/access layer.
create index if not exists city_landmarks_access_point_fk_idx on game.city_landmarks(access_point_id);
create index if not exists city_landmarks_building_fk_idx on game.city_landmarks(building_id);
create index if not exists city_landmarks_district_fk_idx on game.city_landmarks(district_id);
create index if not exists city_landmarks_neighbourhood_fk_idx on game.city_landmarks(neighbourhood_id);
create index if not exists police_facilities_address_fk_idx on game.police_facilities(address_id);
create index if not exists police_facilities_building_fk_idx on game.police_facilities(building_id);
create index if not exists police_facilities_neighbourhood_fk_idx on game.police_facilities(neighbourhood_id);
create index if not exists police_stations_facility_fk_idx on game.police_stations(facility_id);
create index if not exists property_access_points_building_fk_idx on game.property_access_points(building_id);
