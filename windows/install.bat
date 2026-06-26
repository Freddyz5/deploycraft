@echo off
setlocal enabledelayedexpansion
title DeployCraft Installer
color 0A

:: ============================================================
::  DeployCraft Installer - Windows v3.0.0
::  FIX: Java post-install verify, PATH correcto,
::       msiexec /wait real, check TLauncher proceso
:: ============================================================

set "VERSION=3.0.0"
set "RELEASES_BASE=https://github.com/Freddyz5/deploycraft/releases/latest/download"
set "TLAUNCHER_URL=%RELEASES_BASE%/TLauncher.jar"
set "SERVERS_DAT_URL=%RELEASES_BASE%/servers.dat"
set "JAVA_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5+11/OpenJDK21U-jdk_x64_windows_hotspot_21.0.5_11.msi"
set "JAVA_MSI=%TEMP%\java21_deploycraft.msi"
set "INSTALL_DIR=%USERPROFILE%\TLauncher"
set "MC_DIR=%APPDATA%\.minecraft"
set "LOG_FILE=%USERPROFILE%\Desktop\deploycraft-install.log"
set "MSI_LOG=%USERPROFILE%\Desktop\deploycraft-java-msi.log"
set "SHORTCUT=%USERPROFILE%\Desktop\TLauncher.bat"
set "JAVA_EXE=java"

if exist "%LOG_FILE%" del "%LOG_FILE%"
if exist "%MSI_LOG%" del "%MSI_LOG%"

call :ensure_admin
if errorlevel 1 exit /b 1

call :log "============================================"
call :log " DeployCraft Installer v%VERSION%"
call :log " %DATE% %TIME%"
call :log "============================================"

echo.
echo  ============================================
echo   DeployCraft Installer v%VERSION%
echo   Minecraft para amigos
echo  ============================================
echo.
call :info "Iniciando instalacion..."
echo.

:: ─────────────────────────────────────────────────────────────
:: PASO 1 — JAVA
:: FIX 1: Busca java en PATH y en rutas de instalacion conocidas
:: FIX 2: Refresca PATH desde el registro (no de la sesion vieja)
:: FIX 3: Verifica con java.exe real despues de instalar
:: ─────────────────────────────────────────────────────────────
call :step "PASO 1/5" "Verificando Java..."

call :find_java
if "!JAVA_FOUND!"=="1" (
    call :ok "Java encontrado: !JAVA_EXE!"
    call :log "Java ya presente. Saltando instalacion."
    goto :java_done
)

:: Java no disponible — descargar
call :warn "Java no encontrado. Descargando Java 21 Temurin..."
call :log "Iniciando descarga de Java 21 MSI..."

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference='SilentlyContinue';" ^
    "try { Invoke-WebRequest -Uri '%JAVA_URL%' -OutFile '%JAVA_MSI%' -UseBasicParsing } catch { exit 1 }"

if not exist "%JAVA_MSI%" (
    call :error "No se pudo descargar Java. Verifica tu conexion a internet."
    call :log "ERROR: Fallo descarga de Java MSI."
    call :abort
    exit /b 1
)

call :info "Instalando Java 21... no cierres esta ventana (1-2 min)..."
call :log "Ejecutando msiexec con log verbose en %MSI_LOG%..."

:: Ejecutar MSI elevado con log detallado para diagnosticar 1603
msiexec /i "%JAVA_MSI%" INSTALLLEVEL=1 /L*V "%MSI_LOG%" /quiet /norestart
set "MSI_CODE=!errorlevel!"

if !MSI_CODE! equ 0 (
    del "%JAVA_MSI%" >nul 2>&1
)

if !MSI_CODE! equ 3010 (
    call :warn "Java se instalo pero Windows pide reiniciar antes de usarlo."
    call :log "WARN: msiexec devolvio 3010 (reinicio requerido)."
    call :warn "Reinicia tu PC y vuelve a ejecutar el instalador para continuar."
    call :abort
    exit /b 1
)

if !MSI_CODE! neq 0 (
    call :error "Fallo la instalacion de Java. Codigo: !MSI_CODE!"
    call :log "ERROR: msiexec codigo !MSI_CODE!"
    if !MSI_CODE! equ 1603 (
        call :warn "El MSI fallo con 1603. Normalmente es por permisos, reinicio pendiente o una instalacion previa rota."
        call :warn "Revisa tambien el log: %MSI_LOG%"
    )
    call :abort
    exit /b 1
)

call :log "msiexec termino correctamente (codigo 0)."

:: FIX 2: Refrescar PATH desde el registro del sistema, no de la sesion
call :info "Actualizando variables de entorno..."
call :log "Refrescando PATH desde registro..."

