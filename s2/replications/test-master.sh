# Подключение к Master
docker exec -it pg-master psql -U postgres -d testdb

# Вставка тестовых данных
INSERT INTO test_data (name) VALUES ('Test Row 1');
INSERT INTO test_data (name) VALUES ('Test Row 2');
INSERT INTO test_data (name) VALUES ('Test Row 3');

# Проверка на Master
SELECT * FROM test_data;