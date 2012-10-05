#!/bin/bash

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
