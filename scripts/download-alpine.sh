#!/bin/sh

. ./URLS

DOWNLOAD_PATH=bin
FILENAME=$(echo ${ALPINE_URL} | rev | cut -d/ -f 1 | rev)

mkdir -p $DOWNLOAD_PATH

# download file if doesn't exist
if ls $DOWNLOAD_PATH | grep $FILENAME > /dev/null; then
    echo "File $DOWNLOAD_PATH/$FILENAME already exists"
else
    wget $ALPINE_URL -P $DOWNLOAD_PATH -q --show-progress
fi
