#!/bin/bash

TOMCATZIP=`basename $BASEDIR/data/tomcat/*.zip`
FEDORAJAR=`basename $BASEDIR/data/fedora/*.jar`

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
TOMCAT_SERVERNAME=localhost

FEDORAADMIN=fedoraAdmin
FEDORAADMINPASS=fedoraAdminPass

FEDORAUSER=fedoraReadOnlyAdmin
FEDORAUSERPASS=fedoraReadOnlyPass

# The folders
TOMCAT_DIR=$TESTBED_DIR/tomcat

LOG_DIR=$TOMCAT_DIR/logs

FEDORA_DIR=$TESTBED_DIR/services/fedora

DATA_DIR=$TESTBED_DIR/data

CACHE_DIR=$TESTBED_DIR/cache

TOMCAT_CONFIG_DIR=$TESTBED_DIR/services/conf

WEBAPPS_DIR=$TESTBED_DIR/services/webapps
TOMCAT_APPS_DIR=$TESTBED_DIR/services/tomcatapps


#Database
USE_POSTGRESQL=true
POSTGRESQL_DB=doms-test$PORTRANGE
POSTGRESQL_USER=doms-test$PORTRANGE
POSTGRESQL_PASS=doms-test$PORTRANGE

#Bitstorage
BITFINDER=http://bitfinder.statsbiblioteket.dk/
BITSTORAGE_SCRIPT="ssh doms@stage01 bin/server.sh"
