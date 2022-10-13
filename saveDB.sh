#! /bin/bash

# ***************************************************************************
#  Ce script permet d'exporter des databases MySQL au format sql gzippé.
#  Régis TEDONE <regis.tedone@gmail.com> SYRADEV©2022
# ***************************************************************************

TIMESTAMP=$(date +"%F")
BACKUP_DIR="/home/Your_Path/SQL/$TIMESTAMP"
MYSQL_USER="root"
MYSQL_PASSWORD="Your_Password"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

mkdir -p "$BACKUP_DIR"

dataBases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|mysql|sys|phpmyadmin|information_schema|performance_schema|test)"`

for db in $dataBases; do
  $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --add-drop-database --databases $db | gzip > "$BACKUP_DIR/$db.sql.gz"
done

echo "Export $dataBases OK ;-)"