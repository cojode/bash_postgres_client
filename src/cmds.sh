#!/bin/bash

# ---=== Simple lib to make psql stuff inside scenario.sh ===---

source "../src/config.sh"

LOGGED_IN_PATTERN="Logged in"

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

main_menu() {
    local MENU_ARRAY=( 1 "Tour catalog" \
                       2 "Hotel catalog" \
                       3 "Bookings list" \
                       4 "Edit tours" )
    case $(dialog --title "$LOGGED_IN_PATTERN" --cancel-label "Exit" --menu "Main menu" 15 55 5 "${MENU_ARRAY[@]}" 2>&1 >/dev/tty) in
        1)
            list_all_tours
            ;;
        2)
            list_all_hotels
            ;;
        3)
            list_all_bookings
            ;;
        4)  
            editor_list_all_tours
            ;;
    esac
}

list_all_hotels() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c 'SELECT * FROM hotel;' | tail +2 | awk -v FS="|" '{ gsub(" ", "", $2) } {print v++,$2}' | tr -s '\t' ' ' | head -n -2 | tail +2)
    local ARRAY=(${FEATURES//$'\n'/ })
    local CHOSEN_ID=$(dialog --cancel-label "Back" --menu  "Please choose a hotel" 15 55 5 "${ARRAY[@]}" 2>&1 >/dev/tty)
    if [[ -z "$CHOSEN_ID" ]]
    then
        main_menu
    else
        list_hotel_specific_tours $CHOSEN_ID
    fi
}

list_all_tours() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c 'SELECT * FROM tour;' | awk -v FS="|" '{ gsub(" ", "", $2) } {print $1,$2}' | tr -s '\t' ' ' | head -n -2 | tail +3)
    local ARRAY=(${FEATURES//$'\n'/ })
    local CHOSEN_ID=$(dialog --cancel-label "Back" --menu  "Please choose a tour" 15 55 5 "${ARRAY[@]}" 2>&1 >/dev/tty)
    if [[ -z "$CHOSEN_ID" ]]
    then
        main_menu
    else
        list_tour_specific_hotel $CHOSEN_ID
    fi
}

list_all_bookings() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c 'SELECT * FROM booking;' | awk -v FS="|" '{ gsub(" ", "", $2) } {print $1,$2}' | tr -s '\t' ' ' | head -n -2 | tail +3)
    local ARRAY=(${FEATURES//$'\n'/ })
    local CHOSEN_ID=$(dialog --cancel-label "Back" --menu  "Please choose a booking" 15 55 5 "${ARRAY[@]}" 2>&1 >/dev/tty)
    if [[ -z "$CHOSEN_ID" ]]
    then
        main_menu
    else
       inspect_booking $CHOSEN_ID
    fi
}

inspect_booking() {
    local BOOKING_FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM booking WHERE booking_id = '$1';" | tail +3)
    local ARRAY=(${FEATURES// | / })

    dialog --msgbox "${ARRAY[@]}" 0 0

    dialog --extra-button --extra-label "Back" --ok-label "Order" \
                           --msgbox "Booking id: $1\n \
                           Customer id: ${ARRAY[1]}\n \
                           Tour id: ${ARRAY[2]}\n \
                           Hotel id: ${ARRAY[3]}\n \
                           Check in date: ${ARRAY[4]}\n \
                           Check out date: ${ARRAY[5]}\n \
                           Star rating: ${ARRAY[6]}" 0 0
    list_all_bookings
}

list_tour_specific_hotel() {
    local PICKED_LOCATION=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT destination FROM tour WHERE tour_id = '$1';"| awk '{gsub(" ", "", $1)} {print $1}' | tail +3 | head -n -2)
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM hotel WHERE location = '$PICKED_LOCATION';" | awk -v i="-1" -v FS="|" '{ gsub(" ", "", $2) } {print $1,$2}' | tr -s '\t' ' ' | head -n -2 | tail +3)
    local ARRAY=(${FEATURES//$'\n'/ })
    local HOTEL_ID=$(dialog --cancel-label "Back" --menu  "Please choose a hotel" 15 55 5 "${ARRAY[@]}" 2>&1 >/dev/tty)
    if [[ -z "$HOTEL_ID" ]]
    then
         main_menu
    else
         inspect_chosen_booking $1 $HOTEL_ID
    fi
}

list_hotel_specific_tours() {
    local HOTEL_ID=$((200 + $1))
    local PICKED_LOCATION=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT location FROM hotel WHERE hotel_id = '$((200 + $1))';"| awk '{gsub(" ", "", $1)} {print $1}' | tail +3 | head -n -2)
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM tour WHERE destination = '$PICKED_LOCATION';" | awk -v i="-1" -v FS="|" '{ gsub(" ", "", $2) } {print $1,$2}' | tr -s '\t' ' ' | head -n -2 | tail +3)
    local ARRAY=(${FEATURES//$'\n'/ })
    local TOUR_ID=$(dialog --cancel-label "Back" --menu  "Please choose a tour" 15 55 5 "${ARRAY[@]}" 2>&1 >/dev/tty)
    if [[ -z "$TOUR_ID" ]]
    then
         main_menu
    else
         inspect_chosen_booking $TOUR_ID $HOTEL_ID
    fi
}

inspect_chosen_booking() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM tour WHERE tour_id = '$1';" | tail +3)
    local HOTEL_NAME=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT name FROM hotel WHERE hotel_id = '$2';" | tail +3)
    local ARRAY=(${FEATURES// | / })
    dialog --extra-button --extra-label "Back" --ok-label "Order" \
                           --msgbox "Id: ${ARRAY[0]}\n \
                           Destination: ${ARRAY[1]}\n \
                           Hotel: ${HOTEL_NAME%(*}\n \
                           Departure date: ${ARRAY[2]}\n \
                           Return date: ${ARRAY[3]}\n \
                           Price: ${ARRAY[4]}" 0 0
    if [[ $? -eq 0 ]]
    then
        if dialog --yesno "Are you sure about booking?" 0 0
        then
            psql -U $SUPERUSER -d $DB_NAME -c \
                           "INSERT INTO CustomerTour \
                           (customer_id, tour_id) \
                           VALUES \
                           ($LOGIN_ID_ONLY, ${ARRAY[0]})"
            psql -U $SUPERUSER -d $DB_NAME -c \
                           "INSERT INTO Booking \
                           (customer_id, tour_id, \
                            hotel_id, check_in_date, \
                            check_out_date, star_rating) \
                            VALUES \
                            ($LOGIN_ID_ONLY, ${ARRAY[0]}, \
                             $2,'${ARRAY[2]}', '${ARRAY[3]}', 5)"
            if [[ $? -eq 0 ]]
            then
                dialog --msgbox "You succesfully booked a new tour!" 0 0
                main_menu
            else
                dialog --msgbox "An unknown error occured: $ERROR" 0 0
                exit 1
            fi
        fi
    fi
    main_menu
    
}

add_new_tour() {
    local CHOSEN_DESTINATION=$(dialog --inputbox "Enter location" 0 0 2>&1 >/dev/tty)
    local CHOSEN_DEPARTURE_DATE=$(dialog --calendar "Select a departure date:" 0 0 $(date "+%d %m %Y") 2>&1 >/dev/tty)
    local CHOSEN_RETURN_DATE=$(dialog --calendar "Select a return date:" 0 0 $(date "+%d %m %Y") 2>&1 >/dev/tty)
    local CHOSEN_PRICE=$(dialog --inputbox "Enter price" 0 0 2>&1 >/dev/tty)
    local DECISION=$(dialog --ok-label "Confirm" \
           --cancel-label "Discard" \
           --yesno "Confirm new tour:\n \
                    Destination: $CHOSEN_DESTINATION\n \
                    Departure date: $CHOSEN_DEPARTURE_DATE\n \
                    Return date: $CHOSEN_RETURN_DATE\n \
                    Price: $CHOSEN_PRICE" \
                    0 0 2>&1 >/dev/tty)
    if [[ -z "$CHOSEN_ID" ]]
    then
        dialog --msgbox "New tour was discarded" 0 0
        main_menu
    else
        dialog --msgbox "Succesfully added new tour" 0 0
    fi
}

start_menu() {
    dialog --extra-button --extra-label "Sign up" --ok-label "Login" --msgbox "Welcome to P.G.S.C.L.I\n Choose to sign up or login" 0 0 2>&1 > /dev/tty
    if [[ $? -eq 0 ]]
    then
        login_prompt
    else
        register_prompt
    fi
}

login_prompt() {
    local ENTERED_EMAIL=$(dialog --title "Login" --ok-label "Enter" --cancel-label "Exit" --inputbox "Login with your email:" 0 0 2>&1 >/dev/tty)
    if [[ -z $ENTERED_EMAIL ]]
    then
        exit 1
    fi
    local FOUND=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM Customer WHERE email LIKE '$ENTERED_EMAIL';" | tail +3 | head -n -2)
    if [[ -z $FOUND ]]
    then
        dialog --msgbox "Wrong email: $ENTERED_EMAIL" 0 0
        login_prompt
    else
        local USERNAME=$(echo $FOUND | awk -v FS="|" ' {print $2 $3}')
        LOGIN_ID_ONLY=$(echo $FOUND | awk '{print $1}')
        dialog --msgbox "Welcome\n$USERNAME! (id $LOGIN_ID_ONLY)" 0 0
        main_menu
    fi
}

register_prompt() {
    local USER_EMAIL=$(dialog --title "Registration" --inputbox "Enter your email" 0 0 >/dev/tty)
    if [[ $? -eq 0 ]]
    then
        start_menu
    else
        local FOUND=$(psql -U $SUPERUSER -d $DB_NAME -c "SELECT * FROM Customer WHERE email LIKE '$USER_EMAIL';" | tail +3 | head -n -2)
        if [[ -z $FOUND ]]
        then
            local USER_FIRSTNAME=$(dialog --title "Registration" --no-cancel --inputbox  "Enter your firstname" 0 0 2>&1 >/dev/tty)
            local USER_LASTNAME=$(dialog --title "Registration" --no-cancel --inputbox  "Enter your lastname" 0 0 2>&1 >/dev/tty)
            local USER_NUMBER=$(dialog --title "Registration" --no-cancel --inputbox  "Enter your number" 0 0 2>&1 >/dev/tty)
            ERROR=$(psql -U $SUPERUSER -d $DB_NAME -c "INSERT INTO Customer (first_name, last_name, email, phone) \
                                            VALUES ('$USER_FIRSTNAME', '$USER_LASTNAME', '$USER_EMAIL', '$USER_NUMBER')")
            if [[ $? -eq 0 ]]
            then
                dialog --msgbox "You succesfully registrated, proceed with log in with your email" 0 0
                login_prompt
            else
                dialog --msgbox "An unknown error occured: $ERROR" 0 0
                exit 1
            fi
        else
            dialog --title "Registration" --msgbox "This email already registered: $USER_EMAIL" 0 0
            register_prompt
        fi
    fi
    
}

editor_list_all_tours() {
    local FEATURES=$(psql -U $SUPERUSER -d $DB_NAME -c 'SELECT * FROM tour;' | awk -v FS="|" '{ gsub(" ", "", $2) } {print $1,$2}' | tr -s '\t' ' ' | head -n -2 | tail +3)
    local ARRAY=(${FEATURES//$'\n'/ })
    local CHOSEN_ID=$(dialog --cancel-label "Back" --extra-button --extra-label "Remove" --ok-label "Edit" --menu "Please choose a tour" 15 55 5 "${ARRAY[@]}" >/dev/tty)
    dialog --msgbox "$?" 0 0
}
