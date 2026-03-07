-- GIN
CREATE INDEX idx_audit_log_search_vector_gin 
ON papers.audit_log USING GIN (search_vector);
-- DROP INDEX IF EXISTS idx_audit_log_search_vector_gin;

CREATE INDEX idx_passport_metadata_path_ops 
ON identity.passport USING GIN (metadata jsonb_path_ops);
-- DROP INDEX IF EXISTS idx_passport_metadata_gin;

-- GiST 
CREATE INDEX idx_biometry_photo_coords_gist 
ON identity.biometry USING GIST (photo_coords);
-- DROP INDEX IF EXISTS idx_biometry_photo_coords_gist;

CREATE INDEX idx_passport_validity_period_gist 
ON identity.passport USING GIST (validity_period);
-- DROP INDEX IF EXISTS idx_passport_validity_period_gist;