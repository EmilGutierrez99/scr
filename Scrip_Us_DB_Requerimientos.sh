#!/bin/bash

# Variables
read -p "Ingresa el nombre de la DB Caracteres válidos:(a-z),(A-Z),(0-9),(_): " DB_NAME
read -p "Ingresa el nombre del nuevo USER Caracteres válidos:(a-z),(A-Z),(0-9),(_): " DB_USER
read -p "Ingresa el Password del nuevo USER Caracteres válidos:(a-z),(A-Z),(0-9),(_): " USER_PASS
read -p "Ingresa el nombre de la nueva Tabla Caracteres válidos:(a-z),(A-Z),(0-9),(_): " TABLE_NAME
ROOT_USER="root"
ROOT_PASS="password"


# Verificar si la base de datos ya existe
db_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME")
if [ "$db_exists" ]; then
  echo "Advertencia: La base de datos $DB_NAME ya existe. Por favor, elige otro nombre."
  read -p "INTRODUCE OTRO NOMBRE A LA DB: " DB_NAME
fi

# Verificar si el usuario ya existe
user_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$DB_USER';" | grep "$DB_USER")
if [ "$user_exists" ]; then
  echo "Advertencia: El usuario $DB_USER ya existe. Por favor, elige otro nombre."
  read -p "INTRODUCE OTRO NOMBRE AL USER: " DB_USER
fi

# Verificar si la tabla ya existe
#####

table_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "USE $DB_NAME; SHOW TABLES LIKE '$TABLE_NAME';" | grep "$TABLE_NAME")
if [ "$table_exists" ]; then
  echo "Advertencia: La tabla $TABLE_NAME ya existe en la base de datos $DB_NAME. Por favor, elige otro nombre."
  exit 1
fi

#######
# Requerimientos adicionales

# 1. Validar que los inputs estén dentro de un rango de caracteres (8 a 64) usando regex.
validate_length_regex() {
  local input="$1"
  if [[ ! "$input" =~ ^.{8,64}$ ]]; then
    echo "Error: El nombre '$input' no cumple con la longitud permitida (8-64 caracteres)."
    read -p "INTRODUCE OTRA VEZ: " input
    
  fi
}

# 2. Filtro para caracteres inválidos y 3. Lista de caracteres válidos
#    Permitimos solo letras (a-z, A-Z), números (0-9) y guiones bajos (_).
validate_allowed_chars() {
  local input="$1"
  local allowed_chars_regex='^[a-zA-Z0-9_]+$'
  if [[ ! "$input" =~ $allowed_chars_regex ]]; then
    echo "Error: El nombre '$input' contiene caracteres no válidos. Solo se permiten letras, números y guiones bajos (_)."
    echo "Caracteres válidos: letras (a-z, A-Z), números (0-9) y guión bajo (_)."
    read -p "INTRODUCE OTRA VEZ: " input
    
  fi
}

# 4. Uso de argumentos en el script.
#    Permitir que el script se ejecute con parámetros en la línea de comandos.
if [ $# -eq 4 ]; then
  DB_NAME="$1"
  DB_USER="$2"
  USER_PASS="$3"
  TABLE_NAME="$4"
else
  echo "Parametros Completados"
fi

# 5. Trazas (logs) de acciones y resultados en el script.
log() {
  echo "[LOG $(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Ejemplo de uso de trazas:
log "Iniciando la validación de entradas..."
validate_length_regex "$DB_NAME"
validate_allowed_chars "$DB_NAME"
validate_length_regex "$DB_USER"
validate_allowed_chars "$DB_USER"
validate_length_regex "$TABLE_NAME"
validate_allowed_chars "$TABLE_NAME"
log "Validación de entradas completada."
######

###
# Crear base de datos
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Crear usuario y asignar permisos
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$USER_PASS';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "FLUSH PRIVILEGES;"

# Verificar si el usuario puede crear una tabla
mysql -u $DB_USER -p"$USER_PASS" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(64));"

######
#6. Control de errores mejorado
handle_error() {
  local exit_status=$1
  local action="$2"
  if [ $exit_status -ne 0 ]; then
    echo "Error: Hubo un problema al $action. Verifica la conexión y los permisos de usuario."
    exit 1
  fi
}

# Ejemplo de uso de control de errores:
log "Creando la base de datos $DB_NAME..."
mysql -u $ROOT_USER -p"$ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
handle_error $? "crear la base de datos"

# 7. Añadir comentarios explicativos
# Función `validate_length_regex`: Verifica que el input esté dentro del rango [8,64] caracteres.
# Función `validate_allowed_chars`: Filtra caracteres inválidos, permitiendo solo letras, números y guiones bajos.
# Función `log`: Genera trazas con la fecha y hora para seguimiento de las acciones.
# Función `handle_error`: Controla errores y detiene el script si ocurre un fallo en una acción clave.

#############