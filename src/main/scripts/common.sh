#!/bin/bash

#
# Check for install-folder and potentially create it.
#
function parseTestbedDir(){
    TESTBED_DIR=$1
    if [ -z "$TESTBED_DIR" ]; then
        echo "install-dir not specified. Bailing out." 1>&2
        usage
    fi
    if [ -d $TESTBED_DIR ]; then
        echo ""
    else
        mkdir -p $TESTBED_DIR
    fi
    pushd $TESTBED_DIR > /dev/null
    TESTBED_DIR=$(pwd)
    popd > /dev/null
}
