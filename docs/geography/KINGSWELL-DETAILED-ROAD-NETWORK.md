# Kingswell Detailed Road Network — KNG-MAP-0.3

**Status:** Implemented in Supabase and version-controlled in GitHub.  
**Setting:** Kingswell, the fictional capital of Asterfell.  
**Coordinate system:** Local metric grid, 20,000 m east–west × 16,000 m north–south; north-up. These are authored fictional coordinates, not real-world latitude/longitude or survey data.  
**Canonical SVG:** [kingswell-detailed-road-network.svg](./kingswell-detailed-road-network.svg)

## 1. Live network inventory

| Layer | Live total |
|---|---:|
| Named roads | 75 |
| Junctions | 157 |
| Connected road segments | 229 |
| Secondary property entrances | 480 |
| Primary + secondary property entrances | 1136 |
| Weekday peak traffic profiles | 458 |
| Explicit no-U-turn controls | 266 |
| Signalised no-left/no-right movement bans | 16 |
| Total active turn-control records | 282 |
| Segments covered by patrol beats | 229 |

All named roads have at least one connected segment. Every segment has local-grid line geometry and valid start/end junction references. All mapped segments are included in patrol-beat coverage.

## 2. Road gazetteer

The following is the complete current register of the 75 named roads. Segment codes identify the actual routable graph pieces.

