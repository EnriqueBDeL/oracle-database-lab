# Preguntas de comprobación

1. Compara el paso 6 de tu copia lab4-final con el de la copia lab3-final. ¿Qué demuestra la diferencia?
El paso 6 de la copia lab3-final mostraba cinco archivos de datos ubicados fuera del volumen, mientras que en lab4-final indica que no hay ninguno fuera del volumen. Esto demuestra que la reubicación de datafiles dentro del volumen realizada en el Lab 4 se completó correctamente. Evidencia: 00-backup-lab4.script.log, paso 6.

2. Calcula el factor de bloqueo (bfr) de CLIENTE y de PEDIDO con sus estadísticas. ¿Por qué PEDIDO cabe casi el triple de filas por bloque?
CLIENTE tiene un factor de bloqueo de 68 filas por bloque (100000 filas entre 1467 bloques) y PEDIDO tiene un factor de bloqueo de 188 filas por bloque (1000000 filas entre 5320 bloques). PEDIDO alberga casi el triple de filas por bloque porque la longitud media de sus filas es de 32 bytes (R_BYTES igual a 32), mientras que la de CLIENTE es de 98 bytes (R_BYTES igual a 98). Evidencia: 01-perfil-tiendasur.script.log, sección 1.

3. ¿Por qué el banco de medida ejecuta cada sentencia dos veces y mide solo la segunda?
Porque la primera ejecución realiza el análisis de la consulta y el calentamiento de la caché de memoria del buffer. La segunda ejecución mide el trabajo en caliente de manera estable, reflejando las lecturas lógicas reales sin la penalización de parseo o lecturas físicas iniciales. Evidencia: 01-herramienta-medir.sql, procedimiento consulta.

4. Con tu evidencia 02: altura, número de hojas y factor de ramificación (fan-out) real de IX_PED_CLIENTE. ¿Qué altura tendría con mil millones de filas?
En IX_PED_CLIENTE la altura medida es 3, el número de bloques de hoja es 2216 y el factor de ramificación real es 370. Con mil millones de filas, aplicando la fórmula 1 más el techo del logaritmo en base fo máximo de las hojas, la altura resultante sería de 4 niveles (5 lecturas totales para encontrar una fila). Evidencia: 02-anatomia-indice.script.log, sección 2.

5. En el volcado de la hoja de PK_CLIENTE, localiza una entrada y descompón el ROWID que guarda en bloque y fila. ¿Por qué no aparece el número de archivo?
En la entrada row#0, la cadena data: (6) 00 00 03 1b 00 00 se descompone en 4 bytes para el número de bloque (0x0000031b, bloque 795) y 2 bytes para el número de fila o ranura (0x0000, ranura 0). No incluye el número de archivo porque la tabla reside en un tablespace de tipo BIGFILE, donde el ROWID de índice se simplifica a 6 bytes. Evidencia: 02-anatomia-indice.script.log, sección 4.

6. Elige tres pruebas de la Parte D y explica, con las lecturas lógicas medidas, por qué un tipo de índice gana al otro.
Para Q13 por DNI, el índice UNIQUE reduce las lecturas lógicas de 1436 (recorrido completo) a 3 lecturas lógicas. Para Q7 del historial de cliente, el índice cubriente realiza 3 lecturas lógicas al no acceder a la tabla, superando las 15 lecturas del índice compuesto con acceso a tabla. Para Q15 de token de sesión, el clúster Hash requiere 1 lectura lógica directa por dirección de bloque, superando las 4 lecturas del montón con clave primaria. Evidencia: 03-tipos-indice.script.log, secciones 1, 3 y 7.

7. ¿Por qué IX_PED_FECHA tiene un clustering factor cercano al número de bloques e IX_PED_CLIENTE cercano al de filas? ¿Lo arreglaría un REBUILD?
IX_PED_FECHA tiene un clustering factor de 5220 (próximo a los 5320 bloques de la tabla) porque las filas se insertaron en orden cronológico en disco. IX_PED_CLIENTE tiene un clustering factor de 999041 (próximo a 1000000 de filas) porque los clientes se distribuyeron al azar. Un REBUILD no lo arregla porque el clustering factor depende del orden físico de las filas en la tabla y no de la reconstrucción del índice. Evidencia: 04-agrupamiento-equilibrio.script.log, secciones 1 y 2.

