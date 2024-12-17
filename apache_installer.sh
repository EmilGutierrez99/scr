#!/bin/bash

# Actualizar la lista de paquetes
sudo apt update -y

echo "Instalando Apache..."

# Instalar Apache
sudo apt install -y apache2

#verificamos version
sudo apache2 -v

echo "Apache se ha instalado y configurado correctamente de forma desatendida."