-- GIN

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.audit_log 
WHERE search_vector @@ to_tsquery('english', '1000');

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.audit_log 
WHERE search_vector @@ to_tsquery('english', 'User & 123456');

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.audit_log 
WHERE search_vector @@ to_tsquery('russian', '123456 | 587246');

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM papers.audit_log 
WHERE search_vector @@ to_tsquery('russian', '1000 & !672150');

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT 
    *,
    ts_rank(search_vector, to_tsquery('russian', 'User & 500 | Action')) as rank
FROM papers.audit_log 
WHERE search_vector @@ to_tsquery('russian', 'User & 500 | Action')
ORDER BY rank DESC
LIMIT 100;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.passport 
WHERE metadata @> '{"notes": "VIP"}';

-- GiST

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.biometry 
WHERE photo_coords && BOX(POINT(300, 300), POINT(200, 200));

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.biometry 
WHERE photo_coords <@ BOX(POINT(800, 800), POINT(0, 0));

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.passport 
WHERE validity_period && tsrange(
    '2026-12-31'::timestamp,
    '2027-01-01'::timestamp
);

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.passport 
WHERE validity_period @> (NOW() - ('300 days')::INTERVAL)::timestamp;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM identity.passport 
WHERE validity_period << tsrange(NOW()::timestamp, 'infinity'::timestamp);