#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/00-config.sh"

echo "== 09: Verificación de herramientas =="

echo "-- Java --"
if command -v java >/dev/null 2>&1; then
  java -version 2>&1 | head -n 1
else
  echo "ERROR: Java no está instalado"
  exit 1
fi

echo "-- SQLcl --"
if command -v sql >/dev/null 2>&1; then
  sql -version 2>&1 | head -n 3 || true
else
  echo "ERROR: SQLcl no está disponible en PATH"
  exit 1
fi

echo "-- Docker --"
docker version --format 'Docker {{.Server.Version}}'

echo "-- Contenedor Oracle --"
docker ps --filter "name=^/${CONT_NAME}$" \
  --format 'container={{.Names}} status={{.Status}}'

echo "-- Puerto Oracle --"
if command -v nc >/dev/null 2>&1; then
  nc -z localhost "${PORT_DB}"
else
  timeout 3 bash -c "</dev/tcp/127.0.0.1/${PORT_DB}"
fi

echo "-- Puerto ORDS/Database Actions --"
if command -v curl >/dev/null 2>&1; then
  curl --fail --silent --show-error \
    "http://localhost:${PORT_ORDS}/ords/" >/dev/null
  echo "Database Actions responde en el puerto ${PORT_ORDS}"
else
  echo "ADVERTENCIA: curl no está instalado"
fi

echo "OK: herramientas verificadas"