| Road code | Official road name | District | Type | Segments | Direction |
|---|---|---|---|---:|---|
| KNG-BR01 | East River Bridge North | KMX | primary | 3 | two_way |
| KNG-BR02 | Riverside Bridge | KMX | primary | 3 | two_way |
| KNG-BR03 | Harbour River Bridge | KPT | primary | 3 | two_way |
| KNG-L-KAS01 | Airport Campus Local Street | KAS | local | 5 | one_way_forward, two_way |
| KNG-L-KAS02 | Aviation Village Local Street | KAS | local | 5 | one_way_forward, two_way |
| KNG-L-KCB01 | Exchange Square Local Street | KCB | local | 5 | one_way_forward, two_way |
| KNG-L-KCB02 | Bank Quarter Local Street | KCB | local | 5 | one_way_forward, two_way |
| KNG-L-KCI01 | Civic Centre Local Street | KCI | local | 5 | one_way_forward, two_way |
| KNG-L-KCI02 | Assembly Gardens Local Street | KCI | local | 5 | one_way_forward, two_way |
| KNG-L-KDW01 | Old Westhaven Local Street | KDW | local | 5 | one_way_forward, two_way |
| KNG-L-KDW02 | Willow Park Local Street | KDW | local | 5 | one_way_forward, two_way |
| KNG-L-KED01 | University Campus Local Street | KED | local | 5 | one_way_forward, two_way |
| KNG-L-KED02 | Hospital Hill Local Street | KED | local | 5 | one_way_forward, two_way |
| KNG-L-KIN01 | Foundry Estate Local Street | KIN | local | 5 | one_way_forward, two_way |
| KNG-L-KIN02 | Works Park Local Street | KIN | local | 5 | one_way_forward, two_way |
| KNG-L-KLG01 | Freight Village Local Street | KLG | local | 5 | one_way_forward, two_way |
| KNG-L-KLG02 | Distribution Park Local Street | KLG | local | 5 | one_way_forward, two_way |
| KNG-L-KMA01 | Grand Market Local Street | KMA | local | 5 | one_way_forward, two_way |
| KNG-L-KMA02 | Merchants Row Local Street | KMA | local | 5 | one_way_forward, two_way |
| KNG-L-KMX01 | Riverside East Local Street | KMX | local | 5 | one_way_forward, two_way |
| KNG-L-KMX02 | Riverside West Local Street | KMX | local | 5 | one_way_forward, two_way |
| KNG-L-KNA01 | Northgate Heights Local Street | KNA | local | 5 | one_way_forward, two_way |
| KNG-L-KNA02 | Cedar Estate Local Street | KNA | local | 5 | one_way_forward, two_way |
| KNG-L-KPT01 | Harbourfront Local Street | KPT | local | 5 | one_way_forward, two_way |
| KNG-L-KPT02 | Docklands Local Street | KPT | local | 5 | one_way_forward, two_way |
| KNG-L-KST01 | Terminal Quarter Local Street | KST | local | 5 | one_way_forward, two_way |
| KNG-L-KST02 | Railway Approach Local Street | KST | local | 5 | one_way_forward, two_way |
| KNG-R001 | Kingswell Outer Ring Road | Citywide | primary | 11 | two_way |
| KNG-R002 | Inner Civic Loop | KCI | primary | 2 | two_way |
| KNG-R003 | Northgate Avenue | KNA | primary | 1 | two_way |
| KNG-R004 | University Road | KED | primary | 1 | two_way |
| KNG-R005 | Foundry Boulevard | KIN | primary | 1 | two_way |
| KNG-R006 | Harbour Parkway | KPT | primary | 3 | two_way |
| KNG-R007 | Terminal Way | KST | primary | 1 | two_way |
| KNG-R008 | Airport Expressway | KAS | primary | 1 | two_way |
| KNG-R009 | Port Access Road | KLG | primary | 1 | two_way |
| KNG-R010 | Westhaven Road | KDW | secondary | 2 | two_way |
| KNG-R011 | Cedar Avenue | KNA | secondary | 2 | two_way |
| KNG-R012 | Assembly Avenue | KCI | secondary | 2 | two_way |
| KNG-R013 | Exchange Street | KCB | secondary | 2 | two_way |
| KNG-R014 | Campus Drive | KED | secondary | 2 | two_way |
| KNG-R015 | Railway Road | KST | secondary | 2 | two_way |
| KNG-R016 | Market Street | KMA | secondary | 2 | two_way |
| KNG-R017 | Works Road | KIN | secondary | 2 | two_way |
| KNG-R018 | Freightway | KLG | secondary | 2 | two_way |
| KNG-R019 | Dock Road | KPT | secondary | 2 | two_way |
| KNG-R020 | Riverside Drive | KMX | secondary | 2 | two_way |
| KNG-R021 | Aerodrome Road | KAS | secondary | 2 | two_way |
| KNG-R022 | Civic Square | KCI | local | 2 | two_way |
| KNG-R023 | Merchants Lane | KMA | local | 2 | two_way |
| KNG-R024 | Harbour View Road | KPT | local | 2 | two_way |
| KNG-SL-KAS01 | Airport Campus Rear Service Lane | KAS | service | 2 | two_way |
| KNG-SL-KAS02 | Aviation Village Rear Service Lane | KAS | service | 2 | two_way |
| KNG-SL-KCB01 | Exchange Square Rear Service Lane | KCB | service | 2 | two_way |
| KNG-SL-KCB02 | Bank Quarter Rear Service Lane | KCB | service | 2 | two_way |
| KNG-SL-KCI01 | Civic Centre Rear Service Lane | KCI | service | 2 | two_way |
| KNG-SL-KCI02 | Assembly Gardens Rear Service Lane | KCI | service | 2 | two_way |
| KNG-SL-KDW01 | Old Westhaven Rear Service Lane | KDW | service | 2 | two_way |
| KNG-SL-KDW02 | Willow Park Rear Service Lane | KDW | service | 2 | two_way |
| KNG-SL-KED01 | University Campus Rear Service Lane | KED | service | 2 | two_way |
| KNG-SL-KED02 | Hospital Hill Rear Service Lane | KED | service | 2 | two_way |
| KNG-SL-KIN01 | Foundry Estate Rear Service Lane | KIN | service | 2 | two_way |
| KNG-SL-KIN02 | Works Park Rear Service Lane | KIN | service | 2 | two_way |
| KNG-SL-KLG01 | Freight Village Rear Service Lane | KLG | service | 2 | two_way |
| KNG-SL-KLG02 | Distribution Park Rear Service Lane | KLG | service | 2 | two_way |
| KNG-SL-KMA01 | Grand Market Rear Service Lane | KMA | service | 2 | two_way |
| KNG-SL-KMA02 | Merchants Row Rear Service Lane | KMA | service | 2 | two_way |
| KNG-SL-KMX01 | Riverside East Rear Service Lane | KMX | service | 2 | two_way |
| KNG-SL-KMX02 | Riverside West Rear Service Lane | KMX | service | 2 | two_way |
| KNG-SL-KNA01 | Northgate Heights Rear Service Lane | KNA | service | 2 | two_way |
| KNG-SL-KNA02 | Cedar Estate Rear Service Lane | KNA | service | 2 | two_way |
| KNG-SL-KPT01 | Harbourfront Rear Service Lane | KPT | service | 2 | two_way |
| KNG-SL-KPT02 | Docklands Rear Service Lane | KPT | service | 2 | two_way |
| KNG-SL-KST01 | Terminal Quarter Rear Service Lane | KST | service | 2 | two_way |
| KNG-SL-KST02 | Railway Approach Rear Service Lane | KST | service | 2 | two_way |

### Segment-code register

