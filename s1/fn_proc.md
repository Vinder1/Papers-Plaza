## Процедуры

1. Процедуры

1.1 Создать всех пользователей вместе с необходимыми документами

```sql
CREATE OR REPLACE PROCEDURE create_default_user(fullName VARCHAR(100), country INT)
LANGUAGE plpgsql
AS $$
DECLARE
    new_biometry_id INT;
BEGIN
    INSERT INTO identity.biometry DEFAULT VALUES
    RETURNING id INTO new_biometry_id;

    INSERT INTO identity.passport (
        fullName,
        issueDate,
        validUntil,
        biometry,
        country
    ) VALUES (
        fullName,
        '2023-01-15',
        '2033-01-15',
        new_biometry_id,
        country);
    END;
$$;

CALL create_default_user('Евгений Газово', 1);
```

1.2. Создание фукции для добавления титулов (префиксов) к именам в пасспортах

```sql
CREATE OR REPLACE PROCEDURE information_schema.add_prefix_into_person_passport(
    prefix VARCHAR(10), 
    in_fullname VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    person_fullname VARCHAR(100);
BEGIN
    UPDATE identity.passport
    SET fullname = prefix || in_fullname
    WHERE fullName = in_fullname;
END;
$$;

CALL information_schema.add_prefix_into_person_passport('mr.', 'Штирлиц');
```

1.3 Изменение названия предмета с помощью фукнции
```sql
create or replace procedure updateLuggageItemTypeName(
    oldItemName varchar(50),
    newName varChar(50)
)
language plpgsql
as $$
begin
update items.luggageitemtype
    set itemname = newName
    where itemname = oldItemName;
end;
$$;

select * from items.luggageitemtype;
call updateLuggageItemTypeName('Laptop', 'Ноутбук');
select * from items.luggageitemtype;
```
<img width="323" height="187" alt="image" src="https://github.com/user-attachments/assets/4ebc6b89-24b9-46fc-88c0-f4048f2ba642" />
<img width="321" height="185" alt="image" src="https://github.com/user-attachments/assets/4b4ae142-b209-4536-b5a1-846777a7ac0c" />


2. Запрос просмотра всех процедур

```sql
SELECT *
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE';
```

## Функции

3. Функции (без переменных)

3.1 Возвращает true, если входная строка состоит из  2 слов

```sql
CREATE OR REPLACE FUNCTION has_2_words(str VARCHAR(100))
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN str like '_% _%';
END;
$$;

select itemName
from items.luggageitemtype
where has_2_words(itemname);
```

3.2. Функция по получению всех вакцин из сертефиката

```sql
CREATE OR REPLACE FUNCTION information_schema.get_vaccine_from_certificate(
    certeficateId INT
)
RETURNS TABLE (
    vaccinationCertificateId INT,
    vaccineName VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT vc.id AS vaccinationCertificateId, v.name AS vaccineName
    FROM papers.vaccinationCertificate vc
    JOIN papers.diseaseVaccine dv
    ON vc.id = dv.vaccinationCertificateId
    JOIN papers.vaccine v
    ON dv.vaccineId = v.id
    WHERE vc.id = certeficateId;
END;
$$;

SELECT information_schema.get_vaccine_from_certificate(2);
```
3.3 Получить максимальный Id из LuggageItemType
```sql
create or replace function getMaxItemTypeId()
returns int
language plpgsql
as $$
    begin
    return (select max(id) from items.luggageItemType);  
    end;
$$

select getMaxItemTypeId();
```
<img width="223" height="52" alt="image" src="https://github.com/user-attachments/assets/9273da90-d981-4732-bea8-d6f95387f445" />


4. Функции (с переменными)

4.1 Получить самый новый паспорт

```sql
CREATE OR REPLACE FUNCTION get_last_passport()
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    max_date DATE;
    result RECORD;
BEGIN
    SELECT MAX(issueDate)
    FROM identity.passport
    INTO max_date;

    SELECT * FROM identity.passport
    WHERE issueDate = max_date
    INTO result;

    RETURN result;
END;
$$;

select get_last_passport()
```

4.2. Функция по получению профессии человека

