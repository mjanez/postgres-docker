#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE "$MAIN_DB_USER" NOSUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD '$MAIN_DB_PASSWORD';
EOSQL

echo "[00_create_sampledb] $MAIN_DB_USER role created..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE "$MAIN_DB" OWNER "$MAIN_DB_USER" ENCODING 'utf-8';
EOSQL

echo "[00_create_sampledb] $MAIN_DB database created..."
