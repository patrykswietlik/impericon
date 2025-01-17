#!/bin/bash

DB_CONTAINER="prestashop-db"
PRESTASHOP_CONTAINER="prestashop"
BACKUP_FILE="prestashop_db_backup.sql"
IMG_FOLDER="img"
MODULES_FOLDER="modules"
SOURCE_FOLDER="./backup"

if [ ! -f "$SOURCE_FOLDER/$BACKUP_FILE" ]; then
    echo "Error: Database backup file $SOURCE_FOLDER/$BACKUP_FILE does not exist!" >&2
    exit 1
fi

echo "Restoring a database from a file $SOURCE_FOLDER/$BACKUP_FILE"
docker exec -i "$DB_CONTAINER" mysql -u root -pprestashop prestashop < "$SOURCE_FOLDER/$BACKUP_FILE"
if [ $? -eq 0 ]; then
    echo "The database has been successfully restored"
else
    echo "Error while restoring the database" >&2
    exit 1
fi

if [ ! -d "$SOURCE_FOLDER/$IMG_FOLDER" ]; then
    echo "Error: Folder $SOURCE_FOLDER/$IMG_FOLDER does not exist" >&2
    exit 1
fi

if [ ! -d "$SOURCE_FOLDER/$MODULES_FOLDER" ]; then
    echo "Error: Folder $SOURCE_FOLDER/$MODULES_FOLDER does not exist" >&2
    exit 1
fi

docker cp "$SOURCE_FOLDER/$IMG_FOLDER" "$PRESTASHOP_CONTAINER:/var/www/html/"
if [ $? -ne 0 ]; then
    echo "Error while loading a folder $IMG_FOLDER!" >&2
    exit 1
fi

docker cp "$SOURCE_FOLDER/$MODULES_FOLDER" "$PRESTASHOP_CONTAINER:/var/www/html/"
if [ $? -ne 0 ]; then
    echo "Error while loading a folder $MODULES_FOLDER!" >&2
    exit 1
fi

echo "The operation completed successfully."
