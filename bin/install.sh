#!/bin/sh

if test -z "$1" 
then
      echo "install.sh requires the alpine linux tarball name as the first argument"
      exit 1
fi

if test -z "$2" 
then
      echo "install.sh requires the headless bootstrap tarball name as the second argument"
      exit 1
fi

if test -z "$3" 
then
      echo "install.sh requires the installation path as the third argument"
      exit 1
fi

ALPINE_TAR_PATH=$1
HEADLESS_TAR_PATH=$2
INSTALL_PATH=$3

tar -xzvf $ALPINE_TAR_PATH -C $INSTALL_PATH
cp $HEADLESS_TAR_PATH $INSTALL_PATH