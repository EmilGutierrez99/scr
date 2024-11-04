#!/bin/bash

# Verificar que se han pasado los tres argumentos necesarios
if [ "$#" -ne 3 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db>"
    exit 1
fi

# Asignar los argumentos a variables
DB_NAME=$1
DB_USER=$2
DB_PASSWORD=$3

#Usuario root
ROOT_USER="root"
ROOT_PASS="password"

# Mensaje de confirmación de inicio
echo "Iniciando configuración de la base de datos de WordPress..."
echo "Nombre de la base de datos: $DB_NAME"
echo "Usuario de la base de datos: $DB_USER"
echo "Contraseña de la base de datos: $DB_PASSWORD"

# Crear la base de datos
echo "Creando la base de datos..."
mysql -u root -p -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;"

# Crear el usuario y asignarle permisos
echo "Creando usuario y asignando permisos..."
mysql -u $ROOT_USER -p $ROOT_PASS -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u $ROOT_USER -p $ROOT_PASS -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p $ROOT_PASS -e "FLUSH PRIVILEGES;"

# Confirmación de finalización
echo "La configuración de la base de datos ha finalizado exitosamente."
echo "Puedes continuar con la instalación de WordPress."

exit 0