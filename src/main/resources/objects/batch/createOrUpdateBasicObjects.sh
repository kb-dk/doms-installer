#!/bin/bash


USER=$FEDORAADMIN$
PASS=$FEDORAADMINPASS$
SERVER=$TOMCAT_SERVERNAME$:$PORTRANGE$80
FEDORA_DIR=$FEDORA_DIR$


#
# Set up basic variables
#
SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null
BASEDIR=$SCRIPT_DIR/..

mkdir $BASEDIR/logs

#
# Ingest initial objects
#
echo "Ingesting base doms objects"
export FEDORA_HOME=$FEDORA_DIR

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/createBasicObjects.xml \
$BASEDIR/logs/createBasicObjects.log \
http false

echo "If the objects were already there, this should have a lot of errors"


echo "Ingesting base radioTV objects"
export FEDORA_HOME=$FEDORA_DIR

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/createRadioTVobjects.xml \
$BASEDIR/logs/createRadioTVobjects.log \
http false

echo "If the objects were already there, this should have a lot of errors"


echo "Updating radioTV objects"
export FEDORA_HOME=$FEDORA_DIR

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/updateRadioTVobjects.xml \
$BASEDIR/logs/updateRadioTVobjects.log \
http false

echo "There should be no errors in this result. If there are, something have failed."






