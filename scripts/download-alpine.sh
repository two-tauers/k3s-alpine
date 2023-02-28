#!/bin/sh

DOWNLOAD_URL=$(cat alpine-url)
DOWNLOAD_PATH=bin
FILENAME=$(echo ${DOWNLOAD_URL} | rev | cut -d/ -f 1 | rev)

mkdir -p $DOWNLOAD_PATH

# download file if doesn't exist
if ls $DOWNLOAD_PATH | grep $FILENAME > /dev/null; then
    echo "File $DOWNLOAD_PATH/$FILENAME already exists"
else
    wget $DOWNLOAD_URL -P $DOWNLOAD_PATH -q --show-progress
fi
