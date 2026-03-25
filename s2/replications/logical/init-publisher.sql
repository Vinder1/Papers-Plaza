-- init-publisher.sql

-- Пользователь для репликации
CREATE USER replicator WITH REPLICATION LOGIN PASSWORD 'replicator_password';

-- Таблица с PK (нормальная)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Таблица БЕЗ PK (для теста REPLICA IDENTITY)
CREATE TABLE logs (
    timestamp TIMESTAMP DEFAULT NOW(),
    message TEXT,
    level VARCHAR(20)
);

-- Разрешить репликатору читать таблицы
GRANT SELECT ON users TO replicator;
GRANT SELECT ON logs TO replicator;

-- Настройка pg_hba для репликации
-- (добавим вручную после запуска)