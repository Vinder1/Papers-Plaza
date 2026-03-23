# Подключение к Replica 1
docker exec -it pg-replica1 psql -U postgres -d testdb
SELECT * FROM test_data;

# Подключение к Replica 2
docker exec -it pg-replica2 psql -U postgres -d testdb
SELECT * FROM test_data;