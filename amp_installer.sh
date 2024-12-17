#!/bin/bash

DIR_USER="/home/emil/wp-scripts"

cd $DIR_USER/
sudo chmod +x mysql_installer.sh
./mysql_installer.sh

cd $DIR_USER/
sudo chmod +x apache_installer.sh
./apache_installer.sh

cd $DIR_USER/
sudo chmod +x php_installer.sh
./php_installer.sh

echo "Se instalo correctamente mysql, apache y php"
