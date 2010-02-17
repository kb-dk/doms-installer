TOMCAT_HTTPPORT=8080
TOMCAT_SHUTDOWNPORT=8005
TOMCAT_SSLPORT=8443
TOMCAT_AJPPORT=8009
FEDORAADMIN=fedoraAdmin
FEDORAADMINPASS=fedoraAdminPass

BITFINDER=http://bitfinder.statsbiblioteket.dk/
BITSTORAGE_SERVER=domstest@halley
BITSTORAGE_SCRIPT=bin/server.sh

# Variables for the script create_build_environment.sh
# for to define the SourceForge packages to check-out.
SOURCEFORGE_DOMS_SVN_URL="https://doms.svn.sourceforge.net/svnroot/doms"
PACKAGES=( "bitstorage/trunk" "domsclient/trunk" "domsserver/trunk" "ecm/trunk" "surveillance/trunk")
