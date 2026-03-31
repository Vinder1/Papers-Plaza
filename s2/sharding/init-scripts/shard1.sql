-- Создаем локальную таблицу данных
CREATE TABLE local_data (
    id int NOT NULL,
    shard_id int NOT NULL,
    data text,
    created_at timestamptz DEFAULT now(),
    PRIMARY KEY (id, shard_id)
);

-- Вставляем тестовые данные для Шарда 1
INSERT INTO local_data (id, shard_id, data) VALUES 
(1, 1, 'Data from Shard 1 - Row 1'),
(2, 1, 'Data from Shard 1 - Row 2'),
(3, 1, 'Data from Shard 1 - Row 3');

-- Создаем индекс для производительности
CREATE INDEX ON local_data (shard_id);