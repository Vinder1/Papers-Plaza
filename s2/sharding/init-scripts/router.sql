-- Включаем расширение для работы с удаленными таблицами
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 1. Создаем сервера (ссылки на шарды)
-- Используем имена сервисов Docker Compose как хосты
CREATE SERVER shard1_srv FOREIGN DATA WRAPPER postgres_fdw 
    OPTIONS (host 'shard1', port '5432', dbname 'shard_db');

CREATE SERVER shard2_srv FOREIGN DATA WRAPPER postgres_fdw 
    OPTIONS (host 'shard2', port '5432', dbname 'shard_db');

-- 2. Маппинг пользователей (используем те же креды, что и в docker-compose)
CREATE USER MAPPING FOR postgres SERVER shard1_srv 
    OPTIONS (user 'postgres', password 'secret');

CREATE USER MAPPING FOR postgres SERVER shard2_srv 
    OPTIONS (user 'postgres', password 'secret');

-- 3. Создаем внешние таблицы
CREATE FOREIGN TABLE ft_shard1 (
    id int,
    shard_id int,
    data text,
    created_at timestamptz
) SERVER shard1_srv OPTIONS (table_name 'local_data');

CREATE FOREIGN TABLE ft_shard2 (
    id int,
    shard_id int,
    data text,
    created_at timestamptz
) SERVER shard2_srv OPTIONS (table_name 'local_data');

-- 4. Создаем локальную секционированную таблицу-роутер
CREATE TABLE router_table (
    id int,
    shard_id int,
    data text,
    created_at timestamptz
) PARTITION BY LIST (shard_id);

-- 5. Прикрепляем внешние таблицы как партиции
-- Это ключевой момент для работы Partition Pruning
ALTER TABLE router_table ATTACH PARTITION ft_shard1 FOR VALUES IN (1);
ALTER TABLE router_table ATTACH PARTITION ft_shard2 FOR VALUES IN (2);

-- 6. Создаем представление для удобного запроса (опционально)
CREATE VIEW all_data AS SELECT * FROM router_table;