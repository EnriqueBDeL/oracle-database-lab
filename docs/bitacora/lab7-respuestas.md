# Laboratorio 7 · Respuestas · E006

<!--
CÓMO SE RELLENA
- Copia este archivo como docs/bitacora/lab7-respuestas.md y pon tu código en el título.
- Responde con TUS números: cada respuesta cita el archivo de evidencia de donde sale (docs/bitacora/lab7/evidencia/...).
  Una cifra sin evidencia no puntúa. Las cifras del PPTX son de referencia: las tuyas serán parecidas, no iguales.
- 3 a 6 líneas por pregunta. No pegues salidas enteras: el archivo de evidencia ya las tiene.
- No borres los títulos: scripts/lab7/09-verificacion-final.sh comprueba que están todos.
-->

## Parte B · C01 · Más sesiones no es más rendimiento
1. ¿Cuántas llamadas por segundo y qué p95 tuviste con 1, 2 y 8 sesiones? ¿Qué número de sesiones recomiendas y por qué?
   Con 1 sesión obtuve 5,1 llamadas/s y p95 de 207,1 ms; con 2, 9,5 llamadas/s y p95 de 303 ms; con 8, 8,0 llamadas/s y p95 de 1.341,1 ms. Recomiendo 2 sesiones: dan más throughput que 8 con mucha menos latencia, y coinciden con `CPU_COUNT=2`. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261125T182107Z_C01_entender.txt`, `.../20261125T183150Z_C01_validar.txt` y `.../20261125T182536Z_C01_diagnosticar.txt`.
2. ¿Qué evento domina con 8 sesiones y qué significa en Oracle Free?
   Dominó `resmgr:cpu quantum`, con 229 de 296 muestras (77,4 %); el 22,6 % restante fue `ON CPU`. Es la espera por turno de CPU impuesta por el gestor de recursos: Oracle Free limita la instancia a 2 CPU, así que las sesiones excedentes hacen cola en vez de aumentar el rendimiento. Evidencia: `docs/bitacora/lab7/evidencia/casos/20261125T182536Z_C01_diagnosticar.txt`.
3. Comprueba la ley de Little (N = X · R) con tus tres medidas.
   Uso la latencia media `R` (no p95): 1 sesión, `5,1 × 0,190 = 0,97 ≈ 1`; 2 sesiones, `9,5 × 0,2089 = 1,98 ≈ 2`; 8 sesiones, `8,0 × 0,9786 = 7,83 ≈ 8`. Las pequeñas diferencias se deben al redondeo de las medidas. Evidencia: `docs/bitacora/lab7/evidencia/casos/20261125T183218Z_C01_observar.txt`.

## Parte C · C03 · Literales y análisis completos
1. Análisis completos y tiempo con literales, con variables de enlace y con CURSOR_SHARING = FORCE (tus cifras).
   Con literales hubo 5.044 hard parses, 4.140 ms de análisis y 4.980 ms totales para 5.000 llamadas. Con variables de enlace: 28 hard parses y 190 ms totales; con `CURSOR_SHARING=FORCE`: 28 hard parses y 290 ms totales. Los enlaces dieron el menor tiempo. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162600Z_C03_diagnosticar.txt`, `.../20261126T162601Z_C03_solucionar.txt` y `.../20261126T162602Z_C03_observar.txt`.
