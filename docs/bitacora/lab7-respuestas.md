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
   Con 1 sesión obtuve 5,1 llamadas/s y p95 de 207,1 ms; con 2, 9,5 llamadas/s y p95 de 303 ms; con 8, 8,0 llamadas/s y p95 de 1.341,1 ms. Recomiendo 2 sesiones: dan más throughput que 8 con mucha menos latencia, y coinciden con `CPU_COUNT=2`. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261125T182107Z_C01_entender.txt`, `docs/bitacora/lab7/evidencia/casos/20261125T183150Z_C01_validar.txt` y `docs/bitacora/lab7/evidencia/casos/20261125T182536Z_C01_diagnosticar.txt`.
2. ¿Qué evento domina con 8 sesiones y qué significa en Oracle Free?
   Dominó `resmgr:cpu quantum`, con 229 de 296 muestras (77,4 %); el 22,6 % restante fue `ON CPU`. Es la espera por turno de CPU impuesta por el gestor de recursos: Oracle Free limita la instancia a 2 CPU, así que las sesiones excedentes hacen cola en vez de aumentar el rendimiento. Evidencia: `docs/bitacora/lab7/evidencia/casos/20261125T182536Z_C01_diagnosticar.txt`.
3. Comprueba la ley de Little (N = X · R) con tus tres medidas.
   Uso la latencia media `R` (no p95): 1 sesión, `5,1 × 0,190 = 0,97 ≈ 1`; 2 sesiones, `9,5 × 0,2089 = 1,98 ≈ 2`; 8 sesiones, `8,0 × 0,9786 = 7,83 ≈ 8`. Las pequeñas diferencias se deben al redondeo de las medidas. Evidencia: `docs/bitacora/lab7/evidencia/casos/20261125T183218Z_C01_observar.txt`.

## Parte C · C03 · Literales y análisis completos
1. Análisis completos y tiempo con literales, con variables de enlace y con CURSOR_SHARING = FORCE (tus cifras).
   Con literales hubo 5.044 hard parses, 4.140 ms de análisis y 4.980 ms totales para 5.000 llamadas. Con variables de enlace: 28 hard parses y 190 ms totales; con `CURSOR_SHARING=FORCE`: 28 hard parses y 290 ms totales. Los enlaces dieron el menor tiempo. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162600Z_C03_diagnosticar.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T162601Z_C03_solucionar.txt` y `docs/bitacora/lab7/evidencia/casos/20261126T162602Z_C03_observar.txt`.
2. ¿Por qué FORCE es un puente y no la solución? ¿Qué ve el DBA en V$SQL que lo delata (FORCE_MATCHING_SIGNATURE)?
   `FORCE` alivia los análisis, pero sustituye literales en la sesión sin corregir la aplicación; los binds explícitos son la solución duradera y dieron menor tiempo (190 ms frente a 290 ms). En `V$SQL`, una misma `FORCE_MATCHING_SIGNATURE` agrupó 877 `SQL_ID` distintos con 877 ejecuciones: textos literales distintos que Oracle puede hacer coincidir. Con `FORCE`, el SQL aparece con el bind del sistema `:"SYS_B_0"`. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162600Z_C03_diagnosticar.txt` y `docs/bitacora/lab7/evidencia/casos/20261126T162602Z_C03_observar.txt`.

## Parte C · C04 · El informe que se desborda a TEMP
1. Bloques de TEMP, tipo de pasada y tiempo del informe antes y después. ¿Qué hacía el disparador de logon?
   Con la configuración heredada, el informe completo tardó 2.170 ms y escribió/leyó 6.712 bloques de TEMP (52,4 MB); la ordenación hizo 2 pasadas. Tras quitar el disparador y volver a PGA automática, el informe completo tardó 890 ms, sin TEMP y con ordenación `OPTIMAL`. El TOP 100 tardó 140 ms, sin TEMP y también `OPTIMAL`. El trigger imponía `WORKAREA_SIZE_POLICY=MANUAL` y `SORT_AREA_SIZE=1 MB` a `T6_INF`. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162341Z_C04_provocar.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T162342Z_C04_entender.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T162342Z_C04_diagnosticar.txt` y `docs/bitacora/lab7/evidencia/casos/20261126T162344Z_C04_solucionar.txt`.
