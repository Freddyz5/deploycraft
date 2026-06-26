#!/bin/bash

# ============================================================
#  DeployCraft Installer - macOS v3.0.0
#  Soporta Intel (x86_64) y Apple Silicon (arm64)
# ============================================================

VERSION="3.0.0"
RELEASES_BASE="https://github.com/Freddyz5/deploycraft/releases/latest/download"
ASSETS_BASE="https://github.com/Freddyz5/deploycraft/releases/download/v2.0.0"
TLAUNCHER_URL="$ASSETS_BASE/TLauncher.jar"
SERVERS_DAT_URL="$ASSETS_BASE/servers.dat"
INSTALL_DIR="$HOME/Applications/TLauncher"
MC_DIR="$HOME/Library/Application Support/minecraft"
LOG_FILE="$HOME/Desktop/deploycraft-install.log"
SHORTCUT="$HOME/Desktop/TLauncher.command"
JAVA_EXE=""

# ─── COLORES ─────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ─── HELPERS ─────────────────────────────────────────────────
log()   { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
ok()    { echo -e "  ${GREEN}[+]${RESET} $1"; log "[OK] $1"; }
info()  { echo -e "  ${CYAN}[*]${RESET} $1"; log "[INFO] $1"; }
warn()  { echo -e "  ${YELLOW}[!]${RESET} $1"; log "[WARN] $1"; }
err()   { echo -e "\n  ${RED}[ERROR]${RESET} $1\n"; log "[ERROR] $1"; }
step()  { echo -e "\n  [$1] $2"; log "[STEP] $1 $2"; }

abort() {
    echo ""
    echo "  ============================================"
    echo "  Instalacion interrumpida."
    echo "  Revisa el log en tu Escritorio:"
    echo "    deploycraft-install.log"
    echo "  Manda ese archivo por WhatsApp para ayuda."
    echo "  ============================================"
    echo ""
    log "Instalacion ABORTADA."
    read -p "  Presiona Enter para cerrar..."
    exit 1
}

# ─── SUBRUTINA: find_java ─────────────────────────────────────
# Busca java en PATH, /usr/bin, JAVA_HOME, y rutas de Homebrew/Temurin.
# Si lo encuentra setea JAVA_EXE con la ruta absoluta.
find_java() {
    JAVA_EXE=""

    # 1. PATH directo
    if command -v java &>/dev/null; then
        JAVA_EXE="$(command -v java)"
        return 0
    fi

    # 2. JAVA_HOME si esta definido
    if [[ -n "$JAVA_HOME" && -x "$JAVA_HOME/bin/java" ]]; then
        JAVA_EXE="$JAVA_HOME/bin/java"
        return 0
    fi

    # 3. Rutas conocidas de Homebrew, Temurin, macOS JDK
    local candidates=(
        "/usr/bin/java"
        "/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home/bin/java"
        "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home/bin/java"
        "/opt/homebrew/opt/openjdk@21/bin/java"
        "/usr/local/opt/openjdk@21/bin/java"
    )

    for candidate in "${candidates[@]}"; do
        if [[ -x "$candidate" ]]; then
            # Verificar que realmente ejecuta
            "$candidate" -version &>/dev/null && {
                JAVA_EXE="$candidate"
                return 0
            }
        fi
    done

    # 4. Buscar en /Library/Java/JavaVirtualMachines/ (todas las versiones)
    for jvm_home in /Library/Java/JavaVirtualMachines/*/Contents/Home/bin/java; do
        if [[ -x "$jvm_home" ]]; then
            "$jvm_home" -version &>/dev/null && {
                JAVA_EXE="$jvm_home"
                return 0
            }
        fi
    done

    return 1
}

# ─── INICIO ──────────────────────────────────────────────────
# Ir al home del usuario (el .command puede abrirse desde Finder en /)
cd "$HOME" || true

# Limpiar log anterior
> "$LOG_FILE"

log "============================================"
log " DeployCraft Installer v$VERSION"
log " $(date)"
log " OS: $(sw_vers -productName) $(sw_vers -productVersion)"
log " Arch: $(uname -m)"
log "============================================"

clear
echo ""
echo "  ============================================"
echo "   DeployCraft Installer v$VERSION"
echo "   Minecraft para amigos"
echo "  ============================================"
echo ""
info "Iniciando instalacion..."
echo ""

# ─────────────────────────────────────────────────────────────
# PASO 1 — DETECTAR ARQUITECTURA
# ─────────────────────────────────────────────────────────────
step "PASO 1/5" "Detectando sistema..."

ARCH="$(uname -m)"
log "Arquitectura detectada: $ARCH"

if [[ "$ARCH" == "arm64" ]]; then
    JAVA_DOWNLOAD_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_aarch64_mac_hotspot_21.0.5_11.pkg"
    ok "Apple Silicon (M1/M2/M3) detectado."
elif [[ "$ARCH" == "x86_64" ]]; then
    JAVA_DOWNLOAD_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_mac_hotspot_21.0.5_11.pkg"
    ok "Intel Mac detectado."
else
    err "Arquitectura no reconocida: $ARCH"
    log "ERROR: Arquitectura no soportada: $ARCH"
    abort
fi

# ─────────────────────────────────────────────────────────────
# PASO 2 — JAVA
# FIX: Busqueda exhaustiva + verificacion post-instalacion
# ─────────────────────────────────────────────────────────────
step "PASO 2/5" "Verificando Java..."

if find_java; then
    ok "Java encontrado: $JAVA_EXE"
    log "Java ya presente. Saltando instalacion."
else
    warn "Java no encontrado. Descargando Java 21 Temurin..."
    log "Iniciando descarga de Java 21 PKG ($ARCH)..."

    JAVA_PKG="/tmp/java21_deploycraft.pkg"

    info "Descargando Java 21... puede tardar unos minutos segun tu internet."

    curl -fsSL --progress-bar \
        -o "$JAVA_PKG" \
        "$JAVA_DOWNLOAD_URL"

    if [[ ! -f "$JAVA_PKG" || ! -s "$JAVA_PKG" ]]; then
        err "No se pudo descargar Java. Verifica tu conexion."
        log "ERROR: Fallo descarga Java PKG."
        abort
    fi

    info "Instalando Java 21... esto puede pedir tu contrasena de Mac."
    log "Ejecutando installer PKG..."

    # installer requiere sudo — esto abre el prompt nativo de macOS
    sudo installer -pkg "$JAVA_PKG" -target /
    INSTALL_CODE=$?
    rm -f "$JAVA_PKG"

    if [[ $INSTALL_CODE -ne 0 ]]; then
        err "Fallo la instalacion de Java. Codigo: $INSTALL_CODE"
        log "ERROR: installer termino con codigo $INSTALL_CODE"
        abort
    fi

    log "installer termino correctamente (codigo 0)."

    # FIX: Verificacion real post-instalacion
    info "Verificando que Java funciona tras la instalacion..."
    log "Verificando Java post-instalacion..."

    # Esperar un momento para que el sistema registre el JDK
    sleep 2

    if find_java; then
        ok "Java 21 instalado y verificado: $JAVA_EXE"
        log "Java verificado OK: $JAVA_EXE"
    else
        err "Java se instalo pero el sistema no lo reconoce aun."
        warn "Cierra esta ventana, reinicia tu Mac y vuelve a ejecutar el instalador."
        log "ERROR: Java no verificable tras instalacion. Puede requerir reinicio."
        abort
    fi
fi

# ─────────────────────────────────────────────────────────────
# PASO 3 — TLAUNCHER
# ─────────────────────────────────────────────────────────────
step "PASO 3/5" "Descargando TLauncher..."
log "Descargando TLauncher.jar desde GitHub Releases..."

mkdir -p "$INSTALL_DIR"

curl -fsSL --progress-bar \
    -o "$INSTALL_DIR/TLauncher.jar" \
    "$TLAUNCHER_URL"

if [[ ! -f "$INSTALL_DIR/TLauncher.jar" ]]; then
    err "No se pudo descargar TLauncher. Verifica tu internet."
    log "ERROR: TLauncher.jar no descargado."
    abort
fi

# Verificar integridad basica (debe pesar mas de 1 MB)
JAR_SIZE=$(stat -f%z "$INSTALL_DIR/TLauncher.jar" 2>/dev/null || echo 0)
if [[ $JAR_SIZE -lt 1000000 ]]; then
    err "El archivo descargado esta corrupto ($JAR_SIZE bytes). Intenta de nuevo."
    log "ERROR: TLauncher.jar corrupto: $JAR_SIZE bytes"
    rm -f "$INSTALL_DIR/TLauncher.jar"
    abort
fi

ok "TLauncher descargado OK ($JAR_SIZE bytes)."
log "TLauncher.jar OK: $JAR_SIZE bytes"

# ─────────────────────────────────────────────────────────────
# PASO 4 — SERVIDOR
# ─────────────────────────────────────────────────────────────
step "PASO 4/5" "Configurando servidor DeployCraft..."
log "Descargando servers.dat..."

mkdir -p "$MC_DIR"

curl -fsSL \
    -o "$MC_DIR/servers.dat" \
    "$SERVERS_DAT_URL"

if [[ -f "$MC_DIR/servers.dat" && -s "$MC_DIR/servers.dat" ]]; then
    ok "Servidor DeployCraft preconfigurado en Multijugador."
    log "servers.dat instalado en: $MC_DIR"
else
    warn "No se pudo precargar el servidor — agregalo manual: deploycraft.falix.dev"
    log "WARN: servers.dat no descargado. Continuando..."
fi

# ─────────────────────────────────────────────────────────────
# PASO 5 — ACCESO DIRECTO
# ─────────────────────────────────────────────────────────────
step "PASO 5/5" "Creando acceso directo en el Escritorio..."
log "Creando TLauncher.command en Escritorio..."

cat > "$SHORTCUT" << EOF
#!/bin/bash
"$JAVA_EXE" -jar "$INSTALL_DIR/TLauncher.jar"
EOF

chmod +x "$SHORTCUT"

if [[ -f "$SHORTCUT" ]]; then
    ok "Acceso directo creado: TLauncher.command"
    log "Acceso directo OK: $SHORTCUT"
else
    warn "No se pudo crear el acceso directo."
    log "WARN: Acceso directo no creado."
fi

# ─────────────────────────────────────────────────────────────
# ABRIR TLAUNCHER + FIX 4: Verificar que el proceso levanta
# ─────────────────────────────────────────────────────────────
echo ""
echo "  ============================================"
ok "INSTALACION COMPLETADA"
echo ""
echo "  Que hacer ahora:"
echo "  1. Escribe tu nick abajo a la izquierda en TLauncher"
echo "  2. Selecciona 'Oficial 26.2' en el desplegable"
echo "  3. Click 'Entrar al juego' (descarga la version la 1a vez)"
echo "  4. Multijugador > DeployCraft ya aparece en la lista"
echo "     Si no: Agregar servidor > deploycraft.falix.dev"
echo "  ============================================"
echo ""

info "Abriendo TLauncher..."
log "Lanzando TLauncher con: $JAVA_EXE"

"$JAVA_EXE" -jar "$INSTALL_DIR/TLauncher.jar" &
TLAUNCHER_PID=$!

# FIX 4: Esperar y verificar que el proceso levanto
sleep 5

if kill -0 "$TLAUNCHER_PID" 2>/dev/null; then
    ok "TLauncher corriendo correctamente (PID: $TLAUNCHER_PID)."
    log "TLauncher OK — PID $TLAUNCHER_PID activo."
else
    warn "TLauncher puede no haber iniciado automaticamente."
    warn "Haz doble clic en 'TLauncher.command' en tu Escritorio para abrirlo."
    log "WARN: PID $TLAUNCHER_PID no activo tras 5 segundos."
fi

echo ""
log "Script finalizado."
read -p "  Presiona Enter para cerrar..."
exit 0
