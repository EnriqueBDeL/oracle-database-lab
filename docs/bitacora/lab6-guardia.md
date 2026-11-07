## INC-601 · Bloqueo al guardar la ficha del alumno 101
- Detección: 2026-11-07 00:00 UTC · Ana García, Secretaría, avisó por la pantalla de la aplicación que se quedaba colgada al guardar la ficha del alumno 101.
- Impacto: la sesión de Secretaría no podía completar el `UPDATE` de `ADMIN_ACADEMIA.ACA_ESTUDIANTES` para el alumno 101; la aplicación de matrículas mantenía una transacción abierta y la espera duró hasta la intervención.
- Diagnóstico: `08-diagnostico.sql` mostró la sesión de Ana esperando un bloqueo TX de `APP_ACADEMIA`; la fila afectada era la 101 y la sesión bloqueadora correspondía al módulo `matriculas`, acción `cierre-periodo`. Evidencia: `docs/bitacora/lab6/evidencia/script/20261107T000024Z_08-diagnostico.script.log`.
- Causa raíz: una transacción de la aplicación actualizó la fila 101 y permaneció abierta durante una espera de 15 minutos, reteniendo el bloqueo hasta su `ROLLBACK`.
- Intervención: `ALTER SYSTEM KILL SESSION '<sid>,<serial#>' IMMEDIATE;` sobre la sesión bloqueadora, usando el SID y serial obtenidos de `v$session`. Es la intervención mínima porque libera únicamente la sesión responsable del bloqueo, sin reiniciar la PDB ni terminar otras sesiones.
- Validación: se repitió `08-diagnostico.sql` y dejó de aparecer la espera TX; después se comprobó por el camino del consumidor que Ana podía guardar la ficha y que el estado de la fila 101 quedaba en `ACTIVO`.
- Acción preventiva: alertar sobre sesiones con `blocking_session IS NOT NULL` y transacciones abiertas durante más de un umbral; además, establecer un tiempo límite para las transacciones de cierre de periodo y registrar módulo y acción con `DBMS_APPLICATION_INFO`.

## INC-602 · Servicio de matrículas no anunciado
- Detección: 2026-11-07 00:00 UTC · el equipo de matrículas avisó de que ninguna instancia de la aplicación conectaba y recibía `ORA-12514`.
- Impacto: las conexiones de la aplicación al servicio `academia_app` no podían establecerse hasta volver a arrancar el servicio; la base de datos y la PDB seguían abiertas.
- Diagnóstico: `08-diagnostico.sql` mostró `academia_app` con `ARRANCADO = NO` mientras `FREEPDB1` aparecía con `ARRANCADO = SI`. Evidencia: `docs/bitacora/lab6/evidencia/script/20261107T000052Z_08-diagnostico.script.log`.
- Causa raíz: el servicio `academia_app` existía en `FREEPDB1`, pero estaba detenido y por eso el listener no lo anunciaba; no era una caída de la base de datos.
- Intervención: `DBMS_SERVICE.START_SERVICE('academia_app');` tras confirmar que el servicio no estaba activo. Es la intervención mínima porque restaura solo el endpoint de la aplicación sin reiniciar la instancia ni la PDB.
- Validación: se volvió a consultar `v$active_services` mediante `08-diagnostico.sql`, que confirmó `academia_app = SI`; después se validó la conexión de la aplicación al servicio.
- Acción preventiva: monitorizar la diferencia entre `cdb_services` y `v$active_services`, configurar una alerta cuando un servicio requerido figure como `NO` y conservar el estado de la PDB con `ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE`.

## INC-603 · Cuenta de aplicación bloqueada
- Detección: 2026-11-07 00:01 UTC · el equipo de matrículas avisó de `ORA-28000` después del despliegue de las 21:00.
- Impacto: `APP_ACADEMIA` no podía autenticarse y la aplicación no podía acceder a sus operaciones de matrícula hasta desbloquear la cuenta.
- Diagnóstico: `08-diagnostico.sql` mostró `APP_ACADEMIA` con `ACCOUNT_STATUS = LOCKED` en `FREEPDB1`. La evidencia de acceso registró tres `ORA-01017` y después `ORA-28000`; posteriormente se confirmó el estado `LOCKED(TIMED)` de `ANA_GARCIA` durante la prueba de contraseñas. Evidencias: `docs/bitacora/lab6/evidencia/script/20261107T000114Z_08-diagnostico.script.log` y `docs/bitacora/lab6/evidencia/script/20261106T235735Z_06-probar-acceso.script.log`.
- Causa raíz: la cuenta de aplicación fue bloqueada por la política de autenticación tras intentos fallidos; el bloqueo era un estado de seguridad de Oracle, no una caída de la PDB.
- Intervención: `ALTER USER app_academia ACCOUNT UNLOCK;` ejecutado dentro de `FREEPDB1`, después de confirmar la identidad del solicitante y la causa del bloqueo. Es la intervención mínima porque desbloquea la cuenta sin cambiar su contraseña, perfil ni privilegios.
- Validación: se comprobó el estado `OPEN` de la cuenta y se volvió a probar la conexión de la aplicación con el mismo servicio y usuario; la prueba de acceso confirmó que `APP_ACADEMIA` seguía funcionando con `ROL_APP_ACADEMIA`.
- Acción preventiva: alertar sobre cuentas no Oracle con `ACCOUNT_STATUS <> 'OPEN'`, revisar los fallos de autenticación del despliegue y usar un procedimiento de desbloqueo con verificación de identidad y registro de la intervención.
