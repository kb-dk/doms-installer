#!/usr/bin/env bash

SCRIPT_DIR=$(dirname $(readlink -f $BASH_SOURCE[0]))
SSH_KEY=$HOME/.ssh/id_rsa
SBOI_SUMMARISE_VERSION=2.8-SNAPSHOT

rsync \
    -avz \
    -e "ssh -i ${SSH_KEY} -o UserKnownHostsFile=\"$SCRIPT_DIR/known_hosts\"" \
    fedora@alhena.statsbiblioteket.dk:/fedora/SummariseReleases/newspapr-$SBOI_SUMMARISE_VERSION/* \
    ${SCRIPT_DIR}/docker/sboi/
