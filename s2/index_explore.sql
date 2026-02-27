-- все скрины в папке index_search_screenshots

-- БЕЗ ИНДЕКСА
-- С BTREE ИНДЕКСОМ
-- С HASH ИНДЕКСОМ
-- скрины: equality_*
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.country_access_log 
WHERE country_id = 3;

-- БЕЗ ИНДЕКСА
-- С BTREE ИНДЕКСОМ
-- скрины: more_*
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.country_access_log 
WHERE access_time > NOW() - INTERVAL '30 days';

-- БЕЗ ИНДЕКСА
-- С BTREE ИНДЕКСОМ
-- скрины: less_*
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.vaccinationCertificate
WHERE issueByWhom < 'Doctor_900';

-- скрины: less2_*
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.vaccinationCertificate
WHERE issueByWhom < 'Doctor_2';

-- БЕЗ ИНДЕКСА
-- С BTREE ИНДЕКСОМ
-- скрины: like_*
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.audit_log 
WHERE description LIKE 'Event_12%';

-- БЕЗ ИНДЕКСА
-- С BTREE ИНДЕКСОМ
-- С HASH ИНДЕКСОМ
-- скрины: in_*
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.audit_log 
WHERE DATE(event_time) IN ('2026-02-20', '2026-02-21', '2026-02-22');