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

TOMCATZIP=`basename $BASEDIR/tomcat/*.zip`
FEDORAJAR=`basename $BASEDIR/tomcat/*.jar`

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
cp $BASEDIR/tomcat/$TOMCATZIP $TESTBED_DIR/
pushd $TESTBED_DIR
unzip $TOMCATZIP
mv ${TOMCATZIP%.*} tomcat
rm $TOMCATZIP
popd

#
# Replace the tomcat server.xml with our server.xml
#
pushd $BASEDIR/tomcat
# sed/shell magic below according to  http://www.grymoire.com/Unix/Sed.html
# See section "Passing arguments into a sed script".
sed \
-e 's/\$TOMCATHTTP\$/'"$TOMCAT_HTTPPORT"'/g' \
-e 's/\$TOMCATSSL\$/'"$TOMCAT_SSLPORT"'/g' \
-e 's/\$TOMCATAJP\$/'"$TOMCAT_AJPPORT"'/g' \
-e 's/\$TOMCATSHUTDOWN\$/'"$TOMCAT_SHUTDOWNPORT"'/g' \
<server.xml.template >server.xml
mv server.xml $TESTBED_DIR/tomcat/conf/
popd

#
# Update the tomcat tomcat-users.xml to make login possible
#
# Make it possible to log into the tomcat web manager-interface
pushd $TESTBED_DIR/tomcat/conf
cp tomcat-users.xml tomcat-users-backup.xml
sed \
-e 's|<tomcat-users>|<tomcat-users>\
<role rolename="manager"/>\
<user username="tomcat" password="tomcat" roles="manager"/>|g' \
<tomcat-users-backup.xml >tomcat-users.xml
popd

#
# Insert tomcat setenv.sh
#
pushd $BASEDIR/tomcat
# sed/shell magic below according to  http://www.grymoire.com/Unix/Sed.html
# See section "Passing arguments into a sed script".
sed \
-e 's/\$FEDORAHOME\$/'"$BASEDIR/fedora"'/g' \
-e 's/\$TOMCATHOME\$/'"$BASEDIR/tomcat"'/g' \
<setenv.sh.template >setenv.sh
mv setenv.sh $TESTBED_DIR/tomcat/bin/setenv.sh
popd
chmod +x $TESTBED_DIR/tomcat/bin/*.sh

#
# Install log4j configuration
#
cp $BASEDIR/tomcat/log4j.xml $TESTBED_DIR/tomcat/conf/

#TODO context.xml

#
# kill any running tomcats
#
#ps ax | grep org.apache.catalina.startup.Bootstrap | grep -v grep |\
# awk '{print $1}' | xargs kill >/dev/null 2>&1

#
# Install fedora including database
#
pushd $BASEDIR/fedora
# sed/shell magic below according to  http://www.grymoire.com/Unix/Sed.html
# See section "Passing arguments into a sed script".
sed \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$INSTALLDIR\$|'"$TESTBED_DIR"'/fedora|g' \
<fedora.properties.template >fedora.properties
java -jar fedora*.jar fedora.properties
rm fedora.properties
popd
pushd $TESTBED_DIR
cp fedora/install/fedora.war $TESTBED_DIR/tomcat/webapps
popd

#
# TODO: Everything below this point is not yet updated
# Outstanding issues:
#  - Installing all war files in tomcat
#  - Installing surveillance-rest jar file and dependencies in tomcat lib
#  - Patching fcfg with hook
#  - Add context.xml parameters (at the place defined above)
#  - A set of base objects
#  - possibly start testbed

# TODO: PLACEHOLDER UNTIL WE HAVE SPECIFIC INSTALL INSTRUCTIONS FOR EACH
# Install into tomcat: webservices
cp $BASEDIR/webservices/*.war $TESTBED_DIR/tomcat/webapps


#INSTALL ECM
mkdir $BASEDIR/temp
pushd $BASEDIR/temp
cp ../webservices/ecm.war .
unzip ecm.war -d ecm
rm ecm.war
cd ecm/WEB-INF
sed \
-e 's|http://localhost:7910/fedora|'"http://localhost:$TOMCATHTTP/fedora"'|g' \
<web.xml > web.xml.new
rm web.xml
mv web.xml.new web.xml
cd ..
zip ../ecm.war -r .
cp ../ecm.war $TESTBED_DIR/tomcat/webapps
popd
rm -rf $BASEDIR/temp

#INSTALL LOWLEVELBITSTORAGE
mkdir $BASEDIR/temp
pushd $BASEDIR/temp
cp ../webservices/lowlevelbitstorage.war .
unzip lowlevelbitstorage.war -d lowlevelbitstorage
rm lowlevelbitstorage.war
cd lowlevelbitstorage/WEB-INF/classes
sed \
-e 's|<script>bin/server.sh</script>|'"<script>$BITSTORAGE_SCRIPT</script>"'|g' \
-e 's|<server>domstest@halley</server>|'"<server>$BITSTORAGE_SERVER</server>"'|g' \
-e 's|<bitfinder>http://bitfinder.statsbiblioteket.dk/</bitfinder>|'"<bitfinder>$BITFINDER</bitfinder>"'|g' \
< bitstorageSshImpl.xml > bitstorageSshImpl.xml.new
rm bitstorageSshImpl.xml
mv bitstorageSshImpl.xml.new bitstorageSshImpl.xml
cd ../..
zip ../lowlevelbitstorage.war -r .
cp ../lowlevelbitstorage.war $TESTBED_DIR/tomcat/webapps
popd
rm -rf $BASEDIR/temp

#TODO: take care of Fedora validator hook..

#TODO: config webservices (ecm, bitstorage,..)

export FEDORA_HOME=$TESTBED_DIR/fedora

# Start the tomcat server
$TESTBED_DIR/tomcat/bin/startup.sh
sleep 30

#TODO: provide initial objects to ingest
# .. objects should be taken from the old (pre-sourceforge) doms and
# put in a dir by name "data" in the domsserver trunk..
#
#sh $TESTBED_DIR/fedora/client/bin/fedora-ingest.sh dir $TESTBED_DIR/objects\
# 'info:fedora/fedora-system:FOXML-1.1'\
# localhost:$TOMCAT_HTTPPORT $FEDORAADMIN $FEDORAADMINPASS http

$TESTBED_DIR/tomcat/bin/shutdown.sh
