He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 7 · E006
## Entrada 1
- **Herramienta:** ChatGPT
- **Prompt (literal, copiado tal cual):**
```text
¿Cómo veo en Oracle si las estadísticas de una tabla están bloqueadas y desde cuándo no se recogen?
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
SELECT table_name, num_rows, last_analyzed, stale_stats, stattype_locked FROM dba_tab_statistics WHERE owner = 'T6';
```
- **Dónde lo usé (parte, script o pregunta):** Parte G, incidente INC-605
- **Propósito (para qué lo necesitaba):** confirmar que la causa eran estadísticas bloqueadas antes de recogerlas
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** por cada tabla de T6, las filas que cree el optimizador,
la fecha de la última recogida, si están obsoletas (STALE_STATS) y si están bloqueadas (STATTYPE_LOCKED = ALL)
- **Evidencia de ejecución:** docs/bitacora/lab7/evidencia/herramientas/20261201T101502Z_t6_estad_CESTA.txt