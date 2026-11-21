
-- BP-04 workforce dossier synchronisation for employment seeded after migrations.
-- The original dossier migration only backfilled rows already present when it ran.
CREATE OR REPLACE FUNCTION game.sync_organisation_personnel_role_dossier()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_role_ref text;
  v_role_family text;
  v_summary text := 'Role description derived from the existing canonical job title; role-family guide, not a verified individual job specification.';
  v_responsibilities jsonb;
BEGIN
  v_role_ref := 'KWROLE-' || upper(regexp_replace(NEW.job_title, '[^A-Za-z0-9]+', '-', 'g'));
  v_role_family := CASE
    WHEN NEW.job_title ILIKE '%Financial%' THEN 'finance_and_customer_accounts'
    WHEN NEW.job_title ILIKE '%Trade%' OR NEW.job_title ILIKE '%Wholesale%' THEN 'trade_and_commercial_operations'
    WHEN NEW.job_title ILIKE '%Logistics%' THEN 'warehouse_and_logistics'
    WHEN NEW.job_title ILIKE '%Transport%' THEN 'transport_operations'
    WHEN NEW.job_title ILIKE '%Neighbourhood%' THEN 'community_and_local_services'
    WHEN NEW.job_title ILIKE '%Retail%' THEN 'retail_and_customer_service'
    WHEN NEW.job_title ILIKE '%Production%' THEN 'production_and_manufacturing'
    WHEN NEW.job_title ILIKE '%Hospitality%' THEN 'hospitality_and_visitor_services'
    WHEN NEW.job_title ILIKE '%Professional%' THEN 'professional_services'
    WHEN NEW.job_title ILIKE '%Technology%' THEN 'technology_and_media'
    WHEN NEW.job_title ILIKE '%Construction%' THEN 'construction_and_property'
    WHEN NEW.job_title ILIKE '%Property Management%' THEN 'property_management'
    ELSE 'general_business_operations'
  END;
  v_responsibilities := CASE
    WHEN NEW.job_title ILIKE '%Financial%' THEN '["customer account support","transaction processing","financial service administration","record handling"]'::jsonb
    WHEN NEW.job_title ILIKE '%Trade%' OR NEW.job_title ILIKE '%Wholesale%' THEN '["trade order processing","supplier and customer coordination","goods movement administration","commercial records"]'::jsonb
    WHEN NEW.job_title ILIKE '%Logistics%' THEN '["goods receipt and dispatch","stock movement","warehouse operations","inventory handling"]'::jsonb
    WHEN NEW.job_title ILIKE '%Transport%' THEN '["transport service operations","vehicle or passenger coordination","route and service support","operational records"]'::jsonb
    WHEN NEW.job_title ILIKE '%Neighbourhood%' THEN '["local service delivery","community-facing support","service request handling","neighbourhood operations"]'::jsonb
    WHEN NEW.job_title ILIKE '%Retail%' THEN '["customer assistance","sales transactions","merchandise handling","shop-floor operations"]'::jsonb
    WHEN NEW.job_title ILIKE '%Production%' THEN '["production activities","materials handling","quality and output recording","workplace operations"]'::jsonb
    WHEN NEW.job_title ILIKE '%Hospitality%' THEN '["guest assistance","service delivery","booking coordination","venue operations"]'::jsonb
    WHEN NEW.job_title ILIKE '%Professional%' THEN '["client service delivery","professional administration","case or project support","business records"]'::jsonb
    WHEN NEW.job_title ILIKE '%Technology%' THEN '["technology or media support","digital systems or content operations","technical administration","service records"]'::jsonb
    WHEN NEW.job_title ILIKE '%Construction%' THEN '["construction or property project support","site coordination","materials and contractor liaison","project records"]'::jsonb
    WHEN NEW.job_title ILIKE '%Property Management%' THEN '["premises administration","occupier liaison","maintenance coordination","property records"]'::jsonb
    ELSE '["business operations","customer or supplier coordination","routine administrative records"]'::jsonb
  END;

  INSERT INTO game.organisation_job_role_catalog(
    job_role_ref, job_title, role_family, role_summary,
    typical_responsibilities, sector_scope, provenance
  ) VALUES (
    v_role_ref, NEW.job_title, v_role_family, v_summary, v_responsibilities,
    'Derived from existing seeded fictional employment title; actual sector inherited from employing organisation.',
    jsonb_build_object('source','game.organisation_personnel.job_title',
      'classification','seeded fictional role-family reference',
      'not_an_individual_job_description',true)
  )
  ON CONFLICT (job_title) DO NOTHING;

  SELECT job_role_ref INTO v_role_ref
  FROM game.organisation_job_role_catalog WHERE job_title = NEW.job_title;

  INSERT INTO game.organisation_personnel_dossiers(
    organisation_personnel_id, job_role_ref, employment_record_ref,
    employment_summary, work_scope, record_provenance
  ) VALUES (
    NEW.id, v_role_ref, 'KWEMP-' || replace(NEW.id::text, '-', ''),
    v_summary,
    jsonb_build_object('canonical_job_title',NEW.job_title,
      'employment_type',NEW.employment_type,
      'current_status',CASE WHEN NEW.is_current THEN 'current' ELSE 'historical' END,
      'valid_from',NEW.valid_from,'valid_to',NEW.valid_to,
      'employing_organisation_id',NEW.organisation_id,'person_id',NEW.person_id),
    jsonb_build_object('source','existing game.organisation_personnel record and canonical job-role catalogue',
      'classification','derived fictional workforce dossier',
      'no_person_identity_created',true,
      'department_supervisor_site_schedule_and_access_not_inferred',true)
  )
  ON CONFLICT (organisation_personnel_id) DO UPDATE
  SET job_role_ref=EXCLUDED.job_role_ref,
      employment_summary=EXCLUDED.employment_summary,
      work_scope=EXCLUDED.work_scope,
      record_provenance=EXCLUDED.record_provenance,
      updated_at=now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_organisation_personnel_role_dossier ON game.organisation_personnel;
CREATE TRIGGER trg_sync_organisation_personnel_role_dossier
AFTER INSERT OR UPDATE OF job_title, employment_type, valid_from, valid_to, is_current
ON game.organisation_personnel
FOR EACH ROW EXECUTE FUNCTION game.sync_organisation_personnel_role_dossier();

-- Backfill existing records by deliberately invoking the same trigger path.
UPDATE game.organisation_personnel
SET job_title = job_title
WHERE NOT EXISTS (
  SELECT 1 FROM game.organisation_personnel_dossiers d
  WHERE d.organisation_personnel_id = organisation_personnel.id
);

REVOKE ALL ON FUNCTION game.sync_organisation_personnel_role_dossier() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION game.sync_organisation_personnel_role_dossier() TO service_role;