for /f "skip=2 tokens=2,*" %%A in (
    'reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul'
) do set "SYS_PATH=%%B"

for /f "skip=2 tokens=2,*" %%A in (
    'reg query "HKCU\Environment" /v Path 2^>nul'
) do set "USR_PATH=%%B"

if defined SYS_PATH (
    if defined USR_PATH (
        set "PATH=!SYS_PATH!;!USR_PATH!"
    ) else (
        set "PATH=!SYS_PATH!"
    )
)

:: FIX 1: Verificacion real de Java post-instalacion
call :info "Verificando que Java funciona..."
call :log "Verificando Java post-instalacion..."

call :find_java
if "!JAVA_FOUND!"=="0" (
    call :error "Java se instalo pero el sistema no lo reconoce aun."
    call :warn "Cierra esta ventana, reinicia tu PC y vuelve a ejecutar el instalador."
    call :log "ERROR: Java no verificable tras instalacion. Requiere reinicio."
    call :abort
    exit /b 1
)

call :ok "Java 21 instalado y verificado: !JAVA_EXE!"
call :log "Java verificado OK: !JAVA_EXE!"

:java_done

:: ─────────────────────────────────────────────────────────────
:: PASO 2 — CARPETAS
:: ─────────────────────────────────────────────────────────────
call :step "PASO 2/5" "Preparando carpetas..."
call :log "Creando carpetas..."

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%MC_DIR%"      mkdir "%MC_DIR%"

call :ok "Carpetas listas."
call :log "INSTALL_DIR=%INSTALL_DIR% | MC_DIR=%MC_DIR%"

:: ─────────────────────────────────────────────────────────────
:: PASO 3 — TLAUNCHER
:: ─────────────────────────────────────────────────────────────
call :step "PASO 3/5" "Descargando TLauncher..."
call :log "Descargando TLauncher.jar desde GitHub Releases..."

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference='SilentlyContinue';" ^
    "try { Invoke-WebRequest -Uri '%TLAUNCHER_URL%' -OutFile '%INSTALL_DIR%\TLauncher.jar' -UseBasicParsing } catch { exit 1 }"

if not exist "%INSTALL_DIR%\TLauncher.jar" (
    call :error "No se pudo descargar TLauncher. Verifica tu internet."
    call :log "ERROR: TLauncher.jar no descargado."
    call :abort
    exit /b 1
)

:: Verificar integridad basica (debe pesar mas de 1 MB)
for %%F in ("%INSTALL_DIR%\TLauncher.jar") do set "JAR_SIZE=%%~zF"
if !JAR_SIZE! LSS 1000000 (
    call :error "El archivo descargado esta corrupto (!JAR_SIZE! bytes). Intenta de nuevo."
    call :log "ERROR: TLauncher.jar muy pequeno: !JAR_SIZE! bytes"
    del "%INSTALL_DIR%\TLauncher.jar" >nul 2>&1
    call :abort
    exit /b 1
)

call :ok "TLauncher descargado OK (!JAR_SIZE! bytes)."
call :log "TLauncher.jar OK: !JAR_SIZE! bytes"

:: ─────────────────────────────────────────────────────────────
:: PASO 4 — SERVIDOR
:: ─────────────────────────────────────────────────────────────
call :step "PASO 4/5" "Configurando servidor DeployCraft..."
call :log "Descargando servers.dat..."

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference='SilentlyContinue';" ^
    "try { Invoke-WebRequest -Uri '%SERVERS_DAT_URL%' -OutFile '%MC_DIR%\servers.dat' -UseBasicParsing } catch { exit 1 }"

if exist "%MC_DIR%\servers.dat" (
    call :ok "Servidor DeployCraft preconfigurado en Multijugador."
    call :log "servers.dat instalado en %MC_DIR%"
) else (
    call :warn "Servidor no preconfigurado. Agregalo manual: deploycraft.falix.dev"
    call :log "WARN: servers.dat no descargado. Continuando..."
)

:: ─────────────────────────────────────────────────────────────
:: PASO 5 — ACCESO DIRECTO
:: ─────────────────────────────────────────────────────────────
call :step "PASO 5/5" "Creando acceso directo en el Escritorio..."
call :log "Creando TLauncher.bat en Escritorio..."

(
    echo @echo off
    echo start "" "!JAVA_EXE!" -jar "%INSTALL_DIR%\TLauncher.jar"
) > "%SHORTCUT%"

