Preguntas tipo examen (P1 a P12)

P1: Un DBA ejecuta SHUTDOWN IMMEDIATE y copia todos los datafiles, control files y redo logs online. ¿Qué afirmaciones son correctas sobre esta copia? (Elige dos.)

A y D. Un SHUTDOWN IMMEDIATE realiza un cierre ordenado de los archivos y ejecuta un checkpoint. Por lo que la copia resultante es una copia en frío consistente y puede restaurarse y abrirse directamente sin aplicar redo logs.

P2: Un tablespace de usuario tiene su datafile en un disco que se va a retirar. La base es Standard Edition y puede tener una breve indisponibilidad de ese tablespace. ¿Qué secuencia es correcta?

B. Al no disponer de la opción de movimiento online de datafiles (Enterprise Edition), es necesario realizar el procedimiento offline. Esto requiere poner el tablespace OFFLINE, mover/copiar el archivo desde el sistema operativo, actualizar su ubicación en el control file con RENAME DATAFILE y volver a activarlo pasándolo a ONLINE.

P3: Un DBA consulta v$instancey v$database en una base abierta. ¿Qué dos afirmaciones son correctas? (Elige dos.)

El valor STARTUP_TIME en v$instance cambia en cada reinicio de la instancia. Por otro lado, CREATED en v$database conserva permanentemente la fecha original en la que se creó la base de datos.

P4: La instancia está en estado NOMOUNT. ¿Qué dos operaciones puede realizar el DBA en este estado? (Elige dos.)

A y C. En NOMOUNT ya se han leído y cargado los parámetros desde el SPFILE, permitiendo consultar la configuración mediante v$parameter. Además, es el estado adecuado para recrear control files porque la memoria está activa pero los archivos aún no se han abierto.

P5: ¿En qué etapa debe estar la base para ejecutar ALTER DATABASE ARCHIVELOG?

B (MOUNT). El modo ARCHIVELOG solo puede activarse con la base de datos montada. Esta etapa permite que la instancia conozca y registre el cambio estructural en los control files sin abrir todavía el acceso a los datafiles.

P6: Un DBA ejecuta ALTER SYSTEM SET open_cursors = 500; en una instancia que arrancó con SPFILE. ¿Cuál es el resultado?

B. Cuando se usa un SPFILE y no se especifica la cláusula SCOPE explícitamente, Oracle toma por defecto el alcance BOTH. Esto significa que el cambio se aplica de inmediato tanto en memoria como persistido en el archivo SPFILE.


P7: Conectado a FREEPDB1, un DBA ejecuta ALTER SYSTEM SET processes = 300 SCOPE = SPFILE; ¿Qué ocurre?

C. PROCESSES es un parámetro de ámbito de la instancia que no es modificable a nivel de PDB. Por lo tanto, al intentar cambiarlo conectado a FREEPDB1, la base de datos arroja el error ORA-65040 indicando que no se permite.

P8: ¿Qué dos sentencias permiten recuperar una instancia que no arranca por un valor erróneo escrito en el SPFILE? (Elige dos.)

A y C. La solución pasa por arrancar la instancia mediante un PFILE válido extraído previamente usando STARTUP PFILE. Una vez arrancada operativamente, se debe generar nuevamente el SPFILE reparado ejecutando CREATE SPFILE FROM PFILE.

P9: Una instancia tiene MEMORY_TARGET = 0, SGA_TARGET = 2G y DB_CACHE_SIZE = 512M. ¿Qué afirmación es correcta?

B. Con SGA_TARGET mayor a cero y MEMORY_TARGET en cero, el entorno utiliza ASMM. En este contexto automático, asignar un valor explícito a parámetros como DB_CACHE_SIZE fuerza a Oracle a interpretarlos como un tamaño mínimo que nunca reducirá.

P10: ¿Qué dos estructuras forman parte de la PGA de un proceso servidor dedicado? (Elige dos.)

A y D. La PGA administra la memoria privada de los procesos. Sus componentes incluyen las áreas de trabajo para operaciones como la ordenación (sort area) y la memoria utilizada por cada sesión individual (session memory).

P11: Un usuario ejecuta COMMIT. ¿Qué proceso debe completar su escritura antes de que el COMMIT devuelva el control?

C. El proceso LGWR debe escribir obligatoriamente los cambios del log buffer en los redo logs online. Esta acción asegura la persistencia en disco de una transacción confirmada antes de liberar a la sesión.
P12: ¿Qué dos procesos de background son obligatorios en cualquier instancia de Oracle? (Elige dos.)

B y D. PMON y SMON son procesos obligatorios e esenciales para el funcionamiento de la instancia. PMON limpia procesos y deshace transacciones fallidas, mientras que SMON ejecuta la recuperación de la instancia tras una caída.



Preguntas de comprobación

8.1.1 Respaldo

1. ¿Por qué la copia de la Parte B es consistente? ¿Qué pasaría si se tomara con la base abierta?

