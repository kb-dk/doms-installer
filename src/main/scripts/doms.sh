#!/bin/bash

#
# Detect Java version
#
if [ -z "$JAVA_HOME" ] ; then
    JAVA_EXEC=java
else
    JAVA_EXEC="$JAVA_HOME/bin/java"
fi

"$JAVA_EXEC" -version 2>&1|grep "1\.6\.0" > /dev/null

if [ $? -ne 0 ] ; then
    echo "This package only supports Java 1.6"
    exit 2
fi

#
# Setup environment
#
SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR > /dev/null
SCRIPT_DIR=$(pwd)
popd > /dev/null

DOMS_BIN="$SCRIPT_DIR/../tomcat/bin/"
SUMMA_BIN="$SCRIPT_DIR/../summarise/bin"


function start_doms {
    echo "Starting DOMS .."
    $DOMS_BIN/startup.sh
    echo "Done."
}

function stop_doms {
    echo "Stopping DOMS .."
    $DOMS_BIN/shutdown.sh
    echo "Done."
}

function start_summa {
    echo "Starting summa (you can safely ignore the 'SEVERE Catalina.stop' error) .."
    $SUMMA_BIN/start_resident.sh
    echo "Done."
}

function stop_summa {
    echo "Stopping summa .."
    $SUMMA_BIN/stop_resident.sh
    echo "Done."
}

function start {
    start_summa
    start_doms
}

function stop {
    stop_doms
    stop_summa
}

function restart {
    stop
    start
}

function import {
    echo "Ingesting all data .."
    $SUMMA_BIN/ingest_full.sh
    echo "Re-building the index .."
    $SUMMA_BIN/index_full.sh
    echo "Done."
}

function update {
    echo "Ingesting updates .."
    $SUMMA_BIN/ingest_update.sh
    echo "Updating the index .."
    $SUMMA_BIN/index_update.sh
    echo "Done."
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    import)
        import
        ;;
    update)
        update
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|import|update}"
        exit 1

esac
