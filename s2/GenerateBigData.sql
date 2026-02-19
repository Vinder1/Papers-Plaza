-- 1. Низкая селективность (3-5 уникальных значений)
CREATE TABLE IF NOT EXISTS identity.country_access_log (
    id SERIAL PRIMARY KEY,
    country_id INT NOT NULL REFERENCES identity.country(id),
    access_time TIMESTAMP DEFAULT NOW()
);

INSERT INTO identity.country_access_log (country_id, access_time)
SELECT 
    (RANDOM() * 4 + 1)::INT,  -- Всего 5 уникальных значений (1-5)
    NOW() - (RANDOM() * INTERVAL '365 days')
FROM generate_series(1, 300000);

-- Проверка
SELECT 
    'Low Selectivity' AS test_type,
    COUNT(DISTINCT country_id) AS unique_values,
    COUNT(*) AS total_rows
FROM identity.country_access_log;

SELECT
    country_id,
    COUNT(*)
FROM identity.country_access_log
GROUP BY country_id;

-- 2. Равномерное распределение (Uniform)
INSERT INTO papers.vaccine (name)
SELECT 'Vaccine_' || i
FROM generate_series(1, 50) AS i;

INSERT INTO papers.vaccinationCertificate (issueDate, validUntil, issueByWhom)
SELECT 
    NOW() - (RANDOM() * INTERVAL '730 days'),
    NOW() + (RANDOM() * INTERVAL '365 days'),
    'Doctor_' || (RANDOM() * 1000)::INT
FROM generate_series(1, 300000);

INSERT INTO papers.diseaseVaccine (vaccineId, vaccinationCertificateId)
SELECT 
    (RANDOM() * 49 + 1)::INT,
    id
FROM papers.vaccinationCertificate
LIMIT 300000;

-- Проверка
SELECT 
    'Uniform Distribution' AS test_type,
    vaccineId,
    COUNT(*) AS count
FROM papers.diseaseVaccine
GROUP BY vaccineId
ORDER BY count DESC
LIMIT 10;

-- 3. Сильно неравномерное распределение (Zipf / Skewed)
DO $$
DECLARE
    i INT;
BEGIN

    FOR i IN 1..10000 LOOP
        INSERT INTO identity.biometry DEFAULT VALUES;
    END LOOP;

    PERFORM setval('identity.biometry_id_seq', (SELECT MAX(id) FROM identity.biometry));
END $$;

INSERT INTO Criminal.Case (caseType_id)
SELECT (RANDOM() * 4 + 1)::INT
FROM generate_series(1, 5000);

DO $$
DECLARE
    i INT := 0;
    v_crime_id INT;
    v_biometry_id INT;
    v_attempts INT := 0;
    max_attempts INT := 100;
BEGIN
    TRUNCATE TABLE Criminal.Record;
    
    WHILE i < 300000 LOOP
        v_attempts := 0;
        
        LOOP
            BEGIN
                v_crime_id := (RANDOM() * 4999 + 1)::INT;
                v_biometry_id := (10000 ^ (1 - RANDOM()))::INT;
                
                INSERT INTO Criminal.Record (crimeId, biometryId)
                VALUES (v_crime_id, v_biometry_id);

                EXIT;
                
            EXCEPTION 
                WHEN unique_violation THEN
                    v_attempts := v_attempts + 1;
                    
                    IF v_attempts >= max_attempts THEN
                        RAISE NOTICE 'Лимит попыток на строке %. Пропускаем.', i + 1;
                        EXIT;
                    END IF;
            END;
        END LOOP;
        
        i := i + 1;
    END LOOP;
    
    RAISE NOTICE 'Вставлено % уникальных записей.', i;
END $$;

-- Проверка
SELECT 
    'Skewed Distribution' AS test_type,
    biometryId,
    COUNT(*) AS count
FROM Criminal.Record
GROUP BY biometryId
ORDER BY count DESC
LIMIT 10;

-- 4. Высокая селективность (~90-100% уникальных)
INSERT INTO papers.audit_log (event_time, description)
SELECT 
    NOW() - (i || ' seconds')::INTERVAL,
    'Event_' || i || '_User_' || (RANDOM() * 1000000)::INT || '_Action_' || md5(i::TEXT)
FROM generate_series(1, 300000) AS i;

-- Проверка
SELECT 
    'High Selectivity' AS test_type,
    COUNT(DISTINCT description) AS unique_values,
    COUNT(*) AS total_rows
FROM papers.audit_log;