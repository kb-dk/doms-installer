#!/bin/bash

# $Id install.sh $
# $Author$
# $Date:   2008-08-21$
#
# Script for installing the testbed
#

#
# Check whether $1 is set
#
if [ -z "$1" ] ; then
    echo "Usage: $0 <install_dir> [<data_dir>]"
    exit 1
fi

#
# Detect Java version
#
if [ -z "$JAVA_HOME" ] ; then
    JAVA_EXEC=java
else
    JAVA_EXEC="$JAVA_HOME/bin/java"
fi


#
# Set up basic variables
#
SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null
BASEDIR=$SCRIPT_DIR/..



#
# Import settings
#
pushd $SCRIPT_DIR > /dev/null
source common.sh
popd > /dev/null

parseTestbedDir "$@"

parseDataDir "$@"


pushd $SCRIPT_DIR > /dev/null
source setenv.sh
popd > /dev/null


# Do the ingest of the base objects
$SCRIPT_DIR/install_basic_tomcat.sh $TESTBED_DIR

# Do the big package procedure
$SCRIPT_DIR/package.sh $TESTBED_DIR

#Relink the data dir

if [ -z "$DATA_DIR" ]; then
    rm -r $TESTBED_DIR/data
    mkdir -p $DATA_DIR/data
    ln -s $DATA_DIR/data $TESTBED_DIR/data

    rm -r $TESTBED_DIR/cache
    mkdir -p $DATA_DIR/cache
    ln -s $DATA_DIR/cache $TESTBED_DIR/cache
fi


#
# Start the tomcat server
#
echo ""
echo "Starting the tomcat server"
$TOMCAT_DIR/bin/startup.sh > /dev/null
echo "Sleep 30"
sleep 30

# Do the ingest of the base objects
$BASEOBJS_DIR/bin/createBasicObjects.sh
$BASEOBJS_DIR/bin/createRadioTVObjects.sh


SUMMARISE_SOURCE_DIR="$BASEDIR/data/summarise"
SUMMARISE_DIR="$TESTBED_DIR/summarise"

if [ -e "$SUMMARISE_SOURCE_DIR" ] ; then
    echo "Installing Summa"
    unzip -q "$SUMMARISE_SOURCE_DIR/domsgui-*.zip" -d "$SUMMARISE_DIR"
    mkdir -p "$SUMMARISE_DIR/index"
    mkdir -p "$SUMMARISE_DIR/suggest"
    mkdir "$SUMMARISE_DIR/summix-storage/"
    cp "$SUMMARISE_SOURCE_DIR"/summix-*.zip "$SUMMARISE_DIR/summix-storage/"
    cp "$BASEDIR/data/tomcat/"apache-tomcat-*.zip "$SUMMARISE_DIR/"
    echo "Configuring Summa"
    sed -i -e "s/^site.portrange=576$/site.portrange=$SUMMA_PORTRANGE/" "$SUMMARISE_DIR/site.properties"
    sed -i -e "s%http://localhost:7880/centralWebservice-service/central/?wsdl%http://localhost:${PORTRANGE}80/centralWebservice-service/central/?wsdl%g" \
            "$SUMMARISE_DIR/config/storage_domsgui.xml"
    echo "Running Summa installer"
    pushd "$SUMMARISE_DIR" > /dev/null
    VERBOSE=1 "$SUMMARISE_DIR"/bin/all.sh
    popd > /dev/null
fi

BIN_DIR="$TESTBED_DIR/bin"
echo "Creating control script in $BIN_DIR"
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR"/doms.sh "$BIN_DIR/"

echo "Install complete"
