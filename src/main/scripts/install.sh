#!/bin/bash

# $Id install.sh $
# $Author$
# $Date:   2008-08-21$
#
# Script for installing the testbed
#

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
$SCRIPT_DIR/ingest_base_objects.sh $TESTBED_DIR


echo "Install complete"