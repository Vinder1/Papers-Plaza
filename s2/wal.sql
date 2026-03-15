-- 2. Изменение LSN и WAL после изменения данных

-- LSN
SELECT pg_current_wal_lsn() AS lsn_before; -- lsn_before.png

-- изменение
CREATE TABLE IF NOT EXISTS test_wal (id serial, val text);
INSERT INTO test_wal (val) VALUES ('hello');

-- еще раз
SELECT pg_current_wal_lsn() AS lsn_after; -- lsn_after.png

-- WAL
-- скриншот wal_before - до транзакции с добавлением новых записей
-- wal_after - после добавления. Файл сразу же обновился

-- Массовая вставка
INSERT INTO test_wal (val) SELECT md5(random()::text) FROM generate_series(1, 100000);
-- mass_after.png
-- на скрине видно, что изменились сразу два файла. Их размер не изменился, новых файлов не замечено



-- 3. DUMP
-- создание:
docker compose run postgres pg_dump -h postgres -U admin PapersPlease > dump.sql
-- dump весит больше пол гигабайта, поэтому в репозитории его не будет
-- скриншот в wal_lsn_screenshots/dump.png

-- Дальше была создана вторая бд на порту 5433
-- туда был перенесён дамп
-- загрузка дампа:
docker compose exec -T postgres psql -U postgres -f /backup/dump.sql

-- результат в dump_restored.png и dump_restored2.png
-- копировалась база данных полностью, вместе с данными

docker compose down -v
-- удалить всё обратно

-- аналогично, только для исключительно структуры:
docker compose run --rm postgres pg_dump -h postgres -U admin --schema-only PapersPlease > schema_only.sql

-- для одной таблицы:
docker compose run --rm postgres pg_dump -h postgres -U admin --table users PapersPlease > table_users.sql



-- 4. SEED

-- добавление происходит с проверкой, что под такими id никого нет
INSERT INTO identity.country (id, name)
VALUES (1, 'Россия'),
    (2, 'США'),
    (3, 'КНДР'),
    (4, 'Китай'),
    (5, 'Казахстан'),
    (6, 'Германия'),
    (7, 'Афганистан'),
    (8, 'Мексика'),
    (9, 'Нигер')
ON CONFLICT (id) DO NOTHING;

-- или так, по имени, но по одному
INSERT INTO identity.country (name)
SELECT 'Россия'
WHERE NOT EXISTS
(
    SELECT 1 FROM identity.country WHERE name = 'Россия'
);

-- и такое надо сделать со всеми запросами в GenerateBigData, но я не буду