La copia es consistente porque SHUTDOWN IMMEDIATE ejecuta un checkpoint global, cierra los archivos y desconecta a todos antes del apagado. Si la base de datos permaneciera abierta, la copia sería inconsistente y serían necesarios los archivelogs y aplicar redo para recuperar la integridad.

2. ¿Para qué sirven manifiesto.txt y SHA256SUMS? ¿Qué comprueba restaurar-estado.sh antes de tocar nada?

El manifiesto almacena metadatos críticos sobre la procedencia de la copia, y SHA256SUMS alberga las huellas de cada archivo. El script de restauración comprueba primero y exclusivamente las sumas SHA-256 para confirmar la integridad inalterada de la copia antes de sustituir o borrar el volumen.

3. Define RPO y RTO con los datos de tu propia copia.

El RPO (Recovery Point Objective) representa la cantidad de información transaccional que podría perderse, es decir, lo hecho desde la última copia de seguridad. El RTO (Recovery Time Objective) indica el tiempo necesario requerido por el script para completar la restauración y devolver el servicio a su estado operativo.

8.1.2 Diagnóstico y correcciones

4. ¿Dónde creó Oracle los datafiles de V000 y por qué? ¿Qué parámetro habría evitado el problema?

Los archivos se generaron en la ruta $ORACLE_HOME/dbs de la capa del contenedor, ya que se introdujo un nombre relativo sin especificar la ruta absoluta. Si se hubiera configurado el parámetro db_create_file_dest, Oracle habría aplicado OMF para enrutar directamente los archivos al destino correcto por defecto.

5. ¿Por qué ALTER TABLESPACE ... RENAME DATAFILE no basta para mover un archivo?

La instrucción SQL RENAME DATAFILE se limita a actualizar la referencia del archivo registrada internamente en el control file. El desplazamiento o copia física del archivo a su nueva ruta debe realizarse a nivel del sistema operativo previamente.

6. ¿Por qué no se edita V000 y se crea V003? ¿Por qué invalidar una contraseña es mejor que borrarla del archivo?

 V000 no se edita porque ya fue aplicada históricamente al entorno; se aplica V003 para resolver el fallo manteniendo una trazabilidad del cambio. Invalidar credenciales forzándolas a cuentas de solo esquema sin autenticación neutraliza por completo la amenaza, ya que simplemente borrar las contraseñas del script no las hace desaparecer del historial inmutable de Git.


7. ¿Qué demuestra la prueba de persistencia y por qué se ejecuta después de reubicar?

La prueba confirma que los datafiles se encuentran verdaderamente en el volumen de almacenamiento persistente y que sobrevivirán tras destruirse el contenedor temporal. Realizar este paso antes del traslado habría eliminado los datafiles junto a la capa de ejecución del contenedor, causando pérdidas de datos.


8.1.3 Instancia y arranque

8. Con tus evidencias: tres datos que pertenecen a la instancia y tres que pertenecen a la base de datos.

Los datos propios de la instancia (v$instance) incluyen INSTANCE_NAME, STATUS, y la fecha STARTUP_TIME. Los relativos a la base de datos (v$database) comprenden el identificador único DBID, el modo LOG_MODE, y la fecha CREATED.

9. ¿Qué lee Oracle en NOMOUNT, en MOUNT y en OPEN? Relaciónalo con ORA-01507 y ORA-01219.

En NOMOUNT, Oracle lee únicamente la configuración (SPFILE o PFILE), originando el error ORA-01507 si se intenta consultar v$database porque el control file aún no se ha abierto. En MOUNT se leen los control files, pero los datafiles siguen cerrados, resultando en ORA-01219 al intentar acceder a tablas del diccionario de datos como dba_tables. Al pasar a OPEN, Oracle abre y lee los datafiles y redo logs online haciéndolos totalmente accesibles.

10. ¿Por qué FREEPDB1 se abre sola tras ALTER DATABASE OPEN Qué harías si no lo hiciera?

La base conectable se abre automáticamente como resultado de una instrucción previa de SAVE STATE, la cual memoriza en dba_pdb_saved_states su requerimiento de inicio. De no contar con esta configuración, la base permanecería en estado MOUNTED y se necesitaría ejecutar la instrucción ALTER PLUGGABLE DATABASE FREEPDB1 OPEN.

11. Clasifica ORA-00800 y ORA-20013 del alert log: ¿alerta real o ruido conocido? Justifícalo.

Constituyen ruido conocido documentado (soft errors) derivados de las peculiaridades de los entornos basados en contenedores. ORA-00800 reporta un fallo de asignación de prioridades bloqueado por las políticas de Docker, mientras que ORA-20013 advierte que no pueden leerse los inventarios de parches, sin afectar ninguno a la viabilidad de la base.

8.1.4 Parámetros

