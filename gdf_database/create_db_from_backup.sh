#!/bin/bash
# Script to restore a backup to a database on local PostGIS database server

if [ $# -ne 2 ]
then
  echo "Usage: $0 <db_name> <db_backup_file>"
  exit 1
fi

dbname=$1
db_backup_file=$2

# Set default username & password
export PGUSER=cube_admin
export PGPASSWORD='GAcube!'
export PGHOST=localhost

# Create new database ${dbname}
psql -d postgres -c "
CREATE DATABASE ${dbname}
  WITH OWNER = cube_admin
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;"

psql -d ${dbname} -c "
ALTER DATABASE ${dbname}
  SET search_path = "\"$USER\"",public, topology;

COMMENT ON DATABASE ${dbname}
  IS 'GDF Database with Landsat & MOD09 configuration data only';"

# Restore DB from backup
pg_restore -d ${dbname} ${db_backup_file}

psql -d ${dbname} -c "vacuum analyze"
