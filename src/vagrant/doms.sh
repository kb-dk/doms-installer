#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/


INSTALL_DIR="$HOME/7880-doms"

STORAGE_DIR="$HOME/7880-data"
DATADIR_DIR="$STORAGE_DIR/data"
CACHEDIR_DIR="$STORAGE_DIR/cache"
SUMMA_STORAGE_DIR="$STORAGE_DIR/summaStorage"

mkdir -p $STORAGE_DIR
export TMPDIR=$HOME/tmp
mkdir -p $TMPDIR

echo "Getting doms from $NEXUS_URL"

tar -xzf /target/installer-*-testbed.tar.gz
rm -r $INSTALL_DIR
installerDir=$(find * -maxdepth 0 -type d -name 'installer-*' | head -1)

echo "DATA_DIR=$DATADIR_DIR" >> $installerDir/bin/setenv.sh
echo "CACHE_DIR=$CACHEDIR_DIR" >> $installerDir/bin/setenv.sh
echo "SUMMA_STORAGE_DIR=$SUMMA_STORAGE_DIR" >> $installerDir/bin/setenv.sh

$installerDir/bin/install.sh $INSTALL_DIR

rm -r $installerDir