-- 1. Низкая селективность (3-5 уникальных значений)
CREATE TABLE IF NOT EXISTS identity.country_access_log (
    id SERIAL PRIMARY KEY,
    country_id INT NOT NULL REFERENCES identity.country (id),
    access_time TIMESTAMP DEFAULT NOW()
);

INSERT INTO
    identity.country_access_log (country_id, access_time)
SELECT
    CASE
        WHEN RANDOM() < 0.7 THEN (RANDOM() * 0.5 + 1)::INT
        ELSE (RANDOM() * 4 + 1)::INT
    END,
    -- Всего 5 уникальных значений (1-5)
    -- 70% на 1-2 страны
    -- 30% на остальные
    NOW() - (
        RANDOM() * INTERVAL '365 days'
    )
FROM generate_series(1, 300000);

-- Проверка
SELECT
    'Low Selectivity' AS test_type,
    COUNT(DISTINCT country_id) AS unique_values,
    COUNT(*) AS total_rows
FROM identity.country_access_log;

SELECT country_id, COUNT(*)
FROM identity.country_access_log
GROUP BY
    country_id;

-- 2. Равномерное распределение (Uniform)
INSERT INTO
    papers.vaccine (name)
SELECT 'Vaccine_' || i
FROM generate_series(1, 50) AS i;

INSERT INTO
    papers.vaccinationCertificate (
        issueDate,
        validUntil,
        issueByWhom
    )
SELECT NOW() - (
        RANDOM() * INTERVAL '730 days'
    ), NOW() + (
        RANDOM() * INTERVAL '365 days'
    ), 'Doctor_' || (RANDOM() * 1000)::INT
FROM generate_series(1, 3000);

INSERT INTO
    papers.diseaseVaccine (
        vaccineId,
        vaccinationCertificateId
    )
SELECT (RANDOM() * 49 + 1)::INT, id
FROM papers.vaccinationCertificate
LIMIT 3000;

-- Проверка
SELECT 'Uniform Distribution' AS test_type, vaccineId, COUNT(*) AS count
FROM papers.diseaseVaccine
GROUP BY
    vaccineId
ORDER BY count DESC
LIMIT 10;

-- 3. Сильно неравномерное распределение (Zipf / Skewed)
INSERT INTO identity.biometry SELECT FROM generate_series(1, 3000);

INSERT INTO
    Criminal.Case (caseType_id)
SELECT (RANDOM() * 4 + 1)::INT
FROM generate_series(1, 5000);

DO $$
DECLARE
    i INT := 0;
    v_crime_id INT;
    v_biometry_id INT;
    v_attempts INT := 0;
    max_attempts INT := 100;
    v_sentence_min  INT;
    v_sentence_max  INT;
    crime_ids INT[];
BEGIN
    -- TRUNCATE TABLE Criminal.Record;
    SELECT ARRAY_AGG(id) INTO crime_ids FROM Criminal.Case;
    
    WHILE i < 1000 LOOP
        v_attempts := 0;
        
        LOOP
            BEGIN
                v_crime_id := crime_ids[1 + floor(random() * array_length(crime_ids, 1))];
                v_biometry_id := (10000 ^ (1 - RANDOM()))::INT;

                v_sentence_min := (RANDOM() * 12)::INT;
                v_sentence_max := v_sentence_min + (RANDOM() * 120)::INT;
                
                INSERT INTO Criminal.Record (crimeId, biometryId)
                VALUES (
                    v_crime_id,
                    v_biometry_id);

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
SELECT 'Skewed Distribution' AS test_type, biometryId, COUNT(*) AS count
FROM Criminal.Record
GROUP BY
    biometryId
ORDER BY count DESC
LIMIT 10;

-- 4. Высокая селективность (~90-100% уникальных)
INSERT INTO
    papers.audit_log (event_time, description)
