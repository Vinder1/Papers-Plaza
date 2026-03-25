docker exec pg-master psql -U postgres -d testdb -c \
        "INSERT INTO test_data (name, created_at)
        SELECT 'Load Test ' || generate_series(1, 1000000), NOW();"