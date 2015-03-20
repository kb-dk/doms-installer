#!/bin/bash

function drop(){
PGPASSWORD=$2 psql -U $1 $3 -h localhost -t -c "select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname = 'public'"  | PGPASSWORD=$2 psql -U $1 $3 -h localhost
}


killall -9 java
drop domsFieldSearch domsFieldSearchPass domsFieldSearch
drop domsMPT domsMPTPass domsTripleStore
rm -rf ~/7880-d*