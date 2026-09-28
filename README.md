# Minecraft Friends Installer

Página web para que el grupo de amigos instale TLauncher y se conecte al servidor compartido de Minecraft Java Edition sin complicarse.

## Objetivo

Simplificar al máximo el proceso para jugadores con poca experiencia técnica: la página detecta el sistema operativo, lleva a la descarga oficial de TLauncher y explica paso a paso cómo instalarlo y conectarse al servidor.

## Qué incluye la página

* Detección automática del sistema operativo (Windows / macOS).
* Botón de descarga directo a la página oficial de TLauncher (tlauncher.org).
* Instrucciones de instalación paso a paso para Windows y macOS.
* Datos del servidor y cómo agregarlo en Minecraft.
* Link para encender el servidor cuando está apagado (Falix).
* Guía de juego en `guide/`.

## Descargas de TLauncher

Los botones apuntan a los mismos enlaces que usa el botón de descarga de tlauncher.org:

| Sistema | Enlace                            | Archivo                                    |
| ------- | --------------------------------- | ------------------------------------------ |
| Windows | `https://tlauncher.org/installer` | `TLauncher-Installer-x.x.x.exe`            |
| macOS   | `https://tlauncher.org/jar`       | `TLauncher.zip` (contiene `TLauncher.jar`) |
| Otros   | `https://tlauncher.org/en/`       | Página oficial                             |

Si TLauncher cambia estos enlaces, se actualizan en `osConfig` dentro de `script.js`.

## Flujo del jugador

1. Entra a la página y descarga TLauncher con el botón.
2. En Mac: instala Java desde java.com si no lo tiene (en Windows viene con el instalador).
3. Instala / abre TLauncher siguiendo los pasos de su sistema.
4. Pone su nick, elige la versión "Oficial 26.2" y entra al juego.
5. Agrega el servidor en Multijugador y se conecta.

## Estructura del Proyecto

```text
deploycraft/
├── index.html        # Página principal
├── script.js         # Detección de SO, descargas, pasos y FAQ
├── style.css
├── guide/            # Guía de juego
│   └── img/          # Mobs, biomas e íconos de ítems (de Minecraft Wiki, © Mojang)
├── assets/
│   └── servers.dat
├── windows/          # Script experimental del instalador automático (sin uso)
└── mac/              # Script experimental del instalador automático (sin uso)
```

## Despliegue

Sitio estático desplegado en Vercel.

## Contribuciones

Este proyecto está pensado para uso privado entre amigos, pero cualquier mejora o sugerencia es bienvenida.

## Licencia

MIT
