#!/usr/bin/env bash
# scripts/lab5/02-anatomia-indice.sh — anatomía de un índice: diccionario, INDEX_STATS, volcado de raíz y hoja, y radiografía de las hojas
# Uso: bash scripts/lab5/02-anatomia-indice.sh
set -euo pipefail
source scripts/deployment/env/00-config.sh
TS=$(ts)
mkdir -p "$EVID_LAB5/script" "$EVID_LAB5/config"
bash scripts/ops/sysdba.sh scripts/lab5/02-anatomia-indice.sql "$EVID_LAB5/script/${TS}_02-anatomia-indice.script.log"

PK_PED=$(docker exec "$CONT_NAME" sqlplus -s -L / as sysdba <<'SQLEOF'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT NVL(
  (SELECT index_name FROM dba_indexes WHERE owner = 'TIENDASUR' AND index_name = 'PK_PEDIDO'),
  (SELECT constraint_name FROM dba_constraints WHERE owner = 'TIENDASUR' AND table_name = 'PEDIDO' AND constraint_type = 'P')
) FROM dual;
EXIT
SQLEOF
)
PK_PED=$(echo "$PK_PED" | tr -d '[:space:]')

for IDX in "$PK_PED" IX_PED_CLIENTE; do
  bash scripts/ops/grafico-indice.sh TIENDASUR "$IDX" "$EVID_LAB5/script/${TS}_02-grafico-${IDX}.script.log"
done
TRAZA=$(docker exec "$CONT_NAME" bash -c 'ls -t /opt/oracle/diag/rdbms/free/FREE/trace/*lab5_indice*.trc | head -1')
docker cp "$CONT_NAME:$TRAZA" "$EVID_LAB5/config/${TS}_02-volcado-indice.trc.txt"
echo "Traza del treedump y de los volcados copiada a $EVID_LAB5/config/${TS}_02-volcado-indice.trc.txt"
