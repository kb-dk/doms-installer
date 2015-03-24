#!/usr/bin/env bash

apt-get update > /dev/null
apt-get install -y zip unzip

apt-get install -y python-software-properties
add-apt-repository ppa:webupd8team/java
apt-get update > /dev/null
echo debconf shared/accepted-oracle-license-v1-1 select true |  sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true |  sudo debconf-set-selections
apt-get install -y oracle-java7-installer oracle-java7-set-default
export JAVA_HOME=/usr/lib/jvm/java-7-oracle/


apt-get install -y redis-server

apt-get install -y xorg

apt-get install -y postgresql postgresql-contrib



sudo -u postgres psql -c " CREATE ROLE \"domsFieldSearch\" LOGIN PASSWORD 'domsFieldSearchPass'
            NOINHERIT CREATEDB
            VALID UNTIL 'infinity';"

sudo -u postgres psql -U postgres -c "CREATE DATABASE \"domsFieldSearch\"
            WITH
            TEMPLATE=template0
            ENCODING='SQL_ASCII'
            OWNER=\"domsFieldSearch\";"



sudo -u postgres psql -c " CREATE ROLE \"domsMPT\" LOGIN PASSWORD 'domsMPTPass'
            NOINHERIT CREATEDB
            VALID UNTIL 'infinity';"

sudo -u postgres psql -U postgres -c "CREATE DATABASE \"domsTripleStore\"
            WITH
            TEMPLATE=template0
            ENCODING='SQL_ASCII'
            OWNER=\"domsMPT\";"



echo "192.168.50.2 doms-testbed" >> /etc/hosts
echo "192.168.50.4 domswui-testbed" >> /etc/hosts




#sudo -u -u vagrant "bash /vagrant/install_doms.sh"
