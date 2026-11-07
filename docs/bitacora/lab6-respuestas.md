# Lab 6 · Respuestas

## Partes A-C: Rol operativo, parámetros y estados

**1. Errores ORA- en las últimas 24 horas**

Durante el periodo analizado se registraron 202 errores ORA en el alert log. La mayoría procedían de las pruebas de fallo realizadas anteriormente, como ORA-01113 y ORA-01110 del Lab 5. Este valor debe compararse con la línea base habitual antes de interpretarlo como una incidencia.

**2. Ventana de mantenimiento**

La ventana de mantenimiento del miércoles comienza a las 22:00 y dura cuatro horas. Oracle ejecuta en ese intervalo tareas automáticas como la recopilación de estadísticas del optimizador, Segment Advisor y SQL Tuning Advisor.

**3. Diferencia entre V$SPPARAMETER y V$PARAMETER**

Después de establecer el parámetro con `SCOPE=SPFILE`, `V$SPPARAMETER` mostró 250, mientras `V$PARAMETER` mantuvo 200 porque refleja el valor cargado en memoria. Sin un `RESET`, el cambio habría entrado en vigor al reiniciar la instancia.

**4. RESET y el parámetro db_files**

Aplicar `RESET` a `db_files` eliminó su entrada del SPFILE y recuperó el valor predeterminado. Si se hubiera aplicado a `processes`, también se habría eliminado la configuración explícita de 200.

**5. Reinicio sin estado persistente**

Al reiniciar sin guardar el estado de la PDB, `C##OPS_RO` encontró errores como ORA-01109 u ORA-12514 porque la PDB permaneció en `MOUNTED`. Que la instancia indicara que la base estaba abierta solo confirmaba el CDB, no la disponibilidad de las PDB.

## Partes D-E: Servicios, sesiones y diccionario

**6. Sesión de aplicación**

La sesión tenía SID 47, SPID 797 y esperaba en `PL/SQL lock timer`. `MODULE`, `ACTION` y `CLIENT_IDENTIFIER` identificaban el módulo de matrículas, el cierre de periodo y el usuario final, información que no se obtiene únicamente del usuario técnico.

**7. CANCEL SQL frente a KILL SESSION**

Después de `CANCEL SQL` permanecía una transacción abierta; después de `KILL SESSION` ya no existía. El registro 101 volvió a `ACTIVO` porque Oracle hizo rollback de los cambios pendientes al finalizar la sesión.

**8. Valor de common_user_prefix**

`common_user_prefix` aparece vacío en esta instalación, por lo que Oracle no exige el prefijo `C##` para las cuentas comunes.

**9. Las tres perspectivas de ALL_TABLES**

`C##OPS_RO` no visualizaba tablas desde la raíz ni desde `FREEPDB1`, mientras `APP_ACADEMIA` sí observaba una. Las vistas `ALL_` muestran los objetos sobre los que existen privilegios; la aplicación tenía acceso explícito y el usuario operativo tenía permisos de catálogo.

**10. Lecturas lógicas y DB Time**

La carga implicó 5.378 lecturas lógicas por recorrido y aproximadamente 0,37 segundos de DB Time. Como DB Time y DB CPU eran prácticamente iguales, el tiempo correspondió casi por completo a CPU, sin esperas relevantes.

## Partes F-G: Espacio y acceso

**11. Tamaño de TBS_ACADEMIA_HIST**

El tablespace tenía 10 MB asignados, 3,9 MB libres y una capacidad máxima de 40 MB. Para monitorizarlo, el indicador más representativo era el porcentaje usado respecto al máximo: 15,16 %.

**12. Cuotas y ORA-01950**

Aunque la inserción inicial la realizó SYS, el consumo se asignó al propietario del segmento, `CARGA_HIST`, que no tenía cuota suficiente. Ampliar el tablespace no habría solucionado el problema porque la limitación estaba en la cuota.

**13. Funcionamiento de la carga reanudable**

La operación quedó suspendida unos 14 segundos, de 16:39:39 a 16:39:53. El alert log registró la suspensión y la reanudación después de conceder el privilegio necesario.

**14. Uso de SHRINK SPACE**

Antes de `SHRINK SPACE`, la tabla ocupaba 2.944 bloques para 2.000 filas, unos 23 MB. Después quedó en unos 304 bloques y 2,4 MB. El borrado no liberó almacenamiento porque los bloques seguían por debajo del High Water Mark.

**15. Comparación de perfiles**

`DEFAULT` permitía intentos fallidos ilimitados y contraseñas sin caducidad. `PRF_PERSONAS` bloqueaba tras tres intentos incorrectos y exigía renovar la contraseña cada 90 días.

**16. Privilegios de Ana**

Ana podía consultar `ACA_MATRICULAS` mediante `SELECT ANY TABLE ON SCHEMA admin_academia`. Al intentar modificar una columna distinta de `ESTADO`, Oracle devolvió ORA-41900 porque solo tenía permiso de actualización sobre esa columna.

## Partes H-I: Objetos, diagnóstico y guardia

**17. Objetos inválidos**

Añadir una columna no invalidó todos los objetos porque Oracle gestiona las dependencias con granularidad fina. La modificación del correo afectó a `V_CONTACTO_LAB6`; la ampliación de nombres invalidó `V_ACTIVOS_LAB6` y la función dependiente `F_TOTAL_ACTIVOS_LAB6`.

**18. Advisors de memoria**

Duplicar la SGA no aportaría una mejora apreciable porque el factor estimado de DB Time permanecería prácticamente igual. Reducir la PGA por debajo de 512 MB aumentaría el riesgo de sobreasignación y degradación.

**19. Análisis de la traza TKPROF**

La ejecución reflejó 247 lecturas lógicas para obtener los datos de la aplicación. El valor se observa como `cr=247` en la línea `FETCH` del informe TKPROF.

**20. Guardia**

- `INC-601`: el bloqueo se identificó mediante `V$SESSION.BLOCKING_SESSION` y eventos `enq: TX`; se terminó la sesión bloqueadora y se verificó que el registro 101 quedó en `ACTIVO`.
- `INC-602`: `lsnrctl status` y `V$ACTIVE_SERVICES` mostraron que faltaba el servicio; se ejecutó `DBMS_SERVICE.START_SERVICE` y se guardó el estado con `SAVE STATE`.
- `INC-603`: `DBA_USERS` mostró la cuenta bloqueada; se ejecutó `ACCOUNT UNLOCK` y se comprobó que la aplicación volvió a conectar.

