#!/bin/bash

# $Id install.sh $
# $Author$
# $Date:   2008-08-21$
#
# Script for installing the testbed
#
# USAGE: After unpacking, edit config/conf.sh to suit your needs, run
# bin/create_build_environment, then run this script.

function usage() {
    echo ""
    echo -n "Usage: install.sh  <install-dir>"
    echo ""
    exit 1
}




#
# Set up basic variables
#
SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null
BASEDIR=$SCRIPT_DIR/..

TOMCATZIP=`basename $BASEDIR/data/tomcat/*.zip`
FEDORAJAR=`basename $BASEDIR/data/fedora/*.jar`


#
# Parse command line arguments.
# http://www.shelldorado.com/goodcoding/cmdargs.html
#
while getopts h opt
    do
    case "$opt" in
        h) usage;;
        \?) # unknown flag
             echo "Unrecognised option. Bailing out." 1>&2
             usage;;
    esac
done
shift $(expr $OPTIND - 1)


#
# Import settings
#
source $SCRIPT_DIR/../config/conf.sh




##
##  Set up the tomcat
##
echo ""
echo "TOMCAT INSTALL"
echo ""
echo "Unpacking the tomcat server"
# Unpack a tomcat server
TEMPDIR=`mktemp -d`
cp $BASEDIR/data/tomcat/$TOMCATZIP $TEMPDIR
pushd $TEMPDIR > /dev/null
unzip -q -n $TOMCATZIP
mv ${TOMCATZIP%.*} $TOMCAT_DIR
popd > /dev/null
rm -rf $TEMPDIR > /dev/null

echo "Tomcat setup is now done"
## Tomcat is now done

$SCRIPT_DIR/package.sh $TESTBED_DIR

#
# Start the tomcat server
#
echo ""
echo "Starting the tomcat server"
$TOMCAT_DIR/bin/startup.sh > /dev/null
echo "Sleep 30"
sleep 30

#
# Ingest initial objects
#
echo "Ingesting base objects"
export FEDORA_HOME=$FEDORA_DIR
sh $FEDORA_DIR/client/bin/fedora-ingest.sh dir \
$BASEDIR/data/objects \
'info:fedora/fedora-system:FOXML-1.1' \
localhost:${PORTRANGE}80 $FEDORAADMIN $FEDORAADMINPASS http

echo "Install complete"