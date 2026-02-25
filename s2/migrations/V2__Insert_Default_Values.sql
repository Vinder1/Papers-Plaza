-- Так делать нельзя, но да ладно

INSERT INTO identity.country (name)
VALUES ('Россия'),
    ('США'),
    ('КНДР'),
    ('Китай'),
    ('Казахстан'),
    ('Германия'),
    ('Афганистан'),
    ('Мексика'),
    ('Нигер');

INSERT INTO identity.citizenEntryPermission (fromId, toId)
VALUES (1, 4),
    (1, 5),
    (2, 1),
    (2, 4),
    (2, 5),
    (2, 6),
    (2, 8),
    (3, 1),
    (4, 1),
    (4, 2),
    (4, 5),
    (4, 6),
    (5, 1),
    (5, 2),
    (5, 4),
    (6, 1),
    (6, 2),
    (8, 2);
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.biometry DEFAULT
VALUES;
INSERT INTO identity.passport (
        fullName,
        issueDate,
        validUntil,
        biometry,
        country
    )
VALUES (
        'Иван Иваныч',
        '2025-01-01',
        '2026-01-01',
        1,
        1
    ),
    (
        'Джеки Чан',
        '2020-01-01',
        '2030-01-01',
        2,
        4
    ),
    (
        'Гаррье Дюбуа',
        '2020-01-01',
        '2021-01-01',
        3,
        1
    ),
    (
        'Виктор Корнеплод',
        '2000-11-11',
        '2222-11-11',
        4,
        7
    ),
    (
        'Хайзенбургер',
        '2010-03-04',
        '2020-01-02',
        5,
        2
    ),
    (
        'Штирлиц',
        '1941-06-22',
        '1945-05-09',
        6,
        6
    ),
    (
        'Нилл Киггерс',
        '2024-02-22',
        '2028-07-08',
        7,
        9
    ),
    (
        'Нэйт Хиггерс',
        '2023-02-22',
        '2028-01-08',
        8,
        9
    ),
    (
        'Давид Маркович',
        '2023-02-02',
        '2034-01-01',
        9,
        1
    ),
    (
        'Стив Луис',
        '2010-03-04',
        '2020-01-02',
        10,
        2
    );
INSERT INTO papers.vaccine (name)
VALUES ('БЦЖ'),
    ('вакцина Солка'),
    ('вакцина против гепатита В'),
    ('вакцина против тифа'),
    ('пневмококовая вакцина');
INSERT INTO papers.activity (description)
VALUES ('IT Specialist'),
    ('Engineer'),
    ('Doctor');
INSERT INTO papers.workPermission (
        issueDate,
        validUntil,
        fullName,
        countryOfIssue,
        activityid
    )
VALUES (
        '2025-01-01',
        '2026-01-01',
        'Ivan Ivanov',
        3,
        1
    ),
    (
        '2024-05-15',
        '2025-05-15',
        'John Smith',
        1,
        2
    ),
    (
        '2025-03-10',
        '2026-03-10',
        'Pierre Dubois',
        2,
        3
    );
INSERT INTO papers.entryPermission (
        issueDate,
        validUntil,
        countryOfIssue,
        fullName
    )
VALUES (
        '2025-02-01',
        '2025-08-01',
        1,
        'Maria Schmidt'
    ),
    (
        '2024-11-20',
        '2025-05-20',
        3,
        'Akira Tanaka'
    ),
    (
        '2025-04-01',
        '2025-10-01',
        4,
        'Michael Johnson'
    ),
    (
        '2020-01-01',
        '2030-01-01',
        4,
        'Джеки Чан'
    ),
    (
        '2020-01-01',
        '2021-01-01',
        1,
        'Гаррье Дюбуа'
    );
INSERT INTO papers.vaccinationCertificate (
        issueDate,
        validUntil,
        issueByWhom
    )
VALUES (
        '2024-01-01',
        '2030-01-01',
        'WHO Clinic Berlin'
    ),
    (
        '2025-05-10',
        '2031-05-10',
        'Ministry of Health France'
    ),
    (
        '2023-12-15',
        '2029-12-15',
        'Moscow Health Department'
    );
INSERT INTO papers.diplomatCertificate (
        issueDate,
        validUntil,
        fullName,
        countryOfIssue
    )
VALUES (
        '2025-01-01',
        '2027-01-01',
        'Sergey Petrov',
        3
    ),
    (
        '2024-06-01',
        '2026-06-01',
        'Alice Brown',
        4
    ),
    (
        '2025-02-20',
        '2028-02-20',
        'Hiroshi Yamamoto',
        1
    ),
    (
        '2022-05-01',
        '2026-05-01',
        'Гаррье Дюбуа',
        1
    ),
    (
        '2020-01-01',
        '2030-01-01',
        'Джеки Чан',
        4
    ),
    (
        '2020-01-01',
        '2021-01-01',
        'Гаррье Дюбуа',
        1
    );
INSERT INTO papers.diseaseVaccine (
        vaccineId,
        vaccinationCertificateId
    )
VALUES (1, 1),
    -- БЦЖ в сертификате 1 
    (2, 2),
    -- вакцина Солка в сертификате 2 
    (3, 3),
    -- вакцина против гепатита В в сертификате 3 
    (1, 2),
    -- БЦЖ тоже в сертификате 2 
    (4, 3);
-- вакцина против тифа в сертификате 3
INSERT INTO Criminal.CaseType (description)
VALUES ('Украл сладкий рулет'),
    ('Убил человека'),
    ('Побег из тюрьмы'),
    ('Сделал пост в сети'),
    ('Оказался не в том месте'),
    ('Продавал марихуану'),
    ('.крутой'),
    ('Взломал пентагон'),
    ('Неуплата налогов'),
    ('Крупная взятка');
INSERT INTO Criminal.Case (casetype_id)
VALUES (1), (2), (3), (4), (4), (3), (3), (5), (4), (6);

INSERT INTO Items.Luggage DEFAULT
VALUES;
INSERT INTO Items.Luggage DEFAULT
VALUES;
INSERT INTO Items.Luggage DEFAULT
VALUES;
INSERT INTO Items.Luggage DEFAULT
VALUES;
INSERT INTO Items.LuggageItemType (itemName)
VALUES ('Пистолет'),
    ('Абобус'),
    ('Laptop');
INSERT INTO Items.LuggageItem (itemtype_id, luggage_id)
VALUES (1, 1),
    (2, 1),
    (3, 2);
INSERT INTO Criminal.Record (crimeId, biometryId)
VALUES (1, 1),
    (1, 2),
    (3, 2),
    (4, 3);
UPDATE Items.LuggageItemType
SET itemName = 'Пистолет ПМ'
WHERE id = 1;
UPDATE Criminal.CaseType
SET description = 'Кража драгоценностей из музея'
WHERE id = 1;
UPDATE Items.LuggageItemType
SET itemName = 'Лабубу'
WHERE id = 2;