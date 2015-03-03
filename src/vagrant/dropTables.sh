#!/bin/bash

PGUSER=domsFieldSearch
PGDB=domsFieldSearch
PGPASSWORD=domsFieldSearchPass psql -U $PGUSER $PGDB -h localhost -t -c "select 'drop table \"' || tablename || '\" cascade;' from pg_tables where schemaname = 'public'"  | PGPASSWORD=domsFieldSearchPass psql -U domsFieldSearch domsFieldSearch -h localhost

