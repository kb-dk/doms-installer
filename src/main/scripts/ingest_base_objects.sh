#!/bin/bash

#
# Set up basic variables
#
SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null
BASEDIR=$SCRIPT_DIR/..

#
# Parse command line arguments.
# http://www.shelldorado.com/goodcoding/cmdargs.html
#
while getopts h opt
    do
    case "$opt" in
        h) usage;;
        \?) # unknown flag
             echo "Unrecognised option. Bailing out." 1>&2
             usage;;
    esac
done
shift $(expr $OPTIND - 1)


#
# Import settings
#
source $SCRIPT_DIR/setenv.sh

function replace(){
sed \
-e 's|\$LOG_DIR\$|'"$LOG_DIR"'|g' \
-e 's|\$TOMCAT_DIR\$|'"$TOMCAT_DIR"'|g' \
-e 's|\$FEDORA_DIR\$|'"$FEDORA_DIR"'|g' \
-e 's|\$DATA_DIR\$|'"$DATA_DIR"'|g' \
-e 's|\$CACHE_DIR\$|'"$CACHE_DIR"'|g' \
-e 's|\$TOMCAT_CONFIG_DIR\$|'"$TOMCAT_CONFIG_DIR"'|g' \
-e 's|\$WEBAPPS_DIR\$|'"$WEBAPPS_DIR"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$FEDORAUSER\$|'"$FEDORAUSER"'|g' \
-e 's|\$FEDORAUSERPASS\$|'"$FEDORAUSERPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$POSTGRESQL_DB\$|'"$POSTGRESQL_DB"'|g' \
-e 's|\$POSTGRESQL_USER\$|'"$POSTGRESQL_USER"'|g' \
-e 's|\$POSTGRESQL_PASS\$|'"$POSTGRESQL_PASS"'|g' \
-e 's|\$DATABASE_SYSTEM\$|'"$DATABASE_SYSTEM"'|g' \
<$1 > $2
}


for file in $BASEDIR/data/objects/batch/* ; do
  replace $file $file.ready
  echo "Created batch file $file.ready from template file $file"
done

#
# Ingest initial objects
#
echo "Ingesting base objects"
export FEDORA_HOME=$FEDORA_DIR

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
localhost:${PORTRANGE}80 $FEDORAADMIN $FEDORAADMINPASS \
$BASEDIR/data/objects/batch/createBasicObjects.xml.ready \
$BASEDIR/data/objects/batch/createBasicObjects.log \
http false

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
localhost:${PORTRANGE}80 $FEDORAADMIN $FEDORAADMINPASS \
$BASEDIR/data/objects/batch/createRadioTVobjects.xml.ready \
$BASEDIR/data/objects/batch/createRadioTVobjects.log \
http false


rm $BASEDIR/data/objects/batch/*.ready


