import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import postgres from "npm:postgres@3.4.7";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Vary": "Origin",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" },
  });
const fail = (message: string, status = 400) => json({ error: message }, status);
const safeText = (v: unknown, max = 80) =>
  String(v ?? "").trim().slice(0, max).replace(/[,%()]/g, " ").replace(/\s+/g, " ");
const pageInt = (v: string | null, fallback: number, min: number, max: number) => {
  const n = Number.parseInt(v ?? "", 10);
  return Number.isFinite(n) ? Math.min(max, Math.max(min, n)) : fallback;
};

const databaseUrl = Deno.env.get("SUPABASE_DB_URL");
const db = databaseUrl
  ? postgres(databaseUrl, { max: 1, prepare: false, ssl: "require", connect_timeout: 10, idle_timeout: 20 })
  : null;

const personFields = "id,person_ref,given_name,middle_names,family_name,preferred_name,date_of_birth,person_status,occupation,nationality,preferred_language,simulation_level,date_of_death";
const businessFields = "organisation_id,business_number,trading_name,sector,subsector,business_size,ownership_form,incorporation_date,estimated_employee_count,annual_turnover_band,import_export_activity,principal_goods_categories,service_description,business_hours,fictional_website_domain";
const organisationFields = "id,organisation_ref,name,organisation_type,parent_organisation_id,status";
const propertyFields = "p.id,p.property_ref,p.city_id,p.district_id,p.neighbourhood_id,p.road_id,p.street_number,p.address_line,p.property_type,p.latitude,p.longitude,p.status,p.x_m,p.y_m,p.parcel_area_sqm,p.frontage_width_m,p.land_use,p.postal_code";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "GET") return fail("Only GET requests are supported.", 405);

  const url = new URL(req.url);
  const type = safeText(url.searchParams.get("type"), 24).toLowerCase();
  const q = safeText(url.searchParams.get("q"), 80);
  const id = safeText(url.searchParams.get("id"), 80);
  const limit = pageInt(url.searchParams.get("limit"), 25, 1, 50);
  const offset = pageInt(url.searchParams.get("offset"), 0, 0, 100000);
  if (!["people", "businesses", "organisations", "properties"].includes(type)) {
    return fail("Choose people, businesses, organisations or properties.");
  }
  if (!db) return fail("Record service database connection is not configured.", 503);

  try {
    const result = await db.begin(async (tx) => {
      await tx`set transaction read only`;

      if (type === "people") {
        if (id) {
          const rows = await tx`select ${tx.unsafe(personFields)} from game.persons
            where id::text = ${id} or person_ref = ${id} limit 1`;
          const person = rows[0];
          if (!person) return { notFound: "Person record not found." };
          const addresses = await tx`
            select pa.address_role as role, pa.valid_from, pa.valid_to, pa.is_primary,
              case when p.id is null then null else jsonb_build_object(
                'property_ref',p.property_ref,'address',concat_ws(' ',p.street_number,p.address_line),
                'postal_code',p.postal_code,'district_id',p.district_id,'neighbourhood_id',p.neighbourhood_id
              ) end as property,
              case when bu.id is null then null else jsonb_build_object(
                'unit_ref',bu.unit_ref,'unit_name',bu.unit_name,'unit_type',bu.unit_type,'floor_label',bu.floor_label
              ) end as unit
            from game.person_addresses pa
            left join game.properties p on p.id=pa.property_id
            left join game.building_units bu on bu.id=pa.building_unit_id
            where pa.person_id=${person.id} and pa.is_current=true
            order by pa.is_primary desc, pa.valid_from desc limit 5`;
          const relationships = await tx`
            select pr.relationship_type as type,pr.valid_from,pr.valid_to,
              case when p.id is null then null else jsonb_build_object(
                'id',p.id,'person_ref',p.person_ref,'given_name',p.given_name,
                'family_name',p.family_name,'preferred_name',p.preferred_name
              ) end as person
            from game.person_relationships pr
            left join game.persons p on p.id=pr.related_person_id
            where pr.person_id=${person.id} order by pr.relationship_type limit 20`;
          return { record: { ...person, addresses, relationships } };
        }
        const where = q
          ? tx`(person_ref ilike ${"%" + q + "%"} or given_name ilike ${"%" + q + "%"} or middle_names ilike ${"%" + q + "%"} or family_name ilike ${"%" + q + "%"} or preferred_name ilike ${"%" + q + "%"} or occupation ilike ${"%" + q + "%"})`
          : tx`true`;
        const records = await tx`select ${tx.unsafe(personFields)} from game.persons
          where ${where} order by family_name,given_name,person_ref limit ${limit} offset ${offset}`;
        const [{ total }] = await tx`select count(*)::int as total from game.persons where ${where}`;
        return { type, q, limit, offset, total, records };
      }

      if (type === "businesses") {
        if (id) {
          const rows = await tx`
            select bp.*,o.organisation_ref,o.name as organisation_name,o.organisation_type,o.status as organisation_status
            from game.business_profiles bp left join game.organisations o on o.id=bp.organisation_id
            where bp.business_number=${id} limit 1`;
          const business = rows[0];
          if (!business) return { notFound: "Business record not found." };
          const sites = await tx`
            select ol.site_ref,ol.site_name,ol.location_role,ol.occupancy_status,ol.valid_from,ol.valid_to,
              p.property_ref,concat_ws(' ',p.street_number,p.address_line) as address,bu.unit_ref,bu.unit_name
            from game.organisation_locations ol
            left join game.properties p on p.id=ol.property_id
            left join game.building_units bu on bu.id=ol.building_unit_id
            where ol.organisation_id=${business.organisation_id}
            order by ol.is_primary_location desc,ol.site_name limit 30`;
          const workforce = await tx`
            select op.job_title,op.employment_type,op.valid_from,op.valid_to,op.is_current,
              p.person_ref,p.given_name,p.family_name,p.preferred_name
            from game.organisation_personnel op left join game.persons p on p.id=op.person_id
            where op.organisation_id=${business.organisation_id} and op.is_current=true
            order by p.family_name,p.given_name limit 50`;
          return { record: { ...business, sites, workforce } };
        }
        const where = q
          ? tx`(bp.business_number ilike ${"%" + q + "%"} or bp.trading_name ilike ${"%" + q + "%"} or bp.sector ilike ${"%" + q + "%"} or bp.subsector ilike ${"%" + q + "%"})`
          : tx`true`;
        const records = await tx`
          select ${tx.unsafe(businessFields)},o.name as organisation_name,o.organisation_ref
          from game.business_profiles bp left join game.organisations o on o.id=bp.organisation_id
          where ${where} order by bp.trading_name,bp.business_number limit ${limit} offset ${offset}`;
        const [{ total }] = await tx`select count(*)::int as total from game.business_profiles bp where ${where}`;
        return { type, q, limit, offset, total, records };
      }

      if (type === "organisations") {
        if (id) {
          const rows = await tx`
            select o.id,o.organisation_ref,o.name,o.organisation_type,o.parent_organisation_id,o.status,
              op.profile_ref,op.organisation_class,op.operating_model,op.primary_remit,op.service_or_market_scope,
              op.governance_structure_status,op.legal_form_status,op.branch_network_summary,
              op.staffing_summary,op.premises_summary,op.public_contact_profile
            from game.organisations o left join game.organisation_profiles op on op.organisation_id=o.id
            where o.id::text=${id} or o.organisation_ref=${id} limit 1`;
          const org = rows[0];
          if (!org) return { notFound: "Organisation record not found." };
          const sites = await tx`
            select ol.site_ref,ol.site_name,ol.location_role,ol.occupancy_status,ol.valid_from,ol.valid_to,
              p.property_ref,concat_ws(' ',p.street_number,p.address_line) as address,bu.unit_ref,bu.unit_name
            from game.organisation_locations ol
            left join game.properties p on p.id=ol.property_id
            left join game.building_units bu on bu.id=ol.building_unit_id
            where ol.organisation_id=${org.id} order by ol.is_primary_location desc,ol.site_name limit 50`;
          const parentRows = org.parent_organisation_id
            ? await tx`select id,organisation_ref,name,organisation_type,status from game.organisations where id=${org.parent_organisation_id} limit 1`
            : [];
          return { record: { ...org, sites, parent: parentRows[0] ?? null } };
        }
        const where = q
          ? tx`(organisation_ref ilike ${"%" + q + "%"} or name ilike ${"%" + q + "%"} or organisation_type ilike ${"%" + q + "%"})`
          : tx`true`;
        const records = await tx`select ${tx.unsafe(organisationFields)} from game.organisations
          where ${where} order by name,organisation_ref limit ${limit} offset ${offset}`;
        const [{ total }] = await tx`select count(*)::int as total from game.organisations where ${where}`;
        return { type, q, limit, offset, total, records };
      }

      if (type === "properties") {
        if (id) {
          const rows = await tx`
            select p.id,p.property_ref,p.city_id,p.district_id,p.neighbourhood_id,p.road_id,
              p.street_number,p.address_line,p.property_type,p.latitude,p.longitude,p.status,p.x_m,p.y_m,
              p.parcel_area_sqm,p.frontage_width_m,p.land_use,p.postal_code,
              jsonb_build_object('code',d.code,'name',d.name,'district_type',d.district_type) as district,
              jsonb_build_object('code',n.code,'name',n.name) as neighbourhood,
              jsonb_build_object('parcel_number',pp.parcel_number,'cadastral_block',pp.cadastral_block,
                'zoning_code',pp.zoning_code,'permitted_uses',pp.permitted_uses,'development_intensity',pp.development_intensity,
                'tenure_type',pp.tenure_type,'heritage_status',pp.heritage_status,'flood_exposure',pp.flood_exposure,
                'contamination_status',pp.contamination_status,'map_label',pp.map_label,'site_description',pp.site_description) as profile
            from game.properties p
            left join game.districts d on d.id=p.district_id
            left join game.neighbourhoods n on n.id=p.neighbourhood_id
            left join game.property_profiles pp on pp.property_id=p.id
            where p.property_ref=${id} limit 1`;
          const property = rows[0];
          if (!property) return { notFound: "Property record not found." };
          const buildings = await tx`
            select id,building_ref,name,building_type,floors,x_m,y_m,footprint_width_m,footprint_depth_m,
              footprint_area_sqm,construction_type,occupancy_status
            from game.buildings where property_id=${property.id} order by building_ref limit 10`;
          const units = await tx`
            select bu.id,bu.unit_ref,bu.unit_name,bu.unit_type,bu.floor_label,bu.building_id
            from game.building_units bu join game.buildings b on b.id=bu.building_id
            where b.property_id=${property.id} order by bu.unit_ref limit 100`;
          const businesses = await tx`
            select distinct bp.business_number,bp.trading_name,bp.sector,bp.subsector,bp.organisation_id
            from game.business_profiles bp join game.organisation_locations ol on ol.organisation_id=bp.organisation_id
            where ol.property_id=${property.id} order by bp.trading_name limit 30`;
          const sites = await tx`
            select site_ref,site_class,site_status,physical_address,building_ref,building_name,unit_ref,unit_name,organisation_id
            from game.organisation_site_dossiers where property_id=${property.id} limit 30`;
          return { record: { ...property, buildings, units, businesses, sites } };
        }
        const where = q
          ? tx`(p.property_ref ilike ${"%" + q + "%"} or p.address_line ilike ${"%" + q + "%"} or p.street_number ilike ${"%" + q + "%"} or p.postal_code ilike ${"%" + q + "%"})`
          : tx`true`;
        const records = await tx`
          select ${tx.unsafe(propertyFields)},d.name as district_name,n.name as neighbourhood_name
          from game.properties p left join game.districts d on d.id=p.district_id
          left join game.neighbourhoods n on n.id=p.neighbourhood_id
          where ${where} order by p.property_ref limit ${limit} offset ${offset}`;
        const [{ total }] = await tx`select count(*)::int as total from game.properties p where ${where}`;
        return { type, q, limit, offset, total, records };
      }
      return { notFound: "Unsupported record type." };
    });
    if ("notFound" in result) return fail(result.notFound, 404);
    return json(result);
  } catch (error) {
    console.error("kingswell-records", error);
    return fail("The live record query failed. Check the record type and canonical reference.", 500);
  }
});
