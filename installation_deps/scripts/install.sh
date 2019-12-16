#!/bin/sh

REPLR_INSTALL_LOCATION=/usr/local/share/replr

sudo cp $1 $REPLR_INSTALL_LOCATION/config

exec_name=$(basename $1)
exec_file=/usr/bin/$exec_name

touch $exec_name.executable

echo "#!/bin/sh" >> $exec_name.executable
echo "name=$exec_name" >> $exec_name.executable
echo "REPLR_INSTALL_LOCATION=$REPLR_INSTALL_LOCATION" >> $exec_name.executable
echo "sed '1d' \$1 | replr exec \$REPLR_INSTALL_LOCATION/config/\$name" >> $exec_name.executable
chmod +x $exec_name.executable
sudo mv $exec_name.executable $exec_file


