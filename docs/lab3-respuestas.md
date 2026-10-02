# Preguntas de comprobación

### 8.1.1. Docker

**1. ¿Qué diferencia hay entre una imagen y un contenedor? Usa como ejemplo lo que hiciste en los ejercicios G2 y G4.**
Una imagen es un modelo fijo y de solo lectura, mientras que un contenedor es la ejecución real basada en ese modelo. Es como tener una receta (imagen) y preparar el plato (contenedor). En el ejercicio G2 se ejecutó una imagen que solo imprimió un mensaje y terminó. En el G4 se abrió un contenedor interactivo basado en Alpine, mostrando que es un proceso en ejecución.

**2. En el Ejercicio G5 el archivo nota.txt desapareció y en el G6 no. Explica por qué.**
En G5 el archivo se pierde porque el sistema de archivos del contenedor es temporal y se elimina al borrar el contenedor. En G6 el archivo permanece porque se guardó en un volumen persistente que no depende del contenedor.

**3. ¿Qué diferencia hay entre docker ps y docker ps -a, y qué significa STATUS = Exited (0)?**
`docker ps` muestra solo los contenedores activos. `docker ps -a` muestra todos, incluidos los detenidos. El estado `Exited (0)` indica que el contenedor terminó correctamente sin errores.

**4. En -p 8181:8181, ¿qué número corresponde a tu equipo y cuál al contenedor? ¿Qué pasaría con -p 80:8080 en el ejercicio de nginx?**
El primer número es el puerto del host y el segundo el del contenedor. Con `-p 80:8080`, el tráfico del puerto 80 del equipo iría al 8080 del contenedor, pero nginx escucha en el 80 interno, así que la página no cargaría.

**5. ¿Por qué un contenedor de Oracle se queda en marcha y el de hello-world termina solo?**
Un contenedor vive mientras su proceso principal esté activo. Oracle sigue funcionando porque su motor de base de datos está siempre en ejecución. Hello‑world termina porque solo imprime un mensaje y finaliza.

**6. ¿Qué es el digest de una imagen y por qué lo registramos si ya sabemos que usamos :latest?**
El digest es una firma única (sha256) que identifica exactamente una versión de la imagen. Se registra porque `:latest` puede cambiar con el tiempo; el digest garantiza saber qué versión exacta se usó.

**7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué docker rm oralab-26ai no lo hace?**
Los datos se eliminarían borrando el volumen, por ejemplo con `docker volume rm` o limpiezas que incluyan volúmenes. `docker rm oralab-26ai` solo borra el contenedor; los datos permanecen porque están en un volumen persistente.

### 8.1.2. Git, organización y evidencia

**8. ¿Por qué este laboratorio se hace dentro del repositorio oracle-database-lab, con Issue, branch y Pull Request, en vez de en una carpeta aparte?**
Para mantener la trazabilidad, conservar la protección de la rama principal y asegurar que todo el trabajo quede registrado y revisado como en un entorno profesional.

**9. ¿Qué diferencia hay entre source 00-config.sh y bash 00-config.sh? ¿Por qué usamos source?**
`bash 00-config.sh` ejecuta el script en una subshell que desaparece al terminar, perdiendo las variables. `source 00-config.sh` lo ejecuta en la misma sesión, dejando las variables disponibles. Por eso se usa.

**10. Explica cada parte del nombre 20260915T091230Z_02-docker.script.log.**

* **20260915T091230Z:** fecha y hora en formato ISO 8601 UTC.
* **02:** número del paso.
* **docker:** descripción en kebab-case.
* **.script.log:** indica que es un archivo de registro generado desde la terminal.

**11. ¿Para qué sirve .gitattributes y qué error evita?**
Sirve para definir reglas comunes sobre los finales de línea. Evita errores al ejecutar scripts con CRLF en Linux, como `\r: command not found`.

**12. ¿Por qué en este Pull Request elegimos Create a merge commit en lugar de Squash and merge?**
Porque cada commit representa una parte distinta del trabajo y se quiere conservar el historial completo sin fusionarlo en uno solo.

### 8.1.3. Seguridad

**13. Describe las cuatro capas de la estrategia de contraseñas (Parte D) y qué pasaría si te saltas la primera.**

1. Ignorar el archivo real con `.gitignore`.
2. Crear una plantilla sin secretos (`.env.example`).
3. Tener un archivo local con las credenciales reales.
4. Cargar la contraseña como variable en la terminal.

Si falta la primera capa, el archivo real quedaría bajo control de Git y la contraseña quedaría registrada para siempre.

**14. ¿Por qué no escribimos la contraseña directamente en el comando docker run, aunque el script no se suba a Git?**
Porque cualquier comando queda guardado en texto plano en el historial de la terminal. Usar una variable evita que la contraseña aparezca allí.

**15. Si descubres tu contraseña en un commit ya publicado, ¿basta con borrarla en un commit nuevo? ¿Qué debes hacer?**
No basta. La contraseña sigue accesible en el historial. Hay que considerarla comprometida, cambiarla y avisar para limpiar la rama.

### 8.1.4. Oracle y herramientas

**16. ¿Por qué no usamos SPOOL ni @archivo.sql con sqlplus dentro del contenedor, y qué hicimos en su lugar?**
No se usan porque escribirían o buscarían archivos dentro del contenedor. En su lugar, se pasó el archivo desde fuera usando `<` y se capturó la salida con `tee`.

**17. ¿Qué hace WHENEVER SQLERROR EXIT SQL.SQLCODE al inicio de V000 y V001, y qué pasaría sin esa línea?**
Hace que el script se detenga inmediatamente si ocurre un error y devuelva el código correspondiente. Sin esa línea, el script seguiría ejecutándose pese al fallo.

**18. ¿Qué es una migración y por qué V000 y V001 no se deben editar una vez aplicadas?**
Una migración es un script versionado que avanza la base de datos de un estado a otro. No se modifican una vez aplicadas; cualquier cambio se hace creando una nueva migración.

**19. ¿Por qué en SQL Developer se usa el servicio FREEPDB1 y no FREE ni un SID?**
Porque `FREEPDB1` es el servicio asociado a la base de datos donde se trabaja. Usar `FREE` o un SID conectaría al contenedor raíz.

**20. ¿Qué aporta SQLcl frente a SQL*Plus, y por qué un DBA debe dominar ambas?**
SQLcl añade funciones modernas como autocompletado, historial y soporte para Liquibase. SQL*Plus es esencial porque es la herramienta clásica disponible en casi cualquier servidor.

### 8.1.5. Entorno de trabajo

**21. ¿Por qué el curso pasa de Git Bash a Ubuntu en WSL 2? Da al menos dos problemas concretos de Git Bash que desaparecen en Ubuntu.**
Ubuntu ofrece un entorno Linux real, igual al de producción. Problemas que desaparecen:

* Rutas mal traducidas que rompen comandos de Docker.
* Falta de utilidades como `free`, `htop` o `ss`.

**22. ¿Por qué clonamos el repositorio en ~/oracle-database-lab y no trabajamos sobre la carpeta de Windows (/mnt/c/...)? ¿Y por qué recomendamos bash frente a zsh para los scripts del curso?**
Clonar en Linux evita lentitud, problemas de permisos y errores de finales de línea que aparecen al trabajar desde `/mnt/c`. Se recomienda `bash` porque es el intérprete estándar en servidores Linux, mientras que `zsh` suele requerir instalación adicional.
