#!/bin/sh

log () {
    echo "[$1] $2"
    if [ "$1" = "ERROR" ]; then
        exit 1
    fi
}
