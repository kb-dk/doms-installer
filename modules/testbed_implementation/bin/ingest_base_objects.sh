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
# Import settings
#
source $SCRIPT_DIR/setenv.sh



#
# Ingest initial objects
#
echo "Ingesting base objects"
export FEDORA_HOME=$FEDORA_DIR
sh $FEDORA_DIR/client/bin/fedora-ingest.sh dir \
$BASEDIR/data/objects \
'info:fedora/fedora-system:FOXML-1.1' \
localhost:${PORTRANGE}80 $FEDORAADMIN $FEDORAADMINPASS http
