# Taller 2 — Calculadora Distribuida (DevOps / Wall of Confusion)

Ingeniería de Software V — Universidad ICESI

Calculadora distribuida cliente-servidor usada para simular la transición
de despliegue manual en silos (Fase 1) a despliegue automatizado (Fase 2).

## Estructura

```
backend/    API REST (Node.js + Express) — /add /subtract /multiply /divide /operations /health
frontend/   Cliente web (Node.js + Express estático) — consume el backend, expone /status
scripts/    Automatización de Fase 2 (firewall, instalación, despliegue)
docker-compose.yml, backend/Dockerfile, frontend/Dockerfile  — contenedores
DESPLIEGUE.txt   Instrucciones de despliegue manual (Fase 1)
```

## Historias de usuario

- **HU1** — Suma (`POST /add`)
- **HU2** — Resta y multiplicación (`POST /subtract`, `POST /multiply`)
- **HU3** — Historial persistente de las últimas 5 operaciones (`GET /operations`)
- **HU4** — División con validación de cero (`POST /divide` → 400 si `b == 0`)
- **HU5** — Health check / telemetría (`GET /health` en backend, `GET /status` en frontend)

## Despliegue manual (Fase 1)

Ver [`DESPLIEGUE.txt`](./DESPLIEGUE.txt).

## Despliegue automatizado (Fase 2)

```bash
./scripts/deploy.sh backend
./scripts/deploy.sh frontend
```

Cada script instala el runtime/dependencias, configura `ufw` (deja solo
el puerto del componente y SSH abiertos) y arranca el proceso en segundo
plano (log y pid en `.run/`).

## Contenedores

```bash
docker compose up -d --build
```

- Backend: http://localhost:5000
- Frontend: http://localhost:8080

## Métricas (Cuadro 1 del enunciado)

Pendiente de completar tras correr la simulación cronometrada (Fase 1 vs
Fase 2): Lead Time, Deployment Frequency, Change Failure Rate, MTTR.






drwx------  2 swarch swarch 4096 Sep  2 12:19 .
drwxr-x--- 16 swarch swarch 4096 Sep  2 12:19 ..
-rw-r--r--  1 swarch swarch  284 Sep  2 12:25 known_hosts

