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
# Import settings
#
source $SCRIPT_DIR/../config/conf.sh

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
# Check for install-folder and potentially create it.
#
TESTBED_DIR=$@
if [ -z "$TESTBED_DIR" ]; then
    echo "install-dir not specified. Bailing out." 1>&2
    usage
fi
if [ -d $TESTBED_DIR ]; then
    echo ""
else
    mkdir -p $TESTBED_DIR
fi
pushd $@ > /dev/null
TESTBED_DIR=$(pwd)
popd > /dev/null
echo "Full path destination: $TESTBED_DIR"

#
# Unpack a tomcat server
#
cp $BASEDIR/data/tomcat/$TOMCATZIP $TESTBED_DIR/
pushd $TESTBED_DIR > /dev/null
unzip -q $TOMCATZIP
mv ${TOMCATZIP%.*} tomcat
rm $TOMCATZIP
popd > /dev/null

#
# Replace the tomcat server.xml with our server.xml
#
pushd $BASEDIR/data/templates > /dev/null
# sed/shell magic below according to  http://www.grymoire.com/Unix/Sed.html
# See section "Passing arguments into a sed script".
sed \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
<server.xml.template >server.xml
mv server.xml $TESTBED_DIR/tomcat/conf/
popd  > /dev/null

#
# Replace the tomcat context.xml with our context.xml
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$BITSTORAGE_SERVER\$|'"$BITSTORAGE_SERVER"'|g' \
<context.xml.template >context.xml
mv context.xml $TESTBED_DIR/tomcat/conf/
popd > /dev/null

#
# Update the tomcat tomcat-users.xml to make it possible to log into the tomcat
# web manager-interface
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
<tomcat-users.xml.template >tomcat-users.xml
mv tomcat-users.xml $TESTBED_DIR/tomcat/conf/
popd > /dev/null

#
# Insert tomcat setenv.sh
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
-e 's|\$TOMCATHOME\$|'"$TESTBED_DIR/tomcat"'|g' \
<setenv.sh.template >setenv.sh
mv setenv.sh $TESTBED_DIR/tomcat/bin/setenv.sh
popd > /dev/null
chmod +x $TESTBED_DIR/tomcat/bin/*.sh

#
# Fix general logging config
#

#
# Install log4j configuration
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$TESTBEDHOME\$|'"$TESTBED_DIR"'|g' \
<log4j.xml.template >log4j.xml
mv log4j.xml $TESTBED_DIR/tomcat/conf/
popd > /dev/null

#
# Insert logappender in lib
#
cp $BASEDIR/logappender/*.jar $TESTBED_DIR/tomcat/lib


#
# Fix the fedora properties
#
export FEDORA_HOME=$TESTBED_DIR/fedora
pushd $BASEDIR/data/templates > /dev/null
if [ $USE_POSTGRESQL == "true" ]; then
  cat fedora.properties.template fedora.properties.postgresql.template > fedora.properties.temp
else
  cat fedora.properties.template fedora.properties.derby.template > fedora.properties.temp
fi
sed \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$INSTALLDIR\$|'"$TESTBED_DIR"'/fedora|g' \
-e 's|\$DATABASE_NAME\$|'"$DATABASE_NAME"'|g' \
-e 's|\$DATABASE_USERNAME\$|'"$DATABASE_USERNAME"'|g' \
-e 's|\$DATABASE_PASSWORD\$|'"$DATABASE_PASSWORD"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
<fedora.properties.temp >fedora.properties
popd > /dev/null
pushd $BASEDIR/data/fedora > /dev/null
java -jar $FEDORAJAR $BASEDIR/data/templates/fedora.properties
rm $BASEDIR/data/templates/fedora.properties
rm $BASEDIR/data/templates/fedora.properties.temp
popd > /dev/null

#
# Install PLANETS
#
# Insert insertToInstall.sh here, to get planets somewhat configured

#
# Deploy Fedora validator hook, and approve file on publish
# TODO: Not pretty forcing stuff into fedora.war
#
pushd $TESTBED_DIR/fedora/install > /dev/null
mkdir -p WEB-INF/lib
cp $BASEDIR/fedoralib/* WEB-INF/lib
zip -d fedora.war WEB-INF/lib/logback-\* WEB-INF/lib/slf4j-api-\*
zip -r -m -u fedora.war WEB-INF/lib
popd > /dev/null



#
# Install Fedora
#
pushd $TESTBED_DIR > /dev/null
cp fedora/install/fedora.war $TESTBED_DIR/tomcat/webapps
popd > /dev/null

#
# Add logappender to Fedora logback configuration
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$BITSTORAGE_SERVER\$|'"$BITSTORAGE_SERVER"'|g' \
<logback.xml.template >$TESTBED_DIR/fedora/server/config/logback.xml
popd > /dev/null

#
# Patch fedora.fcfg with values for hooks and identify
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$BITSTORAGE_SERVER\$|'"$BITSTORAGE_SERVER"'|g' \
<fedora.fcfg.patch.template >$TESTBED_DIR/fedora/server/config/fedora.fcfg.patch
popd > /dev/null
pushd $TESTBED_DIR/fedora/server/config > /dev/null
patch fedora.fcfg < fedora.fcfg.patch
rm fedora.fcfg.patch
popd > /dev/null

# Install custom policies
pushd $BASEDIR/data/policies > /dev/null
mkdir -p $TESTBED_DIR/fedora/data/fedora-xacml-policies/repository-policies
cp -r * $TESTBED_DIR/fedora/data/fedora-xacml-policies/repository-policies/
popd > /dev/null


#
# Fix jaas.conf so that we use the doms auth checker
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$BITSTORAGE_SERVER\$|'"$BITSTORAGE_SERVER"'|g' \
<jaas.conf.template > $TESTBED_DIR/fedora/server/config/jaas.conf
popd > /dev/null


#
# Install into tomcat: webservices
#
cp $BASEDIR/webservices/*.war $TESTBED_DIR/tomcat/webapps


#
# TODO: kill any running tomcats on HTTP port?
#
# netstat -tnlp 2>&1|grep $TOMCATHTTP|grep -o [0-9]*/java|cut -d/ -f1| xargs kill >/dev/null 2>&1

#
# Start the tomcat server
#
$TESTBED_DIR/tomcat/bin/startup.sh
sleep 30

#
# Ingest initial objects
#
sh $TESTBED_DIR/fedora/client/bin/fedora-ingest.sh dir \
$BASEDIR/data/objects \
'info:fedora/fedora-system:FOXML-1.1' \
localhost:${PORTRANGE}80 $FEDORAADMIN $FEDORAADMINPASS http


#
# TODO: Stop tomcat?
#
#$TESTBED_DIR/tomcat/bin/shutdown.sh