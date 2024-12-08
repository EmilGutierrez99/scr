#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Uso: ./wp_setup_db.sh <nombre_db> <usuario_db> <contraseña_db> <tabla_db>"
    echo "No se proporcionaron los argumentos necesarios. Por favor, ingréselos manualmente."
    while true; do
        read -p "Ingresa el nombre de la DB (8-64 caracteres, a-z, A-Z, 0-9, _): " DB_NAME
        DB_NAME=$(validar_longitud_regex "$DB_NAME")
        DB_NAME=$(validar_caracteres_regex "$DB_NAME")
        [ -n "$DB_NAME" ] && break
    done
    while true; do
        read -p "Ingresa el nombre del nuevo USER (8-64 caracteres, a-z, A-Z, 0-9, _): " DB_USER
        DB_USER=$(validar_longitud_regex "$DB_USER")
        DB_USER=$(validar_caracteres_regex "$DB_USER")
        [ -n "$DB_USER" ] && break
    done
    while true; do
        read -p "Ingresa el Password del nuevo USER (8-64 caracteres): " USER_PASS
        USER_PASS=$(validar_longitud_regex "$USER_PASS")
        [ -n "$USER_PASS" ] && break
    done
    while true; do
        read -p "Ingresa el nombre de la nueva Tabla (8-64 caracteres, a-z, A-Z, 0-9, _): " TABLE_NAME
        TABLE_NAME=$(validar_longitud_regex "$TABLE_NAME")
        TABLE_NAME=$(validar_caracteres_regex "$TABLE_NAME")
        [ -n "$TABLE_NAME" ] && break
    done
else 
    # VARIABLES
    DB_NAME=$1
    DB_NAME=$(validar_caracteres_regex_des "$DB_NAME")
    DB_NAME=$(validar_longitud_regex_des "$DB_NAME")

    DB_USER=$2
    DB_USER=$(validar_caracteres_regex_des "$DB_USER")
    DB_USER=$(validar_longitud_regex_des "$DB_USER")

    USER_PASS=$3

    TABLE_NAME=$4
    TABLE_NAME=$(validar_caracteres_regex_des "$TABLE_NAME")
    TABLE_NAME=$(validar_longitud_regex_des "$TABLE_NAME")
    
fi