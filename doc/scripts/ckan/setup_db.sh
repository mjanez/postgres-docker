#!/bin/bash

# Variables
CKAN_DB_USER="sampledbuser"
CKAN_DB_PASSWORD="sampledbpassword"
CKAN_DB="sampledb"
DATASTORE_DB="datastdatastoreore"
DATASTORE_READONLY_USER="datastore_ro"
DATASTORE_READONLY_PASSWORD="your_datastore_readonly_password"

# Create CKAN user
psql -c "CREATE USER $CKAN_DB_USER WITH PASSWORD '$CKAN_DB_PASSWORD' SUPERUSER;"

# Create CKAN database
psql -c "CREATE DATABASE $CKAN_DB OWNER $CKAN_DB_USER ENCODING 'UTF8';"

# Grant privileges to CKAN user on CKAN database
psql -c "GRANT ALL PRIVILEGES ON DATABASE $CKAN_DB TO $CKAN_DB_USER;"

# Create readonly user for datastore
psql -c "CREATE USER $DATASTORE_READONLY_USER WITH PASSWORD '$DATASTORE_READONLY_PASSWORD' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN NOREPLICATION NOBYPASSRLS;"

# Create datastore database
psql -c "CREATE DATABASE $DATASTORE_DB OWNER $CKAN_DB_USER ENCODING 'UTF8';"

# Grant select to readonly user on datastore database
psql -c "GRANT SELECT ON DATABASE $DATASTORE_DB TO $DATASTORE_READONLY_USER;"