8. Según tu curva de la Parte E, ¿a partir de qué porcentaje deja de compensar cada índice? Compáralo con la fórmula de la Unidad 3.
El índice con clustering factor malo deja de compensar entre el 0,1% y el 0,2% de las filas, coincidiendo con la fórmula k/r menor que (1/bfr) por (c_sec/c_aleat) = (1/188) por (1/5) = 0,11%. El índice con clustering factor bueno mantiene su ventaja hasta cerca del 100% de las filas. Evidencia: 04-agrupamiento-equilibrio.script.log, sección 3.

9. Explica por qué Q4b ('Gonz%') usa el índice y aun así lee más bloques que un recorrido completo.
Q4b utiliza un escaneo por rango del índice pero consume 2024 lecturas lógicas frente a las 1472 del recorrido completo de CLIENTE. Esto sucede porque 'Gonz%' representa el 2,1% de los clientes y, al tener un clustering factor desfavorable con filas dispersas, cada entrada del índice desencadena un salto aleatorio a un bloque distinto de la tabla. Evidencia: 05-sargabilidad.script.log, regla 4.

10. Con tu evidencia 06: bloques modificados por INSERT con 4, 9 y 5 índices. ¿Qué índices de la propuesta del compañero rechazaste y con qué dato?
El coste por INSERT fue de 10,1 bloques por fila con 4 índices, 20,2 bloques por fila con 9 índices (propuesta del compañero) y 12,2 bloques por fila con 5 índices (V005). Se rechazaron IX_PED_ESTADO e IX_PED_CANAL porque sus columnas presentan baja cardinalidad (4 y 3 valores distintos, superando el 0,5% de la tabla cada uno) y DBA_OBJECT_USAGE registró 0 usos durante la carga habitual. Evidencia: 06-indices.script.log, escenarios hoy, compañero y V005.

11. Distingue, con tus gráficos de la Parte H, un índice con divisiones 50/50, uno con divisiones 90/10 y uno con patrón cola.
El índice con divisiones 50/50 (IX_AZAR) presenta un histograma centrado entre el 60% y 80% de ocupación con un mapa uniforme de '=' y ':'. El índice con divisiones 90/10 (IX_CRECIENTE) muestra un 100% de ocupación en sus hojas y un mapa totalmente lleno de '#'. El índice con patrón cola (IX_COLA) muestra un mapa asimétrico con espacios vacíos a la izquierda por borrados antiguos y bloques llenos de '#' a la derecha. Evidencia: 07a-grafico-IX_AZAR.script.log, 07a-grafico-IX_CRECIENTE.script.log y 07b-grafico-IX_COLA-antes.script.log.

12. ¿Qué remedio elegirías para el patrón cola en producción, en horario de servicio, y por qué?
Elegiría ALTER INDEX COALESCE. Se ejecuta en línea sin bloquear la tabla, reorganiza y fusiona las hojas vecinas medio vacías dentro del segmento y reduce el coste de consulta del elemento más antiguo de 253 a 2 lecturas lógicas sin generar sobrecarga excesiva. Evidencia: 07c-remedios.script.log, paso 1.

