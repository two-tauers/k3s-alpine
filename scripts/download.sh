#!/bin/sh

# import common functions
. "scripts/_common.sh"

if test -z "$1"; then
    log "ERROR" "download.sh requires a download url as the first argument"
fi

if test -z "$2"; then
    log "ERROR" "download.sh requires download path as the second argument"
fi

URL=$1
TARGET=$2

log "INFO" "Downloading $URL"
test -f ${TARGET} && log "INFO" "File ${TARGET} already exists, delete it to redownload" || wget ${URL} -O ${TARGET} -q --show-progress || log "ERROR" "Failed to download $URL"
