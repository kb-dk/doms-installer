#!/usr/bin/env bash


echo Creating storage folder ${summarise_storage_dir}
mkdir -p ${summarise_storage_dir}
pushd ${summarise_storage_dir}
mkdir data index suggest storage dump progress summix-storage
popd

bin/start_resident.sh

# Run the command on container startup
cron

#TODO fix firstrun

#Create the log file so we can follow it
touch tomcat/logs/catalina.out
tail -f tomcat/logs/catalina.out
