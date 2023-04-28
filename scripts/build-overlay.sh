#!/bin/sh

CONFIG=$1
STAGING=bin/staging

if [ -z $CONFIG ]; then
    echo "Please specify a path to a config file as an argument, quitting..."
    exit 1
fi
which yq > /dev/null 2>&1 || (echo "Package yq is not installed, quitting..." && exit 1)

echo "[INFO] Reading config file"
hostname=$(yq '.hostname' < $CONFIG)
username=$(yq '.user.name' < $CONFIG)
pubfile=$(eval echo $(yq '.user.pubfile' < $CONFIG))
pubkey=$(cat $pubfile)
k3s_exec=$(yq '.k3s.exec' < $CONFIG)

echo "[INFO] Generating host keys"
mkdir -p overlay/etc/ssh/
test -f overlay/etc/ssh/ssh_host_dsa_key || ssh-keygen -q -N "" -t dsa -f overlay/etc/ssh/ssh_host_dsa_key
test -f overlay/etc/ssh/ssh_host_rsa_key || ssh-keygen -q -N "" -t rsa -b 4096 -f overlay/etc/ssh/ssh_host_rsa_key
test -f overlay/etc/ssh/ssh_host_ecdsa_key || ssh-keygen -q -N "" -t ecdsa -f overlay/etc/ssh/ssh_host_ecdsa_key
test -f overlay/etc/ssh/ssh_host_ed25519_key || ssh-keygen -q -N "" -t ed25519 -f overlay/etc/ssh/ssh_host_ed25519_key
chmod 600 overlay/etc/ssh/ssh_host_*_key

echo "[INFO] Copying files to a staging folder"
mkdir -p $STAGING
rm -r $STAGING/*
cp -r overlay/* $STAGING

echo "[INFO] Setting a hostname"
echo $hostname > $STAGING/etc/hostname

echo "[INFO] Adding the ssh key"
echo $pubkey > $STAGING/etc/pubkeys/$username

echo "[INFO] Adding k3s configs"
mkdir -p $STAGING/etc/boot-data/k3s
yq '.k3s.config' < $CONFIG > $STAGING/etc/boot-data/k3s/config.yaml
echo $k3s_exec > $STAGING/etc/boot-data/k3s/exec

echo "[INFO] Adding k3s installer"
mkdir -p $STAGING/etc/boot-data/install
cp bin/k3s-install.sh $STAGING/etc/boot-data/install/k3s-install.sh
cp bin/k3s $STAGING/etc/boot-data/install/k3s

echo -n "[INFO] Packaging overlay"
chmod +x $STAGING/etc/local.d/headless.start
tar -czf bin/overlay.apkovl.tar.gz -C $STAGING etc --owner=0 --group=0 --checkpoint=1000 --checkpoint-action=dot && echo "done"
