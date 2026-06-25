@echo off
setlocal enabledelayedexpansion
title DeployCraft Installer
color 0A

:: ============================================================
::  DeployCraft Installer - Windows
::  Instala Java, TLauncher y configura el servidor de amigos
:: ============================================================

set "VERSION=2.0.0"
set "TLAUNCHER_URL=https://github.com/Freddyz5/deploycraft/releases/download/v2.0.0/TLauncher.jar"
set "SERVERS_DAT_URL=https://github.com/Freddyz5/deploycraft/releases/download/v2.0.0/servers.dat"
set "JAVA_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_windows_hotspot_21.0.5_11.msi"
set "INSTALL_DIR=%USERPROFILE%\TLauncher"
set "MC_DIR=%APPDATA%\.minecraft"
set "LOG_FILE=%USERPROFILE%\Desktop\deploycraft-install.log"
set "SHORTCUT=%USERPROFILE%\Desktop\TLauncher.bat"

:: Limpiar log anterior
if exist "%LOG_FILE%" del "%LOG_FILE%"

call :log "============================================"
call :log " DeployCraft Installer v%VERSION%"
call :log " %DATE% %TIME%"
call :log "============================================"

echo.
echo  ██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗
echo  ██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝
echo  ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ 
echo  ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  
echo  ██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   
echo  ╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   
echo.
echo  ============================================
echo   Instalador de Minecraft para amigos v%VERSION%
echo  ============================================
echo.
call :print_info "Iniciando instalacion..."
echo.

:: ─── PASO 1: VERIFICAR JAVA ─────────────────────────────────
call :print_step "PASO 1/5" "Verificando Java..."
call :log "Verificando Java..."

java -version >nul 2>&1
if %errorlevel% == 0 (
    for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        set "JAVA_VER=%%g"
    )
    call :print_ok "Java encontrado: !JAVA_VER!"
    call :log "Java encontrado: !JAVA_VER!"
    set "JAVA_OK=1"
) else (
    call :print_warn "Java no encontrado. Se instalara Java 21..."
    call :log "Java no encontrado. Iniciando descarga..."
    set "JAVA_OK=0"
)

if "!JAVA_OK!"=="0" (
    call :print_info "Descargando Java 21 Temurin (puede tardar unos minutos)..."
    
    powershell -Command "& {
        $ProgressPreference = 'SilentlyContinue'
        try {
            Invoke-WebRequest -Uri '%JAVA_URL%' -OutFile '$env:TEMP\java21.msi' -UseBasicParsing
        } catch {
            Write-Host 'ERROR_DOWNLOAD'
            exit 1
        }
    }"
    
    if not exist "%TEMP%\java21.msi" (
        call :print_error "No se pudo descargar Java. Verifica tu conexion a internet."
        call :log "ERROR: Fallo la descarga de Java."
        call :finish_error
        exit /b 1
    )
    
    call :print_info "Instalando Java 21 (esto puede tardar 1-2 minutos)..."
    msiexec /i "%TEMP%\java21.msi" /quiet /norestart
    
    if %errorlevel% neq 0 (
        call :print_error "Fallo la instalacion de Java."
        call :log "ERROR: msiexec fallo con codigo %errorlevel%"
        call :finish_error
        exit /b 1
    )
    
    del "%TEMP%\java21.msi" >nul 2>&1
    
    :: Refrescar PATH para que java sea reconocido
    for /f "tokens=*" %%i in ('powershell -Command "[System.Environment]::GetEnvironmentVariable(\"PATH\",\"Machine\")"') do set "PATH=%%i;%PATH%"
    
    call :print_ok "Java 21 instalado correctamente."
    call :log "Java 21 instalado correctamente."
)

:: ─── PASO 2: CREAR CARPETAS ─────────────────────────────────
call :print_step "PASO 2/5" "Preparando carpetas..."
call :log "Creando carpetas..."

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%MC_DIR%" mkdir "%MC_DIR%"

call :print_ok "Carpetas listas."
call :log "Carpetas creadas: %INSTALL_DIR% | %MC_DIR%"

