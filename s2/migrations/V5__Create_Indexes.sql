-- Запросы с (=)

CREATE INDEX idx_country_access_log_country_id_btree 
ON identity.country_access_log (country_id);

-- CREATE INDEX idx_country_access_log_country_id_hash
-- ON identity.country_access_log USING HASH (country_id);

-- DROP INDEX IF EXISTS idx_country_access_log_country_id_btree;
-- DROP INDEX IF EXISTS idx_country_access_log_country_id_hash;


-- Запросы с (> по TIMESTAMP)

CREATE INDEX idx_country_access_log_time_btree 
ON identity.country_access_log (access_time);
-- DROP INDEX IF EXISTS idx_country_access_log_time_btree;


-- Запросы с (< по строкам)

CREATE INDEX idx_vaccination_cert_issuebywhom_btree 
ON papers.vaccinationCertificate (issueByWhom);
-- DROP INDEX IF EXISTS idx_vaccination_cert_issuebywhom_btree;


-- Запросы с (like%)

CREATE INDEX idx_audit_log_description_btree 
ON papers.audit_log (description);
-- DROP INDEX IF EXISTS idx_audit_log_description_btree;


-- Запросы с (IN)

-- CREATE INDEX idx_audit_log_event_date_btree 
-- ON papers.audit_log (DATE(event_time));

CREATE INDEX idx_audit_log_event_date_hash 
ON papers.audit_log USING HASH (DATE(event_time));

-- DROP INDEX IF EXISTS idx_audit_log_event_date_btree;
-- DROP INDEX IF EXISTS idx_audit_log_event_date_hash;