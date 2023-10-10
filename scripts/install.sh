#!/bin/sh

. "scripts/_common.sh"

if test -z "$1"; then
    log "ERROR" "install.sh requires the alpine linux tarball name as the first argument"
fi

if test -z "$2"; then
    log "ERROR" "install.sh requires the bootstrap tarball name as the second argument"
fi

if test -z "$3"; then
    log "ERROR" "install.sh requires the installation path as the third argument"
fi

ALPINE_TAR_PATH=$1
OVERLAY_TAR_PATH=$2
INSTALL_PATH=$3

log "INFO" "Installing alpine with overlay to $INSTALL_PATH"

log "INFO" "Copying contents of ${ALPINE_TAR_PATH}"
tar -xzf $ALPINE_TAR_PATH -C $INSTALL_PATH || log "ERROR" "Couldn't copy $ALPINE_TAR_PATH to $INSTALL_PATH"

log "INFO" "Copying contents of ${OVERLAY_TAR_PATH}"
cp $OVERLAY_TAR_PATH $INSTALL_PATH  || log "ERROR" "Couldn't copy $OVERLAY_TAR_PATH to $INSTALL_PATH"

log "INFO" "Copying usercfg.txt"
cp boot/usercfg.txt $INSTALL_PATH  || log "ERROR" "Couldn't copy usercfg.txt to $INSTALL_PATH"

log "INFO" "Copying cmdline.txt"
cp boot/cmdline.txt $INSTALL_PATH  || log "ERROR" "Couldn't copy cmdline.txt to $INSTALL_PATH"

log "INFO" "All files copied to $INSTALL_PATH"
