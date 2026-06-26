@echo off
setlocal

title DeployCraft

echo ==========================================
echo          DeployCraft Launcher
echo ==========================================
echo.

:: Comprobar Java
java -version >nul 2>&1

if errorlevel 1 (
    echo Java no esta instalado.
    echo.
    echo Instala Java y vuelve a ejecutar este script.
    pause
    exit /b
)

:: Ruta del escritorio
set "DESKTOP=%USERPROFILE%\Desktop"
set "TLAUNCHER=%DESKTOP%\TLauncher.jar"

:: URL de descarga
set "TLAUNCHER_URL=https://ejemplo.com/TLauncher.jar"

:: Descargar solo si no existe
if not exist "%TLAUNCHER%" (
    echo TLauncher no encontrado.
    echo Descargando...

    powershell -Command ^
        "Invoke-WebRequest -Uri '%TLAUNCHER_URL%' -OutFile '%TLAUNCHER%'"

    if not exist "%TLAUNCHER%" (
        echo.
        echo Error descargando TLauncher.
        pause
        exit /b
    )

    echo Descarga completada.
    echo.
)

echo Iniciando TLauncher...

start "" javaw -jar "%TLAUNCHER%"

exit