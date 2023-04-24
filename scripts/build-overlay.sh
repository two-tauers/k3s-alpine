#!/bin/sh

CONFIG=$1
STAGING=bin/staging

if [ -z $CONFIG ]; then
    echo "Please specify a path to a config file as an argument, quitting..."
    exit 1
fi
which yq > /dev/null 2>&1 || (echo "Package yq is not installed, quitting..." && exit 1)

echo "...Reading config file"
hostname=$(yq '.hostname' < $CONFIG)
username=$(yq '.user.name' < $CONFIG)
pubfile=$(eval echo $(yq '.user.pubfile' < $CONFIG))
pubkey=$(cat $pubfile)
k3s_exec=$(yq '.k3s.exec' < $CONFIG)

echo "...Copying files to a staging folder"
mkdir -p $STAGING
rm -r $STAGING/*
cp -r overlay/* $STAGING

echo "...Setting a hostname"
echo $hostname > $STAGING/etc/hostname

echo "...Adding the ssh key"
echo $pubkey > $STAGING/etc/pubkeys/$username

echo "...Adding k3s configs"
mkdir -p $STAGING/etc/rancher/k3s
yq '.k3s.config' < $CONFIG > $STAGING/etc/rancher/k3s/config.yaml
echo $k3s_exec > $STAGING/etc/rancher/k3s/exec

echo "...Adding k3s installer"
mkdir -p $STAGING/etc/rancher/install
cp bin/k3s-install.sh $STAGING/etc/rancher/install/k3s-install.sh
cp bin/k3s $STAGING/etc/rancher/install/k3s

echo "...Packaging overlay"
chmod +x $STAGING/etc/local.d/headless.start
tar -czf bin/overlay.apkovl.tar.gz -C $STAGING etc --owner=0 --group=0 --checkpoint=1000 --checkpoint-action=dot
echo " bin/overlay.apkovl.tar.gz"
echo "...Done"