2. ¿Por qué el TOP 100 cabe en memoria y el informe completo no?
   El TOP-N mantiene en memoria solo las 100 filas que necesita la pantalla (0,0 MB), por eso su área de trabajo queda `OPTIMAL` y usa 0 bloques de TEMP. El informe completo debe ordenar el millón de filas: con la política manual de 1 MB frente a 55,5 MB óptimos, se desbordó a TEMP y necesitó 2 pasadas; al volver a PGA automática terminó `OPTIMAL` y sin TEMP. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T162342Z_C04_diagnosticar.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T162345Z_C04_validar.txt` y `docs/bitacora/lab7/evidencia/casos/20261126T162345Z_C04_observar.txt`.

## Parte D · C07 · EXPLAIN PLAN frente al plan real
1. Copia el predicado que delata el problema en el plan real y explica de dónde sale.
   El predicado fue `filter(TO_NUMBER("CODIGO_POSTAL")=:B1)`: el cursor recibió `:B1` como `NUMBER`, aunque `CODIGO_POSTAL` es texto. Al convertir la columna, Oracle no pudo usar `IX_T6_PED_CP` como clave y eligió `TABLE ACCESS FULL` para el `SQL_ID 0dbx7196jdajy` (plan `2571571058`). Evidencia: `docs/bitacora/lab7/evidencia/casos/20261126T163757Z_C07_diagnosticar.txt`.
2. Lecturas y p95 de V1 y V2. ¿Por qué EXPLAIN PLAN no lo vio?
   V1 tuvo **5 926 GETS** por búsqueda y p95 de **81,2 ms**; V2 bajó a **1 005 GETS** y **2,4 ms**, usando `INDEX RANGE SCAN` sobre `IX_T6_PED_CP`. `EXPLAIN PLAN` trató `:CP` como texto y predijo el índice, pero no ejecutó la consulta ni conocía el tipo real del bind; `DISPLAY_CURSOR` sí mostró el bind `NUMBER` y la conversión implícita. La validación dejó `OK` para índice y p95, pero `FALLO` en lecturas (`1 005` frente a `5 926`); lo consigno tal como salió. Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T163756Z_C07_entender.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T163757Z_C07_diagnosticar.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T163758Z_C07_solucionar.txt` y `docs/bitacora/lab7/evidencia/casos/20261126T163758Z_C07_validar.txt`.

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
1. **SLI y SLO; p95 antes y después; instantáneas AWR que usaste.**
   El **SLI** medido es el percentil 95 (**p95**) de latencia de la búsqueda por código postal, cuyo **SLO** acordado es **p95 < 20 ms**. Con la versión inicial (V1) la latencia **p95** era de **496,6 ms** (incumpliendo el SLO con **1 861** búsquedas en 120 s), mientras que tras aplicar la solución (V2) bajó a **5,73 ms** cumpliendo el SLO y atendiendo **30 048** búsquedas con la misma carga (`docs/bitacora/lab7/evidencia/casos/20261126T173042Z_C17_entender.txt` y `20261126T173307Z_C17_validar.txt`). Para acotar el intervalo de carga de la V1 se utilizaron las instantáneas AWR **`SNAP_ID` 20 a 21** (`docs/bitacora/lab7/evidencia/casos/20261126T173041Z_C17_provocar.txt` y `20261126T173042Z_C17_entender.txt`).

2. **¿Qué dijeron ASH, AWR y ADDM, y qué no podían decirte? ¿Cuál fue el ÚNICO cambio?**
   **ASH** identificó que el `SQL_ID` **`0dbx7196jdajy`** concentraba **326** muestras en `ON CPU` y **86** en `resmgr:cpu quantum`; **AWR** confirmó que esa sentencia sumaba **299,9 s** y **5 922** lecturas lógicas (`GETS`) por ejecución (**161,23 ms/ejec**); y **ADDM** atribuyó el **100 %** de impacto (**2,8** sesiones activas de un total de **342 s** de *DB time*) a ese SQL recomendando *SQL Tuning Advisor* (`docs/bitacora/lab7/evidencia/casos/20261126T173048Z_C17_diagnosticar.txt` y `20261126T173308Z_C17_observar.txt`). Ninguna de las tres herramientas podía mostrar la causa en los predicados: al inspeccionar el plan real se detectó `filter(TO_NUMBER("CODIGO_POSTAL")=:B1)` por conversión implícita. El **ÚNICO cambio** fue desplegar `BUSCAR_CP_V2(P_CP VARCHAR2)` en lugar de `BUSCAR_CP_V1(P_CP NUMBER)`, pasando a usar el índice `IX_T6_PED_CP` con **205** lecturas y **1,09 ms** por ejecución (`docs/bitacora/lab7/evidencia/casos/20261126T173049Z_C17_solucionar.txt` y `20261126T173308Z_C17_observar.txt`).

