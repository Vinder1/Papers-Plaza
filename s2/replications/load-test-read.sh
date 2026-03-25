docker exec pg-master psql -U postgres -d testdb -c "
    SELECT 
        client_addr,
        pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
    FROM pg_stat_replication;
    "


docker exec pg-replica1 psql -U postgres -d testdb -c \
    "SELECT COUNT(*) FROM test_data;"