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

# Reiniciar el sistema automáticamente
echo "El sistema se reiniciará automáticamente en 10 segundos..."
sleep 10
reboot
