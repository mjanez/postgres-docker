#!/bin/bash
set -e

echo "Databases to test: $DATABASES_TO_CHECK"

# Get the list of databases from the environment variable
IFS=' ' read -r -a databases <<< "$DATABASES_TO_CHECK"

# Loop through each database and try to connect
for db in "${databases[@]}"; do
    echo "Checking connection to $db..."

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" <<-EOSQL
SELECT 1;
EOSQL

    if [ $? -eq 0 ]; then
        echo "[99_check_databases_conn ] Successfully connected to $db"
    else
        echo "[99_check_databases_conn ] Could not connect to $db"
    fi
done