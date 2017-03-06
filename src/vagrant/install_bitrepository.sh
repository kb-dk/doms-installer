#!/usr/bin/env bash

# Note, no error handling!  Brittle - therefore version numbers hardcoded!
cd $HOME

# TODO: Investigate if can be replaced with apt package.
curl -L -o apache-activemq-5.14.3-bin.tar.gz 'http://www.apache.org/dyn/closer.cgi?filename=/activemq/5.14.3/apache-activemq-5.14.3-bin.tar.gz&action=download'
tar xvzf apache-activemq-5.14.3-bin.tar.gz

apache-activemq-5.14.3/bin/activemq start # goes in background

# not package to avoid having Zulu OpenJDK 8 interferring with ubuntu packages.
curl -L -O http://cdn.azul.com/zulu/bin/zulu8.19.0.1-jdk8.0.112-linux_x64.tar.gz
tar xvzf zulu8.19.0.1-jdk8.0.112-linux_x64.tar.gz

# unpack bitrepository quickstart prepared by maven earlier
tar xvzf /target/artifacts-copied/bitrepository-integration-quickstart.tar.gz

# fix collection name, file exchance settings and allow for "/" in file identifiers.
patch -p1 -d bitrepository-quickstart < /vagrant/bitrepository-quickstart.diff

export JAVA_HOME=$HOME/zulu8.19.0.1-jdk8.0.112-linux_x64
bitrepository-quickstart/setup.sh

