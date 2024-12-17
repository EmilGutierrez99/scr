#!/bin/bash

# Actualizar la lista de paquetes
sudo apt update -y

# Instalar PHP junto con algunas extensiones comunes
sudo apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-zip php-gd php-mbstring php-xml

# Verificar la versión de PHP instalada
php -v

echo "PHP se ha instalado y configurado correctamente de forma desatendida."