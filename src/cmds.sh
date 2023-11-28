#!/bin/bash

# ---=== Simple lib to make psql stuff ===---

source "../src/valid.sh"
source "../src/requests.sh"
source "../src/config.sh"

PSQL_PREFIX="psql -U $DB_USER -d $DB_NAME"

register_db() {
    createuser $DB_NAME
    createdb $DB_USER
    psql $DB_NAME -c $GRANT_ALL_OWNER
}

load_db() {
    $PSQL_PREFIX -f 
}

unregister_db() {
    # ! checks for existing db connections
    dropuser $DB_USER
    dropdb $DB_NAME
}

invoke_postgres() {
    $PSQL_PREFIX $1
}

peek_tours() {
    invoke_postgres $(echo 'SELECT * FROM Tours')
}
