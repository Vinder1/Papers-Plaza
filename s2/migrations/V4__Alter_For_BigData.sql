-- =====================================================
-- 1. ДОБАВЛЕНИЕ ТИПОВ ДАННЫХ (JSONB, ARRAY, RANGE, GEOMETRY)
-- =====================================================

-- Schema: identity
ALTER TABLE identity.passport ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
ALTER TABLE identity.passport ADD COLUMN tags TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE identity.passport ADD COLUMN validity_period TSRANGE;
ALTER TABLE identity.biometry ADD COLUMN fingerprints JSONB; -- Хранение данных отпечатков
ALTER TABLE identity.biometry ADD COLUMN photo_coords BOX;    -- Геометрия (координаты лица)

-- Schema: papers
ALTER TABLE papers.workPermission ADD COLUMN restrictions JSONB;
ALTER TABLE papers.workPermission ADD COLUMN allowed_regions TEXT[];
ALTER TABLE papers.entryPermission ADD COLUMN visit_window TSRANGE;
ALTER TABLE papers.vaccinationCertificate ADD COLUMN batch_codes TEXT[];
ALTER TABLE papers.diplomatCertificate ADD COLUMN privileges JSONB;

-- Schema: Items
ALTER TABLE Items.Luggage ADD COLUMN contents_summary JSONB;
ALTER TABLE Items.LuggageItem ADD COLUMN scan_data BYTEA;      -- Бинарные данные

-- Schema: Criminal
ALTER TABLE Criminal.Case ADD COLUMN evidence_locations POINT[];
ALTER TABLE Criminal.Case ADD COLUMN case_details JSONB;
ALTER TABLE Criminal.Record ADD COLUMN sentence_range INT4RANGE;

-- Schema: People
ALTER TABLE People.Entrant ADD COLUMN risk_profile JSONB;
ALTER TABLE People.Entrant ADD COLUMN travel_history TEXT[];
ALTER TABLE People.Entrant ADD COLUMN last_seen TSRange;

-- =====================================================
-- 2. РАСШИРЕНИЕ ТАБЛИЦ ДО 5-7 ПОЛЕЙ
-- =====================================================

-- identity.country (было 2 поля)
ALTER TABLE identity.country ADD COLUMN code CHAR(3) UNIQUE;
ALTER TABLE identity.country ADD COLUMN population INT;
ALTER TABLE identity.country ADD COLUMN risk_level INT DEFAULT 1;
ALTER TABLE identity.country ADD COLUMN created_at TIMESTAMP DEFAULT NOW();

-- identity.citizenEntryPermission (было 3 поля)
ALTER TABLE identity.citizenEntryPermission ADD COLUMN visa_type VARCHAR(20);
ALTER TABLE identity.citizenEntryPermission ADD COLUMN max_stay_days INT;
ALTER TABLE identity.citizenEntryPermission ADD COLUMN is_active BOOLEAN DEFAULT true;

-- papers.vaccine (было 2 поля)
ALTER TABLE papers.vaccine ADD COLUMN manufacturer VARCHAR(100);
ALTER TABLE papers.vaccine ADD COLUMN doses_required INT DEFAULT 1;
ALTER TABLE papers.vaccine ADD COLUMN storage_temp_min DECIMAL(4,1);
ALTER TABLE papers.vaccine ADD COLUMN storage_temp_max DECIMAL(4,1);

-- papers.activity (было 2 поля)
ALTER TABLE papers.activity ADD COLUMN category VARCHAR(50);
ALTER TABLE papers.activity ADD COLUMN is_allowed BOOLEAN DEFAULT true;
ALTER TABLE papers.activity ADD COLUMN permit_fee DECIMAL(10,2);

-- Items.LuggageItemType (было 2 поля)
ALTER TABLE Items.LuggageItemType ADD COLUMN weight_limit DECIMAL(9,4);
ALTER TABLE Items.LuggageItemType ADD COLUMN is_prohibited BOOLEAN DEFAULT false;
ALTER TABLE Items.LuggageItemType ADD COLUMN category VARCHAR(50);

-- Criminal.CaseType (было 2 поля)
ALTER TABLE Criminal.CaseType ADD COLUMN severity_level INT DEFAULT 1;
ALTER TABLE Criminal.CaseType ADD COLUMN min_sentence_months INT;
ALTER TABLE Criminal.CaseType ADD COLUMN is_bailable BOOLEAN DEFAULT true;

-- =====================================================
-- 3. ДОБАВЛЕНИЕ NULL-ЗНАЧЕНИЙ (5-20% строк)
-- =====================================================

-- Снимаем NOT NULL где нужно (если было)
ALTER TABLE identity.passport ALTER COLUMN biometry DROP NOT NULL;
ALTER TABLE papers.workPermission ALTER COLUMN activityId DROP NOT NULL;
ALTER TABLE People.Entrant ALTER COLUMN workPermissionId DROP NOT NULL;
ALTER TABLE People.Entrant ALTER COLUMN luggageId DROP NOT NULL;
ALTER TABLE papers.audit_log ALTER COLUMN description DROP NOT NULL;

-- =====================================================
-- 4. ПОЛНОТЕКСТОВЫЙ ПОИСК
-- =====================================================

-- Добавляем колонки tsvector
ALTER TABLE identity.passport ADD COLUMN search_vector TSVECTOR;
ALTER TABLE papers.audit_log ADD COLUMN search_vector TSVECTOR;
ALTER TABLE Criminal.Case ADD COLUMN search_vector TSVECTOR;
