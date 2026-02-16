-- DROP SCHEMA IF EXISTS criminal CASCADE ;
-- DROP SCHEMA IF EXISTS identity CASCADE ;
-- DROP SCHEMA IF EXISTS library CASCADE ;
-- DROP SCHEMA IF EXISTS public CASCADE ;
-- DROP SCHEMA IF EXISTS papers CASCADE ;
-- DROP SCHEMA IF EXISTS items CASCADE ;
-- DROP SCHEMA IF EXISTS people CASCADE ;

CREATE SCHEMA identity;

CREATE TABLE identity.country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

CREATE TABLE identity.citizenEntryPermission (
    fromId INT NOT NULL REFERENCES identity.country (id),
    toId INT NOT NULL REFERENCES identity.country (id),
    CHECK (fromId <> toId),
    PRIMARY KEY (fromId, toId)
);

CREATE TABLE identity.biometry (id SERIAL PRIMARY KEY);

CREATE TABLE identity.passport (
    id SERIAL PRIMARY KEY,
    fullName VARCHAR(100) NOT NULL,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    biometry INT REFERENCES identity.biometry (id),
    country INT NOT NULL REFERENCES identity.country (id),
    CHECK (issueDate < validUntil)
);

CREATE SCHEMA papers;

CREATE TABLE papers.vaccine (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE papers.activity (
    id SERIAL PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);

CREATE TABLE papers.workPermission (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    fullName VARCHAR(100) NOT NULL,
    countryOfIssue INT NOT NULL REFERENCES identity.country (id),
    activityId INT NOT NULL REFERENCES papers.activity (id),
    CHECK (issueDate < validUntil)
);

CREATE TABLE papers.entryPermission (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    countryOfIssue INT NOT NULL REFERENCES identity.country (id),
    fullName VARCHAR(100) NOT NULL,
    CHECK (issueDate < validUntil)
);

CREATE TABLE papers.vaccinationCertificate (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    issueByWhom VARCHAR(100) NOT NULL,
    CHECK (issueDate < validUntil)
);

CREATE TABLE papers.diplomatCertificate (
    id SERIAL PRIMARY KEY,
    issueDate DATE NOT NULL,
    validUntil DATE NOT NULL,
    fullName VARCHAR(100) NOT NULL,
    countryOfIssue INT NOT NULL REFERENCES identity.country (id),
    CHECK (issueDate < validUntil)
);

CREATE TABLE papers.diseaseVaccine (
    vaccineId INT REFERENCES papers.vaccine (id),
    vaccinationCertificateId INT REFERENCES papers.vaccinationCertificate (id),
    PRIMARY KEY (
        vaccineId,
        vaccinationCertificateId
    )
);

CREATE SCHEMA Items;

CREATE TABLE Items.Luggage (id SERIAL PRIMARY KEY);

CREATE TABLE Items.LuggageItemType (
    id SERIAL PRIMARY KEY,
    itemName TEXT NOT NULL
);

CREATE TABLE Items.LuggageItem (
    id SERIAL PRIMARY KEY,
    itemType_Id INTEGER NOT NULL REFERENCES Items.LuggageItemType (id),
    luggage_id INTEGER NOT NULL REFERENCES Items.Luggage (id)
);

CREATE SCHEMA Criminal;

CREATE TABLE Criminal.CaseType (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL
);

CREATE TABLE Criminal.Case (
    id SERIAL PRIMARY KEY,
    caseType_id INTEGER NOT NULL REFERENCES Criminal.CaseType (id)
);

CREATE TABLE Criminal.Record (
    crimeId INT NOT NULL REFERENCES Criminal.Case (id),
    biometryId INT NOT NULL REFERENCES identity.biometry (id),
    PRIMARY KEY (crimeId, biometryId)
);

CREATE SCHEMA People;

CREATE TABLE People.Entrant (
    passportId INT REFERENCES identity.passport (id) NOT NULL,
    workPermissionId INT REFERENCES papers.workPermission (id),
    entryPermissionId INT REFERENCES papers.entryPermission (id),
    luggageId INT REFERENCES Items.Luggage (id),
    vaccinationCertificateId INT REFERENCES papers.vaccinationCertificate (id),
    diplomatCertificateId INT REFERENCES papers.diplomatCertificate (id),
    PRIMARY KEY (passportId)
);

-- ALTER TABLE identity.country ADD COLUMN name VARCHAR(20) NOT NULL;

ALTER TABLE Items.LuggageItem
ADD COLUMN weight DECIMAL(9, 4) DEFAULT 0.0;

ALTER TABLE Items.LuggageItem DROP COLUMN weight;

ALTER TABLE Items.LuggageItemType
ALTER COLUMN itemName TYPE VARCHAR(255);

ALTER TABLE Items.LuggageItemType
ADD CONSTRAINT length_check CHECK (length(itemname) > 0);

CREATE TABLE papers.audit_log (
    id SERIAL PRIMARY KEY,
    event_time TIMESTAMP NOT NULL DEFAULT now(),
    description TEXT NOT NULL
);