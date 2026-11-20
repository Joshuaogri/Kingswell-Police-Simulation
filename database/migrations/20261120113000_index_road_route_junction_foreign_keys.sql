-- Cover the two route-junction foreign keys flagged by the performance advisor.
create index road_route_calculations_origin_junction_idx on game.road_route_calculations(origin_junction_id);
create index road_route_calculations_destination_junction_idx on game.road_route_calculations(destination_junction_id);