## Parte F · C18 · SQL Plan Management
1. **PLAN_HASH_VALUE y lecturas del lunes, del martes y con la línea base.**
   El lunes, la sentencia `SQL_ID` `8hn59jfgw00y7` utilizaba el plan **`1767728868`** (`INDEX RANGE SCAN` sobre `IX_T6_PED_ESTADO`) con **5 984** lecturas lógicas por ejecución (**37,5** ms). El martes, tras la recogida nocturna sin histograma (`SIZE 1`), regresionó al plan **`2571571058`** (`TABLE ACCESS FULL`) con **5 924** lecturas por ejecución (**47,5** ms) (`docs/bitacora/lab7/evidencia/casos/20261126T174242Z_C18_provocar.txt` y `20261126T174244Z_C18_entender.txt`). Tras cargar el plan del lunes desde AWR como línea base aceptada (`SQL_PLAN_0a27u7nan424ba00b9863`), la consulta volvió a fijar el plan **`1767728868`** por índice con **5 947** lecturas por ejecución (**42,7** ms) (`docs/bitacora/lab7/evidencia/casos/20261126T174253Z_C18_solucionar.txt` y `20261126T174255Z_C18_validar.txt`).

2. **¿Qué hizo la evolución con el plan nuevo y por qué? ¿Qué queda pendiente para que no vuelva a pasar?**
   Al generarse de nuevo el recorrido completo (`SQL_PLAN_0a27u7nan424b95a18d93`), SPM lo guardó en el historial como no aceptado (`ACCEPTED = NO`, `ORIGIN = AUTO-CAPTURE`) sin aplicarlo; durante la **evolución**, verificó ambos planes y **rechazó el plan nuevo** por no superar el criterio de beneficio (*benefit criterion*), ya que su rendimiento verificado fue **0,73831 veces peor** que el de la línea base (`docs/bitacora/lab7/evidencia/casos/20261126T174511Z_C18_observar.txt`). Para evitar que vuelva a ocurrir, queda pendiente corregir la preferencia **`METHOD_OPT`** de la tabla `PEDIDO` (actualmente fijada en `FOR ALL COLUMNS SIZE 1`, que deja `ESTADO` con `HISTOGRAM = NONE`) y recoger estadísticas con red (runbook RB-2).

## Parte G · Incidente 1 · INC-605
- **Síntoma (con números):** A las 18:00 del 26-11-2026, la carga añadió **156 000** cestas; el informe dejó de responder como antes (`20261126T180042Z_INC-605_romper.txt`). El ticket indicó empezar por PB-3 y RB-2.
- **Playbook y pasos seguidos (herramientas y vistas):** `incidente INC-605 romper`; `incidente INC-605 pistas`; PB-3: `t6 estad CESTA` informó `NUM_ROWS=100`, **156 000** inserciones, `STALE=YES` y estadísticas bloqueadas `ALL` (`20261126T180108Z_t6-estad.txt`). Ejecuté el informe con `optimizer_adaptive_plans=FALSE`; `t6 top 10 elapsed t6_inc605` identificó `SQL_ID 7y2dsqjjhbp9y`, plan `470663276`, **164 818 GETS** y **71,9 ms** (`20261126T180213Z_t6-top.txt`). `t6 plan 7y2dsqjjhbp9y` confirmó `NESTED LOOPS` estimando 100 filas (`20261126T180230Z_t6-plan.txt`); `t6 spm lista CESTA` no encontró líneas base.
- **Causa raíz:** La carga masiva dejó 156 100 filas reales frente a las 100 registradas, pero `STATTYPE_LOCKED=ALL` impidió que la recogida automática refrescara las estadísticas. La estimación demasiado baja hizo elegir bucles anidados y una búsqueda por clave primaria por cada cesta.
- **Arreglo aplicado (órdenes exactas) y por qué ese:** En `FREEPDB1` como SYSDBA, apliqué RB-2 para desbloquear y recoger estadísticas actuales, incluyendo las de índices e invalidando el cursor:
  ```sql
  ALTER SESSION SET CONTAINER = FREEPDB1;
  BEGIN
    DBMS_STATS.UNLOCK_TABLE_STATS(ownname => 'T6', tabname => 'CESTA');
    DBMS_STATS.GATHER_TABLE_STATS(
      ownname => 'T6', tabname => 'CESTA',
      cascade => TRUE, no_invalidate => FALSE);
  END;
  /
  ```
