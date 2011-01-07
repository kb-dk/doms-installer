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
-e 's|\$LOG_DIR\$|'"$LOG_DIR"'|g' \
-e 's|\$TOMCAT_DIR\$|'"$TOMCAT_DIR"'|g' \
-e 's|\$FEDORA_DIR\$|'"$FEDORA_DIR"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$TOMCATMANAGER\$|'"$TOMCATMANAGER"'|g' \
-e 's|\$TOMCATMANAGERPASS\$|'"$TOMCATMANAGERPASS"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$FEDORAUSER\$|'"$FEDORAUSER"'|g' \
-e 's|\$FEDORAUSERPASS\$|'"$FEDORAUSERPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$BITSTORAGE_SERVER\$|'"$BITSTORAGE_SERVER"'|g' \
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


CONFIG_DIR=`mktemp -d`


#
# Configuring all the doms config files
#
echo "Creating config files from conf.sh"
for file in $BASEDIR/data/templates/*.template ; do
  newfile1=`basename $file`;
  newfile2=$CONFIG_DIR/${newfile1%.template};
  replace $file $newfile2
  echo "Created config file $newfile2 from template file $file"
done


##
##  Set up the tomcat
##
echo ""
echo "TOMCAT INSTALL"
echo ""

echo "Configuring the tomcat"
mkdir -p $TOMCAT_DIR/conf/
mkdir -p $TOMCAT_DIR/bin/
mkdir -p $TOMCAT_DIR/webapps/

# Replace the tomcat server.xml with our server.xml
cp -v $CONFIG_DIR/server.xml $TOMCAT_DIR/conf/server.xml


# Replace the tomcat context.xml with our context.xml
cp -v $CONFIG_DIR/context.xml $TOMCAT_DIR/conf/context.xml


# Add the iprolemapper config file to the tomcat
cp -v $CONFIG_DIR/ipRangesAndRoles.xml $TOMCAT_DIR/conf/ipRangesAndRoles.xml


# Update the tomcat tomcat-users.xml to make it possible to log into the tomcat
# web manager-interface
cp -v $CONFIG_DIR/tomcat-users.xml $TOMCAT_DIR/conf/tomcat-users.xml


# Insert tomcat setenv.sh
cp -v $CONFIG_DIR/setenv.sh $TOMCAT_DIR/bin/setenv.sh
chmod +x $TOMCAT_DIR/bin/*.sh


# Install log4j configuration
cp -v $CONFIG_DIR/log4j.*.xml $TOMCAT_DIR/conf


# Set the session timeout to 1 min
cp -v $CONFIG_DIR/web.xml $TOMCAT_DIR/conf


echo "Tomcat setup is now done"
## Tomcat is now done


echo ""
echo "WEBSERVICE INSTALL"
echo ""
##
## Install the doms webservices
##
echo "Installing the doms webservices into tomcat"
cp -v $BASEDIR/webservices/*.war $TOMCAT_DIR/webapps


##
## Install Fedora
##
echo ""
echo "INSTALLING FEDORA"
echo ""

echo "Configuring fedora preinstall"
# Fix the fedora properties
pushd $CONFIG_DIR > /dev/null
if [ $USE_POSTGRESQL == "true" ]; then
  cat fedora.properties fedora.properties.postgresql > fedora.properties.temp
else
  cat fedora.properties fedora.properties.derby > fedora.properties.temp
fi
popd > /dev/null

# Install Fedora
echo "Installing Fedora"
pushd $BASEDIR/data/fedora > /dev/null
java -jar $FEDORAJAR $CONFIG_DIR/fedora.properties.temp  > /dev/null
rm $CONFIG_DIR/fedora.properties.temp
popd > /dev/null


# Deploy stuff from fedoralib
echo "Repacking Fedora war files with changes"
pushd $FEDORA_DIR/install/fedorawar > /dev/null
mkdir -p WEB-INF/lib

cp $BASEDIR/fedoralib/* WEB-INF/lib
sed '/<\/web-app>/d' < WEB-INF/web.xml > /tmp/fedoraweb.xml
cat $CONFIG_DIR/fedoraWebXmlInsert.xml >> /tmp/fedoraweb.xml
echo "</web-app>" >> /tmp/fedoraweb.xml
cp /tmp/fedoraweb.xml WEB-INF/web.xml

mv ../fedora.war ../fedora_original.war
zip -r ../fedora.war *    > /dev/null
popd > /dev/null



echo "Install fedora.war into tomcat"
cp -v $FEDORA_DIR/install/fedora.war $TOMCAT_DIR/webapps

echo "Configuring fedora postinstall"
# Add logappender to Fedora logback configuration
cp -v $CONFIG_DIR/logback.xml $FEDORA_DIR/server/config/logback.xml

# Patch fedora.fcfg with values for hooks and identify
cp $CONFIG_DIR/fedora.fcfg.patch $FEDORA_DIR/server/config/fedora.fcfg.patch
pushd $FEDORA_DIR/server/config > /dev/null
patch fedora.fcfg < fedora.fcfg.patch
rm fedora.fcfg.patch
popd > /dev/null

# Install custom policies
mkdir -p $FEDORA_DIR/data/fedora-xacml-policies/repository-policies
cp -rv $BASEDIR/data/policies/* $FEDORA_DIR/data/fedora-xacml-policies/repository-policies/

# Fix jaas.conf so that we use the doms auth checker
cp -v $CONFIG_DIR/jaas.conf $FEDORA_DIR/server/config/jaas.conf

# Setup the custom users
cp -v $CONFIG_DIR/fedora-users.xml $FEDORA_DIR/server/config/fedora-users.xml


echo "Fedora setup complete"

rm -rf $CONFIG_DIR > /dev/null

echo "Install complete"