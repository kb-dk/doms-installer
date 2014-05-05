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


SBOI_SUMMARISE_SOURCE_DIR="$BASEDIR/data/sboi-summarise"
DOMSGUI_SUMMARISE_SOURCE_DIR="$BASEDIR/data/domsgui-summarise"
CONFIG_TEMP_DIR=$TESTBED_DIR/tmp/config

if [ -e "$SBOI_SUMMARISE_SOURCE_DIR" ] ; then
    echo "Installing SBOI Summa"
    unzip -q "$SBOI_SUMMARISE_SOURCE_DIR/newspapr-*.zip" -d "$SBOI_SUMMARISE_DIR"

    mkdir -p "$SBOI_SUMMA_STORAGE_DIR/data"
    ln -s "$SBOI_SUMMA_STORAGE_DIR/data" "$SBOI_SUMMARISE_DIR/data"

    mkdir -p "$SBOI_SUMMA_STORAGE_DIR/index"
    ln -s "$SBOI_SUMMA_STORAGE_DIR/index" "$SBOI_SUMMARISE_DIR/index"

    mkdir -p "$SBOI_SUMMA_STORAGE_DIR/suggest"
    ln -s "$SBOI_SUMMA_STORAGE_DIR/suggest" "$SBOI_SUMMARISE_DIR/suggest"

    mkdir -p "$SBOI_SUMMA_STORAGE_DIR/storage"
    ln -s "$SBOI_SUMMA_STORAGE_DIR/storage" "$SBOI_SUMMARISE_DIR/storage"

    mkdir -p "$SBOI_SUMMA_STORAGE_DIR/dump"
    ln -s "$SBOI_SUMMA_STORAGE_DIR/dump" "$SBOI_SUMMARISE_DIR/dump"

    mkdir -p "$SBOI_SUMMARISE_DIR/summix-storage/"
    cp "$SBOI_SUMMARISE_SOURCE_DIR"/summix-*.zip "$SBOI_SUMMARISE_DIR/summix-storage/"
    cp "$BASEDIR/data/tomcat/"apache-tomcat-*.zip "$SBOI_SUMMARISE_DIR/"
    echo "Configuring SBOI Summa"
    sed -i -e "s/^site.portrange=586$/site.portrange=$SBOI_SUMMA_PORTRANGE/" "$SBOI_SUMMARISE_DIR/site.properties"
    cp -v "$CONFIG_TEMP_DIR/storage_newspapr.xml" "$SBOI_SUMMARISE_DIR/config/storage_newspapr.xml"
    echo "Running SBOI Summa installer"
    pushd "$SBOI_SUMMARISE_DIR" > /dev/null
    VERBOSE=1 "$SBOI_SUMMARISE_DIR"/bin/all.sh
    popd > /dev/null
fi

if [ -e "$DOMSGUI_SUMMARISE_SOURCE_DIR" ] ; then
    echo "Installing DOMSGUI Summa"
    unzip -q "$DOMSGUI_SUMMARISE_SOURCE_DIR/domsgui-*.zip" -d "$DOMSGUI_SUMMARISE_DIR"

    mkdir -p "$DOMSGUI_SUMMA_STORAGE_DIR/data"
    ln -s "$DOMSGUI_SUMMA_STORAGE_DIR/data" "$DOMSGUI_SUMMARISE_DIR/data"

    mkdir -p "$DOMSGUI_SUMMA_STORAGE_DIR/index"
    ln -s "$DOMSGUI_SUMMA_STORAGE_DIR/index" "$DOMSGUI_SUMMARISE_DIR/index"

    mkdir -p "$DOMSGUI_SUMMA_STORAGE_DIR/suggest"
    ln -s "$DOMSGUI_SUMMA_STORAGE_DIR/suggest" "$DOMSGUI_SUMMARISE_DIR/suggest"

    mkdir -p "$DOMSGUI_SUMMA_STORAGE_DIR/storage"
    ln -s "$DOMSGUI_SUMMA_STORAGE_DIR/storage" "$DOMSGUI_SUMMARISE_DIR/storage"

    mkdir -p "$DOMSGUI_SUMMA_STORAGE_DIR/dump"
    ln -s "$DOMSGUI_SUMMA_STORAGE_DIR/dump" "$DOMSGUI_SUMMARISE_DIR/dump"

    mkdir -p "$DOMSGUI_SUMMARISE_DIR/summix-storage/"
    cp "$DOMSGUI_SUMMARISE_SOURCE_DIR"/summix-*.zip "$DOMSGUI_SUMMARISE_DIR/summix-storage/"
    cp "$BASEDIR/data/tomcat/"apache-tomcat-*.zip "$DOMSGUI_SUMMARISE_DIR/"
    echo "Configuring DOMSGUI Summa"
    sed -i -e "s/^site.portrange=576$/site.portrange=$DOMSGUI_SUMMA_PORTRANGE/" "$DOMSGUI_SUMMARISE_DIR/site.properties"
    cp -v "$CONFIG_TEMP_DIR/storage_domsgui.xml" "$DOMSGUI_SUMMARISE_DIR/config/storage_domsgui.xml"
    echo "Running DOMSGUI Summa installer"
    pushd "$DOMSGUI_SUMMARISE_DIR" > /dev/null
    VERBOSE=1 "$DOMSGUI_SUMMARISE_DIR"/bin/all.sh
    popd > /dev/null
fi


BIN_DIR="$TESTBED_DIR/bin"
echo "Creating control script in $BIN_DIR"
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR"/doms.sh "$BIN_DIR/"

echo "Install complete"
