#!/bin/sh

HOSTNAME=$1
ROLE=$2

echo "Setting hostname to $HOSTNAME"
echo $HOSTNAME > overlay/etc/hostname

echo "Setting role to $ROLE"
mkdir -p overlay/etc/rancher/k3s
cp k3s-configs/$ROLE.yaml overlay/etc/rancher/k3s/config.yaml

echo "Adding k3s installation script and binary"
cp bin/k3s-install.sh overlay/etc/rancher/install/k3s-install.sh
cp bin/k3s overlay/etc/rancher/install/k3s

echo "Packaging apkovl in a tarball"
chmod +x overlay/etc/local.d/headless.start
tar -czvf bin/overlay.apkovl.tar.gz -C overlay etc --owner=0 --group=0 --checkpoint=1000 --checkpoint-action=dot

echo "Cleaning up"
overlay/etc/rancher/k3s/config.yaml
rm overlay/etc/rancher/install/k3s-install.sh
rm overlay/etc/rancher/install/k3s
