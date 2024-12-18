#!/bin/bash

####---LOG--CREACIÓN---####
# Definir la ruta absoluta del archivo de log
LOG_FILE="/home/user/registro.log"
# Verificar si el archivo existe en la ruta especificada
if [ -f "$LOG_FILE" ]; then
    echo "El archivo de log ya existe en $LOG_FILE. Será reemplazado por uno nuevo."
    rm "$LOG_FILE"  # Eliminar el archivo existente
fi
# Crear un nuevo archivo de log y otorgar permisos de escritura
touch "$LOG_FILE"  # Crea el archivo si no existe o después de eliminar el anterior
chmod 644 "$LOG_FILE"  # Otorga permisos de lectura y escritura
# Mensaje de confirmación
echo "Archivo de log preparado en $LOG_FILE."
####---LOG--CREACIÓN--FIN---####

####---FUNCIONES---####
log_Regis() {
  local function_name="$1"
  local timestamp=$(date "+%H-%M-%S-%d-%m-%Y")
  echo "$timestamp - Función utilizada: $function_name" >> "$LOG_FILE"
}

# Función para verificar si la base de datos ya existe
verificar_DB() {
  log_Regis "verificar_DB"
  local DB_NAME=$1
  local db_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME")

  if [ "$db_exists" ]; then
    echo "Advertencia: La base de datos $DB_NAME ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE A LA DB: " DB_NAME
    verificar_DB "$DB_NAME"  # Llamada recursiva para verificar el nuevo nombre
  fi

  echo "$DB_NAME"  # Retornar el nombre final
}

# Función para verificar si el usuario ya existe
verificar_Usuario() {
  log_Regis "verificar_Usuario"
  local DB_USER=$1
  local user_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$DB_USER';" | grep "$DB_USER")

  if [ "$user_exists" ]; then
    echo "Advertencia: El usuario $DB_USER ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE AL USER: " DB_USER
    verificar_Usuario "$DB_USER"  # Llamada recursiva para verificar el nuevo nombre
  fi

  echo "$DB_USER"  # Retornar el nombre final
}

# Función para verificar si la tabla ya existe
verificar_Tabla() {
  log_Regis "verificar_Tabla"
  local DB_NAME=$1
  local DB_TABLE=$2
  local table_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "USE $DB_NAME; SHOW TABLES LIKE '$DB_TABLE';" | grep "$DB_TABLE")

  if [ "$table_exists" ]; then
    echo "Advertencia: La tabla $DB_TABLE ya existe en la base de datos $DB_NAME. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE A LA TABLA: " DB_TABLE
    verificar_Tabla "$DB_NAME" "$DB_TABLE"  # Llamada recursiva para verificar el nuevo nombre
  fi

  echo "$DB_TABLE"  # Retornar el nombre final
}

# Función para validar longitud (8-64) y caracteres permitidos (letras, números y _)
validar_longitud_y_caracteres() {
  log_Regis "validar_longitud_y_caracteres"
  local input="$1"
  if [[ ! "$input" =~ ^[a-zA-Z0-9_]{8,64}$ ]]; then
    echo "Error: El nombre '$input' no cumple con la longitud permitida (8-64 caracteres) o contiene caracteres no válidos."
    read -p "INTRODUCE OTRA VEZ: " input
    validar_longitud_y_caracteres "$input"
  else
    echo "$input"  # Retornar el input válido
  fi
}
####---FUNCIONES--FIN--####

# Verificar que se han pasado los cuatro argumentos necesarios
if [ "$#" -ne 4 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    
    read -p "Ingresa el nombre de la DB (a-z, A-Z, 0-9, _): " DB_NAME
    read -p "Ingresa el nombre del nuevo USER (a-z, A-Z, 0-9, _): " DB_USER
    read -p "Ingresa el Password del nuevo USER (a-z, A-Z, 0-9, _): " USER_PASS
    read -p "Ingresa el nombre de la nueva Tabla (a-z, A-Z, 0-9, _): " TABLE_NAME
else 
    #VARIABLES
    DB_NAME=$1
    DB_USER=$2
    USER_PASS=$3
    TABLE_NAME=$4
    ###VARIABLES###
fi


# Usuario root y contraseña para MySQL
ROOT_USER="root"
ROOT_PASS="password"

####---USO--DE--FUNCIONES---####
# Validación y ajuste de los valores de entrada
DB_NAME=$(verificar_DB "$DB_NAME")
DB_USER=$(verificar_Usuario "$DB_USER")
TABLE_NAME=$(verificar_Tabla "$DB_NAME" "$TABLE_NAME")

DB_NAME=$(validar_longitud_y_caracteres "$DB_NAME")
DB_USER=$(validar_longitud_y_caracteres "$DB_USER")
USER_PASS=$(validar_longitud_y_caracteres "$USER_PASS")
TABLE_NAME=$(validar_longitud_y_caracteres "$TABLE_NAME")
####---USO--DE--FUNCIONES--FIN--####

# Creación de base de datos, usuario y tabla
echo "Iniciando configuración de la base de datos de WordPress..."
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$USER_PASS';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"
mysql -u $DB_USER -p"$USER_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"

echo "Base de datos final: $DB_NAME"
echo "Usuario final: $DB_USER"
echo "Contraseña final: $DB_PASSWORD"
echo "Tabla final: $TABLE_NAME"

echo "Configuración completada con éxito."
