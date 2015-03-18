#!/bin/bash

PGUSER=domsFieldSearch
PGPASS=domsFieldSearchPass
PGDB=domsFieldSearch

function drop(){
PGPASSWORD=$2 psql -U $1 $3 -h localhost -t -c "select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname = 'public'"  | PGPASSWORD=$2 psql -U $1 $3 -h localhost
}

drop $PGUSER $PGPASS $PGDB


