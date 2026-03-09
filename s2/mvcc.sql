-- Включаем отображение скрытых системных полей
-- SET hide_system_atts TO off;
CREATE EXTENSION pageinspect;

SELECT pg_relation_filepath('identity.country');

SELECT 
    lp AS line_pointer,
    lp_off AS offset,
    lp_flags,
    t_xmin,
    t_xmax,
    t_field3 AS t_cid_t_infomask,
    t_ctid,
    t_infomask,
    t_infomask2,
    substring(t_bits from 1 for 10) AS t_bits_sample
FROM heap_page_items(get_raw_page('identity.country', 0));

-- 1. Смоделировать обновление данных
insert into identity.country (name)
VALUES 
('Чиназесляндия');

select * 
from identity.country
where name = 'Чиназесляндия';

update identity.country
set population = 1
WHERE name = 'Чиназесляндия';

-- Скриншот результата в mvcc_screenshots/update.png

-- 2. t_infomask - в скриншоте mvcc_screenshots/t_infomask.png

SELECT 
    12::bit(16) AS binary,
    CASE WHEN (12 & 0x0008) != 0 THEN 'XMIN_COMMITTED ' ELSE '' END ||
    CASE WHEN (12 & 0x0010) != 0 THEN 'XMIN_COMMITTED(alt) ' ELSE '' END AS flags;

-- 3. Разные транзакции (на примере Repeatable read)

-- на всякий случай
ROLLBACK;

-- сессия 1
-- BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

UPDATE identity.country SET population = 4 WHERE id = 10;

SELECT ctid, xmin, xmax, name, population FROM identity.country WHERE id = 10;

-- сессия 2
-- UPDATE identity.country SET population = 3 WHERE id = 10;

-- снова сессия 1
SELECT ctid, xmin, xmax, name, population FROM identity.country WHERE id = 10;

COMMIT;

-- 4. Deadlock

-- сессия 1
BEGIN;
UPDATE identity.country SET population = population + 1 WHERE id = 9;

-- сессия 2
BEGIN;
UPDATE identity.country SET population = population + 1 WHERE id = 10;
UPDATE identity.country SET population = population - 1 WHERE id = 9;

-- снова сессия 1
UPDATE identity.country SET population = population + 1 WHERE id = 10;

-- Профит! подтверждение в deadlock.png

-- 5. Блокировки
-- на уровне таблиц - изучили самостоятельно
-- на уровне строк:

-- FOR UPDATE vs ДРУГОЙ FOR UPDATE

-- сессия 1
BEGIN;
SELECT * FROM identity.country WHERE id = 10 FOR UPDATE;
-- Удерживаем
SELECT pg_sleep(5);

-- сессия 2
SELECT * FROM identity.country WHERE id = 10 FOR UPDATE;

-- снова сессия 1
COMMIT;

-- Скриншот в lock.png, блокировка продолжалась до коммита

-- FOR UPDATE vs FOR SHARE

-- сессия 1
BEGIN;
SELECT * FROM identity.country WHERE id = 10 FOR SHARE;
-- Удерживаем
SELECT pg_sleep(20);

-- сессия 2
-- не получится, будет заблокировано до коммита
UPDATE identity.country SET population = population + 1 WHERE id = 10;
-- получится спокойно
SELECT * FROM identity.country WHERE id = 10 FOR SHARE;

-- снова сессия 1
COMMIT;

-- 6. Очистка

-- Статистика
SELECT 
    relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'country';

-- Размер
SELECT 
    pg_size_pretty(pg_total_relation_size('identity.country')) AS total_size,
    pg_size_pretty(pg_relation_size('identity.country')) AS table_size;


-- Обычный VACUUM (не блокирует, помечает место как свободное)
VACUUM VERBOSE identity.country;

-- После этого:
SELECT n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'country';
-- n_dead_tup должен уменьшиться, но физический размер таблицы не изменится

-- Очистка с уменьшением физического веса. Требует блокировку ACCESS EXCLUSIVE
VACUUM FULL VERBOSE identity.country;