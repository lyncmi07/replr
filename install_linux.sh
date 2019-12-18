#!/bin/sh

REPLR_INSTALL_LOCATION=/usr/local/share/replr

opam exec dune build @install
cp -r ./installation_deps ./installation_folder
cp ./_build/default/bin/main.exe ./installation_folder/replr

sudo mkdir $REPLR_INSTALL_LOCATION
sudo mkdir $REPLR_INSTALL_LOCATION/config
sudo mv ./installation_folder/* $REPLR_INSTALL_LOCATION
sudo ln -s $REPLR_INSTALL_LOCATION/scripts/replr_bin.sh /usr/bin/replr