2. ¿Por qué FORCE es un puente y no la solución? ¿Qué ve el DBA en V$SQL que lo delata (FORCE_MATCHING_SIGNATURE)?
   `FORCE` alivia los análisis, pero sustituye literales en la sesión sin corregir la aplicación; los binds explícitos son la solución duradera y dieron menor tiempo (190 ms frente a 290 ms). En `V$SQL`, una misma `FORCE_MATCHING_SIGNATURE` agrupó 877 `SQL_ID` distintos con 877 ejecuciones: textos literales distintos que Oracle puede hacer coincidir. Con `FORCE`, el SQL aparece con el bind del sistema `:"SYS_B_0"`. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162600Z_C03_diagnosticar.txt` y `.../20261126T162602Z_C03_observar.txt`.

## Parte C · C04 · El informe que se desborda a TEMP
1. Bloques de TEMP, tipo de pasada y tiempo del informe antes y después. ¿Qué hacía el disparador de logon?
   Con la configuración heredada, el informe completo tardó 2.170 ms y escribió/leyó 6.712 bloques de TEMP (52,4 MB); la ordenación hizo 2 pasadas. Tras quitar el disparador y volver a PGA automática, el informe completo tardó 890 ms, sin TEMP y con ordenación `OPTIMAL`. El TOP 100 tardó 140 ms, sin TEMP y también `OPTIMAL`. El trigger imponía `WORKAREA_SIZE_POLICY=MANUAL` y `SORT_AREA_SIZE=1 MB` a `T6_INF`. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162341Z_C04_provocar.txt`, `.../20261126T162342Z_C04_entender.txt`, `.../20261126T162342Z_C04_diagnosticar.txt` y `.../20261126T162344Z_C04_solucionar.txt`.
