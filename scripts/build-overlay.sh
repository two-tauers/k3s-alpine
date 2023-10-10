#!/bin/sh

# import common functions
. "scripts/_common.sh"

CONFIG=$1
STAGING=bin/staging
OUTPUT=bin/overlay.apkovl.tar.gz

if test -z $CONFIG; then
    log "ERROR" "Config file not specified"
fi

log "INFO" "Building overlay using config: $CONFIG"
which yq > /dev/null 2>&1 || log "ERROR" "Package yq is not installed"

log "INFO" "Reading config file"
hostname=$(yq '.hostname' < $CONFIG) || log "ERROR" "Could not read hostname from the config"
k3s_exec=$(yq '.k3s.exec' < $CONFIG) || log "ERROR" "Could not read k3s exec mode from the config"

if [ "$k3s_exec" != "server" ] && [ "$k3s_exec" != "agent" ]; then
    log "ERROR" "Unknown k3s exec mode: '$k3s_exec'. Must be one of: 'server', 'agent'"
fi

log "INFO" "Generating host keys"
mkdir -p overlay/etc/ssh/
test -f overlay/etc/ssh/ssh_host_dsa_key || ssh-keygen -q -N "" -t dsa -f overlay/etc/ssh/ssh_host_dsa_key
test -f overlay/etc/ssh/ssh_host_rsa_key || ssh-keygen -q -N "" -t rsa -b 4096 -f overlay/etc/ssh/ssh_host_rsa_key
test -f overlay/etc/ssh/ssh_host_ecdsa_key || ssh-keygen -q -N "" -t ecdsa -f overlay/etc/ssh/ssh_host_ecdsa_key
test -f overlay/etc/ssh/ssh_host_ed25519_key || ssh-keygen -q -N "" -t ed25519 -f overlay/etc/ssh/ssh_host_ed25519_key
chmod 600 overlay/etc/ssh/ssh_host_*_key || log "ERROR" "Cannot change host SSH keys' permissions. You might need to be root"

log "INFO" "Copying files to a staging folder"
mkdir -p $STAGING
rm -r $STAGING/*
cp -r overlay/* $STAGING

log "INFO" "Setting a hostname"
echo $hostname > $STAGING/etc/hostname



log "INFO" "Adding node config"
cp $CONFIG $STAGING/etc/node-config.yaml


log "INFO" "Adding k3s config"
mkdir -p $STAGING/etc/boot-config/k3s
echo $CONFIG > $STAGING/etc/boot-config/k3s/config.yaml
echo $k3s_exec > $STAGING/etc/boot-config/k3s/exec

log "INFO" "Adding k3s installer"
mkdir -p $STAGING/etc/boot-data/install
cp bin/k3s-install.sh $STAGING/etc/boot-data/install/k3s-install.sh
cp bin/k3s $STAGING/etc/boot-data/install/k3s


log "INFO" "Packaging overlay"
chmod +x $STAGING/etc/local.d/headless.start
tar -czf $OUTPUT -C $STAGING etc --owner=0 || log "ERROR" "Failed to package the overlay"

log "INFO" "Overlay saved to $OUTPUT"
