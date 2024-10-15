#!/bin/bash

# Variables
read -p "Introduce el nombre de la DB: " DB_NAME
read -p "Introduce el nombre del nuevo USER: " DB_USER
read -p "Introduce el Password del nuevo USER: " USER_PASS
read -p "Introduce el nombre de la nueva Tabla: " TABLE_NAME
ROOT_USER="root"
ROOT_PASS="password"


# Función para verificar longitud de los nombres
check_length() {
  local name="$1"
  local min_length=8
  local max_length=64
  
  if [ ${#name} -lt $min_length ]; then
    echo "Error: El nombre '$name' es demasiado corto. Mínimo $min_length caracteres."
    exit 1
  elif [ ${#name} -gt $max_length ]; then
    echo "Error: El nombre '$name' es demasiado largo. Máximo $max_length caracteres."
    exit 1
  fi
}

# Validar longitud de los nombres
check_length "$DB_NAME"
check_length "$DB_USER"
check_length "$TABLE_NAME"

# Verificar si la base de datos ya existe
db_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME")
if [ "$db_exists" ]; then
  echo "Advertencia: La base de datos $DB_NAME ya existe. Por favor, elige otro nombre."
  exit 1
fi

# Verificar si el usuario ya existe
user_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$DB_USER';" | grep "$DB_USER")
if [ "$user_exists" ]; then
  echo "Advertencia: El usuario $DB_USER ya existe. Por favor, elige otro nombre."
  read -p "INTRODUCE OTRO NOMBRE A LA DB: " DB_NAME
fi

# Verificar si la tabla ya existe
table_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "USE $DB_NAME; SHOW TABLES LIKE '$TABLE_NAME';" | grep "$TABLE_NAME")
if [ "$table_exists" ]; then
  echo "Advertencia: La tabla $TABLE_NAME ya existe en la base de datos $DB_NAME. Por favor, elige otro nombre."
  exit 1
fi

# Crear base de datos
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Crear usuario y asignar permisos
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$USER_PASS';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"

# Verificar si el usuario puede crear una tabla
mysql -u $DB_USER -p"$USER_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(64));"

# Comprobación final
if [ $? -eq 0 ]; then
  echo "El usuario $DB_USER ha creado la tabla $TABLE_NAME correctamente en la base de datos $DB_NAME."
else
  echo "Hubo un error al intentar crear la tabla con el usuario $DB_USER."
fi
