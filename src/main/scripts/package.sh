#!/bin/bash

# $Id install.sh $
# $Author$
# $Date:   2008-08-21$
#
# Script for installing the testbed
#
# USAGE: After unpacking, edit setenv.sh to suit your needs, run
# then run this script.


function replace(){
sed \
-e 's|\$LOG_DIR\$|'"$LOG_DIR"'|g' \
-e 's|\$TOMCAT_DIR\$|'"$TOMCAT_DIR"'|g' \
-e 's|\$FEDORA_DIR\$|'"$FEDORA_DIR"'|g' \
-e 's|\$DATA_DIR\$|'"$DATA_DIR"'|g' \
-e 's|\$CACHE_DIR\$|'"$CACHE_DIR"'|g' \
-e 's|\$SCHEMA_DIR\$|'"$SCHEMA_DIR"'|g' \
-e 's|\$TOMCAT_CONFIG_DIR\$|'"$TOMCAT_CONFIG_DIR"'|g' \
-e 's|\$WEBAPPS_DIR\$|'"$WEBAPPS_DIR"'|g' \
-e 's|\$PORTRANGE\$|'"$PORTRANGE"'|g' \
-e 's|\$SUMMA_PORTRANGE\$|'"$SUMMA_PORTRANGE"'|g' \
-e 's|\$TOMCAT_SERVERNAME\$|'"$TOMCAT_SERVERNAME"'|g' \
-e 's|\$FEDORAADMIN\$|'"$FEDORAADMIN"'|g' \
-e 's|\$FEDORAADMINPASS\$|'"$FEDORAADMINPASS"'|g' \
-e 's|\$YOUSEEUSER\$|'"$YOUSEEUSER"'|g' \
-e 's|\$YOUSEEUSERPASS\$|'"$YOUSEEUSERPASS"'|g' \
-e 's|\$FEDORAUSER\$|'"$FEDORAUSER"'|g' \
-e 's|\$FEDORAUSERPASS\$|'"$FEDORAUSERPASS"'|g' \
-e 's|\$BITFINDER\$|'"$BITFINDER"'|g' \
-e 's|\$BITSTORAGE_SCRIPT\$|'"$BITSTORAGE_SCRIPT"'|g' \
-e 's|\$POSTGRESQL_DB\$|'"$POSTGRESQL_DB"'|g' \
-e 's|\$POSTGRESQL_USER\$|'"$POSTGRESQL_USER"'|g' \
-e 's|\$POSTGRESQL_PASS\$|'"$POSTGRESQL_PASS"'|g' \
-e 's|\$DATABASE_SYSTEM\$|'"$DATABASE_SYSTEM"'|g' \
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



#
# Import settings
#
source $SCRIPT_DIR/setenv.sh


CONFIG_TEMP_DIR=`mktemp -d`

if [ "$USE_POSTGRESQL" = "true" ]; then
  DATABASE_SYSTEM=localPostgreSQLPool
else
  DATABASE_SYSTEM=localDerbyPool
fi


#
# Configuring all the doms config files
#
echo "Creating config files from conf.sh"
for file in $BASEDIR/data/templates/*.template ; do
  newfile1=`basename $file`;
  newfile2=$CONFIG_TEMP_DIR/${newfile1%.template};
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
mkdir -p $TOMCAT_CONFIG_DIR/

# Replace the tomcat server.xml with our server.xml
mkdir -p $TOMCAT_DIR/conf
cp -v $CONFIG_TEMP_DIR/server.xml $TOMCAT_DIR/conf/server.xml



# Insert tomcat setenv.sh
mkdir -p $TOMCAT_DIR/bin/
cp -v $CONFIG_TEMP_DIR/setenv.sh $TOMCAT_CONFIG_DIR/setenv.sh
rm $TOMCAT_DIR/bin/setenv.sh
ln -s $TOMCAT_CONFIG_DIR/setenv.sh $TOMCAT_DIR/bin/setenv.sh
chmod +x $TOMCAT_DIR/bin/*.sh


# Install log4j configuration
cp -v $CONFIG_TEMP_DIR/log4j.*.xml $TOMCAT_CONFIG_DIR

# Install context.xml configuration
cp -v $CONFIG_TEMP_DIR/context.xml.default $TOMCAT_CONFIG_DIR/tomcat-context-params.xml

# Install schemaStore "webservice" configuration
mkdir $TOMCAT_APPS_DIR
cp -v $CONFIG_TEMP_DIR/schemaStore.xml $TOMCAT_APPS_DIR/schemaStore.xml

# Set the session timeout to 1 min
mkdir -p $TOMCAT_DIR/conf
cp -v $CONFIG_TEMP_DIR/web.xml $TOMCAT_DIR/conf/web.xml


#if we used the odd Maintenance tomcat setup, symlink stuff together again
if [ ! $TOMCAT_CONFIG_DIR -ef $TOMCAT_DIR/conf ]; then

   #first, link to context.xml into the correct location
   mkdir -p $TOMCAT_DIR/conf/Catalina/localhost
   ln -s $TOMCAT_CONFIG_DIR/tomcat-context-params.xml $TOMCAT_DIR/conf/Catalina/localhost/context.xml.default

   ln -s $TOMCAT_APPS_DIR/schemaStore.xml $TOMCAT_DIR/conf/Catalina/localhost/schemaStore.xml
fi

echo "Tomcat setup is now done"
## Tomcat is now done

echo "Installing docs"
mkdir -p $DOCS_DIR
cp -r $BASEDIR/docs/* $DOCS_DIR
echo "Docs installed"



echo ""
echo "WEBSERVICE INSTALL"
echo ""
##
## Install the doms webservices
##
echo "Installing the doms webservices into tomcat"
mkdir -p $WEBAPPS_DIR

for file in $BASEDIR/webservices/*.war ; do
     newname=`basename $file`
     newname=`expr match "$newname" '\([^0-9]*\)'`;
     newname=${newname%-}.war;
     cp -v $file $WEBAPPS_DIR/$newname
done
chmod 644 $WEBAPPS_DIR/*.war


##
## Install Fedora
##
echo ""
echo "INSTALLING FEDORA"
echo ""

echo "Configuring fedora preinstall"

# Install Fedora
echo "Installing Fedora"
pushd $BASEDIR/data/fedora > /dev/null
java -jar $FEDORAJAR $CONFIG_TEMP_DIR/fedora.properties  > /dev/null
popd > /dev/null


# Deploy stuff from fedoralib
echo "Repacking Fedora war files with changes"
pushd $FEDORA_DIR/install/fedorawar > /dev/null
mkdir -p WEB-INF/lib

cp $BASEDIR/fedoralib/* WEB-INF/lib
FEDORAWEBXML=`mktemp`
sed '/<\/web-app>/d' < WEB-INF/web.xml > $FEDORAWEBXML
cat $CONFIG_TEMP_DIR/fedoraWebXmlInsert.xml >> $FEDORAWEBXML
echo "</web-app>" >> $FEDORAWEBXML
cp $FEDORAWEBXML WEB-INF/web.xml
rm $FEDORAWEBXML

mv ../fedora.war ../fedora_original.war
zip -r ../fedora.war *    > /dev/null
popd > /dev/null



echo "Install fedora.war into tomcat"
cp -v $FEDORA_DIR/install/fedora.war $WEBAPPS_DIR

echo "Configuring fedora postinstall"

# Add logappender to Fedora logback configuration
cp -v $CONFIG_TEMP_DIR/logback.xml $FEDORA_DIR/server/config/logback.xml

# Add logappender to Fedora logback configuration
cp -v $CONFIG_TEMP_DIR/fedora.fcfg  $FEDORA_DIR/server/config/fedora.fcfg

# Install custom policies
mkdir -p $FEDORA_DIR/fedora-xacml-policies/repository-policies/
cp -rv $BASEDIR/data/policies/* $FEDORA_DIR/fedora-xacml-policies/repository-policies/

# Fix jaas.conf so that we use the doms auth checker
cp -v $CONFIG_TEMP_DIR/jaas.conf  $FEDORA_DIR/server/config/jaas.conf

# Setup the custom users
cp -v $CONFIG_TEMP_DIR/fedora-users.xml $FEDORA_DIR/server/config/fedora-users.xml

# Setup the the lowlevel storage
cp -v $CONFIG_TEMP_DIR/akubra-llstore.xml $FEDORA_DIR/server/config/akubra-llstore.xml

rm -rf $FEDORA_DIR/install

echo "Fedora setup complete"



echo "Installing Doms Schemas"
mkdir -p $SCHEMA_DIR
cp $BASEDIR/data/schemas/* $SCHEMA_DIR/



mkdir -p $BASEOBJS_DIR/bin
mkdir -p $BASEOBJS_DIR/scripts
for file in $BASEDIR/data/objects/batch/*.xml ; do
  replace $file $BASEOBJS_DIR/scripts/`basename $file`
  echo "Created batch file $BASEOBJS_DIR/scripts/`basename $file` from template file $file"
done

for file in $BASEDIR/data/objects/batch/*.sh ; do
  replace $file $BASEOBJS_DIR/bin/`basename $file`
  chmod a+x $BASEOBJS_DIR/bin/`basename $file`
  echo "Created batch file $BASEOBJS_DIR/bin/`basename $file` from template file $file"
done

if [ -f $BASEDIR/ingester/$INGESTERZIP ]; then
  echo "Installing doms Radio-tv ingester"
  mkdir -p $INGEST_DIR
  unzip -q -n $BASEDIR/ingester/$INGESTERZIP -d $INGEST_DIR
  pushd `dirname $INGEST_DIR/radio-tv-*/bin` > /dev/null
  cp $CONFIG_TEMP_DIR/ingest_config.sh bin/
  mkdir -p files
  cp -r $BASEDIR/data/preingestfiles/ files/
  popd > /dev/null
  rm -rf $CONFIG_TEMP_DIR > /dev/null
fi

echo "Install complete"