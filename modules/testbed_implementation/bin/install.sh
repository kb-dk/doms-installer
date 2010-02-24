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
-e 's|\$TOMCATHTTP\$|'"$TOMCAT_HTTPPORT"'|g' \
-e 's|\$TOMCATSSL\$|'"$TOMCAT_SSLPORT"'|g' \
-e 's|\$TOMCATAJP\$|'"$TOMCAT_AJPPORT"'|g' \
-e 's|\$TOMCATSHUTDOWN\$|'"$TOMCAT_SHUTDOWNPORT"'|g' \
<server.xml.template >server.xml
mv server.xml $TESTBED_DIR/tomcat/conf/
popd  > /dev/null

#
# Replace the tomcat context.xml with our context.xml
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAHOME\$|'"$TESTBED_DIR/fedora"'|g' \
<context.xml.template >context.xml
mv context.xml $TESTBED_DIR/tomcat/conf/
popd > /dev/null

#
# Update the tomcat tomcat-users.xml to make login possible
#
# Make it possible to log into the tomcat web manager-interface
# TODO: Consider using a template for consistency
pushd $TESTBED_DIR/tomcat/conf > /dev/null
cp tomcat-users.xml tomcat-users-backup.xml
sed \
-e 's|<tomcat-users>|<tomcat-users>\
<role rolename="manager"/>\
<user username="tomcat" password="tomcat" roles="manager"/>|g' \
<tomcat-users-backup.xml >tomcat-users.xml
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
# Install log4j configuration
#
cp $BASEDIR/data/templates/log4j.xml $TESTBED_DIR/tomcat/conf/

#
# Install fedora including database
#
pushd $BASEDIR/data/templates > /dev/null
sed \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$INSTALLDIR\$|'"$TESTBED_DIR"'/fedora|g' \
<fedora.properties.template >fedora.properties
popd > /dev/null
pushd $BASEDIR/data/fedora > /dev/null
java -jar $FEDORAJAR $BASEDIR/data/templates/fedora.properties
rm $BASEDIR/data/templates/fedora.properties
popd > /dev/null
pushd $TESTBED_DIR > /dev/null
cp fedora/install/fedora.war $TESTBED_DIR/tomcat/webapps
popd > /dev/null
#TODO: take care of Fedora validator hook..

#
# Install into tomcat: webservices
#
cp $BASEDIR/webservices/*.war $TESTBED_DIR/tomcat/webapps

#
# Install into tomcat: logging appender
#
cp $BASEDIR/logappender/*.jar $TESTBED_DIR/tomcat/lib

#
# TODO: What is currently needed to configure ECM?
#
# mkdir $BASEDIR/temp
# pushd $BASEDIR/temp
# cp ../webservices/ecm.war .
# unzip ecm.war -d ecm
# rm ecm.war
# cd ecm/WEB-INF
# sed \
# -e 's|http://localhost:7910/fedora|'"http://localhost:$TOMCATHTTP/fedora"'|g' \
# <web.xml > web.xml.new
# rm web.xml
# mv web.xml.new web.xml
# cd ..
# zip ../ecm.war -r .
# cp ../ecm.war $TESTBED_DIR/tomcat/webapps
# popd
# rm -rf $BASEDIR/temp

#
# TODO: kill any running tomcats
#
# ps ax | grep org.apache.catalina.startup.Bootstrap | grep -v grep |\
# awk '{print $1}' | xargs kill >/dev/null 2>&1

#
# TODO: Start tomcat
#
# export FEDORA_HOME=$TESTBED_DIR/fedora
# Start the tomcat server
# $TESTBED_DIR/tomcat/bin/startup.sh
# sleep 30

#
# TODO: provide initial objects to ingest
# .. objects should be taken from the old (pre-sourceforge) doms and
# put in a dir by name "data/objects" in the domsserver trunk..
#
#sh $TESTBED_DIR/fedora/client/bin/fedora-ingest.sh dir \
# $TESTBED_DIR/data/objects \
# 'info:fedora/fedora-system:FOXML-1.1' \
# localhost:$TOMCAT_HTTPPORT $FEDORAADMIN $FEDORAADMINPASS http


#
# TODO: Stop tomcat
#
#$TESTBED_DIR/tomcat/bin/shutdown.sh
