#!/bin/bash

#
# Set up basic variables
#
SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null
BASEDIR=$SCRIPT_DIR/..

source $SCRIPT_DIR/setenv.sh

mkdir $BASEDIR/logs >/dev/null 2>&1

#
# Ingest initial objects
#
echo "UPDATING Radio Tv License object from $BASEDIR/scripts/updateRadioTVLicense.xml"


sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/updateRadioTVLicense.xml \
$BASEDIR/logs/updateRadioTVLicense.log \
http false

echo "There should be no errors in this result. If there are, something have failed."






