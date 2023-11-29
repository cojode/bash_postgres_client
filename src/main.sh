#!/bin/bash

source "../src/config.sh"

if [ -f $DB_SOURCE_PATH ] 
then
    cp $DB_SOURCE_PATH /var/lib/postgresql/db.sql
    sudo -u postgres bash scenario.sh #2> /dev/null
else
    echo "No such file: $DB_SOURCE_PATH"
    exit 1
fi


