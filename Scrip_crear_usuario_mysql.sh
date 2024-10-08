#!/bin/bash

# Variables
DB_NAME="DB_001"
DB_USER="USER_001"
DB_PASS="PASSWORD_001"
ROOT_USER="root"
ROOT_PASS="password"


# Crear base de datos
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Crear usuario y asignar permisos
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"

# Verificar si el usuario puede crear una tabla
mysql -u $DB_USER -p"$DB_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS TABLE_001 (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"

# Comprobación final
if [ $? -eq 0 ]; then
  echo "El usuario $DB_USER ha creado la tabla TABLE_001 correctamente en la base de datos $DB_NAME."
else
  echo "Hubo un error al intentar crear la tabla con el usuario $DB_USER."
fi

echo "Listado de usuarios MySQL:"
mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SELECT user, host FROM mysql.user;"

# Mostrar todas las tablas en la base de datos especificada
echo "Listado de tablas en la base de datos $DB_NAME:"
mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SHOW TABLES FROM $DB_NAME;"

# Comprobación de errores
if [ $? -eq 0 ]; then
  echo "Usuarios y tablas mostrados correctamente."
else
  echo "Hubo un error al mostrar los usuarios o tablas."
fi
