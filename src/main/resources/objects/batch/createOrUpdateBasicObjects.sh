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


mkdir $BASEDIR/logs

#
# Ingest initial objects
#
echo "INGESTING base doms objects"

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/createBasicObjects.xml \
$BASEDIR/logs/createBasicObjects.log \
http false

echo "If the objects were already there, this should have a lot of errors"
echo ""
echo ""


echo "INGESTING base radioTV objects"

sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/createRadioTVobjects.xml \
$BASEDIR/logs/createRadioTVobjects.log \
http false

echo "If the objects were already there, this should have a lot of errors"
echo ""
echo ""


echo "UPDATING radioTV objects"


sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/updateRadioTVobjects.xml \
$BASEDIR/logs/updateRadioTVobjects.log \
http false

echo "There should be no errors in this result. If there are, something have failed."


updateRadioTVLicense.sh



