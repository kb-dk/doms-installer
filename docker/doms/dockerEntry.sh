#!/usr/bin/env bash

killall java
if [ ! -f ${storageDir}/base-objects-ingested ]; then #This means first run
    echo "Starting base objects ingest"
    ${tomcatDir}/bin/startup.sh
    echo "Tomcat started, sleeping while waiting for it to be complete"
    sleep 20
    echo "Starting base objects ingester"
    /usr/local/doms/base-objects-ingester/bin/createAll.sh

    echo "Setting flag to indicate base objects are ingested"
    touch ${storageDir}/base-objects-ingested

    echo "Stopping tomcat again"
    ${tomcatDir}/bin/catalina.sh stop 15 -force
    sleep 20
    killall java
fi

echo "Starting the final tomcat"
${tomcatDir}/bin/catalina.sh run