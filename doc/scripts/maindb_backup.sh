#!/bin/bash

# Set the necessary variables
CONTAINER_NAME="db"
DATABASE_NAME="postgres"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="postgres"
BACKUP_DIRECTORY="/tmp/postgres_backup"
DATE=$(date +%Y%m%d%H%M%S)

# Run the backup command
docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $CONTAINER_NAME pg_dump -U $POSTGRES_USER -Fc $DATABASE_NAME > $BACKUP_DIRECTORY/postgres_backup_$DATE.dump