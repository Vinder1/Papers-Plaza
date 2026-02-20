-- Очистка таблиц в случае если в скриптах навалено кринжа

BEGIN;

TRUNCATE TABLE 
    identity.country_access_log,
    identity.passport,
    identity.citizenEntryPermission,
    identity.biometry
RESTART IDENTITY CASCADE;

TRUNCATE TABLE 
    papers.audit_log,
    papers.diseaseVaccine,
    papers.vaccinationCertificate,
    papers.diplomatCertificate,
    papers.entryPermission,
    papers.workPermission,
    papers.vaccine,
    papers.activity
RESTART IDENTITY CASCADE;

TRUNCATE TABLE 
    Criminal.Record,
    Criminal.Case
    -- ,Criminal.CaseType
RESTART IDENTITY CASCADE;

TRUNCATE TABLE 
    Items.LuggageItem,
    Items.Luggage,
    Items.LuggageItemType
RESTART IDENTITY CASCADE;

TRUNCATE TABLE 
    People.Entrant
RESTART IDENTITY CASCADE;

COMMIT;