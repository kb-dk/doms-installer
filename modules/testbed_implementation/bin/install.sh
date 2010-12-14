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


function replace(){
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
-e 's|\$TESTBED_DIR\$|'"$TESTBED_DIR"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$BITSTORAGE_SERVER\$|'"$BITSTORAGE_SERVER"'|g' \
-e 's|\$INSTALLDIR\$|'"$TESTBED_DIR"'/fedora|g' \
-e 's|\$DATABASE_NAME\$|'"$DATABASE_NAME"'|g' \
-e 's|\$DATABASE_USERNAME\$|'"$DATABASE_USERNAME"'|g' \
-e 's|\$DATABASE_PASSWORD\$|'"$DATABASE_PASSWORD"'|g' \
<$1 > $2
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
# Configuring all the doms config files
#
echo "Creating config files from conf.sh"
mkdir $TESTBED_DIR/config
replace $BASEDIR/data/templates/server.xml.template           $TESTBED_DIR/config/server.xml
replace $BASEDIR/data/templates/context.xml.template          $TESTBED_DIR/config/context.xml
replace $BASEDIR/data/templates/ipRangesAndRoles.xml.template $TESTBED_DIR/config/ipRangesAndRoles.xml
replace $BASEDIR/data/templates/tomcat-users.xml.template     $TESTBED_DIR/config/tomcat-users.xml
#replace $BASEDIR/data/templates/log4j.xml.template            $TESTBED_DIR/config/log4j.xml
replace $BASEDIR/data/templates/fedora.properties.template    $TESTBED_DIR/config/fedora.properties
replace $BASEDIR/data/templates/fedora.properties.derby.template $TESTBED_DIR/config/fedora.properties.derby
replace $BASEDIR/data/templates/fedora.properties.postgresql.template $TESTBED_DIR/config/fedora.properties.postgresql
replace $BASEDIR/data/templates/logback.xml.template          $TESTBED_DIR/config/logback.xml
replace $BASEDIR/data/templates/fedora.fcfg.patch.template    $TESTBED_DIR/config/fedora.fcfg.patch
replace $BASEDIR/data/templates/jaas.conf.template            $TESTBED_DIR/config/jaas.conf
replace $BASEDIR/data/templates/setenv.sh.template            $TESTBED_DIR/config/setenv.sh
replace $BASEDIR/data/templates/fedoraWebXmlInsert.xml.template            $TESTBED_DIR/config/fedoraWebXmlInsert.xml


##
##  Set up the tomcat
##
echo ""
echo "TOMCAT INSTALL"
echo ""
echo "Unpacking the tomcat server"
# Unpack a tomcat server
cp $BASEDIR/data/tomcat/$TOMCATZIP $TESTBED_DIR/
pushd $TESTBED_DIR > /dev/null
unzip -q $TOMCATZIP
mv ${TOMCATZIP%.*} tomcat
rm $TOMCATZIP
popd > /dev/null

echo "Configuring the tomcat"
# Replace the tomcat server.xml with our server.xml
cp $TESTBED_DIR/config/server.xml $TESTBED_DIR/tomcat/conf/server.xml

# Replace the tomcat context.xml with our context.xml
cp $TESTBED_DIR/config/context.xml $TESTBED_DIR/tomcat/conf/context.xml

# Add the iprolemapper config file to the tomcat
cp $TESTBED_DIR/config/ipRangesAndRoles.xml $TESTBED_DIR/tomcat/conf/ipRangesAndRoles.xml

# Update the tomcat tomcat-users.xml to make it possible to log into the tomcat
# web manager-interface
cp $TESTBED_DIR/config/tomcat-users.xml $TESTBED_DIR/tomcat/conf/tomcat-users.xml

# Insert tomcat setenv.sh
cp $TESTBED_DIR/config/setenv.sh $TESTBED_DIR/tomcat/bin/setenv.sh
chmod +x $TESTBED_DIR/tomcat/bin/*.sh

# Install log4j configuration
cp $TESTBED_DIR/config/log4j.xml $TESTBED_DIR/tomcat/conf/log4j.xml

# Insert logappender in lib
cp $BASEDIR/logappender/*.jar $TESTBED_DIR/tomcat/lib

echo "Tomcat setup is now done"
## Tomcat is now done


echo ""
echo "WEBSERVICE INSTALL"
echo ""
##
## Install the doms webservices
##
echo "Installing the doms webservices into tomcat"
cp -v $BASEDIR/webservices/*.war $TESTBED_DIR/tomcat/webapps


##
## Install Fedora
##
echo ""
echo "INSTALLING FEDORA"
echo ""

echo "Configuring fedora preinstall"
# Fix the fedora properties
pushd $TESTBED_DIR/config > /dev/null
if [ $USE_POSTGRESQL == "true" ]; then
  cat fedora.properties fedora.properties.postgresql > fedora.properties.temp
else
  cat fedora.properties fedora.properties.derby > fedora.properties.temp
fi
popd > /dev/null

# Install Fedora
echo "Installing Fedora"
pushd $BASEDIR/data/fedora > /dev/null
java -jar $FEDORAJAR $TESTBED_DIR/config/fedora.properties.temp  > /dev/null
rm $TESTBED_DIR/config/fedora.properties.temp
popd > /dev/null


# Deploy stuff from fedoralib
echo "Repacking Fedora war files with changes"
pushd $TESTBED_DIR/fedora/install/fedorawar > /dev/null
mkdir -p WEB-INF/lib

cp $BASEDIR/fedoralib/* WEB-INF/lib
sed '/<\/web-app>/d' < WEB-INF/web.xml > /tmp/fedoraweb.xml
cat $BASEDIR/config/fedoraWebXmlInsert.xml >> /tmp/fedoraweb.xml
echo "</web-app>" >> /tmp/fedoraweb.xml
cp /tmp/fedoraweb.xml WEB-INF/web.xml

mv ../fedora.war ../fedora_original.war
zip -r ../fedora.war * 
popd > /dev/null



echo "Install fedora.war into tomcat"
cp $TESTBED_DIR/fedora/install/fedora.war $TESTBED_DIR/tomcat/webapps

echo "Configuring fedora postinstall"
# Add logappender to Fedora logback configuration
cp $TESTBED_DIR/config/logback.xml $TESTBED_DIR/fedora/server/config/logback.xml

# Patch fedora.fcfg with values for hooks and identify
cp $TESTBED_DIR/config/fedora.fcfg.patch $TESTBED_DIR/fedora/server/config/fedora.fcfg.patch
pushd $TESTBED_DIR/fedora/server/config > /dev/null
patch fedora.fcfg < fedora.fcfg.patch
rm fedora.fcfg.patch
popd > /dev/null

# Install custom policies
mkdir -p $TESTBED_DIR/fedora/data/fedora-xacml-policies/repository-policies
cp -r $BASEDIR/data/policies/* $TESTBED_DIR/fedora/data/fedora-xacml-policies/repository-policies/

# Fix jaas.conf so that we use the doms auth checker
cp $TESTBED_DIR/config/jaas.conf $TESTBED_DIR/fedora/server/config/jaas.conf

echo "Fedora setup complete"




#
# Start the tomcat server
#
echo ""
echo "Starting the tomcat server"
$TESTBED_DIR/tomcat/bin/startup.sh > /dev/null
echo "Sleep 30"
sleep 30

#
# Ingest initial objects
#
echo "Ingesting base objects"
export FEDORA_HOME=$TESTBED_DIR/fedora
sh $TESTBED_DIR/fedora/client/bin/fedora-ingest.sh dir \
$BASEDIR/data/objects \
'info:fedora/fedora-system:FOXML-1.1' \
localhost:${PORTRANGE}80 $FEDORAADMIN $FEDORAADMINPASS http

echo "Install complete"