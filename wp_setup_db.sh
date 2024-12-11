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
  echo "$timestamp - Función utilizada: $function_name ......" >> "$LOG_FILE"
}

# Función para verificar si la tabla ya existe
verificar_Tabla() { 
  log_Regis "verificar_Tabla"
  local DB_NAME=$1
  local DB_TABLE=$2
  while true; do
    local table_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -se \
      "USE $DB_NAME; SHOW TABLES LIKE '$DB_TABLE';" 2>/dev/null)
    
    if [ "$table_exists" ]; then
      echo "Advertencia: La tabla '$DB_TABLE' ya existe en la base de datos '$DB_NAME'."
      read -p "Introduce otro nombre para la tabla: " DB_TABLE
    else
      break  # Salir del bucle si no existe
    fi
  done
  echo "$DB_TABLE"  
}

validar_longitud_regex() {
    log_Regis "validar_longitud_regex"
    local input="$1"
    if [[ ${#input} -ge 8 && ${#input} -le 64 ]]; then
        echo "$input"
    else
        echo "Error: La longitud debe estar entre 8 y 64 caracteres." >&2
        echo ""
    fi
}

validar_caracteres_regex() {
    log_Regis "validar_caracteres_regex"
    local input="$1"
    if [[ "$input" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "$input"
    else
        echo "Error: Solo se permiten letras, números y guiones bajos (_)." >&2
        echo ""
    fi
}

validar_longitud_regex_des() {
    log_Regis "validar_longitud_regex_des"
    local input="$1"
    if [[ ${#input} -ge 8 && ${#input} -le 64 ]]; then
        echo "$input"
    else
        echo "Error: La longitud debe estar entre 8 y 64 caracteres."
        echo "no se puede ejecutar"
        log_Regis "Error en validar_longitud_regex_des de "$input""
        exit 1
    fi
}

#Funcion para validar caracteres permitidos (letras, números y _)
validar_caracteres_regex_des() {
    log_Regis "validar_caracteres_regex_des"
    local input="$1"
    if [[ "$input" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "$input"
    else
        echo "Error: Solo se permiten letras, números y guiones bajos (_)."
        echo "no se puede ejecutar"
        log_Regis "Error en validar_caracteres_regex_des de "$input""
        exit 1
    fi
}

verificar_database_exists() {
  local db_name=$1  
  # Verificar si la base de datos existe usando las variables globales ROOT_USER y ROOT_PASS
  local db_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$db_name';" | grep "$db_name") 
  # Si la base de datos existe, solicita un nuevo nombre
  while [ "$db_exists" ]; do
    echo "Advertencia: La base de datos '$db_name' ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE A LA DB: " db_name
    db_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$db_name';" | grep "$db_name")
  done
  echo "La base de datos '$db_name' no existe. Puedes usar este nombre."
  echo "$db_name" # Devuelve el nombre final
}

verificar_user_exists() {
  local db_user=$1
  # Verificar si el usuario existe usando las variables globales ROOT_USER y ROOT_PASS
  local user_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$db_user';" | grep "$db_user")
  # Si el usuario existe, solicita un nuevo nombre
  while [ "$user_exists" ]; do
    echo "Advertencia: El usuario '$db_user' ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE AL USER: " db_user
    user_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$db_user';" | grep "$db_user")
  done
  echo "El usuario '$db_user' no existe. Puedes usar este nombre."
  echo "$db_user" # Devuelve el nombre final
}

verificar_database_exists_des() {
  local db_name=$1 
  # Verificar si la base de datos existe usando las variables globales ROOT_USER y ROOT_PASS
  local db_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$db_name';" | grep "$db_name") 
  # Si la base de datos existe, solicita un nuevo nombre
  while [ "$db_exists" ]; do
    echo "Advertencia: La base de datos '$db_name' ya existe. Por favor, elige otro nombre."
    exit 1
  done
  echo "La base de datos '$db_name' no existe. Puedes usar este nombre."
  echo "$db_name" # Devuelve el nombre final
}

verificar_user_exists_des() {
  local db_user=$1
  # Verificar si el usuario existe usando las variables globales ROOT_USER y ROOT_PASS
  local user_exists=$(mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$db_user';" | grep "$db_user")
  # Si el usuario existe, solicita un nuevo nombre
  while [ "$user_exists" ]; do
    echo "Advertencia: El usuario '$db_user' ya existe. Por favor, elige otro nombre."
    exit 1
  done
  echo "El usuario '$db_user' no existe. Puedes usar este nombre."
  echo "$db_user" # Devuelve el nombre final
}
####---FUNCIONES--FIN--##
# Verificar que se han pasado los cuatro argumentos necesarios 
if [ "$#" -ne 4 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    echo "No se proporcionaron los argumentos necesarios. Por favor, ingréselos"
    echo "Se cancelo la operación"
    exit 1
    
else 
    # VARIABLES
    DB_NAME=$1
    DB_USER=$2
    USER_PASS=$3
    TABLE_NAME=$4
    validar_caracteres_regex_des "$DB_NAME"
    validar_longitud_regex_des "$DB_NAME"
    verificar_database_exists_des "$DB_NAME"
    validar_caracteres_regex_des "$DB_USER"
    validar_longitud_regex_des "$DB_USER"
    verificar_user_exists_des "$DB_USER"
    validar_caracteres_regex_des "$TABLE_NAME"
    validar_longitud_regex_des "$TABLE_NAME"    
fi
    echo "Iniciando configuración de la base de datos de WordPress..."
    mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$USER_PASS';"
    mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
    mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"
    mysql -u "$ROOT_USER" -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"
    echo "Base de datos creada: $DB_NAME"
    echo "Usuario creado: $DB_USER"
    echo "Contraseña del usuario: $USER_PASS"
    echo "Tabla creada: $TABLE_NAME"
    echo "Configuración completada con éxito."

    