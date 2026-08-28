#!/usr/bin/env bash
# Instala el runtime (Node.js) y las dependencias del componente indicado.
# Idempotente: se puede correr varias veces sin romper nada.
#
# Uso: ./install.sh {backend|frontend}

set -euo pipefail

COMPONENT="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ "$COMPONENT" != "backend" && "$COMPONENT" != "frontend" ]]; then
  echo "Uso: $0 {backend|frontend}" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js no encontrado. Instalando Node.js 18 LTS..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

echo "Node: $(node -v)"
echo "npm:  $(npm -v)"

cd "${PROJECT_DIR}/${COMPONENT}"
npm install

echo "Dependencias de ${COMPONENT} instaladas correctamente."
