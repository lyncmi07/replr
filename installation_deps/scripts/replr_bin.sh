#!/bin/sh

REPLR_INSTALL_LOCATION=/usr/local/share/replr

if test "$1" = 'install'; then
    $REPLR_INSTALL_LOCATION/scripts/install.sh
fi

if test "$1" = 'list'; then
    $REPLR_INSTALL_LOCATION/scripts/list.sh
fi

if test "$1" = 'remove'; then
    $REPLR_INSTALL_LOCATION/scripts/remove.sh
fi

if test "$1" = 'exec'; then
    $REPLR_INSTALL_LOCATION/replr $2
fi
