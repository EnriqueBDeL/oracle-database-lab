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

## Parte E · C12 · Estadísticas obsoletas
1. Filas según las estadísticas y reales; método de unión y lecturas antes y después.
2. ¿Por qué la tarea automática no lo habría arreglado a tiempo? ¿Quién debe recoger y cuándo?

## Parte E · C13 · El ciclo de estadísticas con red
1. Describe el ciclo que seguiste (pendientes, probar, publicar, restaurar, bloquear) con la vista que comprueba cada paso.
2. ¿Qué error obtuviste al recoger sobre estadísticas bloqueadas y cómo se recoge si de verdad hace falta?

## Parte E · C14 · El índice invisible
1. Lecturas por apertura del panel antes y después. ¿Cómo probaste el índice sin que lo viera nadie más?
2. Redo con el índice INVISIBLE y VISIBLE: ¿qué demuestra?

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
