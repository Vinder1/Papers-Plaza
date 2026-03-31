-- Создаем локальную таблицу данных
CREATE TABLE local_data (
    id int NOT NULL,
    shard_id int NOT NULL,
    data text,
    created_at timestamptz DEFAULT now(),
    PRIMARY KEY (id, shard_id)
);

-- Вставляем тестовые данные для Шарда 2
INSERT INTO local_data (id, shard_id, data) VALUES 
(4, 2, 'Data from Shard 2 - Row 1'),
(5, 2, 'Data from Shard 2 - Row 2'),
(6, 2, 'Data from Shard 2 - Row 3');

-- Создаем индекс для производительности
CREATE INDEX ON local_data (shard_id);