- **KNG-BR01 — East River Bridge North:** RIVER-RB01-BRIDGE, RIVER-RB01-EAST, RIVER-RB01-WEST
- **KNG-BR02 — Riverside Bridge:** RIVER-RB02-BRIDGE, RIVER-RB02-EAST, RIVER-RB02-WEST
- **KNG-BR03 — Harbour River Bridge:** RIVER-RB03-BRIDGE, RIVER-RB03-EAST, RIVER-RB03-WEST
- **KNG-L-KAS01 — Airport Campus Local Street:** N-KAS01-01, N-KAS01-02, N-KAS01-03, N-KAS01-04, N-KAS01-05
- **KNG-L-KAS02 — Aviation Village Local Street:** N-KAS02-01, N-KAS02-02, N-KAS02-03, N-KAS02-04, N-KAS02-05
- **KNG-L-KCB01 — Exchange Square Local Street:** N-KCB01-01, N-KCB01-02, N-KCB01-03, N-KCB01-04, N-KCB01-05
- **KNG-L-KCB02 — Bank Quarter Local Street:** N-KCB02-01, N-KCB02-02, N-KCB02-03, N-KCB02-04, N-KCB02-05
- **KNG-L-KCI01 — Civic Centre Local Street:** N-KCI01-01, N-KCI01-02, N-KCI01-03, N-KCI01-04, N-KCI01-05
- **KNG-L-KCI02 — Assembly Gardens Local Street:** N-KCI02-01, N-KCI02-02, N-KCI02-03, N-KCI02-04, N-KCI02-05
- **KNG-L-KDW01 — Old Westhaven Local Street:** N-KDW01-01, N-KDW01-02, N-KDW01-03, N-KDW01-04, N-KDW01-05
- **KNG-L-KDW02 — Willow Park Local Street:** N-KDW02-01, N-KDW02-02, N-KDW02-03, N-KDW02-04, N-KDW02-05
- **KNG-L-KED01 — University Campus Local Street:** N-KED01-01, N-KED01-02, N-KED01-03, N-KED01-04, N-KED01-05
- **KNG-L-KED02 — Hospital Hill Local Street:** N-KED02-01, N-KED02-02, N-KED02-03, N-KED02-04, N-KED02-05
- **KNG-L-KIN01 — Foundry Estate Local Street:** N-KIN01-01, N-KIN01-02, N-KIN01-03, N-KIN01-04, N-KIN01-05
- **KNG-L-KIN02 — Works Park Local Street:** N-KIN02-01, N-KIN02-02, N-KIN02-03, N-KIN02-04, N-KIN02-05
- **KNG-L-KLG01 — Freight Village Local Street:** N-KLG01-01, N-KLG01-02, N-KLG01-03, N-KLG01-04, N-KLG01-05
- **KNG-L-KLG02 — Distribution Park Local Street:** N-KLG02-01, N-KLG02-02, N-KLG02-03, N-KLG02-04, N-KLG02-05
- **KNG-L-KMA01 — Grand Market Local Street:** N-KMA01-01, N-KMA01-02, N-KMA01-03, N-KMA01-04, N-KMA01-05
- **KNG-L-KMA02 — Merchants Row Local Street:** N-KMA02-01, N-KMA02-02, N-KMA02-03, N-KMA02-04, N-KMA02-05
- **KNG-L-KMX01 — Riverside East Local Street:** N-KMX01-01, N-KMX01-02, N-KMX01-03, N-KMX01-04, N-KMX01-05
- **KNG-L-KMX02 — Riverside West Local Street:** N-KMX02-01, N-KMX02-02, N-KMX02-03, N-KMX02-04, N-KMX02-05
- **KNG-L-KNA01 — Northgate Heights Local Street:** N-KNA01-01, N-KNA01-02, N-KNA01-03, N-KNA01-04, N-KNA01-05
- **KNG-L-KNA02 — Cedar Estate Local Street:** N-KNA02-01, N-KNA02-02, N-KNA02-03, N-KNA02-04, N-KNA02-05
- **KNG-L-KPT01 — Harbourfront Local Street:** N-KPT01-01, N-KPT01-02, N-KPT01-03, N-KPT01-04, N-KPT01-05
- **KNG-L-KPT02 — Docklands Local Street:** N-KPT02-01, N-KPT02-02, N-KPT02-03, N-KPT02-04, N-KPT02-05
- **KNG-L-KST01 — Terminal Quarter Local Street:** N-KST01-01, N-KST01-02, N-KST01-03, N-KST01-04, N-KST01-05
- **KNG-L-KST02 — Railway Approach Local Street:** N-KST02-01, N-KST02-02, N-KST02-03, N-KST02-04, N-KST02-05
- **KNG-R001 — Kingswell Outer Ring Road:** S001, S002, S003, S004, S005, S006, S007, S008, S009, S010, S011
- **KNG-R002 — Inner Civic Loop:** S012, S013
- **KNG-R003 — Northgate Avenue:** S014
- **KNG-R004 — University Road:** S015
- **KNG-R005 — Foundry Boulevard:** S016
- **KNG-R006 — Harbour Parkway:** S017, S018, S022
- **KNG-R007 — Terminal Way:** S019
- **KNG-R008 — Airport Expressway:** S020
- **KNG-R009 — Port Access Road:** S021
- **KNG-R010 — Westhaven Road:** KNG-R010-A, KNG-R010-B
- **KNG-R011 — Cedar Avenue:** KNG-R011-A, KNG-R011-B
- **KNG-R012 — Assembly Avenue:** KNG-R012-A, KNG-R012-B
- **KNG-R013 — Exchange Street:** KNG-R013-A, KNG-R013-B
- **KNG-R014 — Campus Drive:** KNG-R014-A, KNG-R014-B
- **KNG-R015 — Railway Road:** KNG-R015-A, KNG-R015-B
- **KNG-R016 — Market Street:** KNG-R016-A, KNG-R016-B
- **KNG-R017 — Works Road:** KNG-R017-A, KNG-R017-B
- **KNG-R018 — Freightway:** KNG-R018-A, KNG-R018-B
- **KNG-R019 — Dock Road:** KNG-R019-A, KNG-R019-B
- **KNG-R020 — Riverside Drive:** KNG-R020-A, KNG-R020-B
- **KNG-R021 — Aerodrome Road:** KNG-R021-A, KNG-R021-B
- **KNG-R022 — Civic Square:** KNG-R022-A, KNG-R022-B
- **KNG-R023 — Merchants Lane:** KNG-R023-A, KNG-R023-B
- **KNG-R024 — Harbour View Road:** KNG-R024-A, KNG-R024-B
- **KNG-SL-KAS01 — Airport Campus Rear Service Lane:** SL-KAS01-01, SL-KAS01-02
- **KNG-SL-KAS02 — Aviation Village Rear Service Lane:** SL-KAS02-01, SL-KAS02-02
- **KNG-SL-KCB01 — Exchange Square Rear Service Lane:** SL-KCB01-01, SL-KCB01-02
- **KNG-SL-KCB02 — Bank Quarter Rear Service Lane:** SL-KCB02-01, SL-KCB02-02
- **KNG-SL-KCI01 — Civic Centre Rear Service Lane:** SL-KCI01-01, SL-KCI01-02
- **KNG-SL-KCI02 — Assembly Gardens Rear Service Lane:** SL-KCI02-01, SL-KCI02-02
- **KNG-SL-KDW01 — Old Westhaven Rear Service Lane:** SL-KDW01-01, SL-KDW01-02
- **KNG-SL-KDW02 — Willow Park Rear Service Lane:** SL-KDW02-01, SL-KDW02-02
- **KNG-SL-KED01 — University Campus Rear Service Lane:** SL-KED01-01, SL-KED01-02
- **KNG-SL-KED02 — Hospital Hill Rear Service Lane:** SL-KED02-01, SL-KED02-02
- **KNG-SL-KIN01 — Foundry Estate Rear Service Lane:** SL-KIN01-01, SL-KIN01-02
- **KNG-SL-KIN02 — Works Park Rear Service Lane:** SL-KIN02-01, SL-KIN02-02
- **KNG-SL-KLG01 — Freight Village Rear Service Lane:** SL-KLG01-01, SL-KLG01-02
- **KNG-SL-KLG02 — Distribution Park Rear Service Lane:** SL-KLG02-01, SL-KLG02-02
- **KNG-SL-KMA01 — Grand Market Rear Service Lane:** SL-KMA01-01, SL-KMA01-02
- **KNG-SL-KMA02 — Merchants Row Rear Service Lane:** SL-KMA02-01, SL-KMA02-02
- **KNG-SL-KMX01 — Riverside East Rear Service Lane:** SL-KMX01-01, SL-KMX01-02
- **KNG-SL-KMX02 — Riverside West Rear Service Lane:** SL-KMX02-01, SL-KMX02-02
- **KNG-SL-KNA01 — Northgate Heights Rear Service Lane:** SL-KNA01-01, SL-KNA01-02
- **KNG-SL-KNA02 — Cedar Estate Rear Service Lane:** SL-KNA02-01, SL-KNA02-02
- **KNG-SL-KPT01 — Harbourfront Rear Service Lane:** SL-KPT01-01, SL-KPT01-02
- **KNG-SL-KPT02 — Docklands Rear Service Lane:** SL-KPT02-01, SL-KPT02-02
- **KNG-SL-KST01 — Terminal Quarter Rear Service Lane:** SL-KST01-01, SL-KST01-02
- **KNG-SL-KST02 — Railway Approach Rear Service Lane:** SL-KST02-01, SL-KST02-02