2. ¿Por qué el TOP 100 cabe en memoria y el informe completo no?
   El TOP-N mantiene en memoria solo las 100 filas que necesita la pantalla (0,0 MB), por eso su área de trabajo queda `OPTIMAL` y usa 0 bloques de TEMP. El informe completo debe ordenar el millón de filas: con la política manual de 1 MB frente a 55,5 MB óptimos, se desbordó a TEMP y necesitó 2 pasadas; al volver a PGA automática terminó `OPTIMAL` y sin TEMP. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162342Z_C04_diagnosticar.txt`, `.../20261126T162345Z_C04_validar.txt` y `.../20261126T162345Z_C04_observar.txt`.

## Parte D · C07 · EXPLAIN PLAN frente al plan real
1. Copia el predicado que delata el problema en el plan real y explica de dónde sale.
2. Lecturas y p95 de V1 y V2. ¿Por qué EXPLAIN PLAN no lo vio?

## Parte D · C08 · El optimizador cree 6 filas y son 99 (E-Rows frente a A-Rows)

1. **Estimación y filas reales antes y después del grupo de columnas. ¿En qué línea del plan se separan por primera vez?**
   Antes de crear la estadística extendida, el optimizador estimaba **6** clientes (`E-Rows`) frente a los **99** reales (`A-Rows`) en el acceso a `CLIENTE`, arrastrando el error hacia arriba hasta estimar **55** pedidos finales frente a **987** reales (`docs/bitacora/lab7/evidencia/casos/20261126T164517Z_C08_diagnosticar.txt`). Leyendo el plan de dentro afuera, la primera operación donde `E-Rows × Starts` se desvía de `A-Rows` es la **línea 3 (`TABLE ACCESS BY INDEX ROWID BATCHED` sobre `CLIENTE`)**. Tras crear el grupo de columnas `(CIUDAD, COMUNIDAD)` y recoger estadísticas, la estimación en esa línea 3 pasa a **100** filas frente a **99** reales, y el total del plan se ajusta a **991** estimadas frente a **987** reales (`docs/bitacora/lab7/evidencia/casos/20261126T164518Z_C08_solucionar.txt` y `20261126T164518Z_C08_validar.txt`).

2. **¿Por qué el optimizador multiplicaba mal las dos selectividades?**
   Porque, al no tener estadísticas conjuntas, el optimizador asume que ambas columnas son estadísticamente independientes y multiplica sus selectividades individuales ($100\,000 \times \frac{1}{1\,001} \times \frac{1}{18} \approx 5{,}6 \rightarrow 6$). Como `CIUDAD` y `COMUNIDAD` están correlacionadas (cada ciudad pertenece a una única comunidad), filtrar por la comunidad no reduce más el conjunto de clientes ya filtrados por ciudad, provocando esa subestimación (`docs/bitacora/lab7/evidencia/casos/20261126T164516Z_C08_entender.txt`).

## Parte E · C12 · Tras la carga nocturna el plan se equivoca (estadísticas obsoletas)

1. **Filas según las estadísticas y reales; método de unión y lecturas antes y después.**
   Antes de recoger estadísticas, `CARRITO` registraba **100** filas en `NUM_ROWS` (`STALE_STATS = YES`) frente a **200 100** filas reales, lo que llevó al optimizador a elegir **`NESTED LOOPS`** realizando **212 169** lecturas lógicas (`docs/bitacora/lab7/evidencia/casos/20261126T165622Z_C12_entender.txt` y `20261126T165634Z_C12_diagnosticar.txt`). Tras ejecutar `DBMS_STATS.GATHER_TABLE_STATS` únicamente sobre `CARRITO`, las estadísticas reflejan **200 100** filas (`STALE_STATS = NO`), el plan pasa a usar **`HASH JOIN`** y las lecturas lógicas caen a **6 604** (`docs/bitacora/lab7/evidencia/casos/20261126T165646Z_C12_solucionar.txt` y `20261126T165656Z_C12_validar.txt`).

2. **¿Por qué la tarea automática no lo habría arreglado a tiempo? ¿Quién debe recoger y cuándo?**
   Porque la tarea automática (`auto optimizer stats collection`, del grupo `ORA$AT_WGRP_OS`) solo actúa durante las ventanas de mantenimiento nocturnas (a partir de las **22:00**, como `THURSDAY_WINDOW`), por lo que una carga de madrugada queda con estadísticas obsoletas hasta la noche siguiente penalizando los informes matinales (`docs/bitacora/lab7/evidencia/casos/20261126T165710Z_C12_observar.txt`). Para evitarlo, debe ser el propio proceso o *job* que realiza la carga masiva quien ejecute `DBMS_STATS.GATHER_TABLE_STATS` sobre la tabla afectada justo al terminar la inserción (runbook RB-2).

## Parte E · C13 · Cambiar estadísticas con red: pendientes, publicar, restaurar y bloquear

1. **Describe el ciclo que seguiste (pendientes, probar, publicar, restaurar, bloquear) con la vista que comprueba cada paso.**
   Tras actualizar **133 748** pedidos (`STALE_STATS = YES`, `PUBLISH = TRUE`, estimando **250 000** filas en `'E'` frente a **183 235** reales), se desactivó `PUBLISH` y se recogieron estadísticas que quedaron como **pendientes** (`1 000 000` filas, `2026-11-26 17:07:40`), comprobables en **`DBA_TAB_PENDING_STATS`** (`docs/bitacora/lab7/evidencia/casos/20261126T170738Z_C13_entender.txt`, `20261126T170739Z_C13_diagnosticar.txt` y `20261126T170745Z_C13_solucionar.txt`). Se **probaron** en la sesión con `optimizer_use_pending_statistics = TRUE` (estimación de **183 235** filas) y se **publicaron** restaurando `PUBLISH = TRUE`, verificando el histograma `FREQUENCY` en **`DBA_TAB_COL_STATISTICS`**, `STALE_STATS = NO` en **`DBA_TAB_STATISTICS`** y sin pendientes (`docs/bitacora/lab7/evidencia/casos/20261126T170745Z_C13_solucionar.txt` y `20261126T170745Z_C13_validar.txt`). Finalmente, usando el historial de **`DBA_TAB_STATS_HISTORY`** (retención de **31** días), se **restauraron** las estadísticas previas (volviendo `ESTADO` a `NONE` en **`DBA_TAB_COL_STATISTICS`**) y se **bloquearon**, quedando `STATTYPE_LOCKED = ALL` en **`DBA_TAB_STATISTICS`** (`docs/bitacora/lab7/evidencia/casos/20261126T170752Z_C13_observar.txt`).

2. **¿Qué error obtuviste al recoger sobre estadísticas bloqueadas y cómo se recoge si de verdad hace falta?**
   Al intentar recoger estadísticas sobre `PEDIDO` estando bloqueadas se obtuvo el error **`ORA-20005: object statistics are locked (stattype = ALL)`** (`docs/bitacora/lab7/evidencia/casos/20261126T170752Z_C13_observar.txt`). Si de verdad hace falta recogerlas manteniendo el bloqueo, se pasa **`force => TRUE`** a `DBMS_STATS.GATHER_TABLE_STATS`, o bien se desbloquean antes con `DBMS_STATS.UNLOCK_TABLE_STATS`.

## Parte E · C14 · Un índice nuevo sin riesgo: invisible, probar, publicar y medir

1. **Lecturas por apertura del panel antes y después. ¿Cómo probaste el índice sin que lo viera nadie más?**
   Antes de crear el índice, cada apertura del panel realizaba **1 793** lecturas lógicas (**47,9** ms) para devolver **2 023** pedidos (`docs/bitacora/lab7/evidencia/casos/20261126T171627Z_C14_provocar.txt` y `20261126T171628Z_C14_entender.txt`). Para no afectar al resto de sesiones, se creó el índice compuesto `IX_T6_C14_PEND` sobre `(ESTADO, CANAL, FECHA_PEDIDO, IMPORTE)` como **`INVISIBLE`** y se probó de forma aislada activando únicamente en la sesión actual **`ALTER SESSION SET optimizer_use_invisible_indexes = TRUE`**. Tras verificar la mejora y hacerlo `VISIBLE`, cada apertura pasó a consumir solo **13** lecturas lógicas (**0,32** ms) (`docs/bitacora/lab7/evidencia/casos/20261126T171636Z_C14_solucionar.txt` y `20261126T171637Z_C14_validar.txt`).

2. **Redo con el índice INVISIBLE y VISIBLE: ¿qué demuestra?**
   Al actualizar 20 000 pedidos, el redo generado sin mantener el índice (`UNUSABLE`) fue de **9 002** KB, mientras que con el índice **`INVISIBLE`** generó **10 271** KB y con **`VISIBLE`** **10 270** KB (`docs/bitacora/lab7/evidencia/casos/20261126T171644Z_C14_observar.txt`). Esto demuestra que poner un índice como `INVISIBLE` solo lo oculta al optimizador para que no cambie planes de ejecución, pero Oracle sigue manteniéndolo en cada operación DML con el mismo coste de escritura y redo que uno visible.

## Parte F · C17 · INC-604 con AWR, ASH y ADDM
1. SLI y SLO; p95 antes y después; instantáneas AWR que usaste.
2. ¿Qué dijeron ASH, AWR y ADDM, y qué no podían decirte? ¿Cuál fue el ÚNICO cambio?

## Parte F · C18 · SQL Plan Management
1. PLAN_HASH_VALUE y lecturas del lunes, del martes y con la línea base.
2. ¿Qué hizo la evolución con el plan nuevo y por qué? ¿Qué queda pendiente para que no vuelva a pasar?

## Parte G · Incidente 1 · INC-6NN
- **Síntoma (con números):**
- **Playbook y pasos seguidos (herramientas y vistas):**
- **Causa raíz:**
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
- **Verificación (archivo de evidencia con todo OK):**
- **Prevención (qué evitaría que se repita):**

## Parte G · Incidente 2 · INC-6NN
- **Síntoma (con números):**
- **Playbook y pasos seguidos (herramientas y vistas):**
- **Causa raíz:**
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
- **Verificación (archivo de evidencia con todo OK):**
- **Prevención (qué evitaría que se repita):**

## Parte G · Incidente 3 · INC-6NN
- **Síntoma (con números):**
- **Playbook y pasos seguidos (herramientas y vistas):**
- **Causa raíz:**
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
- **Verificación (archivo de evidencia con todo OK):**
- **Prevención (qué evitaría que se repita):**

## Parte H · Reflexión
1. De todo el laboratorio, ¿qué cambio dio más mejora por menos riesgo? Justifícalo con tus números.
2. Un caso no evaluable (sin ★) que hayas hecho y qué aprendiste de él (opcional, cuenta para la certificación).
