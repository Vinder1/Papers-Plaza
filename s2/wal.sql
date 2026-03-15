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



