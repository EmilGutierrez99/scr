#!/bin/bash 
# Usuario root y contraseña para MySQL
ROOT_USER="root"
ROOT_PASS="password"

# Definir la ruta del archivo de log
RUTA_SCRIP="/home/user/scrip"
mkdir -p "$RUTA_SCRIP"  # Crear el directorio si no existe

# Definir el nombre del archivo de log con marca de tiempo
TIEMPO_LOG=$(date "+%Y%m%d_%H%M%S")
NOMBRE_LOG="wp_setup_db.log"
NOMBRE_FICH_LOG="${TIEMPO_LOG}_$NOMBRE_LOG"
LOG_FILE="$RUTA_SCRIP/$NOMBRE_FICH_LOG"

# Crear el archivo de log
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
echo "Archivo de log preparado en $LOG_FILE."

# Función para registrar en el log
log_Regis() {
  local function_name="$1"
  local timestamp=$(date "+%H-%M-%S-%d-%m-%Y")
  echo "$timestamp - Función utilizada: $function_name" >> "$LOG_FILE"
}

# Función para verificar si la base de datos ya existe
verificar_DB() {
  log_Regis "verificar_DB"
  local DB_NAME=$1
  local db_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SHOW DATABASES;" | grep "^$DB_NAME$")

  if [ "$db_exists" ]; then
    echo "Advertencia: La base de datos '$DB_NAME' ya existe. Por favor, elige otro nombre."
    read -p "Introduce otro nombre para la base de datos: " DB_NAME
    verificar_DB "$DB_NAME"
  fi
  echo "$DB_NAME"
}

# Función para verificar si el usuario ya existe
verificar_Usuario() {
  log_Regis "verificar_Usuario"
  local DB_USER=$1
  local user_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$DB_USER';" | grep "$DB_USER")

  if [ "$user_exists" ]; then
    echo "Advertencia: El usuario $DB_USER ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE AL USER: " DB_USER
    verificar_Usuario "$DB_USER"
  fi
  echo "$DB_USER"
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
    verificar_Tabla "$DB_NAME" "$DB_TABLE"
  fi
  echo "$DB_TABLE"
}

# Verificar los argumentos y variables
if [ "$#" -ne 4 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    echo "Ingrese manualmente"
    read -p "Ingresa el nombre de la DB: " DB_NAME
    read -p "Ingresa el nombre del nuevo USER: " DB_USER
    read -p "Ingresa el Password del nuevo USER: " USER_PASS
    read -p "Ingresa el nombre de la nueva Tabla: " TABLE_NAME
else 
    DB_NAME=$1
    DB_USER=$2
    USER_PASS=$3
    TABLE_NAME=$4
fi

DB_NAME=$(verificar_DB "$DB_NAME")
DB_USER=$(verificar_Usuario "$DB_USER")
TABLE_NAME=$(verificar_Tabla "$DB_NAME" "$TABLE_NAME")

# Creación de base de datos, usuario y tabla
echo "Iniciando configuración de la base de datos de WordPress..."
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$USER_PASS';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"

echo "Base de datos final: $DB_NAME"
echo "Usuario final: $DB_USER"
echo "Contraseña final: $USER_PASS"
echo "Tabla final: $TABLE_NAME"
echo "Configuración completada con éxito."
