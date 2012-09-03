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
    echo "Usage: $0 <install_dir>"
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

"$JAVA_EXEC" -version 2>&1|grep "1\.6\.0" > /dev/null

if [ $? -ne 0 ] ; then
    echo "This package only supports Java 1.6"
    exit 2
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
source $SCRIPT_DIR/setenv.sh

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
echo "Sleep 30"
sleep 30

# Do the ingest of the base objects
$BASEOBJS_DIR/bin/createOrUpdateBasicObjects.sh

SUMMARISE_SOURCE_DIR="$BASEDIR/data/summarise"
SUMMARISE_DIR="$TESTBED_DIR/summarise"

if [ -e "$SUMMARISE_SOURCE_DIR" ] ; then
    echo "Installing Summa"
    unzip -q "$SUMMARISE_SOURCE_DIR/domsgui-*-test.zip" -d "$SUMMARISE_DIR"
    mkdir -p "$SUMMARISE_DIR/index"
    mkdir -p "$SUMMARISE_DIR/suggest"
    cp "$SUMMARISE_SOURCE_DIR"/summix-*.zip "$SUMMARISE_DIR/summix-storage/"
    cp "$BASEDIR/data/tomcat/"apache-tomcat-*.zip "$SUMMARISE_DIR/"
    echo "Configuring Summa"
    sed -ie "s/^site.portrange=576$/site.portrange=$SUMMA_PORTRANGE/" "$SUMMARISE_DIR/site.properties"
    echo "Running Summa installer"
    VERBOSE=1 "$SUMMARISE_DIR"/bin/all.sh
fi

echo "Install complete"
