-- Active: 1758114810365@@localhost@5432@PapersPlease
-- 1. Секционирование: RANGE / LIST / HASH

-- RANGE

CREATE TABLE orders_range (
    id int,
    order_date date,
    amount numeric
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_range_2023_q1 PARTITION OF orders_range
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');
CREATE TABLE orders_range_2023_q2 PARTITION OF orders_range
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');
CREATE TABLE orders_range_2023_q3 PARTITION OF orders_range
    FOR VALUES FROM ('2023-07-01') TO ('2023-10-01');

INSERT INTO orders_range (id, order_date, amount)
VALUES (1, '2023-04-05', 12), (2, '2023-05-10', 11)

CREATE INDEX ON orders_range (order_date);

EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM orders_range 
WHERE order_date >= '2023-05-01' AND order_date < '2023-06-01';

-- LIST

CREATE TABLE orders_list (
    id int,
    region text,
    amount numeric
) PARTITION BY LIST (region);

CREATE TABLE orders_list_eu PARTITION OF orders_list FOR VALUES IN ('EU', 'DE', 'FR');
CREATE TABLE orders_list_us PARTITION OF orders_list FOR VALUES IN ('US', 'CA');
CREATE TABLE orders_list_asia PARTITION OF orders_list FOR VALUES IN ('CN', 'JP');

INSERT INTO orders_list (id, region, amount)
VALUES (1, 'US', 12), (2, 'CA', 11)

CREATE INDEX ON orders_list (region);

EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM orders_list
WHERE region IN ('US', 'DE');

-- HASH

CREATE TABLE orders_hash (
    id int,
    user_id int,
    amount numeric
) PARTITION BY HASH (user_id);

CREATE TABLE orders_hash_p0 PARTITION OF orders_hash FOR VALUES WITH (MODULUS 3, REMAINDER 0);
CREATE TABLE orders_hash_p1 PARTITION OF orders_hash FOR VALUES WITH (MODULUS 3, REMAINDER 1);
CREATE TABLE orders_hash_p2 PARTITION OF orders_hash FOR VALUES WITH (MODULUS 3, REMAINDER 2);

INSERT INTO orders_hash (id, user_id, amount)
VALUES (1, 11, 12), (2, 100, 11)

CREATE INDEX ON orders_hash (user_id);

EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM orders_hash WHERE user_id = 100;

EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM orders_hash WHERE user_id > 91 AND user_id < 200;

-- Секционирование и физическая репликация

-- скрин в sections_screenshots/master-replica-sections.png
-- использовались те же мастер + 2 реплики, что и в прошлой дз с физической репликацией



-- Логическая репликация

-- у publisher-a
CREATE PUBLICATION my_pub FOR TABLE orders_range 
    WITH (publish_via_partition_root = on);

-- у subscriber-a
CREATE SUBSCRIPTION my_sub
    CONNECTION 'host=pg-publisher port=5432 dbname=pubdb user=replicator password=replicator_password'
    PUBLICATION my_pub;
-- тут без partition, одна таблица orders_range



-- Шардирование
-- читать файл readme.sql в папке sharding