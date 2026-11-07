## INC-601 · Pantalla bloqueada en Secretaría

- Detección: 2026-11-07 00:00 UTC · Ana García informó de que la pantalla quedaba bloqueada al guardar información.
- Impacto: no se podía completar el guardado de la ficha del alumno 101.
- Diagnóstico: `V$SESSION` mostró una espera `enq: TX - row lock contention` y una sesión bloqueadora mediante `BLOCKING_SESSION`.
- Causa raíz: otra sesión mantenía una transacción sin confirmar y retenía el bloqueo sobre la fila que Secretaría intentaba modificar.
- Intervención: `ALTER SYSTEM KILL SESSION '<sid>,<serial#>' IMMEDIATE;`. Fue la alternativa mínima porque liberó solo la sesión responsable sin reiniciar la PDB.
- Validación: el guardado volvió a funcionar y el alumno 101 quedó en estado `ACTIVO`.
- Acción preventiva: alertar sobre bloqueos prolongados y establecer tiempos máximos para transacciones de la aplicación.

## INC-602 · La aplicación no conecta (ORA-12514)

- Detección: 2026-11-07 00:00 UTC · el equipo de matrículas notificó errores `ORA-12514`.
- Impacto: las conexiones de la aplicación quedaron interrumpidas.
- Diagnóstico: `lsnrctl status` y `V$ACTIVE_SERVICES` confirmaron que `academia_app` no estaba registrado ni disponible.
- Causa raíz: el servicio de aplicación no se había iniciado automáticamente después del reinicio de la PDB.
- Intervención: `DBMS_SERVICE.START_SERVICE('academia_app');` y `ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE;`. Fue lo mínimo necesario para restaurar el endpoint y conservarlo tras reinicios.
- Validación: el servicio apareció como `READY` y la aplicación recuperó el acceso.
- Acción preventiva: hacer obligatoria la configuración persistente de los servicios y monitorizar la diferencia entre `CDB_SERVICES` y `V$ACTIVE_SERVICES`.

## INC-603 · La aplicación no accede (ORA-28000)

- Detección: 2026-11-07 00:01 UTC · el equipo de matrículas notificó `ORA-28000` tras el mantenimiento programado.
- Impacto: la aplicación no podía autenticarse con su cuenta técnica.
- Diagnóstico: `DBA_USERS` mostró `APP_ACADEMIA` en estado `LOCKED`.
- Causa raíz: el procedimiento de bajas trató la cuenta técnica como una cuenta de usuario convencional y terminó bloqueándola mediante la política de autenticación.
- Intervención: `ALTER USER APP_ACADEMIA ACCOUNT UNLOCK;`. Fue la intervención mínima porque desbloqueó la cuenta sin cambiar contraseña, perfil ni privilegios.
- Validación: se comprobó que la cuenta estaba abierta y que la aplicación volvía a conectarse correctamente.
- Acción preventiva: excluir cuentas técnicas de los procesos de bajas y aplicar esos controles solo a usuarios finales con el perfil `PRF_PERSONAS`.
