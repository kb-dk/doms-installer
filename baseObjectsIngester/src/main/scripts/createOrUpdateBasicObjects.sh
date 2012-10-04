#!/bin/bash


SCRIPT_DIR=$(dirname $(readlink -f $0))

BASEDIR=$SCRIPT_DIR/..

source $SCRIPT_DIR/setenv.sh


mkdir $BASEDIR/logs  >/dev/null 2>&1

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


echo "UPDATING base doms objects"


sh $FEDORA_DIR/client/bin/fedora-modify.sh \
$SERVER $USER $PASS \
$BASEDIR/scripts/updateBasicObjects.xml \
$BASEDIR/logs/updateBasicObjects.log \
http false

echo "There should be no errors in this result. If there are, something has failed."
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

echo "There should be no errors in this result. If there are, something has failed."
echo ""
echo ""


bash $SCRIPT_DIR/updateRadioTVLicense.sh



