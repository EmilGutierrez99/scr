#!/bin/bash

# Verificar que se han pasado los tres argumentos necesarios
if [ "$#" -ne 4 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    
    read -p "Ingresa el nombre de la DB (a-z, A-Z, 0-9, _): " DB_NAME
    DB_NAME=$(validate_length_regex "$DB_NAME")
    DB_NAME=$(validate_allowed_chars "$DB_NAME")

    read -p "Ingresa el nombre del nuevo USER (a-z, A-Z, 0-9, _): " DB_USER
    read -p "Ingresa el Password del nuevo USER (a-z, A-Z, 0-9, _): " USER_PASS
    read -p "Ingresa el nombre de la nueva Tabla (a-z, A-Z, 0-9, _): " TABLE_NAME
fi
###----VARIABLES---###
# Asignar los argumentos a variables
DB_NAME=$1
DB_USER=$2
DB_PASSWORD=$3
DB_TABLE=$4

#Usuario root
ROOT_USER="root"
ROOT_PASS="password"
###----VARIABLES--FIN--###

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

# Crear tabla en la base de datos
mysql -u $DB_USER -p"$DB_PASSWORD" -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $DB_TABLE (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));"

####---FUNCIONES---####
## Función para verificar si la base de datos ya existe
verificar_DB() {
  log_Regis "verificar_DB"
  local DB_NAME=$1
  local db_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME")

  if [ "$db_exists" ]; then
    echo "Advertencia: La base de datos $DB_NAME ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE A LA DB: " DB_NAME
    verificar_DB "$DB_NAME"  # Llamada recursiva para verificar el nuevo nombre
  fi

  # Retornar el nombre final de la base de datos
  echo "$DB_NAME"
}

## Función para verificar si el usuario ya existe
verificar_Usuario() {
  log_Regis "verificar_Usuario"
  local DB_USER=$1
  local user_exists=$(mysql -u $ROOT_USER -p"$ROOT_PASS" -e "SELECT User FROM mysql.user WHERE User = '$DB_USER';" | grep "$DB_USER")

  if [ "$user_exists" ]; then
    echo "Advertencia: El usuario $DB_USER ya existe. Por favor, elige otro nombre."
    read -p "INTRODUCE OTRO NOMBRE AL USER: " DB_USER
    verificar_Usuario "$DB_USER"  # Llamada recursiva para verificar el nuevo nombre
  fi

  # Retornar el nombre final del usuario
  echo "$DB_USER"
}

## Función para verificar si la tabla ya existe
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

  # Retornar el nombre final de la tabla
  echo "$DB_TABLE"
}

## Función para validar que la longitud esté en el rango de 8 a 64 caracteres
validar_longitud_regex() {
  log_Regis "validar_longitud_regex"
  local input="$1"
  # si la cadena input NO coincide con ^.{8,64} (logitud de caracteres) se ejecuta el then 
  if [[ ! "$input" =~ ^.{8,64}$ ]]; then
    echo "Error: El nombre '$input' no cumple con la longitud permitida (8-64 caracteres)."
    read -p "INTRODUCE OTRA VEZ: " input
    validar_longitud_regex "$input"  # Llamada recursiva para verificar el nuevo input
  else
    echo "$input"  # Retornar el input válido
  fi
}

## Función para validar caracteres permitidos: solo letras, números y guión bajo (_)
validar_caracteres_regex() {
  log_Regis "validar_caracteres_regex"
  local input="$1"
  local allowed_chars_regex='^[a-zA-Z0-9_]+$'
  # si la cadena input NO coincide con allowed chars se ejecuta el then 
  if [[ ! "$input" =~ $allowed_chars_regex ]]; then
    echo "Error: El nombre '$input' contiene caracteres no válidos. Solo se permiten letras, números y guiones bajos (_)."
    echo "Caracteres válidos: letras (a-z, A-Z), números (0-9) y guión bajo (_)."
    read -p "INTRODUCE OTRA VEZ: " input
    validar_caracteres_regex "$input"  # Llamada recursiva para verificar el nuevo input
  else
    echo "$input"  # Retornar el input válido
  fi
}
#Registro usando log
log_Regis() {
  local function_name="$1"
  local timestamp=$(date "+%H-%M-%S-%d-%m-%Y")
  echo "$timestamp - Función utilizada: $function_name" >> registro.log
}

####---FUNCIONES--FIN--####

####---USO--DE--FUNCIONES---####
# Llamar a las funciones para verificar y obtener los nombres finales
DB_NAME=$(verificar_DB "$DB_NAME")
DB_USER=$(verificar_Usuario "$DB_USER")
DB_TABLE=$(verificar_Tabla "$DB_NAME" "$DB_TABLE")

DB_NAME=$(validar_longitud_regex "$DB_NAME")
DB_USER=$(validar_longitud_regex "$DB_USER")
DB_PASSWORD=$(validar_longitud_regex "$DB_PASSWORD")
DB_TABLE=$(validar_longitud_regex "$DB_TABLE")

DB_NAME=$(validar_caracteres_regex "$DB_NAME")
DB_USER=$(validar_caracteres_regex "$DB_USER")
DB_PASSWORD=$(validar_caracteres_regex "$DB_PASSWORD")
DB_TABLE=$(validar_caracteres_regex "$DB_TABLE")
####---USO--DE--FUNCIONES--FIN--####

# Muestra los valores validados
echo "Nombre de la base de datos validado: $DB_NAME"
echo "Nombre de usuario validado: $DB_USER"
echo "Contraseña validada: $DB_PASSWORD"
echo "Nombre de la tabla validado: $DB_TABLE"
####---USO--DE--FUNCIONES--FIN--####

echo "Base de datos final: $DB_NAME"
echo "Usuario final: $DB_USER"
echo "Tabla final: $DB_TABLE"

# Confirmación de finalización
echo "La configuración de la base de datos ha finalizado exitosamente."
echo "Puedes continuar con la instalación de WordPress."

exit 0