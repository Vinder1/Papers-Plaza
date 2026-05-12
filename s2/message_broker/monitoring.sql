-- Посмотреть лаг
SELECT EXTRACT(EPOCH FROM (NOW() - MIN(created_at))) AS lag_sec 
FROM tasks WHERE status = 'ready';

-- Для очистки старых записей
VACUUM (VERBOSE, ANALYZE) tasks;

-- Размер таблицы
SELECT pg_size_pretty(pg_total_relation_size('tasks')) AS total_size;