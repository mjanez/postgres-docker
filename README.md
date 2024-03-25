# PostgreSQL Docker Compose
This repository provides a simple and customizable setup for deploying PostgreSQL and PgAdmin using Docker Compose. It is designed to be a source repository for easy deployments.

## Features
- [**PostgreSQL**](https://www.postgresql.org/): The world's most advanced open-source relational database. This setup uses the alpine version for a smaller footprint.
- [**PgAdmin**](https://www.pgadmin.org/): A popular open-source and full-featured PostgreSQL administration tool. This setup allows you to manage your databases through a web interface.
- [**Docker Compose**](https://docs.docker.com/compose/): Easy deployment with a single command. Docker Compose also allows you to manage your application's services.
- **Multiple Databases**: This setup supports multiple databases, making it suitable for complex applications.
- **Environment Variables**: Customize your setup easily using environment variables. An example file ([`.env.example`](.env.example)) is provided to get you started.

## Getting Started
1. Clone this repository to your local machine.
2. Rename [`.env.example`](.env.example) to `.env` and modify the values to fit your needs.
3. Run `docker-compose up -d` to start the PostgreSQL and PgAdmin services.

Please refer to the individual Dockerfiles and scripts in the [`postgresql`](postgresql) and [`pgadmin`](pgadmin) directories for more details on how the images are built and how the databases are initialized.

### Environment Variables
The following environment variables are available for customization:
```ini

# Container names
POSTGRESQL_CONTAINER_NAME=db # Name of the PostgreSQL container
PGADMIN_CONTAINER_NAME=pgadmin # Name of the PgAdmin container

# Host Ports
PGADMIN_PORT_HOST=8888 # Port for the PgAdmin web interface
POSTGRESQL_CONTAINER_PORT_HOST=5433 # Port for the PostgreSQL container

...

## List all databases to be checked
DATABASES_TO_CHECK="sampledb datastore sampledb_test datastore_test"

# Postgres DB
POSTGRES_USER=postgres # Postgres user
POSTGRES_PASSWORD=postgres # Postgres password
POSTGRES_DB=postgres # Postgres database
PGADMIN_DEFAULT_EMAIL=admin@localhost # PgAdmin default email
PGADMIN_DEFAULT_PASSWORD=pgadminpassword # PgAdmin default password

## Main data DB
MAIN_DB_USER=sampledbuser 
MAIN_DB_PASSWORD=sampledbpassword
MAIN_DB=sampledb

## Aux datastore DB
DATASTORE_READONLY_USER=datastore_ro
DATASTORE_READONLY_PASSWORD=datastore
DATASTORE_DB=datastore

...

# Test databases
MAIN_TEST_DB=sampledb_test
DATASTORE_TEST_DB=datastore_test
```

## Usage
### Connect PostgreSQL Database Container into PgAdmin 4
1. Open your browser and go to `http://localhost:{PGADMIN_PORT_HOST}`.
2. Log in using the email and password you set in the `.env` file.
3. Click on `Add New Server`.
4. Enter the following details:
   - **General**:
     - Name: Any name you want to give to the server.
   - **Connection**:
     - Host name/address: `{POSTGRESQL_CONTAINER_NAME}`
     - Port: `{POSTGRESQL_CONTAINER_PORT}`
     - Maintenance database: `{POSTGRES_DB}`
     - Username: `user`
     - Password: `password`

### Connect to PostgreSQL Database Container
You can connect to the PostgreSQL database container using the following command:
```bash
docker exec -it {POSTGRESQL_CONTAINER_NAME} psql -U {POSTGRES_USER} -d {POSTGRES_DB}
```

### Backups
PostgreSQL offers the command line tools [`pg_dump`](https://www.postgresql.org/docs/current/static/app-pgdump.html) and [`pg_restore`](https://www.postgresql.org/docs/current/static/app-pgrestore.html) for dumping and restoring a database and its content to/from a file.

#### Backup service for db container
1. Create a new file called `maindb_backup_custom.sh` and open it in your preferred text editor.

2. Add the following code to the script, replacing the placeholders with your actual values:

    ```sh
    #!/bin/bash

    # Set the necessary variables
    CONTAINER_NAME="your_postgresql_container_name"
    DATABASE_NAME="your_database_name"
    POSTGRES_USER="your_postgres_user"
    POSTGRES_PASSWORD="your_postgres_password"
    BACKUP_DIRECTORY="/path/to/your/backup/directory"
    DATE=$(date +%Y%m%d%H%M%S)
    MONTH=$(date +%m)
    YEAR=$(date +%Y)

    # Create the monthly backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIRECTORY/monthly/$YEAR-$MONTH"

    # Run the backup command
    docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $CONTAINER_NAME pg_dump -U $POSTGRES_USER -Fc $DATABASE_NAME > "$BACKUP_DIRECTORY/monthly/$YEAR-$MONTH/ckan_backup_$DATE.dump"

    # Compress the dump files into a zip archive
    cd "$BACKUP_DIRECTORY/monthly/$YEAR-$MONTH" || exit
    zip "backup_${YEAR}-${MONTH}.zip" *.dump

    # Remove the original dump files
    rm -f *.dump
    ```

3. Replace the following placeholders with your values from the `.env` file.

    > [!WARNING]
    > If you have changed the values of the PostgreSQL container, database or user, change them too.
    > Check that `zip` package is installed, eg: `sudo apt-get install zip`

4. Save and close the file.

5. Make the script executable:

    ```bash
    chmod +x maindb_backup_custom.sh
    ```

6. Open the crontab for the current user:

    ```bash
    crontab -e
    ```

7. Add the following line to schedule the backup to run daily at midnight (adjust the schedule as needed):

    ```sh
    0 0 * * * /path/to/your/script/maindb_backup_custom.sh
    ```

    > [!NOTE]
    > Replace `/path/to/your/script` with the actual path to the `maindb_backup_custom.sh` script.
  
8. Save and close the file.

The cronjob is now set up and will backup your CKAN PostgreSQL database daily at midnight using the custom format. The backups will be stored in the specified directory with the timestamp in the filename.

> [!NOTE]
> Sample scripts for backing up CKAN: [`doc/scripts`](doc/scripts)


#### Restore a backup
##### From pg_dump
If need to use a backup of `maindb` in a new deployment, you can restore it using the following steps:

> [!WARNING]
> Target database already exist before starting to run the restore with the same properties. [PostgresSQL Documentation: Backup](https://www.postgresql.org/docs/8.1/backup.html#BACKUP-DUMP-RESTORE).

1. Import a previously created dump.

    ```bash
    docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $POSTGRESQL_CONTAINER_NAME pg_restore -U $POSTGRES_USER --clean --if-exists -d $MAIN_DB < /path/to/your/backup/directory/maindb.dump
    ```

##### From .sql file
Restoring a PostgreSQL database from a `.sql` file involves executing the SQL commands in the file on a PostgreSQL database. This is typically done using the `psql` command-line utility, which is a terminal-based front-end to PostgreSQL. 

Here's how you can do it:

    ```bash
    # Create users and db if not exists
    docker exec -e PGPASSWORD=$POSTGRES_PASSWORD $POSTGRESQL_CONTAINER_NAME psql -U $POSTGRES_USER -c "CREATE DATABASE $DATABASE_NAME OWNER $DATABASE_OWNER;"

    # Restore with pg_restore
    docker exec -i $POSTGRESQL_CONTAINER_NAME psql -U $POSTGRES_USER -d $DATABASE_NAME < /path/to/your/backup/directory/database.sql
    ```

This command will restore the database `$DATABASE_NAME` from the `database.sql` file in the container `$POSTGRESQL_CONTAINER_NAME`. Replace `$POSTGRESQL_CONTAINER_NAME`, `$POSTGRES_USER`, `$DATABASE_NAME`, and `/path/to/your/backup/directory/database.sql` with your actual values.

If the `database.sql` file is on your local machine and not in the container, you'll need to copy it to the container first or mount it as a volume.

Please note that the `.sql` file should contain valid SQL commands. If the file was created using `pg_dump` with a format other than plain text, you'll need to use `pg_restore` instead of `psql` to restore the database.

## Contributing
Contributions are welcome! Please feel free to submit a pull request.

## License
This project is open source and available under the [MIT License](LICENSE).

## Support

If you have any questions or issues, please submit an issue on the GitHub page. We'll do our best to respond promptly.