- **Verificación (archivo de evidencia con todo OK):** `incidente INC-605 verificar` dio `OK` para estadísticas de **156 100** filas frente a **156 100** reales y para `HASH JOIN`; informó que las estadísticas ya no están bloqueadas (`20261126T180327Z_INC-605_verificar.txt`).
- **Prevención (qué evitaría que se repita):** No mantener bloqueadas las estadísticas de una tabla que recibe cargas masivas. Tras cada carga, recoger estadísticas de CESTA y comprobar `NUM_ROWS`, `STALE_STATS` y `STATTYPE_LOCKED`; la tarea automática no puede actualizarlas mientras sigan bloqueadas.

## Parte G · Incidente 2 · INC-609
- **Síntoma (con números):** A las 18:04 del 26-11-2026, los informes de T6_APP usaron `sort_area_size = 160 KB` y el informe de ventas tardó **5 375,9 ms** (`20261126T180410Z_INC-609_romper.txt` y `20261126T180550Z_t6-top.txt`).
- **Playbook y pasos seguidos (herramientas y vistas):** `incidente INC-609 romper`; `incidente INC-609 pistas`; seguí PB-4. `t6 memoria` mostró `pga_aggregate_target = 512 MB`, **98 %** de acierto estimado y **100 %** con 614 MB (`20261126T180447Z_t6-memoria.txt`); `t6 sesiones informes` no encontró sesiones activas en ese instante (`20261126T180453Z_t6-sesiones.txt`). El verificador inicial ejecutó el informe en una sesión nueva y mostró política `MANUAL`, una pasada múltiple a TEMP y un disparador activo (`20261126T180531Z_INC-609_verificar.txt`). `t6 top 10 elapsed t6_inc609` identificó `SQL_ID bmcg9273wgu8q`; `t6 plan bmcg9273wgu8q` mostró `HASH GROUP BY` usando **29 MB** de TEMP y `SORT ORDER BY` otros **3 072 KB** (`20261126T180550Z_t6-top.txt` y `20261126T180603Z_t6-plan.txt`). `DBA_TRIGGERS`/`DBA_SOURCE` identificaron `T6.TRG_SESION_APLICACION` y los ajustes de sesión que ejecutaba.
- **Causa raíz:** El disparador `AFTER LOGON` de T6_APP imponía `workarea_size_policy=MANUAL`, `sort_area_size=160 KB` y `hash_area_size=320 KB`. Las áreas manuales provocaban el desbordamiento pese a que la PGA tenía margen; aumentar `pga_aggregate_target` no corregía esos límites de sesión.
- **Arreglo aplicado (órdenes exactas) y por qué ese:** En `FREEPDB1` como SYSDBA, deshabilité el disparador que cambiaba la política de cada sesión nueva; no aumenté la PGA:
  ```sql
  ALTER SESSION SET CONTAINER = FREEPDB1;
  ALTER TRIGGER T6.TRG_SESION_APLICACION DISABLE;
  ```
- **Verificación (archivo de evidencia con todo OK):** `incidente INC-609 verificar` confirmó política `AUTO`, **0** pasadas de una o varias a TEMP y ningún disparador activo que altere la memoria de T6_APP (`20261126T180639Z_INC-609_verificar.txt`).
- **Prevención (qué evitaría que se repita):** No aplicar límites manuales de PGA mediante disparadores de logon. Mantener el dimensionamiento centralizado con PGA automática y revisar el asesor `t6 memoria` antes de cambiar `pga_aggregate_target`.

