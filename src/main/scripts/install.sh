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
SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))
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
if [ -z "$SETENV_SOURCED" ]; then
    source setenv.sh
fi
popd > /dev/null


# Do the ingest of the base objects
$SCRIPT_DIR/install_basic_tomcat.sh $TESTBED_DIR

# Do the big package procedure
$SCRIPT_DIR/package.sh $TESTBED_DIR


#
# Start the tomcat server
#
echo ""
echo "Starting the tomcat server"
$TOMCAT_DIR/bin/startup.sh > /dev/null
sleepSeconds=10
echo "Sleep $sleepSeconds"
sleep $sleepSeconds


# Do the ingest of the base objects
$BASEOBJS_DIR/bin/createAll.sh


SUMMARISE_SOURCE_DIR="$BASEDIR/data/summarise"
CONFIG_TEMP_DIR=$TESTBED_DIR/tmp/config

if [ -e "$SUMMARISE_SOURCE_DIR" ] ; then
    echo "Installing Summa"
    unzip -q "$SUMMARISE_SOURCE_DIR/newspapr-*.zip" -d "$SUMMARISE_DIR"

    mkdir -p "$SUMMA_STORAGE_DIR/data"
    ln -s "$SUMMA_STORAGE_DIR/data" "$SUMMARISE_DIR/data"

    mkdir -p "$SUMMA_STORAGE_DIR/index"
    ln -s "$SUMMA_STORAGE_DIR/index" "$SUMMARISE_DIR/index"

    mkdir -p "$SUMMA_STORAGE_DIR/suggest"
    ln -s "$SUMMA_STORAGE_DIR/suggest" "$SUMMARISE_DIR/suggest"

    mkdir -p "$SUMMA_STORAGE_DIR/storage"
    ln -s "$SUMMA_STORAGE_DIR/storage" "$SUMMARISE_DIR/storage"

    mkdir -p "$SUMMA_STORAGE_DIR/dump"
    ln -s "$SUMMA_STORAGE_DIR/dump" "$SUMMARISE_DIR/dump"

    mkdir -p "$SUMMARISE_DIR/summix-storage/"
    cp "$SUMMARISE_SOURCE_DIR"/summix-*.zip "$SUMMARISE_DIR/summix-storage/"
    cp "$BASEDIR/data/tomcat/"apache-tomcat-*.zip "$SUMMARISE_DIR/"
    echo "Configuring Summa"
    sed -i -e "s/^site.portrange=586$/site.portrange=$SUMMA_PORTRANGE/" "$SUMMARISE_DIR/site.properties"
    cp -v "$CONFIG_TEMP_DIR/storage_newspapr.xml" "$SUMMARISE_DIR/config/storage_newspapr.xml"
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
