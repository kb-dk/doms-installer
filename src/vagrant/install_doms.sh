#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/

if [ ! -e visualvm_137.zip ]; then
wget -N https://java.net/projects/visualvm/downloads/download/release137/visualvm_137.zip
unzip visualvm_137.zip
fi


INSTALL_DIR="$HOME/7880-doms"

STORAGE_DIR="$HOME/7880-data"
DATADIR_DIR="$STORAGE_DIR/data"
CACHEDIR_DIR="$STORAGE_DIR/cache"
SBOI_SUMMA_STORAGE_DIR="$STORAGE_DIR/sboi-summaStorage"
DOMSWUI_SUMMA_STORAGE_DIR="$STORAGE_DIR/domswui-summaStorage"
mkdir -p $STORAGE_DIR
export TMPDIR=$HOME/tmp
mkdir -p $TMPDIR

installer="/target/installer-*-testbed.tar.gz"

echo "Getting doms from $installer"

tar -xzf $installer
rm -r $INSTALL_DIR
installerDir=$(find * -maxdepth 0 -type d -name 'installer-*' | head -1)

echo "DATA_DIR=$DATADIR_DIR" >> $installerDir/bin/setenv.sh
echo "CACHE_DIR=$CACHEDIR_DIR" >> $installerDir/bin/setenv.sh
echo "SBOI_SUMMA_STORAGE_DIR=$SBOI_SUMMA_STORAGE_DIR" >> $installerDir/bin/setenv.sh
echo "DOMSWUI_SUMMA_STORAGE_DIR=$DOMSWUI_SUMMA_STORAGE_DIR" >> $installerDir/bin/setenv.sh
echo "USE_POSTGRESQL=true" >> $installerDir/bin/setenv.sh

$installerDir/bin/install.sh $INSTALL_DIR

rm -r $installerDir