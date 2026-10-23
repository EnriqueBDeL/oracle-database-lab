Preguntas tipo examen (P1 a P12)

P1:
A y D. Un SHUTDOWN IMMEDIATE realiza un cierre ordenado y ejecuta un checkpoint, por lo que la copia resultante queda consistente y puede restaurarse sin aplicar redo logs.

P2:
B. Al no disponer de movimiento online de datafiles, es necesario poner el tablespace OFFLINE, mover el archivo desde el sistema operativo, actualizar su ubicación en el control file y volver a activarlo.

P3:
A y C. STARTUP_TIME cambia en cada reinicio de la instancia, mientras que CREATED conserva la fecha original en la que se creó la base de datos.

P4:
A y C. En NOMOUNT ya se han cargado los parámetros desde el SPFILE, permitiendo consultar la configuración. Además, es el estado adecuado para recrear control files porque aún no están abiertos.

P5:
B. El modo ARCHIVELOG solo puede activarse con la base de datos montada, permitiendo registrar el cambio en los control files sin abrir todavía los datafiles.

P6:
B. Cuando se usa un SPFILE y no se especifica SCOPE, Oracle aplica el cambio tanto en memoria como en el archivo de parámetros persistente.

P7:
C. PROCESSES es un parámetro de ámbito de instancia, por lo que no puede modificarse desde una PDB y produce el error ORA-65040.

P8:
A y C. La solución pasa por arrancar la instancia mediante un PFILE válido y, una vez operativa, generar nuevamente el SPFILE.

P9:
B. En un entorno ASMM, asignar un valor explícito a DB_CACHE_SIZE garantiza un tamaño mínimo que Oracle no reducirá automáticamente.

P10:
A y D. La PGA administra la memoria privada de los procesos, incluyendo tanto las áreas de trabajo como la memoria utilizada por cada sesión.

P11:
C. LGWR debe escribir obligatoriamente los cambios del log buffer en los redo logs para asegurar la persistencia de una transacción confirmada.

P12:
B y D. PMON y SMON son procesos esenciales; PMON libera recursos de procesos fallidos y SMON ejecuta las tareas de recuperación tras una caída.



Preguntas de comprobación:

Respaldo

1. La copia es consistente porque SHUTDOWN IMMEDIATE ejecuta un checkpoint global antes del apagado. Si la base de datos permaneciera abierta, serían necesarios archivelogs para recuperar la consistencia.

2. El manifiesto almacena metadatos y hashes SHA-256. El proceso de restauración valida estos valores para asegurar que los archivos no han sido modificados.

3. El RPO representa la información que podría perderse desde el último respaldo. El RTO indica el tiempo necesario para completar la restauración y recuperar el servicio.


Diagnóstico y correcciones

4. Los archivos se generaron en $ORACLE_HOME/dbs al no especificar una ruta absoluta. Con db_create_file_dest configurado, Oracle habría utilizado automáticamente la ubicación correcta.

5. La instrucción SQL solo actualiza la referencia del archivo dentro del control file. El movimiento físico debe realizarse previamente desde el sistema operativo.

6. La modificación se aplica mediante la migración V003 para mantener la trazabilidad. La desactivación de la autenticación evita accesos indebidos cuando existen credenciales expuestas.

7. La comprobación garantiza que los datafiles se encuentran en almacenamiento persistente y sobrevivirán a la recreación del entorno. Realizarla antes del traslado podría ocasionar pérdidas.


Instancia y arranque

8. La información de la instancia incluye VERSION_FULL, STATUS y la fecha de inicio. La información de la base de datos incluye DBID, LOG_MODE y la fecha de creación.

9. En NOMOUNT solo se carga la configuración. En MOUNT ya están disponibles los control files, aunque los datafiles siguen cerrados. En OPEN toda la base de datos está accesible.

10. La PDB se abre automáticamente porque su estado quedó guardado mediante SAVE STATE. Si no fuera así, habría que abrirla manualmente con ALTER PLUGGABLE DATABASE FREEPDB1 OPEN.

11. Estos mensajes corresponden a advertencias conocidas relacionadas con Docker y QOPATCH, y no afectan al funcionamiento normal de la base de datos.


Parámetros

12. v$parameter muestra los valores activos de la instancia, mientras que v$spparameter refleja los parámetros almacenados en el SPFILE.

13. SCOPE=BOTH actualiza simultáneamente los valores en memoria y los almacenados para futuros reinicios.

14. PROCESSES es un parámetro estático definido durante el arranque, por lo que no admite modificaciones dinámicas.

15. Versionar el PFILE permite auditar cambios, detectar modificaciones no autorizadas y controlar la evolución de la configuración.


Memoria y procesos

16. La configuración refleja el uso de ASMM, utilizando SGA_TARGET y PGA_AGGREGATE_TARGET para gestionar la memoria y manteniendo MEMORY_TARGET desactivado.

17. Las dos ejecuciones producen las mismas lecturas lógicas, pero en la segunda desaparecen las lecturas físicas porque los datos ya están almacenados en la Buffer Cache.

18. Sumar directamente los valores RSS puede inducir a error, ya que contabiliza varias veces la memoria compartida utilizada por la SGA.

19. SPID identifica el proceso dentro del contenedor, mientras que Docker muestra el identificador correspondiente desde la perspectiva del sistema anfitrión.

20. PMON libera recursos y bloqueos asociados a sesiones terminadas de forma anómala. SMON realiza las tareas de recuperación y mantenimiento tras fallos de la instancia.


Seguridad y trabajo profesional

21. Se aplica el principio de mínimo privilegio, permitiendo a C##OPS_RO consultar información de monitorización sin capacidad para modificar datos.

22. Las mejoras implementadas consistieron en eliminar credenciales embebidas en scripts y limitar los privilegios de las cuentas propietarias al ámbito de sus esquemas.