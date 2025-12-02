### Триггеры

1. NEW 

1.1 Выкидывать уведомление, если придёт чел из КНДР

```sql
CREATE OR REPLACE FUNCTION identity.notify_if_from_kndr()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.country = 3 THEN
        RAISE INFO 'очуметь, чел из КНДР';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_passport
    BEFORE INSERT OR UPDATE ON identity.passport
    FOR EACH ROW
    EXECUTE FUNCTION identity.notify_if_from_kndr();
```

![фото](trigger_cron_screenshots/1.1_regular_insert.png)
![фото](trigger_cron_screenshots/1.1_regular_result.png)
![фото](trigger_cron_screenshots/1.1_special_insert.png)
![фото](trigger_cron_screenshots/1.1_special_result.png)

2. OLD

2.1 Предотвратить изменение страны в паспорте

```sql
CREATE OR REPLACE FUNCTION identity.prevent_country_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.country <> NEW.country THEN
        RAISE EXCEPTION 'Изменение страны в паспорте запрещено! Заводи новый паспорт, придурок! Паспорт ID %', OLD.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_country_change
    BEFORE UPDATE OF country ON identity.passport
    FOR EACH ROW
    EXECUTE FUNCTION identity.prevent_country_change();
```

![фото](trigger_cron_screenshots/2_1_change_failed.png)

3. BEFORE

3.1 Запрет на изменение паспортов с истёкшим сроком действия (это теперь реликвия из прошлого, трогать нельзя)

```sql
CREATE OR REPLACE FUNCTION identity.prevent_update_expired_passport()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.validUntil <= CURRENT_DATE THEN
        RAISE EXCEPTION 'Срок действия паспорта истёк! Трогать его уже поздно) (ID: %, владелец: %)', 
            OLD.id, OLD.fullName;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_update_passport
    BEFORE UPDATE ON identity.passport
    FOR EACH ROW
    EXECUTE FUNCTION identity.prevent_update_expired_passport();
```

![фото](trigger_cron_screenshots/3_1_change_failed.png)

4. AFTER

4.1 

```sql
CREATE OR REPLACE FUNCTION identity.cleanup_permissions_on_country_delete()
RETURNS TRIGGER AS $$
DECLARE
    deleted_permissions INT;
    deleted_diplomats INT;
BEGIN
    DELETE FROM identity.citizenEntryPermission
    WHERE fromId = OLD.id OR toId = OLD.id;
    GET DIAGNOSTICS deleted_permissions = ROW_COUNT;
    
    DELETE FROM papers.diplomatCertificate
    WHERE countryOfIssue = OLD.id;
    GET DIAGNOSTICS deleted_diplomats = ROW_COUNT;

    RAISE NOTICE 'Стёрты все разрешения на въезд (%) и документы дипломатов (%), связанные со страной ID=% (название: %)',
        deleted_permissions,
        deleted_diplomats,
        OLD.id, OLD.name;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_delete_country
    AFTER DELETE ON identity.country
    FOR EACH ROW
    EXECUTE FUNCTION identity.cleanup_permissions_on_country_delete();
```

![фото](trigger_cron_screenshots/4_1_queries.png)
![фото](trigger_cron_screenshots/4_1_result.png)

5. Row level

6. Statement level

7. Отображение списка триггеров

### Кроны

8. Кроны

9. Запрос на просмотр выполнения кронов

```sql
select * from cron.job_run_details
order by start_time desc
limit 10;
```

10. Запрос на просмотр кронов

```sql
select * from cron.job;
```