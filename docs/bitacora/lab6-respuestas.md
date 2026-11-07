# Lab 6 · Respuestas

## Parte B · Lista de turno

La lista de turno comprueba la identidad de la sesión, el estado de la instancia y de la PDB, los errores ORA recientes, el espacio, los bloqueos y las alertas pendientes. La evidencia está en `docs/bitacora/lab6/evidencia/script/20261106T231816Z_01-turno.script.log`.

## Parte C · Parámetros y estados de la PDB

Los parámetros pueden proceder del valor por defecto, del fichero de parámetros o de la memoria. Un cambio con `SCOPE=SPFILE` requiere reinicio; `SCOPE=MEMORY` afecta a la instancia actual; `SCOPE=BOTH` aplica a memoria y al fichero cuando Oracle lo permite. `FREEPDB1` quedó abierta en `READWRITE`, sin `RESTRICTED`, y con el estado guardado para el siguiente arranque.

## Parte D · Servicios y sesiones

`academia_app` es un servicio dedicado de `FREEPDB1`, separado del servicio general de la PDB. La aplicación usa la cuenta local `APP_ACADEMIA`, mientras que las sesiones se observan y cancelan desde las vistas dinámicas con sus SID y serial.

## Parte E · Diccionario y observabilidad

La misma consulta produce resultados distintos según la identidad y el contenedor. `C##OPS_RO` puede consultar el catálogo autorizado y tiene `CONTAINER_DATA=ALL`; `APP_ACADEMIA` solo ve sus objetos y los objetos concedidos de `ADMIN_ACADEMIA`. Los `ORA-00942` de `DBA_USERS`, `CDB_USERS` y `V$DATAFILE` para la cuenta de aplicación son la evidencia de que no tiene privilegios de catálogo.

## Parte F · Espacio y cuotas

`TBS_ACADEMIA_HIST` quedó limitado a 40 MB y `CARGA_HIST` tiene una cuota de 30 MB. La tabla histórica se compactó hasta conservar 2000 filas. Una cuota limita lo que un usuario puede asignar; el techo del datafile limita el crecimiento físico del tablespace.

## Parte G · Gobierno del acceso

`PRF_PERSONAS` limita los intentos fallidos a 3. `ANA_GARCIA` usa `ROL_SECRETARIA_ACADEMIA`, que permite leer el esquema de Academia y actualizar solo la columna `ESTADO`. `APP_ACADEMIA` usa `ROL_APP_ACADEMIA` y no conserva privilegios de objeto sueltos ni `RESUMABLE`.

## Parte H · Objetos y limpieza

Los objetos de prueba se eliminaron, la papelera de `ADMIN_ACADEMIA` quedó vacía y no hay objetos inválidos en los esquemas de negocio.

## Parte I · Guardia

Se documentaron los tres incidentes en [lab6-guardia.md](./lab6-guardia.md):

- `INC-601`: bloqueo de la fila 101 por una transacción abierta.
- `INC-602`: `academia_app` detenido y error `ORA-12514`.
- `INC-603`: cuenta `APP_ACADEMIA` bloqueada y error `ORA-28000`.

La validación final se ejecuta con `scripts/lab6/09-verificacion-final.sh`.