13. Con tu evidencia 08: ¿qué valores compara Oracle al abrir para decidir si hace falta recuperación?
Oracle compara el SCN de checkpoint guardado en el archivo de control (v$datafile.checkpoint_change#) con el SCN de checkpoint escrito en la cabecera de cada archivo de datos (v$datafile_header.checkpoint_change#). Si los valores coinciden, los archivos están sincronizados; si difieren, el archivo requiere recuperación. Evidencia: 08-scn-checkpoint.script.log, sección 2.

14. ¿Qué protege la multiplexación del control file en el mismo volumen y qué no? ¿Cómo se haría en producción?
Protege ante el borrado accidental o la corrupción de una de las copias individuales del archivo de control. No protege frente a la pérdida del disco o volumen físico subyacente donde residen todas las copias. En producción se ubica cada copia en discos y controladoras independientes o en grupos de discos ASM con redundancia. Evidencia: 09-multiplexar-controlfile.script.log, pasos 1 a 4.

15. Explica los estados CURRENT, ACTIVE e INACTIVE con tu evidencia 10 y por qué Oracle rechaza los tres borrados del paso 4.
CURRENT indica el grupo activo donde escribe LGWR; ACTIVE corresponde a un grupo no actual pero cuyos cambios no han sido volcados totalmente por DBWn; INACTIVE ha completado su volcado a disco y puede ser reutilizado. Oracle rechaza borrar el grupo CURRENT (ORA-01623) o su miembro (ORA-01609) para evitar la pérdida del registro activo, y rechaza eliminar un grupo inactivo si deja menos de dos grupos en total (ORA-01567) para preservar la arquitectura circular. Evidencia: 10-redo.script.log, secciones 1 y 4.

16. Describe la cadena de causas del escenario de la FRA llena, desde ORA-19815 hasta que la base deja de aceptar cambios.
Al llenarse la FRA se registra la advertencia ORA-19815 en el alert log. El proceso ARCn intenta archivar y falla con ORA-19809 y ORA-16038 al sobrepasar el límite. Como los grupos de redo log no pueden archivarse, LGWR no puede conmutar de grupo y las transacciones DML quedan colgadas en la espera 'log file switch (archiving needed)', generando además ORA-00257 en las nuevas conexiones. Evidencia: 11-fra-llena.script.log, secciones 3 y 4.

17. Explica, con los pasos 1 a 4 de tu evidencia 12, la frase "lectores no bloquean a escritores".
En el paso 1, la sesión B lee el valor confirmado 'ACTIVO' del estudiante 101 sin ser bloqueada, utilizando bloques de undo para construir una versión consistente en memoria mientras A mantiene un UPDATE sin confirmar. En el paso 4, la sesión B intenta modificar la misma fila mediante SELECT FOR UPDATE y queda bloqueada con ORA-00054 por el bloqueo TX exclusivo de A. Los lectores obtienen datos consistentes sin bloquear ni ser bloqueados por los escritores. Evidencia: 12-lectura-consistente.script.log, pasos 1 y 4.

18. ¿Por qué un DELETE genera más undo que un INSERT? ¿Por qué el ROLLBACK también genera redo?
DELETE genera más undo (3416 KB frente a 1128 KB en 10000 filas) porque debe guardar la fila completa y sus entradas de índice para reconstruirla, mientras que INSERT solo almacena el ROWID a eliminar. El ROLLBACK genera redo (4701 KB al deshacer el DELETE) porque revertir cambios implica aplicar operaciones inversas sobre los bloques, y todo cambio en bloques debe registrarse en el redo para ser duradero ante fallos. Evidencia: 12-undo-y-redo.script.log, sección 1.

19. Con tu evidencia 13: ¿dónde está la garantía de durabilidad justo después del COMMIT y después del checkpoint?
Justo después del COMMIT, la durabilidad está garantizada por las escrituras secuenciales del registro de redo en disco realizadas por LGWR (11 escrituras de LGWR, 7685 KB de redo). Después del checkpoint, la durabilidad reside físicamente en los archivos de datos tras el volcado de los 231 bloques sucios por parte de DBWn (580 bloques escritos en total). Evidencia: 13-lgwr-dbwn.script.log, tabla de resultados.

20. Simulacro A: explica roll forward y roll back con las filas 102 y 103 y las líneas del alert log.
El alert log refleja 'Beginning crash recovery... Started redo application'. En el roll forward, SMON lee el redo online desde el último checkpoint y aplica los cambios en memoria para las filas 102 y 103. En el roll back, SMON consulta los bloques de undo y revierte la fila 103 (sin confirmar) a 'ACTIVO', mientras la fila 102 (confirmada) permanece como 'EGRESADO'. Evidencia: 14a-caida-instancia.script.log, secciones 3 y 4.

21. Simulacros C y D: tu RTO y tu RPO en cada uno. ¿Por qué son tan distintos?
Simulacro C presentó RTO = 53 s y RPO = 2 s (el tiempo transcurrido desde la copia completa). Simulacro D presentó RTO = 9 s y RPO = 0. Son distintos porque C obligó a restaurar la base de datos completa desde una copia en frío perdiendo cambios intermedios, mientras que D aisló y restauró únicamente el datafile afectado mediante RMAN y aplicó el redo archivado sin perder ninguna transacción. Evidencia: 14c-simulacro-restauracion.script.log y 14d-perdida-datafile.script.log.

22. Clasifica cada error ORA- del bloque 5 de tu runbook: incidente real, efecto del laboratorio o ruido conocido.
Los errores ORA-63999, ORA-01116, ORA-01110 y ORA-01113 son efectos del laboratorio producidos intencionadamente durante el Simulacro D. El error ORA-20013 corresponde a ruido conocido del entorno por la ejecución de DBMS_QOPATCH. Ningún código corresponde a un incidente real no controlado. Evidencia: 15-healthcheck.spool.log, bloque 5.

# Simulacro de examen 1Z0-182

S1. B Un clustering factor próximo al número de filas indica que las filas contiguas del índice están dispersas en bloques de tabla distintos, requiriendo un acceso de bloque por fila. Comprobado en Lab 5, Parte E.

S2. A, C Crear un índice basado en función sobre UPPER(email) o comparar directamente con LOWER(:e) permite mantener la columna libre de funciones y utilizar el índice B-tree. Comprobado en Lab 5, Parte F.

S3. B Al comparar un VARCHAR2 con un número literal, Oracle aplica implícitamente TO_NUMBER() sobre la columna, impidiendo la navegación por el índice. Comprobado en Lab 5, Parte F.

S4. B Los índices bitmap están diseñados para columnas de baja cardinalidad en sistemas de data warehouse con carga nocturna y consultas sin DML concurrente. Comprobado en Lab 5, Parte D.

S5. B El optimizador ejecuta un INDEX SKIP SCAN cuando la columna inicial de un índice compuesto no está en el WHERE pero tiene pocos valores distintos. Comprobado en Lab 5, Parte D.

S6. B Cambiar el índice a INVISIBLE permite comprobar si el optimizador deja de usarlo manteniendo las actualizaciones en DML, facilitando una marcha atrás inmediata. Comprobado en Lab 5, Parte G.

S7. A, C ALTER INDEX COALESCE y SHRINK SPACE reorganizan los bloques de hoja y devuelven el espacio sobrante en línea sin bloquear la tabla. Comprobado en Lab 5, Parte H.

S8. B Invertir los bytes de la clave distribuye las inserciones secuenciales entre múltiples bloques de hoja pero invalida el orden para consultas por rango. Comprobado en Lab 5, Parte H.

S9. C Un UPDATE sobre columnas no indexadas no modifica las entradas de ningún índice, afectando únicamente a los bloques de la tabla. Comprobado en Lab 5, Parte G.

S10. B La altura de un B-tree depende del número de filas y del factor de ramificación del bloque de rama, determinado por la longitud de la clave. Comprobado en Lab 5, Parte C.

S11. A, C En una IOT la tabla se almacena dentro del propio índice B+ de la clave primaria, eliminando la necesidad de acceder a un segmento de tabla separado. Comprobado en Lab 5, Parte D.

S12. B Al montar y abrir la base de datos, Oracle compara el SCN de checkpoint del control file con el SCN registrado en la cabecera de los datafiles. Comprobado en Lab 5, Parte I.

S13. C El proceso de fondo CKPT es el encargado de actualizar el SCN de checkpoint en el control file y en las cabeceras de cada datafile. Comprobado en Lab 5, Parte I.

S14. B, E En estado NOMOUNT la instancia ha leído el SPFILE (v$parameter) y está iniciada (v$instance), pero aún no ha abierto el control file. Comprobado en Lab 5, Parte J.

S15. B El cambio de modo de archivado requiere detener la base y ejecutar ALTER DATABASE ARCHIVELOG con la instancia en estado MOUNT. Comprobado en Lab 5, Parte L.

S16. D La pérdida de un miembro en un grupo inactivo y archivado no detiene la instancia y el servicio continúa normalmente. Comprobado en Lab 5, Parte K.

S17. A, C El undo permite reconstruir versiones anteriores de bloques de datos para proporcionar lectura consistente y ejecutar Flashback Query. Comprobado en Lab 5, Parte M.

S18. B Los bloques del tablespace de undo residen en la caché y pueden perderse en un fallo; para poder ejecutar el rollback tras el arranque, el undo debe protegerse en el redo. Comprobado en Lab 5, Parte M.

S19. A El mensaje Commit complete confirma únicamente que el registro de redo correspondiente a la transacción se ha grabado en disco por LGWR. Comprobado en Lab 5, Parte N.

S20. A Reducir FAST_START_MTTR_TARGET incrementa la frecuencia de los checkpoints de DBWn, acortando el tiempo necesario para la recuperación de instancia. Comprobado en Lab 5, Parte I.

S21. B Cuando el proceso ARCn no puede archivar un redo log porque la FRA está llena, LGWR no puede reusar los grupos y congela la ejecución de DML. Comprobado en Lab 5, Parte L.

S22. B Poner el datafile dañado en estado OFFLINE aisla la falla y permite mantener el resto de la base de datos operativa mientras se realiza la restauración. Comprobado en Lab 5, Parte O.

S23. B La pérdida de un datafile del tablespace SYSTEM impide la operación de la base de datos, requiriendo parada, montaje, restore, recover y apertura. Comprobado en Lab 5, Parte O.

S24. B En modo NOARCHIVELOG no existen archivos de redo archivados para aplicar media recovery, por lo que solo es posible restaurar la copia completa en frío. Comprobado en Lab 5, Parte O.

S25. B, D Aumentar UNDO_RETENTION, ampliar el espacio del tablespace de undo y activar RETENTION GUARANTEE evita que las consultas largas fallen por sobrescritura de undo. Comprobado en Lab 5, Parte M.

S26. A La vista V$RECOVERY_AREA_USAGE muestra el porcentaje de espacio utilizado en la FRA desglosado por cada tipo de archivo. Comprobado en Lab 5, Parte L.

# Tabla de RTO/RPO

| Simulacro | Escenario / Fallo | Mecanismo de recuperación | RTO (Tiempo de recuperación) | RPO (Pérdida de datos) |
| --- | --- | --- | --- | --- |
| Simulacro A | Caída brusca de la instancia (SHUTDOWN ABORT) | Recuperación automática de instancia (roll forward con redo y roll back con undo por SMON) | 5 s | 0 s |
| Simulacro B | Pérdida de una copia del control file | Copia física manual de una copia sana y apertura de la base (ALTER DATABASE MOUNT / OPEN) | 1 min | 0 s |
| Simulacro C | Borrado de tabla con PURGE (error humano grave) | Restauración completa de la base de datos a partir de la última copia de seguridad | 53 s | 2 s |
| Simulacro D | Pérdida de un datafile (fallo de disco / medio) | RMAN RESTORE + RECOVER DATAFILE con aplicación de redo archivado | 9 s | 0 s |

# Retrospectiva

## Incidente: DML colgado por FRA llena (entorno de laboratorio)
- **Impacto:** Sesiones colgadas esperando el evento "log file switch (archiving needed)"; ninguna pérdida de datos confirmados.
- **Detección:** Una carga masiva de datos no terminaba de ejecutarse; la consulta a v$session mostró el evento de espera "log file switch (archiving needed)".
- **Causa raíz:** Reconstrucción y ejecución reiterada de las pruebas del banco TiendaSur teniendo el modo ARCHIVELOG activo y un límite fijado en la FRA de 4 GB.
- **Mitigación:** Ejecución del comando de limpieza en RMAN: `DELETE NOPROMPT ARCHIVELOG ALL` (procedimiento aceptable únicamente en entorno de laboratorio).
- **Qué cambia:** El runbook de salud diaria alertará cuando el uso de la FRA supere el 80% y se exigirá revisar la vista v$recovery_area_usage antes de realizar cargas masivas.
- **Lección aprendida:** El sistema emitía advertencias ORA-19815 en el alert log con bastante antelación antes de producirse el bloqueo total de escrituras, por lo que deben automatizarse alertas sobre dicho registro.
