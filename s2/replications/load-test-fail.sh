#!/bin/bash

echo "Начало нагрузки INSERT на Master..."

for i in {1..1000}; do
    # docker exec pg-master psql -U postgres -d testdb -c \
    #     "INSERT INTO test_data (name) FROM ('Load Test $i');"

    docker exec pg-master psql -U postgres -d testdb -c \
        "INSERT INTO test_data (name, created_at)
        SELECT 'Load Test ' || generate_series(1, 1000000), NOW();"
    
    # Проверка лага каждые 1 записей
    if [ $((i % 1)) -eq 0 ]; then
        echo "=== Lag после $i записей ==="
        docker exec pg-master psql -U postgres -d testdb -c "
        SELECT 
            client_addr,
            pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
        FROM pg_stat_replication;
        "

        docker exec pg-replica1 psql -U postgres -d testdb -c \
        "SELECT COUNT(*) FROM test_data;"
    fi
done

echo "Нагрузка завершена!"