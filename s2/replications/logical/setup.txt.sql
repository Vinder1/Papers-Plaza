-- Active: 1774426738919@@127.0.0.1@5440@pubdb
1) сначала docker-compose.yml

2) pg_hba в publisher
host    all             replicator      0.0.0.0/8               md5
host    replication     replicator      0.0.0.0/8               md5

3) 
# Обновление
docker exec pg-publisher psql -U postgres -c "SELECT pg_reload_conf();"

# Проверка подключения
docker exec pg-publisher psql -U postgres -c "SELECT usename, userepl FROM pg_user WHERE usename='replicator';"

4) Смотрим публикатора

# Подключение к publisher
docker exec -it pg-publisher psql -U postgres -d pubdb

-- Создать publication для конкретных таблиц
-- CREATE PUBLICATION my_publication FOR TABLE users, logs;

CREATE PUBLICATION my_publication FOR ALL TABLES;

-- Проверить publication
SELECT * FROM pg_publication;

-- Проверить таблицы в publication
SELECT * FROM pg_publication_tables;

5) Смотрим подписчика

docker exec -it pg-subscriber psql -U postgres -d subdb

-- Сначала создать ТАКИЕ ЖЕ таблицы на subscriber
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE logs (
    timestamp TIMESTAMP DEFAULT NOW(),
    message TEXT,
    level VARCHAR(20)
);

-- Создать subscription
CREATE SUBSCRIPTION my_subscription
CONNECTION 'host=pg-publisher port=5432 dbname=pubdb user=replicator password=replicator_password'
PUBLICATION my_publication;

-- Проверить subscription
SELECT * FROM pg_subscription;

-- Проверить статус репликации
SELECT * FROM pg_stat_subscription;


6) Проверка
у публикатора:

INSERT INTO users (name, email) VALUES 
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');


у подписчика

SELECT * FROM users;


7) DDL не реплицируется

ALTER TABLE users ADD COLUMN phone VARCHAR(20);

# Проверить схему на Publisher
docker exec -it pg-publisher psql -U postgres -d pubdb -c "\d users"

# Проверить схему на Subscriber
docker exec -it pg-subscriber psql -U postgres -d subdb -c "\d users"

8) Вставка без PK

Вставка в publisher

-- Insert

CREATE TABLE logs (
    timestamp TIMESTAMP DEFAULT NOW(),
    message TEXT,
    level VARCHAR(20)
);

INSERT INTO logs (message, level) VALUES 
('Error 1', 'ERROR'),
('Error 2', 'ERROR'),
('Warning 1', 'WARNING');

Проверка в subscriber

SELECT * FROM logs;

-- Update

На Publisher

UPDATE logs SET level = 'CRITICAL' WHERE message = 'Error 1';

Не получилось, скрин в cant-update.png

есть решения:

# На Publisher - установить REPLICA IDENTITY
docker exec -it pg-publisher psql -U postgres -d pubdb -c

-- Вариант 1: Использовать уникальный индекс
CREATE UNIQUE INDEX idx_logs_message ON logs(message);
ALTER TABLE logs REPLICA IDENTITY USING INDEX idx_logs_message;

-- Вариант 2: FULL (все колонки)
-- ALTER TABLE logs REPLICA IDENTITY FULL;

-- Вариант 3: NOTHING (только INSERT)
-- ALTER TABLE logs REPLICA IDENTITY NOTHING;

# Проверить REPLICA IDENTITY
SELECT relname, relreplident FROM pg_class WHERE relname = 'logs';


9) REPLICATION STATUS

у публикатора:

SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn
FROM pg_stat_replication;

SELECT 
    slot_name,
    plugin,
    slot_type,
    database,
    active,
    restart_lsn,
    confirmed_flush_lsn
FROM pg_replication_slots;

у подписчика:

SELECT 
    subname,
    subenabled,
    subconninfo,
    subslotname
FROM pg_subscription;

SELECT 
    subname,
    pid,
    relid,
    received_lsn,
    last_msg_send_time,
    last_msg_receipt_time,
    latest_end_lsn,
    latest_end_time
FROM pg_stat_subscription;


10) Дампы
Дампы могут использоваться для начальной инициализации
читать файл dump.txt