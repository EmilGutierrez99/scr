#!/bin/bash

DIR_USER="/home/emil/wp-scripts/"

read -p "INTRODUCE EL PASSWORD ROOT: " DB_ROOT_PASSWORD
$DB_ROOT_PASSWORD = $1

# Actualizar la lista de paquetes
sudo apt update -y

echo "MySQL instalando.."
# Instalar debconf-utils para preconfigurar la instalación
sudo apt install -y debconf-utils

# Configurar las respuestas para la instalación de MySQL

echo "mysql-server mysql-server/root_password password $DB_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DB_ROOT_PASSWORD" | sudo debconf-set-selections

# Instalar MySQL Server
sudo apt install -y mysql-server

echo "MySQL se ha instalado y configurado correctamente de forma desatendida."


echo "MySQL Correct"


