-- SELECT *  FROM items.luggageitem;


-- SELECT (fullname) FROM papers.entrypermission;


-- SELECT id, name as vaccine_name FROM papers.vaccine;

-- SELECT id, activitytype, issuedate <= CURRENT_DATE as is_created FROM papers.workpermission;


-- SELECT -id, itemname FROM items.luggageitem;

-- SELECT id, fullname,
-- CASE 
--     WHEN id % 2 = 0
--     THEN 'ЧЕТНОЕ'
--     ELSE 'НЕЧЕТНОЕ'
-- END AS четность
-- FROM papers.entrypermission;


-- SELECT * FROM criminal.record
-- WHERE description = 'Сделал пост в сети';

-- SELECT * fROM papers.diplomatcertificate
-- WHERE validuntil > CURRENT_DATE AND id < 2;

-- SELECT id, fullname
-- FROM papers.entrypermission
-- WHERE LENGTH(fullname) BETWEEN 10 AND 13;

-- SELECT id, fullname
-- FROM papers.entrypermission
-- WHERE fullname IN ('Maria Schmidt', 'Michael Johnson');

-- SELECT * FROM papers.workpermission
-- ORDER BY fullname;

-- SELECT * FROM papers.vaccine
-- WHERE name LIKE '_% %_'


-- SELECT DISTINCT countryOfIssue 
-- FROM papers.entrypermission;


-- SELECT * FROM identity.passport
-- LIMIT 2;

-- SELECT id, fullname, crimeId
-- FROM identity.passport p 
-- INNER JOIN criminal.case c 
-- ON p.id = c.crimeId;

-- SELECT i.id, i.fullname, c.name as country_name
-- FROM identity.passport i INNER JOIN
-- identity.country c 
-- ON i.country = c.id;


-- SELECT p.id, p.fullname, e.id
-- FROM identity.passport p
-- LEFT JOIN papers.entrypermission e
-- ON p.fullname = e.fullname; 

-- SELECT p.id as passportId, p.fullname, e.id as entrypermissionId
-- FROM identity.passport p
-- RIGHT JOIN papers.entrypermission e
-- ON p.fullname = e.fullname; 


-- SELECT DISTINCT  pass.fullname AS fullname, rec.description AS description
-- FROM identity.passport pass, criminal.record rec
-- LIMIT 15;


-- SELECT p.fullname as name, r.description as description
-- FROM identity.passport p 
-- INNER JOIN criminal.case c ON p.id = c.passportId
-- INNER JOIN criminal.record r ON c.crimeId = r.id;



SELECT 