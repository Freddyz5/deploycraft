#!/bin/bash

clear

echo "=========================================="
echo "         DeployCraft Launcher"
echo "=========================================="
echo

# Comprobar Java
if ! command -v java >/dev/null 2>&1; then
    echo "Java no está instalado."
    echo
    echo "Instálalo y vuelve a ejecutar este script."
    read -p "Presiona Enter para salir..."
    exit 1
fi

DESKTOP="$HOME/Desktop"
TLAUNCHER="$DESKTOP/TLauncher.jar"

# URL de descarga
TLAUNCHER_URL="https://ejemplo.com/TLauncher.jar"

# Descargar solo si no existe
if [ ! -f "$TLAUNCHER" ]; then
    echo "TLauncher no encontrado."
    echo "Descargando..."

    curl -L "$TLAUNCHER_URL" -o "$TLAUNCHER"

    if [ ! -f "$TLAUNCHER" ]; then
        echo
        echo "Error descargando TLauncher."
        read -p "Presiona Enter para salir..."
        exit 1
    fi

    echo
    echo "Descarga completada."
fi

echo
echo "Iniciando TLauncher..."

nohup java -jar "$TLAUNCHER" >/dev/null 2>&1 &

exit 0