## 3. Junction gazetteer

Coordinates are metres on the Kingswell local grid. Junction control and pedestrian facilities are stored as structured fields in Supabase.

| Junction code | Proper name | X (m) | Y (m) | Junction type | Control | Pedestrian crossing |
|---|---|---:|---:|---|---|---|
| J001 | Northwest Gateway | 1000 | 14000 | at_grade | signalised | Yes |
| J002 | North Central | 6000 | 14000 | at_grade | signalised | Yes |
| J003 | Northeast Gateway | 14000 | 14000 | at_grade | signalised | Yes |
| J004 | East Industrial Gateway | 19000 | 12000 | at_grade | signalised | Yes |
| J005 | West Central | 2000 | 8000 | at_grade | signalised | Yes |
| J006 | Civic West | 7000 | 9000 | at_grade | signalised | Yes |
| J007 | Civic Centre | 9500 | 9000 | at_grade | signalised | Yes |
| J008 | Central Exchange | 12500 | 9000 | at_grade | signalised | Yes |
| J009 | East Logistics | 17000 | 7000 | at_grade | priority_or_uncontrolled | Yes |
| J010 | Southwest Airport Gate | 1000 | 2000 | at_grade | priority_or_uncontrolled | Yes |
| J011 | Riverside South | 7000 | 2500 | at_grade | priority_or_uncontrolled | Yes |
| J012 | Terminal Interchange | 10000 | 5500 | at_grade | priority_or_uncontrolled | Yes |
| J013 | Market Junction | 14500 | 6000 | at_grade | priority_or_uncontrolled | Yes |
| J014 | Harbour Gate | 17000 | 2500 | at_grade | priority_or_uncontrolled | Yes |
| J015 | Southwest Ring | 2500 | 500 | at_grade | priority_or_uncontrolled | Yes |
| J016 | Southeast Ring | 18500 | 500 | at_grade | priority_or_uncontrolled | Yes |
| KAS-01-SL01 | Airport Campus Service Lane Midpoint | 2200 | 3815 | service_lane_access | priority_or_uncontrolled | Yes |
| KAS-01A | KAS-01 Northwest | 1950 | 3750 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-01B | KAS-01 Northeast | 2450 | 3750 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-01C | KAS-01 Southeast | 2450 | 3250 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-01D | KAS-01 Southwest | 1950 | 3250 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-02-SL01 | Aviation Village Service Lane Midpoint | 4500 | 1815 | service_lane_access | priority_or_uncontrolled | Yes |
| KAS-02A | KAS-02 Northwest | 4250 | 1750 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-02B | KAS-02 Northeast | 4750 | 1750 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-02C | KAS-02 Southeast | 4750 | 1250 | local_intersection | priority_or_uncontrolled | Yes |
| KAS-02D | KAS-02 Southwest | 4250 | 1250 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-01-SL01 | Exchange Square Service Lane Midpoint | 11800 | 10815 | service_lane_access | priority_or_uncontrolled | Yes |
| KCB-01A | KCB-01 Northwest | 11550 | 10750 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-01B | KCB-01 Northeast | 12050 | 10750 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-01C | KCB-01 Southeast | 12050 | 10250 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-01D | KCB-01 Southwest | 11550 | 10250 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-02-SL01 | Bank Quarter Service Lane Midpoint | 14000 | 8515 | service_lane_access | priority_or_uncontrolled | Yes |
| KCB-02A | KCB-02 Northwest | 13750 | 8450 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-02B | KCB-02 Northeast | 14250 | 8450 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-02C | KCB-02 Southeast | 14250 | 7950 | local_intersection | priority_or_uncontrolled | Yes |
| KCB-02D | KCB-02 Southwest | 13750 | 7950 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-01-SL01 | Civic Centre Service Lane Midpoint | 8500 | 8515 | service_lane_access | priority_or_uncontrolled | Yes |
| KCI-01A | KCI-01 Northwest | 8250 | 8450 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-01B | KCI-01 Northeast | 8750 | 8450 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-01C | KCI-01 Southeast | 8750 | 7950 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-01D | KCI-01 Southwest | 8250 | 7950 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-02-SL01 | Assembly Gardens Service Lane Midpoint | 10800 | 10315 | service_lane_access | priority_or_uncontrolled | Yes |
| KCI-02A | KCI-02 Northwest | 10550 | 10250 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-02B | KCI-02 Northeast | 11050 | 10250 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-02C | KCI-02 Southeast | 11050 | 9750 | local_intersection | priority_or_uncontrolled | Yes |
| KCI-02D | KCI-02 Southwest | 10550 | 9750 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-01-SL01 | Old Westhaven Service Lane Midpoint | 2200 | 9315 | service_lane_access | priority_or_uncontrolled | Yes |
| KDW-01A | KDW-01 Northwest | 1950 | 9250 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-01B | KDW-01 Northeast | 2450 | 9250 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-01C | KDW-01 Southeast | 2450 | 8750 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-01D | KDW-01 Southwest | 1950 | 8750 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-02-SL01 | Willow Park Service Lane Midpoint | 3800 | 11515 | service_lane_access | priority_or_uncontrolled | Yes |
| KDW-02A | KDW-02 Northwest | 3550 | 11450 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-02B | KDW-02 Northeast | 4050 | 11450 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-02C | KDW-02 Southeast | 4050 | 10950 | local_intersection | priority_or_uncontrolled | Yes |
| KDW-02D | KDW-02 Southwest | 3550 | 10950 | local_intersection | priority_or_uncontrolled | Yes |
| KED-01-SL01 | University Campus Service Lane Midpoint | 3600 | 14815 | service_lane_access | priority_or_uncontrolled | Yes |
| KED-01A | KED-01 Northwest | 3350 | 14750 | local_intersection | priority_or_uncontrolled | Yes |
| KED-01B | KED-01 Northeast | 3850 | 14750 | local_intersection | priority_or_uncontrolled | Yes |
| KED-01C | KED-01 Southeast | 3850 | 14250 | local_intersection | priority_or_uncontrolled | Yes |
| KED-01D | KED-01 Southwest | 3350 | 14250 | local_intersection | priority_or_uncontrolled | Yes |
| KED-02-SL01 | Hospital Hill Service Lane Midpoint | 5600 | 13115 | service_lane_access | priority_or_uncontrolled | Yes |
| KED-02A | KED-02 Northwest | 5350 | 13050 | local_intersection | priority_or_uncontrolled | Yes |
| KED-02B | KED-02 Northeast | 5850 | 13050 | local_intersection | priority_or_uncontrolled | Yes |
| KED-02C | KED-02 Southeast | 5850 | 12550 | local_intersection | priority_or_uncontrolled | Yes |
| KED-02D | KED-02 Southwest | 5350 | 12550 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-01-SL01 | Foundry Estate Service Lane Midpoint | 16500 | 11815 | service_lane_access | priority_or_uncontrolled | Yes |
| KIN-01A | KIN-01 Northwest | 16250 | 11750 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-01B | KIN-01 Northeast | 16750 | 11750 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-01C | KIN-01 Southeast | 16750 | 11250 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-01D | KIN-01 Southwest | 16250 | 11250 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-02-SL01 | Works Park Service Lane Midpoint | 18500 | 13515 | service_lane_access | priority_or_uncontrolled | Yes |
| KIN-02A | KIN-02 Northwest | 18250 | 13450 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-02B | KIN-02 Northeast | 18750 | 13450 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-02C | KIN-02 Southeast | 18750 | 12950 | local_intersection | priority_or_uncontrolled | Yes |
| KIN-02D | KIN-02 Southwest | 18250 | 12950 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-01-SL01 | Freight Village Service Lane Midpoint | 16500 | 8515 | service_lane_access | priority_or_uncontrolled | Yes |
| KLG-01A | KLG-01 Northwest | 16250 | 8450 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-01B | KLG-01 Northeast | 16750 | 8450 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-01C | KLG-01 Southeast | 16750 | 7950 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-01D | KLG-01 Southwest | 16250 | 7950 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-02-SL01 | Distribution Park Service Lane Midpoint | 18500 | 6515 | service_lane_access | priority_or_uncontrolled | Yes |
| KLG-02A | KLG-02 Northwest | 18250 | 6450 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-02B | KLG-02 Northeast | 18750 | 6450 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-02C | KLG-02 Southeast | 18750 | 5950 | local_intersection | priority_or_uncontrolled | Yes |
| KLG-02D | KLG-02 Southwest | 18250 | 5950 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-01-SL01 | Grand Market Service Lane Midpoint | 14000 | 7515 | service_lane_access | priority_or_uncontrolled | Yes |
| KMA-01A | KMA-01 Northwest | 13750 | 7450 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-01B | KMA-01 Northeast | 14250 | 7450 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-01C | KMA-01 Southeast | 14250 | 6950 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-01D | KMA-01 Southwest | 13750 | 6950 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-02-SL01 | Merchants Row Service Lane Midpoint | 16000 | 5915 | service_lane_access | priority_or_uncontrolled | Yes |
| KMA-02A | KMA-02 Northwest | 15750 | 5850 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-02B | KMA-02 Northeast | 16250 | 5850 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-02C | KMA-02 Southeast | 16250 | 5350 | local_intersection | priority_or_uncontrolled | Yes |
| KMA-02D | KMA-02 Southwest | 15750 | 5350 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-01-SL01 | Riverside East Service Lane Midpoint | 8500 | 3315 | service_lane_access | priority_or_uncontrolled | Yes |
| KMX-01A | KMX-01 Northwest | 8250 | 3250 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-01B | KMX-01 Northeast | 8750 | 3250 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-01C | KMX-01 Southeast | 8750 | 2750 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-01D | KMX-01 Southwest | 8250 | 2750 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-02-SL01 | Riverside West Service Lane Midpoint | 6500 | 1515 | service_lane_access | priority_or_uncontrolled | Yes |
| KMX-02A | KMX-02 Northwest | 6250 | 1450 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-02B | KMX-02 Northeast | 6750 | 1450 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-02C | KMX-02 Southeast | 6750 | 950 | local_intersection | priority_or_uncontrolled | Yes |
| KMX-02D | KMX-02 Southwest | 6250 | 950 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-01-SL01 | Northgate Heights Service Lane Midpoint | 6800 | 14015 | service_lane_access | priority_or_uncontrolled | Yes |
| KNA-01A | KNA-01 Northwest | 6550 | 13950 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-01B | KNA-01 Northeast | 7050 | 13950 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-01C | KNA-01 Southeast | 7050 | 13450 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-01D | KNA-01 Southwest | 6550 | 13450 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-02-SL01 | Cedar Estate Service Lane Midpoint | 8800 | 12515 | service_lane_access | priority_or_uncontrolled | Yes |
| KNA-02A | KNA-02 Northwest | 8550 | 12450 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-02B | KNA-02 Northeast | 9050 | 12450 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-02C | KNA-02 Southeast | 9050 | 11950 | local_intersection | priority_or_uncontrolled | Yes |
| KNA-02D | KNA-02 Southwest | 8550 | 11950 | local_intersection | priority_or_uncontrolled | Yes |
| KNG-R010-MID | Westhaven Road Midpoint Junction | 3025 | 9725 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R011-MID | Cedar Avenue Midpoint Junction | 7525 | 12975 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R012-MID | Assembly Avenue Midpoint Junction | 9400 | 9908 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R013-MID | Exchange Street Midpoint Junction | 13375 | 8225 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R014-MID | Campus Drive Midpoint Junction | 4675 | 14375 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R015-MID | Railway Road Midpoint Junction | 9375 | 5025 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R016-MID | Market Street Midpoint Junction | 14375 | 7175 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R017-MID | Works Road Midpoint Junction | 16500 | 13000 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R018-MID | Freightway Midpoint Junction | 16375 | 6175 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R019-MID | Dock Road Midpoint Junction | 17750 | 1500 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R020-MID | Riverside Drive Midpoint Junction | 8125 | 3525 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R021-MID | Aerodrome Road Midpoint Junction | 2875 | 1625 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R022-MID | Civic Square Midpoint Junction | 9400 | 9908 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R023-MID | Merchants Lane Midpoint Junction | 14375 | 7175 | at_grade | priority_or_uncontrolled | Yes |
| KNG-R024-MID | Harbour View Road Midpoint Junction | 17750 | 1500 | at_grade | priority_or_uncontrolled | Yes |
| KPT-01-SL01 | Harbourfront Service Lane Midpoint | 15500 | 3815 | service_lane_access | priority_or_uncontrolled | Yes |
| KPT-01A | KPT-01 Northwest | 15250 | 3750 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-01B | KPT-01 Northeast | 15750 | 3750 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-01C | KPT-01 Southeast | 15750 | 3250 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-01D | KPT-01 Southwest | 15250 | 3250 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-02-SL01 | Docklands Service Lane Midpoint | 18500 | 2115 | service_lane_access | priority_or_uncontrolled | Yes |
| KPT-02A | KPT-02 Northwest | 18250 | 2050 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-02B | KPT-02 Northeast | 18750 | 2050 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-02C | KPT-02 Southeast | 18750 | 1550 | local_intersection | priority_or_uncontrolled | Yes |
| KPT-02D | KPT-02 Southwest | 18250 | 1550 | local_intersection | priority_or_uncontrolled | Yes |
| KST-01-SL01 | Terminal Quarter Service Lane Midpoint | 9000 | 5115 | service_lane_access | priority_or_uncontrolled | Yes |
| KST-01A | KST-01 Northwest | 8750 | 5050 | local_intersection | priority_or_uncontrolled | Yes |
| KST-01B | KST-01 Northeast | 9250 | 5050 | local_intersection | priority_or_uncontrolled | Yes |
| KST-01C | KST-01 Southeast | 9250 | 4550 | local_intersection | priority_or_uncontrolled | Yes |
| KST-01D | KST-01 Southwest | 8750 | 4550 | local_intersection | priority_or_uncontrolled | Yes |
| KST-02-SL01 | Railway Approach Service Lane Midpoint | 11000 | 6515 | service_lane_access | priority_or_uncontrolled | Yes |
| KST-02A | KST-02 Northwest | 10750 | 6450 | local_intersection | priority_or_uncontrolled | Yes |
| KST-02B | KST-02 Northeast | 11250 | 6450 | local_intersection | priority_or_uncontrolled | Yes |
| KST-02C | KST-02 Southeast | 11250 | 5950 | local_intersection | priority_or_uncontrolled | Yes |
| KST-02D | KST-02 Southwest | 10750 | 5950 | local_intersection | priority_or_uncontrolled | Yes |
| RB01-E | RB01 East Bank | 17400 | 10500 | bridge_approach | priority_or_uncontrolled | Yes |
| RB01-W | RB01 West Bank | 16400 | 10500 | bridge_approach | priority_or_uncontrolled | Yes |
| RB02-E | RB02 East Bank | 17400 | 6500 | bridge_approach | priority_or_uncontrolled | Yes |
| RB02-W | RB02 West Bank | 16400 | 6500 | bridge_approach | priority_or_uncontrolled | Yes |
| RB03-E | RB03 East Bank | 17400 | 2800 | bridge_approach | priority_or_uncontrolled | Yes |
| RB03-W | RB03 West Bank | 16400 | 2800 | bridge_approach | priority_or_uncontrolled | Yes |

