#!/bin/bash

source "../src/msg.sh"

error_message() {
    echo "$ERR_PREFIX$1"
    exit 1
}

param_count_ceil() {
    if [ $1 -gt $2 ] 
        then
            error_message "Too much params: max count is $2, provided: $1"
    fi
}

param_count_floor() {
    if [ $1 -lt $2 ] 
        then
            error_message "Too low params: min count is $2, provided: $1"
    fi
}


valid_regular() {
    if ! [[ "$1" =~ $2 ]]
        then
            return 1
    fi
    return 0
}