## Parte G · Incidente 3 · INC-610
- **Síntoma (con números):** A las 18:07 del 26-11-2026, varias consultas de la aplicación empeoraron a la vez. La búsqueda V2 por código postal (`SQL_ID 53mx77snb43uw`) usaba el plan **2571571058** (`TABLE ACCESS FULL`), con **6 419** lecturas lógicas y **28,3 ms** por ejecución (`20261126T180734Z_INC-610_romper.txt`, `20261126T181013Z_t6-top.txt` y `20261126T181030Z_t6-plan.txt`).
- **Playbook y pasos seguidos (herramientas y vistas):** `incidente INC-610 romper`; `incidente INC-610 pistas` indicó PB-3 porque habían cambiado varias consultas a la vez. `t6 top 10 elapsed CODIGO_POSTAL` identificó la V2 y `t6 plan 53mx77snb43uw` mostró el `TABLE ACCESS FULL`; su historial AWR conservaba el plan bueno **2982358210** (`INDEX RANGE SCAN`), por ejemplo en las instantáneas 22 y 23. La consulta de parámetros en `FREEPDB1` y el verificador inicial confirmaron `optimizer_index_cost_adj = 4200`, frente al valor por defecto **100** (`20261126T180949Z_INC-610_verificar.txt`).
- **Causa raíz:** Se había fijado `optimizer_index_cost_adj` a **4200** a nivel de `FREEPDB1`, haciendo que el optimizador considerase demasiado costosos los índices y eligiese un recorrido completo de `PEDIDO` para la búsqueda por código postal.
- **Arreglo aplicado (órdenes exactas) y por qué ese:** Como SYSDBA, restablecí el parámetro a su valor por defecto en la PDB, eliminé su valor persistido y vacié la caché para que las consultas se optimizaran de nuevo:
  ```sql
  ALTER SESSION SET CONTAINER = FREEPDB1;
  ALTER SYSTEM RESET optimizer_index_cost_adj SCOPE=BOTH;
  ALTER SYSTEM FLUSH SHARED_POOL;
  ```
- **Verificación (archivo de evidencia con todo OK):** `incidente INC-610 verificar` confirmó el valor **100**, que no queda valor guardado en el SPFILE de la PDB y que la V2 vuelve a usar `IX_T6_PED_CP` (`20261126T181057Z_INC-610_verificar.txt`). Después, `t6 top` y `t6 plan` confirmaron el plan **2982358210** con `INDEX RANGE SCAN`, **1 112** lecturas lógicas y **6,3 ms** por ejecución (`20261126T181129Z_t6-top.txt` y `20261126T181144Z_t6-plan.txt`).
- **Prevención (qué evitaría que se repita):** Antes de modificar parámetros del optimizador, registrar la línea base y medir el efecto en las consultas afectadas. Tras el cambio, revisar en `FREEPDB1` tanto `V$SYSTEM_PARAMETER` como `V$SPPARAMETER` y validar los planes con PB-3; no dejar ajustes extremos sin justificación ni medición.

## Parte H · Reflexión
1. De todo el laboratorio, ¿qué cambio dio más mejora por menos riesgo? Justifícalo con tus números.
   El mejor equilibrio me parece C14: el panel pasó de **1 793 GETS y 47,9 ms** a **13 GETS y 0,32 ms** por apertura, alrededor de un 99,3 % menos. El índice se probó primero como `INVISIBLE`, activándolo solo en la sesión de prueba, y se publicó tras validar el plan; así no se exponía el cambio a las demás sesiones durante la prueba. La contrapartida es que el índice invisible sigue generando redo al escribir: **10 271 KB**, prácticamente igual que visible (**10 270 KB**). Evidencias: `docs/bitacora/lab7/evidencia/casos/20261126T171628Z_C14_entender.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T171636Z_C14_solucionar.txt`, `docs/bitacora/lab7/evidencia/casos/20261126T171637Z_C14_validar.txt` y `docs/bitacora/lab7/evidencia/casos/20261126T171644Z_C14_observar.txt`.
2. Un caso no evaluable (sin ★) que hayas hecho y qué aprendiste de él (opcional, cuenta para la certificación).
   No ejecuté ni guardé evidencia de un caso adicional sin ★ en el material disponible. No voy a inventar una experiencia ni atribuirme resultados sin respaldo. Dejo constancia de que no reclamo este crédito opcional.
