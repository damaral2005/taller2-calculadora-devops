#!/usr/bin/env bash

set -euo pipefail

BACKEND_URL="http://localhost:5000"
FRONTEND_URL="http://localhost:8080"


echo "======================================"
echo "   TESTS CALCULADORA - CI"
echo "======================================"


wait_for_service() {
    local url="$1"
    local name="$2"

    echo "Esperando $name..."

    for i in {1..30}; do

        if curl -fsS "$url" > /dev/null; then
            echo "$name disponible."
            return 0
        fi

        sleep 2
    done

    echo "ERROR: $name no respondió."
    exit 1
}


# -----------------------------------
# Esperar servicios
# -----------------------------------

wait_for_service "$BACKEND_URL/health" "Backend"
wait_for_service "$FRONTEND_URL/status" "Frontend"


# -----------------------------------
# TEST 1 - Health Backend
# -----------------------------------

echo ""
echo "TEST 1: Backend /health"

response=$(curl -fsS "$BACKEND_URL/health")

echo "$response"

echo "$response" |
    grep -Eq '"status"[[:space:]]*:[[:space:]]*"ok"'

echo "OK - Backend saludable"


# -----------------------------------
# TEST 2 - Frontend
# -----------------------------------

echo ""
echo "TEST 2: Frontend /status"

response=$(curl -fsS "$FRONTEND_URL/status")

echo "$response"

echo "$response" |
    grep -Eq '"status"[[:space:]]*:[[:space:]]*"ok"'

echo "OK - Frontend saludable"


# -----------------------------------
# TEST 3 - Suma
# -----------------------------------

echo ""
echo "TEST 3: 10 + 5 = 15"

response=$(curl -fsS \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"a":10,"b":5}' \
    "$BACKEND_URL/add")

echo "$response"

echo "$response" |
    grep -Eq '"result"[[:space:]]*:[[:space:]]*15'

echo "OK - Suma correcta"


# -----------------------------------
# TEST 4 - Resta
# -----------------------------------

echo ""
echo "TEST 4: 10 - 5 = 5"

response=$(curl -fsS \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"a":10,"b":5}' \
    "$BACKEND_URL/subtract")

echo "$response"

echo "$response" |
    grep -Eq '"result"[[:space:]]*:[[:space:]]*5'

echo "OK - Resta correcta"


# -----------------------------------
# TEST 5 - Multiplicación
# -----------------------------------

echo ""
echo "TEST 5: 10 x 5 = 50"

response=$(curl -fsS \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"a":10,"b":5}' \
    "$BACKEND_URL/multiply")

echo "$response"

echo "$response" |
    grep -Eq '"result"[[:space:]]*:[[:space:]]*50'

echo "OK - Multiplicación correcta"


# -----------------------------------
# TEST 6 - División
# -----------------------------------

echo ""
echo "TEST 6: 10 / 5 = 2"

response=$(curl -fsS \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"a":10,"b":5}' \
    "$BACKEND_URL/divide")

echo "$response"

echo "$response" |
    grep -Eq '"result"[[:space:]]*:[[:space:]]*2'

echo "OK - División correcta"


# -----------------------------------
# TEST 7 - División por cero
# -----------------------------------

echo ""
echo "TEST 7: División por cero debe devolver HTTP 400"

http_code=$(curl -s \
    -o /tmp/division_zero.json \
    -w "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"a":10,"b":0}' \
    "$BACKEND_URL/divide")

cat /tmp/division_zero.json
echo ""

if [ "$http_code" != "400" ]; then
    echo "ERROR: Se esperaba HTTP 400 pero llegó $http_code"
    exit 1
fi

echo "OK - División por cero controlada"


# -----------------------------------
# TEST 8 - Historial
# -----------------------------------

echo ""
echo "TEST 8: Historial de operaciones"

response=$(curl -fsS "$BACKEND_URL/operations")

echo "$response"

echo "$response" |
    grep -Eq '"operation"'

echo "OK - Historial disponible"


echo ""
echo "======================================"
echo " TODOS LOS TESTS PASARON"
echo "======================================"