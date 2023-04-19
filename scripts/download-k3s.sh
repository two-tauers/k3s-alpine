#!/bin/sh

. ./URLS

DOWNLOAD_PATH=bin
K3S_FILENAME=k3s
K3S_INSTALL_FILENAME=k3s-install.sh

mkdir -p $DOWNLOAD_PATH

# download file if doesn't exist
if ls $DOWNLOAD_PATH | grep $K3S_FILENAME > /dev/null; then
    echo "File $DOWNLOAD_PATH/$K3S_FILENAME already exists"
else
    wget $K3S_URL -q --show-progress -O $DOWNLOAD_PATH/$K3S_FILENAME
fi

# download file if doesn't exist
if ls $DOWNLOAD_PATH | grep $K3S_INSTALL_FILENAME > /dev/null; then
    echo "File $DOWNLOAD_PATH/$K3S_INSTALL_FILENAME already exists"
else
    wget $K3S_INSTALL_URL -q --show-progress -O $DOWNLOAD_PATH/$K3S_INSTALL_FILENAME
fi
