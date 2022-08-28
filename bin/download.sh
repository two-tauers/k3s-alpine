#!/bin/sh

if test -z "$1" 
then
      echo "download.sh requires the download url as the first argument"
      exit 1
fi

DOWNLOAD_URL=$1
DOWNLOAD_PATH=bin/download
FILENAME=`echo ${DOWNLOAD_URL} | rev | cut -d/ -f 1 | rev`

mkdir -p $DOWNLOAD_PATH

# download file if doesn't exist
if ls $DOWNLOAD_PATH | grep $FILENAME > /dev/null; then
    echo "File $DOWNLOAD_PATH/$FILENAME already exists"
else
    wget $DOWNLOAD_URL -P $DOWNLOAD_PATH -q --show-progress
fi
