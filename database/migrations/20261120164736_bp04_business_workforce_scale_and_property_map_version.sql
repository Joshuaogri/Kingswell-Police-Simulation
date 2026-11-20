update game.business_profiles
set estimated_employee_count=case business_size
 when 'major_corporate' then 150+((substring(business_number from '[0-9]+')::integer*17)%450)
 when 'large' then 50+((substring(business_number from '[0-9]+')::integer*13)%100)
 when 'medium' then 15+((substring(business_number from '[0-9]+')::integer*11)%35)
 when 'small' then 4+((substring(business_number from '[0-9]+')::integer*7)%12)
 else 1+((substring(business_number from '[0-9]+')::integer*5)%3) end;
update game.cities set map_version='KNG-MAP-0.2' where code='KNG';
