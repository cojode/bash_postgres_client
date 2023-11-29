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

peek_menu() {
    local MENU_ARRAY=( 1 "List tours" \
                       2 "List hotels" )
    case $(dialog --cancel-label "Back" --menu "Peek menu" 15 55 5 "${MENU_ARRAY[@]}" 2>&1 >/dev/tty) in
        1)
            peek_tours
            ;;
        2)
            echo "Hotel"
            ;;
    esac
}

peek_tours() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c 'SELECT * FROM tour;' | tail +2 | awk -v FS="|" '{ gsub(" ", "", $2) } {print v++,$2}' | tr -s '\t' ' ' | head -n -2 | tail +2)
    local ARRAY=(${FEATURES//$'\n'/ })
    local CHOSEN_ID=$(dialog --cancel-label "Back" --menu  "Please choose a tour" 15 55 5 "${ARRAY[@]}" 2>&1 >/dev/tty)
    if [[ -z "$CHOSEN_ID" ]]
    then
        peek_menu
    else
        inspect_chosen_tour $CHOSEN_ID
    fi
}

inspect_chosen_tour() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM tour WHERE tour_id = '$1';" | tail +3)
    local ARRAY=(${FEATURES// | / })
    dialog --cancel-label "Back" --msgbox "Id: ${ARRAY[0]}\n Destination: ${ARRAY[1]}\n Departure date: ${ARRAY[2]} \n Return date: ${ARRAY[3]}\n Price: ${ARRAY[4]}" 0 0
    peek_tours
}
