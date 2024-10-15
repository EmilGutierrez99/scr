#!/bin/bash

# Variables
DB_NAME="DB_004"
DB_USER="USER_003"
DB_PASS="PASSWORD_003"
ROOT_USER="root"
ROOT_PASS="password"
TABLE_NAME="TABLE_002"

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