```sql
CREATE OR REPLACE FUNCTION information_schema.get_person_work(
    in_fullname VARCHAR(100)
)
RETURNS VARCHAR(100)
LANGUAGE plpgsql
AS $$
DECLARE
    activity VARCHAR(100);
BEGIN
    SELECT a.description INTO activity
    FROM papers.workPermission w
    JOIN papers.activity a
    ON w.activityId = a.id
    WHERE w.fullname = in_fullname; 

    RETURN activity;
END;
$$;

SELECT fullname, information_schema.get_person_work(fullname)
FROM papers.workpermission;
```

4.3 Получить максимальную длину предмету через функцию
```sql
create or replace function getMaxItemTypeName()
    returns varchar(200)
    language plpgsql
as $$
declare 
    maxName varchar(200);
begin
    select max(itemname) into maxName from items.luggageItemType;
    return maxName;
end;
$$;

select getMaxItemTypeName();
```
<img width="242" height="56" alt="image" src="https://github.com/user-attachments/assets/c1feef31-98a7-4a22-9696-efb252d9be0e" />


5. Запрос просмотра всех функций

```sql
SELECT *
FROM information_schema.routines
WHERE routine_type = 'FUNCTION';
```

## DO

6. Do

6.1. Анонимная функция для проверки того, что у въезжающий людей есть зарегестрированные документы (предполагалось, что в системе с подтвержденными разрешениями на въезд не может быть незарегестрированных пасспортов, но для проверки был написана функция)

```sql
DO $$
DECLARE
    invalid_person INTEGER;
BEGIN
    SELECT COUNT(e.fullName) INTO invalid_person
    FROM papers.entryPermission e
    WHERE e.fullName NOT IN (SELECT p.fullName FROM identity.passport p);
    
    RAISE INFO 'Найдено % въезжающих без загерестрированных паспортов', invalid_person;
END $$;
```

6.2 Создание нового предмета анонимно
```sql
select * from items.luggageitemtype;

do $$
begin    
    
insert into items.luggageitemtype (id, itemname) values (getMaxItemTypeId() + 1,
                                                             'Abobus');
end $$ language  plpgsql;

select * from items.luggageitemtype;
```
<img width="325" height="190" alt="image" src="https://github.com/user-attachments/assets/92544d57-bb23-45ab-b2b6-18cc2db8256d" />
<img width="322" height="213" alt="image" src="https://github.com/user-attachments/assets/1753ee77-c829-4127-b1ad-b33c052624bd" />

6.3 Do bi do bi do bi - абсолютно бесполезный, но наглядный пример создания и вызова анонимных функций друг в друге
```sql
do $$
    begin
        do $$
            begin
                do $$
                    begin
                        raise syntax_error ;
                    exception when SYNTAX_ERROR then raise info 'Gotcha';
                    end $$ language plpgsql;
            end $$ language plpgsql;
    end $$ language plpgsql;

```

7. IF
Функция для получения того, имеет ли зарегестрированный паспорт въезжающий человек

```sql
CREATE OR REPLACE FUNCTION papers.check_passport_existence()
RETURNS TABLE(
    full_name VARCHAR(100),
    status TEXT,
    passport_id INTEGER
) 
LANGUAGE plpgsql
AS $$
DECLARE
    ep_rec RECORD;
    status_text TEXT;
    pass_id INTEGER;
BEGIN
    FOR ep_rec IN SELECT * FROM papers.entryPermission
    LOOP
        -- Проверяем наличие паспорта
        IF EXISTS (SELECT 1 FROM identity.passport WHERE fullName = ep_rec.fullName) THEN
            status_text := 'зарегистрирован';
            pass_id := (SELECT id FROM identity.passport WHERE fullName = ep_rec.fullName LIMIT 1);
        ELSE
            status_text := 'не зарегистрирован';
            pass_id := 0;
        END IF;
        
        full_name := ep_rec.fullName;
        status := status_text;
        passport_id := pass_id;
        RETURN NEXT;
    END LOOP;
END;
$$;

SELECT * FROM papers.check_passport_existence();
```

8. CASE
Функция, которая позволяет получить исформацию о документах для въезда с состояниями - "зарегистрирован (действителен)", "зарегистрирован (просрочен)", "не зарегистрирован" 

