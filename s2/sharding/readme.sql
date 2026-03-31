docker-compose up -d

docker exec -it pg_router psql -U postgres -d router_db

-- Все данные
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM router_table;
-- result: all_scan.png


-- Данные с фильтрацией
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM router_table WHERE shard_id = 1;
-- result: filtered_scan.png


-- Вставка данных через роутер
INSERT INTO router_table (id, shard_id, data) VALUES (7, 1, 'New data for Shard 1');
INSERT INTO router_table (id, shard_id, data) VALUES (8, 2, 'New data for Shard 2');

# Проверка Шарда 1 (должен видеть id 1,2,3,7)
docker exec -it pg_shard1 psql -U postgres -d shard_db -c "SELECT * FROM local_data;"

# Проверка Шарда 2 (должен видеть id 4,5,6,8)
docker exec -it pg_shard2 psql -U postgres -d shard_db -c "SELECT * FROM local_data;"

-- результат insert и select в after_insert.sql