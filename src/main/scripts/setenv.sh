#!/bin/bash

TOMCATZIP=`basename $BASEDIR/data/tomcat/*.zip`
FEDORAJAR=`basename $BASEDIR/data/fedora/*.jar`
INGESTERZIP=`basename $BASEDIR/ingester/*.zip`

#
# Check for install-folder and potentially create it.
#
TESTBED_DIR=$@
if [ -z "$TESTBED_DIR" ]; then
    echo "install-dir not specified. Bailing out." 1>&2
    usage
fi
if [ -d $TESTBED_DIR ]; then
    echo ""
else
    mkdir -p $TESTBED_DIR
fi
pushd $@ > /dev/null
TESTBED_DIR=$(pwd)
popd > /dev/null

# The normal config values
PORTRANGE=78
SUMMA_PORTRANGE=576
TOMCAT_SERVERNAME=localhost

FEDORAADMIN=fedoraAdmin
FEDORAADMINPASS=fedoraAdminPass

FEDORAUSER=fedoraReadOnlyAdmin
FEDORAUSERPASS=fedoraReadOnlyPass

# The folders
TOMCAT_DIR=$TESTBED_DIR/tomcat

LOG_DIR=$TOMCAT_DIR/logs

SERVICES_DIR=$TESTBED_DIR/services


FEDORA_DIR=$SERVICES_DIR/fedora

SCHEMA_DIR=$SERVICES_DIR/schemas

TOMCAT_CONFIG_DIR=$SERVICES_DIR/conf

WEBAPPS_DIR=$SERVICES_DIR/webapps

TOMCAT_APPS_DIR=$SERVICES_DIR/tomcat-apps


INGEST_DIR=$TESTBED_DIR/ingester

DATA_DIR=$TESTBED_DIR/data

CACHE_DIR=$TESTBED_DIR/cache

BASEOBJS_DIR=$TESTBED_DIR/baseObjectsIngest

DOCS_DIR=$TESTBED_DIR/docs

#Database
#USE_POSTGRESQL=true
POSTGRESQL_DB=doms-test$PORTRANGE
POSTGRESQL_USER=doms-test$PORTRANGE
POSTGRESQL_PASS=doms-test$PORTRANGE

#Bitstorage
BITFINDER=http://bitfinder.statsbiblioteket.dk/
BITSTORAGE_SCRIPT="ssh doms@stage01 bin/server.sh"
