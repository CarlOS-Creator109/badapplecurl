#!/usr/bin/env bash
# Lanzador de Bad Apple curl -- COS-Mods (Carlos)
# Atajo: siempre baja badapple.sh fresco via curl y lo corre en una xterm
# con el tamano/fuente correctos. No usa cache -- cada corrida jala de nuevo.
#
# Uso:
#   curl -s https://raw.githubusercontent.com/CarlOS-Creator109/badapplecurl/main/launch.sh | bash
#
#   bash launch.sh --here   -> lo corre en la terminal actual, sin abrir xterm nueva

RAW_URL="https://raw.githubusercontent.com/CarlOS-Creator109/badapplecurl/main/badapple.sh"
TMP_SCRIPT="/tmp/badapple.sh"

RUN_HERE=0
for arg in "$@"; do
  case "$arg" in
    --here) RUN_HERE=1 ;;
  esac
done

echo "Descargando badapple.sh..."
curl -s "$RAW_URL" -o "$TMP_SCRIPT" || { echo "Fallo la descarga."; exit 1; }
chmod +x "$TMP_SCRIPT"

if [ "$RUN_HERE" -eq 1 ]; then
  bash "$TMP_SCRIPT"
else
  command -v xterm >/dev/null 2>&1 || { echo "xterm no encontrado, corriendo aqui mismo..."; bash "$TMP_SCRIPT"; exit 0; }
  xterm -fa monospace -fs 12 -geometry 81x29 -e bash "$TMP_SCRIPT"
fi