## 4. Geometry and road construction detail

Every road segment stores a four-point polyline in `game.road_segments.geometry_local_m`. The first coordinate must equal the from-junction coordinate and the final coordinate must equal the to-junction coordinate. Intermediate coordinates preserve the authored local-grid alignment and bends. Segment lengths are recalculated from the stored polyline.

Each segment also records:
- road class and road hierarchy;
- lane count per direction and directionality;
- posted speed limit and surface type;
- carriageway width and lane-marking profile;
- median type;
- sidewalk, cycle-lane and street-lighting presence;
- on-street parking availability;
- road condition and elevation-change field;
- crossing type, access profile and routability;
- map version and geometry provenance.

## 5. Directionality and junction controls

The 24 neighbourhood local-street loops each contain four clockwise one-way segments (96 one-way segments total). Their collector connections remain two-way. The 24 named rear service lanes contain two connected low-speed segments each and remain two-way. Remaining streets retain their authored directionality.

The junction register distinguishes signalised junctions, priority/uncontrolled junctions, local intersections, service-lane access points and bridge approaches. Pedestrian crossings, tactile crossings, signal cycle data and lighting standards are recorded independently of road geometry.

## 6. Bridges

Three river bridges are explicit named road assets:
- East River Bridge North;
- Riverside Bridge;
- Harbour River Bridge.

