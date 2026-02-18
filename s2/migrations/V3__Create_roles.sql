
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'admin') THEN
        -- Admin: полный доступ (аналог postgres)
        CREATE ROLE admin WITH
            LOGIN
            PASSWORD 'nimda'
            SUPERUSER
            CREATEDB
            CREATEROLE
            REPLICATION
            CONNECTION LIMIT 2;
    ELSE
        ALTER ROLE admin WITH PASSWORD 'nimda';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app') THEN
        -- App: чтение и изменение данных
        CREATE ROLE app WITH
            LOGIN
            PASSWORD '123456789'
            NOSUPERUSER
            NOCREATEDB
            NOCREATEROLE
            NOREPLICATION
            CONNECTION LIMIT 10;
    ELSE
        ALTER ROLE app WITH PASSWORD '123456789';
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'readonly') THEN
        -- Readonly: только чтение
        CREATE ROLE readonly WITH
            LOGIN
            PASSWORD ''
            NOSUPERUSER
            NOCREATEDB
            NOCREATEROLE
            NOREPLICATION
            CONNECTION LIMIT 100;
    ELSE
        ALTER ROLE readonly WITH PASSWORD 'readonly';
    END IF;

    END
$$;

-- Права на подключение
GRANT CONNECT ON DATABASE "PapersPlease" TO admin;
GRANT CONNECT ON DATABASE "PapersPlease" TO app;
GRANT CONNECT ON DATABASE "PapersPlease" TO readonly;
REVOKE CONNECT ON DATABASE "PapersPlease" FROM PUBLIC;

-- Права на использование
GRANT ALL ON SCHEMA criminal, identity, items, papers, people, public TO admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA criminal, identity, items, papers, people, public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA criminal, identity, items, papers, people, public TO admin;

GRANT USAGE ON SCHEMA criminal, identity, items, papers, people, public TO app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA criminal, identity, items, papers, people, public TO app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA criminal, identity, items, papers, people, public TO app;

GRANT USAGE ON SCHEMA criminal, identity, items, papers, people, public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA criminal, identity, items, papers, people, public TO readonly;

-- Права по умолчанию
ALTER DEFAULT PRIVILEGES IN SCHEMA criminal, identity, items, papers, people, public 
    GRANT ALL ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA criminal, identity, items, papers, people, public 
    GRANT ALL ON SEQUENCES TO admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA criminal, identity, items, papers, people, public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app;
ALTER DEFAULT PRIVILEGES IN SCHEMA criminal, identity, items, papers, people, public 
    GRANT USAGE, SELECT ON SEQUENCES TO app;

ALTER DEFAULT PRIVILEGES IN SCHEMA criminal, identity, items, papers, people, public 
    GRANT SELECT ON TABLES TO readonly;