```sql
CREATE OR REPLACE FUNCTION papers.check_passport_existence_detailed()
RETURNS TABLE(
    full_name VARCHAR(100),
    status TEXT,
    passport_id INTEGER
) 
LANGUAGE plpgsql
AS $$
DECLARE
    ep_rec RECORD;
    status_text TEXT;
    pass_id INTEGER;
BEGIN
    FOR ep_rec IN SELECT * FROM papers.entryPermission
    LOOP
        CASE
            WHEN EXISTS (SELECT 1 FROM identity.passport WHERE fullName = ep_rec.fullName) AND ep_rec.validUntil >= CURRENT_DATE THEN
                status_text := 'зарегистрирован (действителен)';
                pass_id := (SELECT id FROM identity.passport WHERE fullName = ep_rec.fullName LIMIT 1);
            WHEN EXISTS (SELECT 1 FROM identity.passport WHERE fullName = ep_rec.fullName) AND ep_rec.validUntil < CURRENT_DATE THEN
                status_text := 'зарегистрирован (просрочен)';
                pass_id := (SELECT id FROM identity.passport WHERE fullName = ep_rec.fullName LIMIT 1);
            ELSE
                status_text := 'не зарегистрирован';
                pass_id := 0;
        END CASE;
        
        full_name := ep_rec.fullName;
        status := status_text;
        passport_id := pass_id;
        RETURN NEXT;
    END LOOP;
END;
$$;

SELECT * FROM papers.check_passport_existence_detailed();
```

9. WHILE

9.1 Функция проверяет каждый паспорт и определяет, достаточно ли для общей картины валидных паспортов.
Если невалидных минимум 3, то недостаточно.

```sql
CREATE OR REPLACE FUNCTION check_enough_valid_passports()
RETURNS BOOLEAN 
LANGUAGE plpgsql
AS $$
DECLARE
    passports_count INT;
    i INT := 1;
    invalid INT := 0;
    current_date DATE := CURRENT_DATE;
    is_valid BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO passports_count FROM identity.passport;

    WHILE i <= passports_count AND invalid < 3 LOOP
        SELECT (validUntil > current_date) INTO is_valid
        FROM identity.passport LIMIT 1 OFFSET (i-1);
        
        IF NOT is_valid THEN
            invalid := invalid + 1;
            RAISE INFO 'Invalid passport found, now: %', invalid;
        ELSE
            RAISE INFO 'Normal passport, demdalsh';
        END IF;
        
        i := i + 1;
    END LOOP;
    
    RETURN invalid < 3;
END;
$$;

DO $$
BEGIN
    RAISE INFO 'Достаточно ли валидных паспортов: %', check_enough_valid_passports();
END $$;
```

9.2. Процедура для создания группы профессий из n рангов

```sql
CREATE OR REPLACE PROCEDURE information_schema.create_activity_with_n_rank(
    activity_type VARCHAR(100), 
    n INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= n LOOP
        INSERT INTO papers.activity (description)
        VALUES (
            activity_type || '' || i || ' ранга'
        );

        i := i + 1;
    END LOOP;

    RAISE NOTICE 'было создано % рангов для профессии', n;
END;
$$;

CALL information_schema.create_activity_with_n_rank('столяр', 6);

SELECT * FROM papers.activity;
```

10. EXCEPTION

10.1 Попытаться посчитать 1 / 0

```sql
DO $$
BEGIN
    RAISE INFO '1/0 = %', (1 / 0);
EXCEPTION
    WHEN division_by_zero THEN
        RAISE INFO 'Ага, щас, размечтался';
END $$;
```

10.1 Изловить ошибку синтаксиса
```sql
do $$
begin
raise syntax_error ;
exception when SYNTAX_ERROR then raise info 'Gotcha';
end $$ language plpgsql;
```

11. RAISE

11.1 Вывести количество паспортов

```sql
DO $$
BEGIN
    RAISE INFO 'Кол-во %', (SELECT COUNT(*) FROM identity.passport);
END $$;
```

11.1 Создать ошибку синтаксиса (сам не знаю зачем)
```sql
do $$
begin
raise syntax_error ;
exception when SYNTAX_ERROR then raise info 'Gotcha';
end $$ language plpgsql;
```
