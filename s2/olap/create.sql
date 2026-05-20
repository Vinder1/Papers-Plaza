-- 1. Создание схемы
CREATE SCHEMA IF NOT EXISTS olap;

-- 2. Измерения (DDL)
CREATE TABLE olap.dim_date (
    date_id DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    quarter INT,
    day_of_week VARCHAR(20)
);

CREATE TABLE olap.dim_country (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(20)
);

CREATE TABLE olap.dim_activity (
    activity_id INT PRIMARY KEY,
    activity_description VARCHAR(100)
);

-- Добавим строку "Не указана" для обработки NULL в activity
INSERT INTO olap.dim_activity VALUES (0, 'Не указана');

-- 3. Заполнение измерений из OLTP
-- Date Dimension (генерация на 5 лет вперед/назад)
INSERT INTO olap.dim_date
SELECT 
    d,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    EXTRACT(DAY FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    TO_CHAR(d, 'FMDay')
FROM generate_series('2020-01-01'::date, '2026-12-31'::date, '1 day'::interval) AS d;

-- Country Dimension
INSERT INTO olap.dim_country (country_id, country_name)
SELECT id, name FROM identity.country
ON CONFLICT (country_id) DO NOTHING;

-- Activity Dimension
INSERT INTO olap.dim_activity (activity_id, activity_description)
SELECT id, description FROM papers.activity
ON CONFLICT (activity_id) DO NOTHING;

-- 4. Факт-таблица (DDL)
CREATE TABLE olap.fact_entries (
    fact_id BIGSERIAL PRIMARY KEY,
    entry_date DATE,
    date_id DATE REFERENCES olap.dim_date(date_id),
    country_id INT REFERENCES olap.dim_country(country_id),
    activity_id INT DEFAULT 0 REFERENCES olap.dim_activity(activity_id),
    has_work_permission BOOLEAN DEFAULT FALSE,
    has_entry_permission BOOLEAN DEFAULT FALSE,
    has_vaccination_cert BOOLEAN DEFAULT FALSE,
    has_diplomat_cert BOOLEAN DEFAULT FALSE,
    luggage_items_count INT DEFAULT 0,
    has_criminal_record BOOLEAN DEFAULT FALSE
);

-- 5. ETL: Заполнение факта из OLTP
-- Примечание: т.к. в People.Entrant нет явной даты въезда, используем дату выдачи самого раннего документа или паспорта.
INSERT INTO olap.fact_entries (entry_date, date_id, country_id, activity_id, 
                               has_work_permission, has_entry_permission, has_vaccination_cert, 
                               has_diplomat_cert, luggage_items_count, has_criminal_record)
SELECT 
    COALESCE(wp.issueDate, ep.issueDate, dc.issueDate, vc.issueDate, p.issueDate) AS entry_date,
    COALESCE(wp.issueDate, ep.issueDate, dc.issueDate, vc.issueDate, p.issueDate) AS date_id,
    p.country AS country_id,
    COALESCE(wp.activityId, 0) AS activity_id,
    (wp.id IS NOT NULL)::BOOLEAN,
    (ep.id IS NOT NULL)::BOOLEAN,
    (vc.id IS NOT NULL)::BOOLEAN,
    (dc.id IS NOT NULL)::BOOLEAN,
    COALESCE(l.luggage_cnt, 0) AS luggage_items_count,
    (cr.biometryId IS NOT NULL)::BOOLEAN AS has_criminal_record
FROM People.Entrant e
JOIN identity.passport p ON e.passportId = p.id
LEFT JOIN identity.biometry b ON p.biometry = b.id
LEFT JOIN papers.workPermission wp ON e.workPermissionId = wp.id
LEFT JOIN papers.entryPermission ep ON e.entryPermissionId = ep.id
LEFT JOIN papers.vaccinationCertificate vc ON e.vaccinationCertificateId = vc.id
LEFT JOIN papers.diplomatCertificate dc ON e.diplomatCertificateId = dc.id
LEFT JOIN (
    SELECT luggage_id, COUNT(*) AS luggage_cnt
    FROM Items.LuggageItem
    GROUP BY luggage_id
) l ON e.luggageId = l.luggage_id
LEFT JOIN Criminal.Record cr ON b.id = cr.biometryId
WHERE COALESCE(wp.issueDate, ep.issueDate, dc.issueDate, vc.issueDate, p.issueDate) IS NOT NULL;