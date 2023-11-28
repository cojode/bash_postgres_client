#!/bin/bash

# ---=== Simple lib to make psql stuff inside scenario.sh ===---

source "../src/config.sh"

invoke_postgres() {
    local PSQL_PREFIX="psql -U $SUPERUSER -d $DB_NAME"
    $PSQL_PREFIX $1
}

register_db() {
    if psql -lqt | cut -d \| -f 1 | grep -qw $DB_NAME
    then
        echo "Database already created"
    else
        echo "No database $DB_NAME found, creating new"
        createdb $DB_NAME
        load_db
    fi
}

load_db() {
    if [ -f "db.sql" ]
    then
        psql -U $SUPERUSER -d $DB_NAME -f db.sql
        echo "Succesfully imported database in a $DB_NAME"
    else
        echo "Some trouble with database initialization: do you provide one?"
    fi
}

unregister_db() {
    dropdb $DB_NAME
}

peek_tours() {
    IFS=$'\n'
    read -a TOURS -d '' <<< "$(psql -U $SUPERUSER -d $DB_NAME -c 'SELECT * FROM tour;' | tail +3 | sed )"
    INVOKE_DIALOG="dialog --radiolist 'Select items:' 0 0 0 "
    for (( i = 0; i < ${#TOURS[@]}; i++ )); do
        INVOKE_DIALOG=$INVOKE_DIALOG"${TOURS[i]} "
    done
    echo $INVOKE_DIALOG
}
