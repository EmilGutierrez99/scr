#!/bin/bash

# Variables
read -p "Introduce el nombre de la DB a revisar: " DB_NAME
ROOT_USER="root"
ROOT_PASS="password"


#####
echo "Listado de usuarios MySQL:"
mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SELECT user, host FROM mysql.user;"

echo "Listado de bases de datos en el servidor MySQL:"
mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SHOW DATABASES;"

# Mostrar todas las tablas en la base de datos especificada
echo "Listado de tablas en la base de datos $DB_NAME:"
mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SHOW TABLES FROM $DB_NAME;"

# Comprobación de errores
if [ $? -eq 0 ]; then
  echo "Usuarios y tablas mostrados correctamente."
else
  echo "Hubo un error al mostrar los usuarios o tablas."
fi
######