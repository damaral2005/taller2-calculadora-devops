#!/usr/bin/env bash
# Script principal de despliegue (Fase 2 - Continuous Delivery).
# Instala dependencias, configura el firewall y (re)inicia el componente
# como proceso en segundo plano, dejando log y pid para poder pararlo
# o hacer rollback rapidamente.
#
# Uso:
#   ./deploy.sh backend
#   ./deploy.sh frontend
#   PORT=5001 ./deploy.sh backend   # puerto alterno

set -euo pipefail

COMPONENT="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RUN_DIR="${PROJECT_DIR}/.run"

if [[ "$COMPONENT" != "backend" && "$COMPONENT" != "frontend" ]]; then
  echo "Uso: $0 {backend|frontend}" >&2
  exit 1
fi

mkdir -p "$RUN_DIR"
PID_FILE="${RUN_DIR}/${COMPONENT}.pid"
LOG_FILE="${RUN_DIR}/${COMPONENT}.log"

# 1. Runtime + dependencias
"${SCRIPT_DIR}/install.sh" "$COMPONENT"

# 2. Firewall (requiere sudo; se puede omitir con SKIP_FIREWALL=1 en entornos de prueba)
if [[ "${SKIP_FIREWALL:-0}" != "1" ]]; then
  "${SCRIPT_DIR}/firewall.sh" "$COMPONENT" || echo "Aviso: no se pudo configurar ufw (¿falta sudo?)."
fi

# 3. Si ya habia una instancia corriendo, se detiene (rollback / redeploy limpio)
if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "Deteniendo instancia previa de ${COMPONENT} (pid $(cat "$PID_FILE"))..."
  kill "$(cat "$PID_FILE")"
  sleep 1
fi

# 4. Arranque en segundo plano
cd "${PROJECT_DIR}/${COMPONENT}"
nohup node server.js > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

sleep 1
if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "${COMPONENT} desplegado. PID=$(cat "$PID_FILE"). Log: ${LOG_FILE}"
  tail -n 5 "$LOG_FILE"
else
  echo "El despliegue de ${COMPONENT} fallo. Revisa ${LOG_FILE}" >&2
  exit 1
fi
