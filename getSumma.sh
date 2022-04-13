#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f -- ${BASH_SOURCE[0]})")

SBOI_SUMMARISE_VERSION=$(\
    xmlstarlet sel \
            -N pom='http://maven.apache.org/POM/4.0.0' \
           --template \
           --value-of \
           "/pom:project/pom:profiles/pom:profile[pom:id/text()='testbed']/pom:properties/pom:sboi.summarise.version" \
           "$SCRIPT_DIR/pom.xml"
)

rsync \
    -avz \
    --delete \
    "fedora@alhena.statsbiblioteket.dk:/fedora/SummariseReleases/newspapr-$SBOI_SUMMARISE_VERSION/" \
    "${SCRIPT_DIR}/docker/sboi/summa/"

