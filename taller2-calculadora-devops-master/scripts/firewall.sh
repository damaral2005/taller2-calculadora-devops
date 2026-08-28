#!/usr/bin/env bash
# Configura ufw en el servidor de produccion (Ops): activa el firewall,
# bloquea todo el trafico entrante por defecto y abre unicamente el
# puerto del componente que se esta desplegando en esta maquina.
#
# Uso:
#   sudo ./firewall.sh backend    # abre el puerto del backend (5000)
#   sudo ./firewall.sh frontend   # abre el puerto del frontend (8080)
#   sudo ./firewall.sh <puerto>   # abre un puerto especifico

set -euo pipefail

BACKEND_PORT=5000
FRONTEND_PORT=8080

if [[ $# -ne 1 ]]; then
  echo "Uso: $0 {backend|frontend|<puerto>}" >&2
  exit 1
fi

case "$1" in
  backend)
    PORT="$BACKEND_PORT"
    ;;
  frontend)
    PORT="$FRONTEND_PORT"
    ;;
  ''|*[!0-9]*)
    echo "Argumento invalido: $1" >&2
    exit 1
    ;;
  *)
    PORT="$1"
    ;;
esac

if ! command -v ufw >/dev/null 2>&1; then
  echo "ufw no esta instalado. Instalando..." >&2
  sudo apt-get update -y && sudo apt-get install -y ufw
fi

# Deja siempre abierto SSH (22) para no perder acceso remoto al PC de Ops.
sudo ufw allow OpenSSH >/dev/null 2>&1 || sudo ufw allow 22/tcp

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow "${PORT}/tcp"

sudo ufw --force enable

echo "Firewall activo. Puerto ${PORT}/tcp autorizado (entrante)."
sudo ufw status verbose