Each has west-bank approach, bridge-deck and east-bank approach segments. The bridge deck is represented as a distinct crossing segment; no false at-grade intersection is created across the river.

## 7. Property access and service entrances

The primary entrance layer is retained. An additional 480 secondary access points are now recorded for non-residential premises and high-rise buildings, including rear service entrances, loading/service entrances and secondary garage/service entrances. Each access point is linked to its property, building, road segment and nearest junction. Dispatch and navigation can resolve the appropriate entrance rather than assuming every arrival uses the public front door.

## 8. Turn restrictions, traffic and road closures

### Turn restrictions
`game.road_turn_restrictions` stores incoming segment, via-junction and outgoing segment combinations, restriction kind (prohibited or only), turn type, vehicle profiles, validity period and reason. The baseline has explicit no-immediate-U-turn controls at both ends of every two-way segment (266 records). Eight signalised junctions also have authored movement bans: one prohibited left-turn and one prohibited right-turn movement at each junction (16 records). These public-traffic bans preserve police/emergency exemptions. The routing helper enforces vehicle-specific prohibited and only-turn rules.

### Scheduled traffic
`game.road_segment_traffic_profiles` stores weekday morning and evening peak profiles for every segment. Profiles include applicable days, local clock interval, speed multiplier, fixed delay and vehicle applicability. The route engine applies these only when supplied with the fictional simulation timestamp; no fictional clock is started by geography tests.

