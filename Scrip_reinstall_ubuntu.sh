#!/bin/bash

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

echo "Iniciando el proceso de limpieza desatendida..."

# Actualizar la lista de paquetes
echo "Actualizando lista de paquetes..."
apt update -y

# Eliminar todos los paquetes instalados manualmente
echo "Eliminando paquetes instalados manualmente..."
apt autoremove --purge -y

# Reinstalar paquetes esenciales del sistema
echo "Reinstalando paquetes esenciales..."
apt install --reinstall ubuntu-server -y

# Limpiar archivos de configuración obsoletos
echo "Limpiando archivos de configuración antiguos..."
apt-get remove --purge $(dpkg -l | grep '^rc' | awk '{print $2}') -y

# Limpiar la caché de paquetes
echo "Limpiando la caché de paquetes..."
apt clean -y
apt autoclean -y

# Eliminar configuraciones y archivos de usuario
echo "Eliminando archivos y configuraciones de usuario..."
rm -rf /home/*               # Elimina todos los archivos de los usuarios
rm -rf /root/.cache           # Limpia la caché del usuario root
rm -rf /var/log/*             # Elimina todos los archivos de log
rm -rf /tmp/*                 # Limpia el directorio temporal
rm -rf /etc/network/interfaces.d/*  # Restablece la configuración de red

# Restablecer las configuraciones de red
echo "Restableciendo las configuraciones de red a los valores predeterminados..."
cat <<EOF > /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
EOF

# Aplicar la nueva configuración de red
echo "Aplicando la nueva configuración de red..."
netplan apply

# Limpiar archivos del sistema temporal
echo "Limpiando archivos temporales del sistema..."
find /tmp -type f -delete


#Aqui poner reinstalacion de php,apache,mysql#!/bin/bash

echo "Iniciando la desinstalación de Apache, PHP y MySQL de forma desatendida..."

# Desinstalar Apache
echo "Desinstalando Apache..."
apt-get remove --purge apache2 apache2-utils apache2-bin apache2.2-common -y

# Eliminar archivos de configuración de Apache
echo "Eliminando archivos de configuración de Apache..."
rm -rf /etc/apache2
rm -rf /var/www/html

# Desinstalar PHP
echo "Desinstalando PHP..."
apt-get remove --purge php* -y

# Eliminar archivos de configuración de PHP
echo "Eliminando archivos de configuración de PHP..."
rm -rf /etc/php

# Desinstalar MySQL
echo "Desinstalando MySQL..."
apt-get remove --purge mysql-server mysql-client mysql-common -y

# Eliminar archivos de configuración y datos de MySQL
echo "Eliminando archivos de configuración y datos de MySQL..."
rm -rf /etc/mysql
rm -rf /var/lib/mysql
rm -rf /var/log/mysql

# Limpiar paquetes no utilizados y caché
echo "Limpiando paquetes no utilizados y caché..."
apt-get autoremove -y
apt-get autoclean -y

# Verificación final
echo "Desinstalación completa. Apache, PHP y MySQL han sido eliminados del sistema de forma desatendida."

# Fin del script

#Fin reinstall

# Reiniciar el sistema automáticamente
echo "El sistema se reiniciará automáticamente en 10 segundos..."
sleep 10
reboot