if exist "%SHORTCUT%" (
    call :ok "Acceso directo creado: TLauncher.bat"
    call :log "Acceso directo OK: %SHORTCUT%"
) else (
    call :warn "No se pudo crear el acceso directo."
    call :log "WARN: Acceso directo no creado."
)

:: ─────────────────────────────────────────────────────────────
:: ABRIR TLAUNCHER + FIX 4: Verificar que el proceso levanta
:: ─────────────────────────────────────────────────────────────
echo.
echo  ============================================
call :ok "INSTALACION COMPLETADA"
echo.
echo   Que hacer ahora:
echo   1. Escribe tu nick abajo a la izquierda en TLauncher
echo   2. Selecciona "Oficial 26.2" en el desplegable
echo   3. Click "Entrar al juego" (descarga la version la 1a vez)
echo   4. Multijugador ^> DeployCraft ya aparece en la lista
echo      Si no: Agregar servidor ^> deploycraft.falix.dev
echo  ============================================
echo.

call :info "Abriendo TLauncher..."
call :log "Lanzando TLauncher con: !JAVA_EXE!"

start "" "!JAVA_EXE!" -jar "%INSTALL_DIR%\TLauncher.jar"

:: FIX 4: Esperar y verificar que el proceso java levanto
call :info "Verificando que TLauncher inicio correctamente..."
timeout /t 6 /nobreak >nul

set "TLAUNCHER_OK=0"
tasklist 2>nul | find /i "javaw.exe" >nul && set "TLAUNCHER_OK=1"
if "!TLAUNCHER_OK!"=="0" (
    tasklist 2>nul | find /i "java.exe" >nul && set "TLAUNCHER_OK=1"
)

if "!TLAUNCHER_OK!"=="1" (
    call :ok "TLauncher corriendo correctamente."
    call :log "TLauncher OK — proceso java detectado."
) else (
    call :warn "TLauncher puede no haber abierto automaticamente."
    call :warn "Haz doble clic en 'TLauncher.bat' en tu Escritorio para abrirlo."
    call :log "WARN: No se detecto proceso java tras 6 segundos."
)

echo.
call :log "Script finalizado."
pause
exit /b 0

:: ─────────────────────────────────────────────────────────────
:: SUBRUTINA: find_java
:: Busca java en PATH y en rutas de instalacion conocidas.
:: Setea JAVA_FOUND=1 y JAVA_EXE=<ruta> si lo encuentra.
:: ─────────────────────────────────────────────────────────────
:find_java
set "JAVA_FOUND=0"

java -version >nul 2>&1
if !errorlevel! == 0 (
    set "JAVA_EXE=java"
    set "JAVA_FOUND=1"
    goto :eof
)

for %%D in (
    "%ProgramFiles%\Eclipse Adoptium"
    "%ProgramFiles%\Microsoft"
    "%ProgramFiles%\Java"
    "%ProgramFiles(x86)%\Java"
) do (
    if exist "%%~D" (
        for /d %%S in ("%%~D\jdk-21*" "%%~D\jre-21*") do (
            if exist "%%S\bin\java.exe" (
                "%%S\bin\java.exe" -version >nul 2>&1
                if !errorlevel! == 0 (
                    set "JAVA_EXE=%%S\bin\java.exe"
                    set "JAVA_FOUND=1"
                    goto :eof
                )
            )
        )
    )
)
goto :eof

:: ─────────────────────────────────────────────────────────────
:: HELPERS DE OUTPUT
:: ─────────────────────────────────────────────────────────────
:step
echo.
echo  [%~1] %~2
call :log "[STEP] %~1 %~2"
goto :eof

:ok
echo  [+] %~1
goto :eof

:info
echo  [*] %~1
goto :eof

:warn
echo  [!] %~1
goto :eof

:error
echo.
echo  [ERROR] %~1
echo.
goto :eof

:log
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
goto :eof

:abort
echo.
echo  ============================================
echo  Instalacion interrumpida.
echo  Revisa el log en tu Escritorio:
echo    deploycraft-install.log
echo    deploycraft-java-msi.log
echo  Manda ese archivo por WhatsApp para ayuda.
echo  ============================================
echo.
call :log "Instalacion ABORTADA."
pause
goto :eof

:ensure_admin
net session >nul 2>&1
if %errorlevel% equ 0 goto :eof

echo.
echo  [*] Se requieren permisos de administrador para instalar Java.
echo  [*] Acepta el aviso de Windows para continuar.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "try { Start-Process -FilePath '%~f0' -Verb RunAs } catch { exit 1 }"

if errorlevel 1 (
    echo  [ERROR] No se pudo elevar permisos o se cancelo el aviso de Windows.
    pause
)
exit /b 1
