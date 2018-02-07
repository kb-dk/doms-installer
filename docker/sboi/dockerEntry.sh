#!/usr/bin/env bash


echo Creating storage folder ${summarise_storage_dir}
mkdir -p \
    ${summarise_storage_dir}/data \
    ${summarise_storage_dir}/index \
    ${summarise_storage_dir}/suggest \
    ${summarise_storage_dir}/storage \
    ${summarise_storage_dir}/dump \
    ${summarise_storage_dir}/progress \
    ${summarise_storage_dir}/summix-storage

bin/start_resident.sh

# In a docker container, cron does not start automatically, so start it here
cron
# see crontab to see how we use cron to run updates every X mins.
# In prod, we run every 5 mins, but for development, a faster update cycle is often preferred

#TODO fix firstrun

#Create the log file so we can follow it
touch tomcat/logs/catalina.out
tail -f tomcat/logs/catalina.out
