#!/bin/sh

if test -z "$1"
then
    echo "install.sh requires the alpine linux tarball name as the first argument"
    exit 1
fi

if test -z "$2"
then
    echo "install.sh requires the bootstrap tarball name as the second argument"
    exit 1
fi

if test -z "$3"
then
    echo "install.sh requires the installation path as the third argument"
    exit 1
fi

ALPINE_TAR_PATH=$1
OVERLAY_TAR_PATH=$2
INSTALL_PATH=$3

echo -n "Copying contents of ${ALPINE_TAR_PATH}"
tar -xzf $ALPINE_TAR_PATH -C $INSTALL_PATH --checkpoint=1000 --checkpoint-action=dot && echo " done"

echo -n "Copying contents of ${OVERLAY_TAR_PATH}..."
cp $OVERLAY_TAR_PATH $INSTALL_PATH && echo " done"

echo -n "Copying usercfg.txt..."
cp boot/usercfg.txt $INSTALL_PATH && echo " done"

echo -n "Copying cmdline.txt..."
cp boot/cmdline.txt $INSTALL_PATH && echo " done"
