#!/bin/bash

# Verificar que se han pasado los tres argumentos necesarios
if [ "$#" -ne 4 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    exit 1
fi

# Asignar los argumentos a variables
DB_NAME=$1
DB_USER=$2
DB_PASSWORD=$3
DB_TABLE=$4

#Usuario root
ROOT_USER="root"
ROOT_PASS="password"

# Mensaje de confirmación de inicio
echo "Iniciando configuración de la base de datos de WordPress..."
echo "Nombre de la base de datos: $DB_NAME"
echo "Usuario de la base de datos: $DB_USER"
echo "Contraseña de la base de datos: $DB_PASSWORD"
echo "Nombre de la tabla $DB_TABLE en la base de datos: $DB_NAME"

# Crear la base de datos
echo "Creando la base de datos..."
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Crear el usuario y asignarle permisos
echo "Creando usuario y asignando permisos..."
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"

# Verificar si el usuario puede crear una tabla
mysql -u $DB_USER -p"$DB_PASSWORD" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $DB_TABLE (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"


# Confirmación de finalización
echo "La configuración de la base de datos ha finalizado exitosamente."
echo "Puedes continuar con la instalación de WordPress."

exit 0