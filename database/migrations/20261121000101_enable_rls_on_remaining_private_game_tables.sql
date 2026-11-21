-- Defense in depth for all remaining private game tables.
-- The game schema remains unexposed to anon/authenticated; no broad policies are added.
ALTER TABLE game.organisation_control_interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.organisation_site_agreement_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.organisation_site_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.property_asset_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.property_valuation_records ENABLE ROW LEVEL SECURITY;