:: ─── PASO 3: DESCARGAR TLAUNCHER ────────────────────────────
call :print_step "PASO 3/5" "Descargando TLauncher..."
call :log "Descargando TLauncher desde %TLAUNCHER_URL%"

if exist "%INSTALL_DIR%\TLauncher.jar" (
    call :print_ok "TLauncher ya estaba instalado. Actualizando..."
    call :log "TLauncher existente encontrado. Reemplazando..."
)

powershell -Command "& {
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri '%TLAUNCHER_URL%' -OutFile '%INSTALL_DIR%\TLauncher.jar' -UseBasicParsing
    } catch {
        Write-Host 'ERROR_DOWNLOAD'
        exit 1
    }
}"

if not exist "%INSTALL_DIR%\TLauncher.jar" (
    call :print_error "No se pudo descargar TLauncher. Verifica tu conexion."
    call :log "ERROR: TLauncher.jar no descargado."
    call :finish_error
    exit /b 1
)

call :print_ok "TLauncher descargado correctamente."
call :log "TLauncher.jar descargado en %INSTALL_DIR%"

:: ─── PASO 4: CONFIGURAR SERVIDOR ────────────────────────────
call :print_step "PASO 4/5" "Configurando servidor de amigos..."
call :log "Descargando servers.dat..."

powershell -Command "& {
    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri '%SERVERS_DAT_URL%' -OutFile '%MC_DIR%\servers.dat' -UseBasicParsing
    } catch {
        Write-Host 'WARN: No se pudo descargar servers.dat'
    }
}"

if exist "%MC_DIR%\servers.dat" (
    call :print_ok "Servidor DeployCraft configurado automaticamente."
    call :log "servers.dat copiado en %MC_DIR%"
) else (
    call :print_warn "No se pudo precargar el servidor. Debes agregarlo manualmente en Multijugador."
    call :log "WARN: servers.dat no descargado. Continuando..."
)

:: ─── PASO 5: ACCESO DIRECTO ─────────────────────────────────
call :print_step "PASO 5/5" "Creando acceso directo en el Escritorio..."
call :log "Creando acceso directo..."

(
    echo @echo off
    echo start javaw -jar "%INSTALL_DIR%\TLauncher.jar"
) > "%SHORTCUT%"

if exist "%SHORTCUT%" (
    call :print_ok "Acceso directo creado en el Escritorio."
    call :log "Acceso directo creado: %SHORTCUT%"
) else (
    call :print_warn "No se pudo crear el acceso directo."
    call :log "WARN: No se pudo crear acceso directo."
)

:: ─── LISTO ───────────────────────────────────────────────────
echo.
echo  ============================================
echo.
call :print_ok "INSTALACION COMPLETADA"
echo.
echo   Que hacer ahora:
echo   1. Doble clic en "TLauncher" en tu Escritorio
echo   2. Escribe tu nick en el campo de abajo
echo   3. Selecciona "Oficial 26.2"
echo   4. Click en "Entrar al juego"
echo   5. Multijugador ^> DeployCraft ya deberia aparecer
echo      Si no aparece: Agregar servidor ^> deploycraft.falix.dev
echo.
echo  ============================================
echo.
call :log "Instalacion completada exitosamente."

:: Abrir TLauncher
call :print_info "Abriendo TLauncher..."
start "" javaw -jar "%INSTALL_DIR%\TLauncher.jar"

echo.
pause
exit /b 0

:: ─── FUNCIONES ───────────────────────────────────────────────

:print_step
echo.
echo  [%~1] %~2
goto :eof

:print_ok
echo  [+] %~1
goto :eof

:print_info
echo  [*] %~1
goto :eof

:print_warn
echo  [!] %~1
goto :eof

:print_error
echo.
echo  [ERROR] %~1
echo.
goto :eof

:log
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
goto :eof

:finish_error
echo.
echo  ============================================
echo  [ERROR] La instalacion no se completo.
echo  Se genero un reporte en:
echo  %LOG_FILE%
echo  Comparte ese archivo para recibir ayuda.
echo  ============================================
echo.
call :log "Instalacion finalizada CON ERRORES."
pause
goto :eof