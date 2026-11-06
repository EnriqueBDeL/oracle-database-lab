#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/00-config.sh"

cd "${ROOT_DIR}"

ok=0
fail=0

check() {
  local description="$1"
  shift

  if "$@"; then
    printf '[OK]   %s\n' "${description}"
    ok=$((ok + 1))
  else
    printf '[ERROR] %s\n' "${description}"
    fail=$((fail + 1))
  fi
}

echo "== 13: Verificación final =="

check ".gitattributes existe" test -f .gitattributes
check ".gitignore existe" test -f .gitignore
check "config/.env.example existe" test -f config/.env.example
check "00-config.sh existe" test -f scripts/deployment/env/00-config.sh
check "V000 existe" test -f database/migrations/V000__setup_entornos_negocio.sql
check "V001 existe" test -f database/migrations/V001__create_esquemas_negocio.sql
check "respuestas del laboratorio existen" test -f docs/bitacora/lab3-respuestas.md
check "contenedor Oracle está ejecutándose" docker ps \
  --filter "name=^/${CONT_NAME}$" --filter "status=running" \
  --format '{{.Names}}' | grep -qx "${CONT_NAME}"
check "puerto Oracle está disponible" bash -c \
  "timeout 3 bash -c '</dev/tcp/127.0.0.1/${PORT_DB}'"
check "no existe config/.env versionado" bash -c \
  "! git ls-files --error-unmatch config/.env >/dev/null 2>&1"

echo
echo "Resultado: ${ok} comprobaciones correctas, ${fail} errores"

if [ "${fail}" -ne 0 ]; then
  exit 1
fi

echo "VERIFICACIÓN FINAL: OK"
