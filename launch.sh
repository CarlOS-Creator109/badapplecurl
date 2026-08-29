#!/usr/bin/env bash
# Lanzador de Bad Apple curl -- COS-Mods (Carlos)
# Baja badapple.sh fresco via curl, revisa/instala dependencias que falten,
# y lo corre en xterm o xfce4-terminal (el que este disponible) con la
# geometria correcta. Si no hay ninguna terminal grafica, lo corre inline.
#
# Uso:
#   curl -s https://raw.githubusercontent.com/CarlOS-Creator109/badapplecurl/main/launch.sh | bash
#   bash launch.sh --here   -> lo corre en la terminal actual, sin abrir una nueva

RAW_URL="https://raw.githubusercontent.com/CarlOS-Creator109/badapplecurl/main/badapple.sh"
TMP_SCRIPT="/tmp/badapple.sh"

RUN_HERE=0
SKIP_CHECKS=0
for arg in "$@"; do
  case "$arg" in
    --here)         RUN_HERE=1 ;;
    --skip-checks)  SKIP_CHECKS=1 ;;
  esac
done

detect_pkg_manager() {
  if command -v pacman   >/dev/null 2>&1; then echo pacman;  return; fi
  if command -v apt-get  >/dev/null 2>&1; then echo apt;     return; fi
  if command -v dnf      >/dev/null 2>&1; then echo dnf;     return; fi
  if command -v zypper   >/dev/null 2>&1; then echo zypper;  return; fi
  if command -v apk      >/dev/null 2>&1; then echo apk;     return; fi
  echo none
}

install_pkg() {
  local pkg="$1"
  local mgr
  mgr=$(detect_pkg_manager)
  echo "Instalando '$pkg' con $mgr..."
  case "$mgr" in
    pacman) sudo pacman -Sy --noconfirm "$pkg" ;;
    apt)    sudo apt-get update -y && sudo apt-get install -y "$pkg" ;;
    dnf)    sudo dnf install -y "$pkg" ;;
    zypper) sudo zypper --non-interactive install "$pkg" ;;
    apk)    sudo apk add "$pkg" ;;
    *)      echo "No se detecto un gestor de paquetes conocido. Instala '$pkg' manualmente."; return 1 ;;
  esac
}

ensure_cmd() {
  local cmd="$1" pkg="${2:-$1}"
  command -v "$cmd" >/dev/null 2>&1 && return 0
  echo "Falta '$cmd' (paquete: $pkg)."
  read -r -p "Instalarlo automaticamente? [S/n] " resp
  resp=${resp:-S}
  case "$resp" in
    [sS]*) install_pkg "$pkg" ;;
    *)     echo "Saltando '$pkg' -- puede que algo no funcione."; return 1 ;;
  esac
}

if [ "$SKIP_CHECKS" -eq 0 ]; then
  # Dependencias basicas que usa badapple.sh
  ensure_cmd curl
  ensure_cmd gunzip gzip
  ensure_cmd base64 coreutils
  if ! command -v ffplay >/dev/null 2>&1 && ! command -v ffmpeg >/dev/null 2>&1; then
    ensure_cmd ffplay ffmpeg
  fi
fi

echo "Descargando badapple.sh..."
curl -s "$RAW_URL" -o "$TMP_SCRIPT" || { echo "Fallo la descarga."; exit 1; }
chmod +x "$TMP_SCRIPT"

if [ "$RUN_HERE" -eq 1 ]; then
  bash "$TMP_SCRIPT"
  exit 0
fi

# Terminal grafica: prueba xterm, luego xfce4-terminal, si no hay ninguna ofrece instalar xterm
if [ "$SKIP_CHECKS" -eq 0 ] && ! command -v xterm >/dev/null 2>&1 && ! command -v xfce4-terminal >/dev/null 2>&1; then
  echo "No se encontro xterm ni xfce4-terminal."
  ensure_cmd xterm
fi

if command -v xterm >/dev/null 2>&1; then
  xterm -fa monospace -fs 12 -geometry 81x29 -e bash "$TMP_SCRIPT"
elif command -v xfce4-terminal >/dev/null 2>&1; then
  xfce4-terminal --geometry=81x29 -x bash "$TMP_SCRIPT"
else
  echo "No hay terminal grafica disponible, corriendo aqui mismo..."
  bash "$TMP_SCRIPT"
fi
