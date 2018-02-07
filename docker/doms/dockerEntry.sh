#!/usr/bin/env bash


MARKER=${storageDir}/completed-ingest-of-base-objects

#Ensure that tomcat or anything is not currently running
killall --quiet java
if [ ! -f ${MARKER} ]; then
    # In first run, we ingest the base objects

    echo "Starting base objects ingest"
    ${tomcatDir}/bin/startup.sh
    echo "Tomcat started, sleeping while waiting for it to be complete"
    sleep 20

    echo "Starting base objects ingester"
    /usr/local/doms/base-objects-ingester/bin/createAll.sh || exit 1

    echo "Setting flag '${MARKER}' to indicate base objects are ingested"
    touch ${MARKER}

    echo "Stopping tomcat again"
    ${tomcatDir}/bin/catalina.sh stop 15 -force
    sleep 20
    killall java
fi

echo "Starting the final tomcat"
${tomcatDir}/bin/catalina.sh run