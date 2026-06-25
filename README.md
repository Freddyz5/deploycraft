# Minecraft Friends Installer

Instalador multiplataforma para preparar automáticamente un entorno de Minecraft Java Edition utilizando TLauncher y conectar a un servidor privado compartido entre amigos.

## Objetivo

Este proyecto busca simplificar al máximo el proceso de instalación y configuración para jugadores con poca experiencia técnica.

La idea es que cualquier persona pueda ejecutar un único instalador y tener todo listo para jugar en pocos minutos, sin necesidad de configurar Java, servidores, redes virtuales o archivos manualmente.

## Características Planeadas

* Detección automática del sistema operativo.
* Soporte para Windows y macOS.
* Verificación de requisitos previos.
* Instalación automática de Java.
* Instalación automática de TLauncher.
* Configuración inicial del entorno de Minecraft.
* Configuración automática del servidor favorito.
* Creación de accesos directos.
* Validaciones y mensajes amigables para usuarios no técnicos.
* Registro de errores para facilitar soporte.

## Flujo Esperado

1. El usuario ejecuta el instalador.
2. El instalador verifica requisitos.
3. Si Java no está instalado, se instala automáticamente.
4. Se descarga e instala TLauncher.
5. Se configura el acceso al servidor compartido.
6. Se crean accesos directos necesarios.
7. Se abre TLauncher.
8. El usuario inicia sesión y comienza a jugar.

## Estructura del Proyecto

```text
minecraft-friends-installer/
│
├── windows/
│   └── install.ps1
│
├── macos/
│   └── install.sh
│
├── assets/
│   ├── servers.dat
│   └── icons/
│
├── docs/
│
└── README.md
```

## Sistemas Operativos Soportados

### Windows

* Windows 10
* Windows 11

### macOS

* Intel
* Apple Silicon (M1, M2, M3 y posteriores)

## Tecnologías

* PowerShell
* Bash
* GitHub
* GitHub Releases

## Roadmap

### Fase 1

* [ ] Instalador Windows
* [ ] Instalador macOS
* [ ] Detección de Java
* [ ] Instalación automática de Java

### Fase 2

* [ ] Instalación automática de TLauncher
* [ ] Configuración automática del servidor
* [ ] Creación de accesos directos

### Fase 3

* [ ] Interfaz gráfica
* [ ] Actualizaciones automáticas
* [ ] Soporte para múltiples servidores

## Contribuciones

Este proyecto está pensado inicialmente para uso privado entre amigos, pero cualquier mejora o sugerencia es bienvenida.

## Licencia

MIT
