#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE ${MAIN_TEST_DB} OWNER "$MAIN_DB_USER" ENCODING 'utf-8';
EOSQL

echo "[03_setup_test_databases] $MAIN_TEST_DB database created..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE ${DATASTORE_TEST_DB} OWNER "$MAIN_DB_USER" ENCODING 'utf-8';
EOSQL

echo "[03_setup_test_databases] $DATASTORE_TEST_DB database created..."