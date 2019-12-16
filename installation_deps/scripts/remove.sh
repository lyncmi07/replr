#!/bin/sh

REPLR_INSTALL_LOCATION=/usr/local/share/replr

if test -f $REPLR_INSTALL_LOCATION/config/$1; then
    echo "Deleting $1 replr files"
    sudo rm $REPLR_INSTALL_LOCATION/config/$1
    sudo rm /usr/bin/$1
    exit 0
fi

echo "There is no replr program $1"
exit 1
