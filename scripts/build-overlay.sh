#!/bin/sh

HOSTNAME=$1

echo "Setting hostname to $HOSTNAME"
echo $HOSTNAME > overlay/etc/hostname

echo "Packaging apkovl in a tarball"
chmod +x overlay/etc/local.d/headless.start
tar -czvf bin/overlay.apkovl.tar.gz -C overlay etc --owner=0 --group=0 --checkpoint=1000 --checkpoint-action=dot