SELECT NOW() - (i || ' seconds')::INTERVAL, 'Event_' || i || '_User_' || (RANDOM() * 1000000)::INT || '_Action_' || md5(i::TEXT)
FROM generate_series(1, 3000) AS i;

-- Проверка
SELECT
    'High Selectivity' AS test_type,
    COUNT(DISTINCT description) AS unique_values,
    COUNT(*) AS total_rows
FROM papers.audit_log;

-- 5. Высокая кардинальность + NULL (10% NULL)
INSERT INTO
    identity.passport (
        fullName,
        issueDate,
        validUntil,
        biometry,
        country
    )
SELECT 'Person_' || i || '_' || md5(random()::TEXT), NOW() - (
        RANDOM() * INTERVAL '3650 days'
    ), NOW() + (
        RANDOM() * INTERVAL '1825 days'
    ),
    -- CASE
    --     WHEN RANDOM() < 0.1 THEN NULL
    --     ELSE (RANDOM() * 10000 + 1)::INT
    -- END, -- 10% NULL
    1, (RANDOM() * 4 + 1)::INT
    -- JSONB с разной структурой
    -- Массив тегов
FROM generate_series(1, 3000) AS i;

-- 6. JSONB + Массивы + NULL (15% NULL)
DO $$
DECLARE
    activity_ids INT[];
    v_activity_id INT;
BEGIN
    -- Получаем все существующие ID видов деятельности
    SELECT ARRAY_AGG(id) INTO activity_ids FROM papers.activity;
    INSERT INTO
        papers.workPermission (
            issueDate,
            validUntil,
            fullName,
            countryOfIssue,
            activityId
        )
    SELECT
        NOW() - (
            RANDOM() * INTERVAL '730 days'
        ),
        NOW() + (
            RANDOM() * INTERVAL '365 days'
        ),
        'Worker_' || i,
        (RANDOM() * 4 + 1)::INT,

        activity_ids[1 + floor(random() * array_length(activity_ids, 1))]
 
    FROM generate_series(1, 3000) AS i;
END $$;

-- 7. Низкая кардинальность (статусы) + NULL (10% NULL)
DO $$
DECLARE
    work_permission_ids INT[];
    entry_permission_ids INT[];
    luggage_ids INT[];
    dc_ids INT[];
BEGIN
    -- Получаем все существующие ID разрешений на работу
    SELECT ARRAY_AGG(id) INTO work_permission_ids FROM papers.workPermission;
    SELECT ARRAY_AGG(id) INTO entry_permission_ids FROM papers.entryPermission;
    SELECT ARRAY_AGG(id) INTO luggage_ids FROM items.luggage;
    SELECT ARRAY_AGG(id) INTO dc_ids FROM papers.diplomatCertificate;
    
    INSERT INTO
        People.Entrant (
            passportId,
            workPermissionId,
            entryPermissionId,
            luggageId,
            vaccinationCertificateId,
            diplomatCertificateId
        )
    SELECT 
        i,     
        work_permission_ids[1 + floor(random() * array_length(work_permission_ids, 1))],
        entry_permission_ids[1 + floor(random() * array_length(entry_permission_ids, 1))],
        luggage_ids[1 + floor(random() * array_length(luggage_ids, 1))],
        (RANDOM() * 1000 + 1)::INT,

        dc_ids[1 + floor(random() * array_length(dc_ids, 1))]
    FROM generate_series(1, 3000) AS i;
END $$;

INSERT INTO
    papers.workPermission (
        issueDate,
        validUntil,
        fullName,
        countryOfIssue,
        activityId
    )
SELECT
    NOW()::DATE - (RANDOM() * 730)::INT,
    NOW()::DATE + (RANDOM() * 365)::INT,
    'Person_' || i || '_' || md5(i::TEXT),
    (RANDOM() * 4 + 1)::INT,
    (RANDOM() * 2 + 1)::INT
FROM generate_series(1, 1000) AS i;