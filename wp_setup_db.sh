#!/bin/bash
# Usuario root y contraseña para MySQL
ROOT_USER="root"
ROOT_PASS="password"

# Definir la ruta del archivo de log
RUTA_SCRIP="/home/user/scrip"
mkdir -p "$RUTA_SCRIP"  # Crear el directorio si no existe

####---LOG--CREACIÓN---####
# Definir el nombre del archivo de log con marca de tiempo
TIEMPO_LOG=$(date "+%Y%m%d_%H%M%S")
NOMBRE_LOG="wp_setup_db.log"
NOMBRE_FICH_LOG="${TIEMPO_LOG}_$NOMBRE_LOG"
MENSAJE="CORRECTO"

# Ruta completa del archivo de log
LOG_FILE="$RUTA_SCRIP/$NOMBRE_FICH_LOG"

# Verificar si el archivo de log ya existe y eliminarlo si es necesario
if [ -f "$LOG_FILE" ]; then
    echo "El archivo de log ya existe en $LOG_FILE. Será reemplazado por uno nuevo."
    rm "$LOG_FILE"
fi

# Crear el nuevo archivo de log y definir permisos
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
echo "Archivo de log preparado en $LOG_FILE."
####---LOG--CREACIÓN--FIN---####

####---FUNCIONES---####
log_Regis() {
  local function_name="$1"
  local timestamp=$(date "+%H-%M-%S-%d-%m-%Y")
  echo "$timestamp - Función utilizada: $function_name ......$MENSAJE" >> "$LOG_FILE"
}

# Función para verificar si la base de datos ya existe
verificar_DB() {
  log_Regis "verificar_DB"
  local DB_NAME=$1
  
  # Buscar la existencia de la base de datos sin necesidad de conectarse a una en específico
  local db_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SHOW DATABASES;" | grep "^$DB_NAME$")

  if [ "$db_exists" ]; then
    echo "Advertencia: La base de datos '$DB_NAME' ya existe. Por favor, elige otro nombre."
    read -p "Introduce otro nombre para la base de datos: " DB_NAME
    verificar_DB "$DB_NAME"  # Llamada recursiva con el nuevo nombre
  fi
  
  echo "$DB_NAME"  # Retorna el nombre de la base de datos válido
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
#######--Funcion con Errores--######
# Función para validar longitud (8-64) 
validar_longitud_regex() {
  local input="$1"
  if [[ ! "$input" =~ ^.{8,64}$ ]]; then
    echo "Error: El nombre '$input' no cumple con la longitud permitida (8-64 caracteres)."
    read -p "INTRODUCE OTRA VEZ: " input
    
  fi
}
#Funcion para validar caracteres permitidos (letras, números y _)
validar_caracteres_regex() {
  local input="$1"
  local allowed_chars_regex='^[a-zA-Z0-9_]+$'
  if [[ ! "$input" =~ $allowed_chars_regex ]]; then
    echo "Error: El nombre '$input' contiene caracteres no válidos. Solo se permiten letras, números y guiones bajos (_)."
    echo "Caracteres válidos: letras (a-z, A-Z), números (0-9) y guión bajo (_)."
    read -p "INTRODUCE OTRA VEZ: " input
    
  fi
}
#######--Funcion con Errores-Fin-######
#
####---FUNCIONES--FIN--####

# Verificar que se han pasado los cuatro argumentos necesarios
if [ "$#" -ne 4 ]; then
    echo "No Uso Argumentos: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    echo "Ingrese manualmente"
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

####---USO--DE--FUNCIONES---####
# Validación y ajuste de los valores de entrada
DB_NAME=$(verificar_DB "$DB_NAME")
DB_USER=$(verificar_Usuario "$DB_USER")
TABLE_NAME=$(verificar_Tabla "$DB_NAME" "$TABLE_NAME")

DB_NAME=$(validar_longitud_regex "$DB_NAME")
DB_NAME=$(validar_caracteres_regex "$DB_NAME")

DB_USER=$(validar_longitud_regex "$DB_USER")
DB_USER=$(validar_caracteres_regex "$DB_USER")

USER_PASS=$(validar_longitud_regex "$USER_PASS")
USER_PASS=$(validar_caracteres_regex "$USER_PASS")

TABLE_NAME=$(validar_longitud_regex "$TABLE_NAME")
TABLE_NAME=$(validar_caracteres_regex "$TABLE_NAME")

####---USO--DE--FUNCIONES--FIN--####

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
