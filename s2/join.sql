-- Nested loop

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT p.fullName, p.issueDate, wp.issueDate as work_issue
FROM identity.passport p
JOIN papers.workPermission wp ON (p.id % 1000) = wp.id
WHERE p.fullName LIKE 'Person_2%'
LIMIT 100;

-- Hash join

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT p.fullName, p.issueDate, c.name as country_name
FROM identity.passport p
JOIN identity.country c ON p.country = c.id
WHERE c.id IN (1, 2, 3);

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT p.fullName, cal.country_id, cal.access_time
FROM identity.passport p
JOIN identity.country_access_log cal ON p.country = cal.country_id
WHERE cal.access_time > NOW() - INTERVAL '30 days';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT e.passportId, wp.fullName, wp.validUntil
FROM People.Entrant e
JOIN papers.workPermission wp ON e.workPermissionId = wp.id
WHERE e.passportId < 1000;

-- Merge join
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT p.fullName, vc.issueDate, vc.validUntil
FROM identity.passport p
JOIN papers.vaccinationCertificate vc ON p.id = vc.id
ORDER BY p.id, vc.id;