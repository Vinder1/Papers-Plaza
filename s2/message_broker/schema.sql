-- Active: 1774426901049@@127.0.0.1@5444@broker_db
CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    -- payload JSONB NOT NULL,
    payload TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ready',
    priority INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    attempts INT NOT NULL DEFAULT 0,
    max_attempts INT NOT NULL DEFAULT 3,
    worker_id TEXT,
    error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_tasks_ready ON tasks (priority DESC, created_at ASC)
WHERE status = 'ready';

CREATE INDEX IF NOT EXISTS idx_tasks_running ON tasks (updated_at ASC)
WHERE status = 'running';

ALTER TABLE tasks SET (
    autovacuum_vacuum_scale_factor = 0.0,
    autovacuum_vacuum_threshold = 1000,
    autovacuum_analyze_scale_factor = 0.0,
    autovacuum_analyze_threshold = 5000,
    toast.autovacuum_vacuum_scale_factor = 0.0
);