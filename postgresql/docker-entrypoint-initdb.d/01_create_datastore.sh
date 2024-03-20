#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE "$DATASTORE_READONLY_USER" NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '$DATASTORE_READONLY_PASSWORD';
EOSQL

echo "[01_create_datastore] $DATASTORE_READONLY_USER role created..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE "$DATASTORE_DB" OWNER "$MAIN_DB_USER" ENCODING 'utf-8';
EOSQL

echo "[01_create_datastore] $DATASTORE_DB database created..."