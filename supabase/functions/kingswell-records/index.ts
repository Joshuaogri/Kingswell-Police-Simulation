import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "https://joshuaogri.github.io",
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
const safeText = (v: unknown, max = 80) => String(v ?? "").trim().slice(0, max).replace(/[,%()]/g, " ").replace(/\s+/g, " ");
const pageInt = (v: string | null, fallback: number, min: number, max: number) => {
  const n = Number.parseInt(v ?? "", 10);
  return Number.isFinite(n) ? Math.min(max, Math.max(min, n)) : fallback;
};
const personSelect = "id,person_ref,given_name,middle_names,family_name,preferred_name,date_of_birth,person_status,occupation,nationality,preferred_language,simulation_level,date_of_death";
const businessSelect = "organisation_id,business_number,trading_name,sector,subsector,business_size,ownership_form,incorporation_date,estimated_employee_count,annual_turnover_band,import_export_activity,principal_goods_categories,service_description,business_hours,fictional_website_domain";
const orgSelect = "id,organisation_ref,name,organisation_type,parent_organisation_id,status";
const propertySelect = "id,property_ref,city_id,district_id,neighbourhood_id,road_id,street_number,address_line,property_type,latitude,longitude,status,x_m,y_m,parcel_area_sqm,frontage_width_m,land_use,postal_code";
const personSearch = (q: string) => `person_ref.ilike.%${q}%,given_name.ilike.%${q}%,middle_names.ilike.%${q}%,family_name.ilike.%${q}%,preferred_name.ilike.%${q}%,occupation.ilike.%${q}%`;
const businessSearch = (q: string) => `business_number.ilike.%${q}%,trading_name.ilike.%${q}%,sector.ilike.%${q}%,subsector.ilike.%${q}%`;
const orgSearch = (q: string) => `organisation_ref.ilike.%${q}%,name.ilike.%${q}%,organisation_type.ilike.%${q}%`;
const propertySearch = (q: string) => `property_ref.ilike.%${q}%,address_line.ilike.%${q}%,street_number.ilike.%${q}%,postal_code.ilike.%${q}%`;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "GET") return fail("Only GET requests are supported.", 405);

  const url = new URL(req.url);
  const type = safeText(url.searchParams.get("type"), 24).toLowerCase();
  const q = safeText(url.searchParams.get("q"), 80);
  const id = safeText(url.searchParams.get("id"), 80);
  const limit = pageInt(url.searchParams.get("limit"), 25, 1, 50);
  const offset = pageInt(url.searchParams.get("offset"), 0, 0, 100000);
  const allowed = ["people", "businesses", "organisations", "properties"];
  if (!allowed.includes(type)) return fail("Choose people, businesses, organisations or properties.");


  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const legacyKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const secretKeysRaw = Deno.env.get("SUPABASE_SECRET_KEYS");
  let serviceKey = legacyKey;
  if (secretKeysRaw) {
    try { serviceKey = JSON.parse(secretKeysRaw).default ?? serviceKey; } catch { /* use legacy key */ }
  }
  if (!supabaseUrl || !serviceKey) return fail("Record service is not configured.", 503);
  const db = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
    db: { schema: "game" },
  });

  try {
    if (type === "people") {
      if (id) {
        let base = db.from("persons").select(personSelect).limit(1);
        base = id.includes("-") ? base.eq("id", id) : base.eq("person_ref", id);
        const { data: person, error } = await base.maybeSingle();
        if (error) throw error;
        if (!person) return fail("Person record not found.", 404);
        const [{ data: addresses, error: addressError }, { data: links, error: linksError }] = await Promise.all([
          db.from("person_addresses").select("address_role,valid_from,valid_to,is_current,is_primary,property_id,building_unit_id").eq("person_id", person.id).eq("is_current", true).limit(5),
          db.from("person_relationships").select("relationship_type,related_person_id,valid_from,valid_to").eq("person_id", person.id).limit(20),
        ]);
        if (addressError) throw addressError;
        if (linksError) throw linksError;
        const propertyIds = [...new Set((addresses ?? []).map((a: any) => a.property_id).filter(Boolean))];
        const unitIds = [...new Set((addresses ?? []).map((a: any) => a.building_unit_id).filter(Boolean))];
        const [{ data: properties }, { data: units }] = await Promise.all([
          propertyIds.length ? db.from("properties").select("id,property_ref,street_number,address_line,postal_code,neighbourhood_id,district_id").in("id", propertyIds) : Promise.resolve({ data: [] }),
          unitIds.length ? db.from("building_units").select("id,unit_ref,unit_name,unit_type,floor_label").in("id", unitIds) : Promise.resolve({ data: [] }),
        ]);
        const addressRecords = (addresses ?? []).map((a: any) => ({
          role: a.address_role, from: a.valid_from, to: a.valid_to, primary: a.is_primary,
          property: (properties ?? []).find((p: any) => p.id === a.property_id) ?? null,
          unit: (units ?? []).find((u: any) => u.id === a.building_unit_id) ?? null,
        }));
        const relatedIds = [...new Set((links ?? []).map((x: any) => x.related_person_id))];
        const { data: related } = relatedIds.length
          ? await db.from("persons").select("id,person_ref,given_name,family_name,preferred_name").in("id", relatedIds)
          : { data: [] };
        return json({ record: { ...person, addresses: addressRecords, relationships: (links ?? []).map((x: any) => ({ type: x.relationship_type, valid_from: x.valid_from, valid_to: x.valid_to, person: (related ?? []).find((p: any) => p.id === x.related_person_id) ?? null })) } });
      }
      let query = db.from("persons").select(personSelect, { count: "exact" }).order("family_name").order("given_name").range(offset, offset + limit - 1);
      if (q) query = query.or(personSearch(q));
      const { data, error, count } = await query;
      if (error) throw error;
      return json({ type, q, limit, offset, total: count ?? 0, records: data ?? [] });
    }

    if (type === "businesses") {
      if (id) {
        const { data: business, error } = await db.from("business_profiles").select(businessSelect).eq("business_number", id).maybeSingle();
        if (error) throw error;
        if (!business) return fail("Business record not found.", 404);
        const [{ data: org }, { data: sites }, { data: staff }] = await Promise.all([
          db.from("organisations").select(orgSelect).eq("id", business.organisation_id).maybeSingle(),
          db.from("organisation_locations").select("site_ref,site_name,location_role,occupancy_status,valid_from,valid_to,property_id,building_unit_id").eq("organisation_id", business.organisation_id).limit(30),
          db.from("organisation_personnel").select("id,person_id,job_title,employment_type,valid_from,valid_to,is_current").eq("organisation_id", business.organisation_id).eq("is_current", true).limit(50),
        ]);
        return json({ record: { ...business, organisation: org ?? null, sites: sites ?? [], workforce: staff ?? [] } });
      }
      let query = db.from("business_profiles").select(businessSelect, { count: "exact" }).order("trading_name").range(offset, offset + limit - 1);
      if (q) query = query.or(businessSearch(q));
      const { data, error, count } = await query;
      if (error) throw error;
      return json({ type, q, limit, offset, total: count ?? 0, records: data ?? [] });
    }

    if (type === "organisations") {
      if (id) {
        let query = db.from("organisations").select(orgSelect).limit(1);
        query = id.includes("-") ? query.eq("id", id) : query.eq("organisation_ref", id);
        const { data: org, error } = await query.maybeSingle();
        if (error) throw error;
        if (!org) return fail("Organisation record not found.", 404);
        const [{ data: profile }, { data: sites }, { data: parent }] = await Promise.all([
          db.from("organisation_profiles").select("profile_ref,organisation_class,operating_model,primary_remit,service_or_market_scope,governance_structure_status,legal_form_status,branch_network_summary,staffing_summary,premises_summary,public_contact_profile").eq("organisation_id", org.id).maybeSingle(),
          db.from("organisation_locations").select("site_ref,site_name,location_role,occupancy_status,valid_from,valid_to,property_id,building_unit_id").eq("organisation_id", org.id).limit(50),
          org.parent_organisation_id ? db.from("organisations").select(orgSelect).eq("id", org.parent_organisation_id).maybeSingle() : Promise.resolve({ data: null }),
        ]);
        return json({ record: { ...org, profile: profile ?? null, sites: sites ?? [], parent: parent.data ?? null } });
      }
      let query = db.from("organisations").select(orgSelect, { count: "exact" }).order("name").range(offset, offset + limit - 1);
      if (q) query = query.or(orgSearch(q));
      const { data, error, count } = await query;
      if (error) throw error;
      return json({ type, q, limit, offset, total: count ?? 0, records: data ?? [] });
    }

    if (type === "properties") {
      if (id) {
        const { data: property, error } = await db.from("properties").select(propertySelect).eq("property_ref", id).maybeSingle();
        if (error) throw error;
        if (!property) return fail("Property record not found.", 404);
        const [{ data: buildings }, { data: profile }, { data: district }, { data: neighbourhood }] = await Promise.all([
          db.from("buildings").select("id,building_ref,name,building_type,floors,x_m,y_m,footprint_width_m,footprint_depth_m,footprint_area_sqm,construction_type,occupancy_status").eq("property_id", property.id).limit(10),
          db.from("property_profiles").select("parcel_number,cadastral_block,zoning_code,permitted_uses,development_intensity,tenure_type,heritage_status,flood_exposure,contamination_status,map_label,site_description").eq("property_id", property.id).maybeSingle(),
          property.district_id ? db.from("districts").select("code,name,district_type").eq("id", property.district_id).maybeSingle() : Promise.resolve({ data: null }),
          property.neighbourhood_id ? db.from("neighbourhoods").select("code,name").eq("id", property.neighbourhood_id).maybeSingle() : Promise.resolve({ data: null }),
        ]);
        const buildingIds = (buildings ?? []).map((b: any) => b.id);
        const { data: units } = buildingIds.length
          ? await db.from("building_units").select("id,unit_ref,unit_name,unit_type,floor_label,building_id").in("building_id", buildingIds).order("unit_ref").limit(100)
          : { data: [] };
        const { data: locationRows } = await db.from("organisation_locations").select("organisation_id").eq("property_id", property.id);
        const organisationIds = [...new Set((locationRows ?? []).map((x: any) => x.organisation_id).filter(Boolean))];
        const [{ data: businesses }, { data: sites }] = await Promise.all([
          organisationIds.length
            ? db.from("business_profiles").select("business_number,trading_name,sector,subsector,organisation_id").in("organisation_id", organisationIds).limit(30)
            : Promise.resolve({ data: [] }),
          db.from("organisation_site_dossiers").select("site_ref,site_class,site_status,physical_address,building_ref,building_name,unit_ref,unit_name,organisation_id").eq("property_id", property.id).limit(30),
        ]);
        return json({ record: { ...property, district: district.data ?? null, neighbourhood: neighbourhood.data ?? null, profile: profile ?? null, buildings: buildings ?? [], units: units ?? [], businesses: businesses ?? [], sites: sites ?? [] } });
      }
      let query = db.from("properties").select(propertySelect, { count: "exact" }).order("property_ref").range(offset, offset + limit - 1);
      if (q) query = query.or(propertySearch(q));
      const { data, error, count } = await query;
      if (error) throw error;
      return json({ type, q, limit, offset, total: count ?? 0, records: data ?? [] });
    }
  } catch (error) {
    console.error("kingswell-records", error);
    return fail("The record query failed. Check the requested record type and canonical reference.", 500);
  }
});
