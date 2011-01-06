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


PORTRANGE=79
TOMCAT_SERVERNAME=localhost

FEDORAADMIN=fedoraAdmin
FEDORAADMINPASS=fedoraAdminPass

FEDORAUSER=fedoraUser
FEDORAUSERPASS=fedoraUserPass

TOMCATMANAGER=fedoraAdmin
TOMCATMANAGERPASS=fedoraAdminPass

LOG_DIR=$TESTBED_DIR/logs
TOMCAT_DIR=$TESTBED_DIR/tomcat
FEDORA_DIR=$TESTBED_DIR/fedora

BITFINDER=http://bitfinder.statsbiblioteket.dk/
BITSTORAGE_SCRIPT="ssh doms@stage01 bin/server.sh"

USE_POSTGRESQL=true