12. Diferencia entre v$parameter y v$spparameter con el ejemplo de db_files de tu evidencia.

La vista v$parameter enseña los valores efectivos, activos y en funcionamiento en ese momento en la memoria de la instancia, mientras que v$spparameter muestra solo los valores grabados específicamente de manera persistente en el archivo SPFILE.


13. ¿Qué hace SCOPE=BOTH y cuál es el SCOPE por defecto con SPFILE?

El modificador SCOPE=BOTH ejecuta un cambio de manera sincrónica en el comportamiento en vivo de la memoria y lo graba en el archivo físico para persistir tras los reinicios. Es el comportamiento que adopta Oracle por defecto cuando la instancia se ha arrancado con un SPFILE.

14. ¿Por qué PROCESSES rechaza el cambio en memoria aunque v$parameter lo marque IMMEDIATE?

Aunque la vista técnica refleje erróneamente un estado IMMEDIATE, PROCESSES es un parámetro de naturaleza puramente estática en la arquitectura SGA que dimensiona en su totalidad las estructuras desde el momento del arranque, lo que impide ajustarlo sin reiniciar (requiriendo SCOPE=SPFILE).

15. ¿Para qué sirve versionar el PFILE? Explica "configuration drift".

Versionar y guardar copias legibles en texto del PFILE permite disponer de respaldos editables para casos de rescate e histórico auditable de parámetros. Evita la deriva de configuración (configuration drift), un escenario problemático donde los valores operativos reales cambian respecto a la documentación de manera silenciosa, pudiendo detectarse inmediatamente al aplicar un git diff.

8.1.5 Memoria y procesos

16. ¿Qué modelo de gestión de memoria usa tu instancia? Justifícalo con tres parámetros.

La instancia aplica una Gestión Automática de Memoria Compartida (ASMM). Los parámetros que lo fundamentan revelan sga_target=1536M para delegar la gestión del balance SGA, pga_aggregate_target=512M para manejar por separado los procesos de sesión, y la desactivación total de la capa superior conjunta mediante memory_target=0.

17. Explica las cifras de tu experimento de caché: lecturas lógicas, físicas y tasa de acierto.

En la primera ronda del experimento (caché fría), los bloques deben llevarse al espacio en memoria produciendo lecturas físicas desde el disco equivalentes al tamaño ocupado por la tabla. En la segunda ronda, aunque las lecturas lógicas requeridas de procesamiento son idénticas, las lecturas físicas se reducen a cero, obteniendo un acierto perfecto del 100% gracias a la respuesta íntegra del Buffer Cache.

18. ¿Por qué no se suma el RSS de los procesos para saber la memoria de la instancia?

El método de sumar ciegamente el RSS (Resident Set Size) contamina el resultado porque el espacio base de SGA compartida aparece referenciado y computado de manera repetida para cada proceso individual de background, ofreciendo un sumatorio irreal superior a la memoria del propio equipo.


19. Relaciona el SPID de LGWR de v$process con el PID de /proc. ¿Por qué docker top muestra otro número?

El valor SPID consultado dentro de Oracle refleja el identificador nativo que ha asignado el entorno de ejecución interior del contenedor, y coincide con los registros reportados por el comando top o la ruta local /proc. En cambio, el comando externo docker top rastrea y reporta un número diferente que es el mapeo traducido a los identificadores del sistema operativo anfitrión.

20. ¿Qué hace PMON y qué hace SMON? Pon un ejemplo de cada uno.

PMON vigila la integridad de procesos individuales; por ejemplo, si se apaga de golpe la aplicación de un cliente, PMON deshace su transacción incompleta y libera bloqueos para proteger el entorno. Por el contrario, SMON se orienta a reparaciones sistémicas mayores; por ejemplo, procesando tareas de recuperación tras la interrupción eléctrica que causa una caída de la base entera.

8.1.6 Seguridad y trabajo profesional

21. ¿Por qué C##OPS_RO y no SYSTEM para observar? ¿Qué no puede hacer C##OPS_RO?

Utilizar un perfil específico de monitorización respeta el principio de seguridad de mínimo privilegio dictaminado para la industria (Least Privilege). C##OPS_RO solo dispone de acceso al rol SELECT_CATALOG_ROLE, por lo que está completamente incapacitado e inhabilitado para cualquier modificación, inserción, alteración y borrado, a diferencia del control destructivo ilimitado que posee SYSTEM.

22. ¿Qué dos vías de exposición de contraseñas corrige este laboratorio respecto al Lab 3?

Resuelve en primer lugar la vulnerabilidad de las contraseñas legibles y codificadas en las migraciones forzando a los perfiles de usuario a cuentas sin privilegio lógico de inicio de sesión (NO AUTHENTICATION). En segundo lugar, oculta la aparición de la contraseña base en las invocaciones en línea de comandos adoptando una autenticación silente conectando al contenedor mediante sqlplus / as sysdba (OS Authentication).