### Dynamic conditions
`game.road_segment_conditions` supports collisions, roadworks, flooding, weather hazards, public events, police cordons, bridge lifts and surface damage. Conditions can apply speed reductions, fixed delays or full closures, with vehicle-specific closure rules and emergency overrides. The route engine excludes active closed segments and applies active delays and speed multipliers.

## 9. Routing and police operations

The routing engine uses directed edge states, not just undirected junction reachability. It enforces one-way travel, turn restrictions, access profiles, active closures and scheduled traffic. It supports fastest and shortest routes for public, police and emergency vehicle profiles.

Dispatch and deployment route snapshots pass the fictional simulation clock into the route engine, so estimated arrival times reflect scheduled traffic and active road conditions. The same road-segment identities are used by patrol-beat coverage and patrol movement records.

## 10. Authoritative storage

- **GitHub:** source-controlled migration history, this road gazetteer, test suites and the database-derived SVG map.
- **Supabase:** authoritative live road, junction, segment, geometry, entrance, traffic, closure, turn-control and patrol-coverage records.
- **ChatGPT:** gameplay interface and explanation layer; it is not the only storage location for the map.

## 11. Regression and acceptance gates

The BP-02 detailed street atlas regression checks:
1. 75 unique named roads and no road without segments;
2. 157 junctions inside the city grid;
3. 229 segments with four-point geometry and correct endpoint coordinates;
4. 96 one-way neighbourhood loop segments;
5. 24 service lanes and 48 service-lane segments;
6. three mapped bridge deck segments;
7. 480 secondary and 1,136 total property entrances;
8. 458 scheduled traffic profiles;
9. 266 explicit no-U-turn controls;
10. complete patrol-beat coverage and connected road graph;
11. row-level security on road operations tables;
12. prohibited-turn and only-turn behaviour;
13. baseline and peak-hour route calculations;
14. active closure avoidance;
15. one-way route compliance and preservation of the uninitialised fictional clock.

The companion tests are:
- `database/tests/kingswell_geography_seed.sql`
- `database/tests/kingswell_bp02_detailed_street_atlas.sql`
- `database/tests/kingswell_weighted_road_routing.sql`
- `database/tests/kingswell_live_dispatch_route_integration.sql`
- `database/tests/kingswell_dispatch_route_end_to_end.sql`

**Map version:** KNG-MAP-0.3. Any later change to road identity, junction position, segment topology, access, traffic or route behaviour must update the database, migration history, SVG and regression tests together.
