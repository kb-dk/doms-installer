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
echo "Updating Radio Tv License object from $BASEDIR/scripts/updateRadioTVLicense.xml"
export FEDORA_HOME=$FEDORA_DIR

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/updateRadioTVLicense.xml \
$BASEDIR/logs/updateRadioTVLicense.log \
http false

echo "There should be no errors in this result. If there are, something have failed."






