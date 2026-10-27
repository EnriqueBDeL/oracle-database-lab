-- scripts/lab5/01-perfil-tiendasur.sql — el perfil del banco: lo que el optimizador sabe de cada tabla y columna
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 170 PAGESIZE 100 FEEDBACK OFF VERIFY OFF TAB OFF
COLUMN table_name FORMAT A8
COLUMN column_name FORMAT A14
COLUMN histogram FORMAT A10
COLUMN data_type FORMAT A12
ALTER SESSION SET CONTAINER = FREEPDB1;
PROMPT
PROMPT ===== 1. Tablas: r filas, b bloques, R bytes por fila y bfr = r / b =====
SELECT table_name, num_rows AS r, blocks AS b, avg_row_len AS r_bytes, ROUND(num_rows / blocks) AS bfr,
       ROUND(blocks * 8192 / 1048576, 1) AS mb, last_analyzed
  FROM dba_tables WHERE owner = 'TIENDASUR' ORDER BY table_name;
PROMPT
PROMPT ===== 2. Columnas: valores distintos (NDV), selectividad de una igualdad (1/NDV) y si hay histograma =====
SELECT c.table_name, c.column_name, t.data_type, c.num_distinct AS ndv, ROUND(100 / NULLIF(c.num_distinct, 0), 4) AS pct_por_valor,
       c.num_nulls, c.histogram, c.avg_col_len
  FROM dba_tab_col_statistics c JOIN dba_tab_columns t
    ON t.owner = c.owner AND t.table_name = c.table_name AND t.column_name = c.column_name
 WHERE c.owner = 'TIENDASUR' ORDER BY c.table_name, t.column_id;
PROMPT
PROMPT ===== 3. Los sesgos que dan juego a las consultas Q1-Q16 =====
SELECT 'cliente pais = ES' AS dato, ROUND(100 * AVG(CASE WHEN pais = 'ES' THEN 1 ELSE 0 END), 1) AS pct FROM tiendasur.cliente
UNION ALL SELECT 'cliente ciudad = Lorca', ROUND(100 * AVG(CASE WHEN ciudad = 'Lorca' THEN 1 ELSE 0 END), 2) FROM tiendasur.cliente
UNION ALL SELECT 'cliente apellidos LIKE Gonz%', ROUND(100 * AVG(CASE WHEN apellidos LIKE 'Gonz%' THEN 1 ELSE 0 END), 1) FROM tiendasur.cliente
UNION ALL SELECT 'pedido estado = P', ROUND(100 * AVG(CASE WHEN estado = 'P' THEN 1 ELSE 0 END), 1) FROM tiendasur.pedido
UNION ALL SELECT 'pedido último año', ROUND(100 * AVG(CASE WHEN fecha_pedido >= SYSDATE - 365 THEN 1 ELSE 0 END), 1) FROM tiendasur.pedido;
PROMPT
PROMPT ===== 4. El entorno de medida que usaremos en todo el laboratorio =====
PROMPT   SELECT /*+ GATHER_PLAN_STATISTICS */ ...;
PROMPT   SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(FORMAT => 'IOSTATS LAST'));
PROMPT   Y en una línea: EXEC lab_tools.medir.consulta('etiqueta', 'SELECT ...')
EXIT
