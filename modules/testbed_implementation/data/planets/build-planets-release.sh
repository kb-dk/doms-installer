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
PLANETS_DIR=$@
if [ -z "$PLANETS_DIR" ]; then
    echo "install-dir not specified. Bailing out." 1>&2
    usage
fi
if [ -d $PLANETS_DIR ]; then
    echo ""
else
    mkdir -p $PLANETS_DIR
fi
pushd $@ > /dev/null
PLANETS_DIR=$(pwd)
popd > /dev/null
echo "Full path destination: $PLANETS_DIR"

pushd $PLANETS_DIR > /dev/null

#checkout if_sp
svn checkout http://gforge.planets-project.eu/svn/if_sp/trunk $PLANETS_DIR/ifsp


#checkout pserv
svn checkout http://gforge.planets-project.eu/svn/pserv/trunk $PLANETS_DIR/pserv

#copy framework.properties to if_sp
#replace INSTALLDIR in framework.properties

# sed/shell magic below according to  http://www.grymoire.com/Unix/Sed.html
# See section "Passing arguments into a sed script".
sed \
  -e 's|INSTALLDIR|'"$PLANETS_DIR/planets"'|g' \
  <$SCRIPT_DIR/framework.properties > $PLANETS_DIR/ifsp/framework.properties


#copy build.properties to pserv
#replace INSTALLDIR in build.properties
sed \
  -e 's|INSTALLDIR|'"$PLANETS_DIR/planets"'|g' \
  <$SCRIPT_DIR/build.properties > $PLANETS_DIR/pserv/build.properties


#if_sp: ant deploy-framework
cd $PLANETS_DIR/ifsp
ant deploy-framework

#pserv: ant deploy:common
cd $PLANETS_DIR/pserv
ant deploy:common

#if_sp: ant create-dbs
cd $PLANETS_DIR/ifsp
ant create-dbs

#if_sp: ant deploy-all
cd $PLANETS_DIR/ifsp
ant deploy-all

#pserv: ant IF/admin
cd $PLANETS_DIR/pserv/IF/admin
ant

#pserv: ant IF/users
cd $PLANETS_DIR/pserv/IF/users
ant

#pserv: ant IF/selfreg
cd $PLANETS_DIR/pserv/IF/selfreg
ant

#pserv: ant IF/servreg
cd $PLANETS_DIR/pserv/IF/servreg
ant

#pserv: ant PC/droid
cd $PLANETS_DIR/pserv/PC/droid
ant


#pserv: ant PC/jhove
cd $PLANETS_DIR/pserv/PC/jhove
ant

cd $PLANETS_DIR
tar -cvzf $PLANETS_DIR/planets.tgz planets

popd > /dev/null
