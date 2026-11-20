-- BP-02 data correction: complete the metre conversion for every district envelope.
-- The first correction intentionally targeted non-zero minima; this pass also fixes
-- envelopes whose x or y origin is zero. All source values are divisible by 1,000.
update game.district_map_areas
set min_x_m=min_x_m/1000,
    max_x_m=max_x_m/1000,
    min_y_m=min_y_m/1000,
    max_y_m=max_y_m/1000
where map_version='KNG-MAP-0.1'
  and (max_x_m>20000 or max_y_m>16000)
  and min_x_m%1000=0 and max_x_m%1000=0
  and min_y_m%1000=0 and max_y_m%1000=0;
