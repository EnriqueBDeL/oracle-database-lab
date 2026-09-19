1. ¿Cuál es la diferencia entre Working Directory, Staging Area y Local Repository? Da un ejemplo de un
archivo pasando por las tres.

El Working Directory es la carpeta/directorio principal donde se encuentra el proyecto y desde donde puedes modificar los archivos. 

El Staging Area es un espacio en donde almacena/prepara la información que contendrá el commit.

El Local Repository es un historial que se almacena dentro de “.git”, que contiene la información de todos los commits hechos.


  1. Working Directory -- git add --> 2. Staging Area -- git commit --> 3. Local Repository

    1. Contiene el archivo README.md que modificamos.
    2. Tenemos los cambios a realizar y se procede a realizar el commit.
    3. Se almacena en el historial, el commit de la modificación del archivo README.md.


2. Si modificas un archivo pero no haces git add, ¿aparece ese cambio en tu próximo commit? Explica por
qué.

  No aparecen los cambios, porque lo que hace add es pasarle al Staging  Area la información de los cambios realizados a x numero de archivos, pero al no pasarle     la información, no se pueden confirmar esos cambios, y al no confirmarse, no se actualizarán esos cambios.

3. ¿Por qué git status no mostraba las carpetas vacías que creaste en la Parte C? ¿Qué truco usamos para
solucionarlo?

  No se mostraban, porque git  tal y como está configurado, solo muestra las carpetas/directorios que contienen al menos un archivo.

  El truco que utilizamos fue agregar un archivo placeholder, que en git se le llama normalmente “.gitkeep”.
  Aparte de ese, existe la opción de agregarle un README.md explicando para que sirve el repositorio, pero no lo llegamos a utilizar en el laboratorio.
  
4. Explica con tus palabras qué es HEAD.

  Es un identificador que funciona como puntero que se utiliza para identificar un commit exacto en concreto y en que Branch se encuentra dicho commit.

5. ¿Qué diferencia hay entre crear una branch con git switch -c y crear una carpeta nueva con mkdir?
¿Cómo lo comprobamos en la Parte G?

  El “switch -c “ se utiliza para crear una rama en el historial de git, donde guardará una sere de commits exclusivos de dicha rama.
  Mientras tanto, “mkdir” se utiliza para crear una carpeta en nuestro dispositivo para almacenar documentos u otros sub-repositorios.
  En la parte G, lo comprobamos usando el comando “ls -la” justo después de crear la rama, verificando que en el disco no había aparecido ninguna carpeta física      nueva.

6. Durante el conflicto de la Parte H, ¿qué representaba el contenido entre <<<<<<< HEAD y =======? ¿Y
entre ======= y >>>>>>>?

  El contenido entre esos caracteres, representan un conflicto generado por la fusión de dos branches.
  Concretamente estas marcas contiene en su interior, líneas de código que no son comunes a los archivos que se quieren fusionar.
  
7. ¿Por qué NO se debe hacer git commit --amend sobre un commit que ya se subió con git push?

  Porque reescribe el historial de commits creando un nuevo commit con un código hash diferente. Esto genera problemas si estás trabajando en equipo y algunos de     los desarolladores descargó el commit anterior a este “commit –apend”.

8. Si borras por accidente la carpeta .git de tu proyecto, ¿qué se pierde exactamente? ¿Se pierde también
el código fuente que está en el disco?

  Se borraría el historial de commits, las ramas y la configuración del repositorio.

  El código seguiría estando, pero solo estaría con el estado del ultimo guardado, por lo que si querías una versión anterior, ya no podrás volver a un commit        pasado para volver a ese código.

9. Explica con tus propias palabras la diferencia entre Git y GitHub, sin usar la palabra "nube".

  Git es un programa local que sirve para controlar versiones de de un directorio base (Working Directory).
  Por otro lado GitHub es una plataforma web que almacena los repositorios de Git de forma remota y que permite colaborar con otros usuarios.

10. ¿Por qué no se debe subir un archivo .env con contraseñas reales a un repositorio, aunque el
repositorio sea privado?

  No se debe subir, porque cualquier contraseña o información sensible subida en un commit, quedará registrada en el historial, y si el repositorio es compartido     con alguien o se le cambia la visibilidad a público, esa contraseña subida a ese commit, quedará expuesto.

11. Un compañero te dice: "hice push y ahora GitHub me rechaza el segundo push con 'non-fast-
forward'". ¿Qué ha ocurrido probablemente y qué comando ejecutarías primero?

  Que el compañero está intentando hacer un commit sin el tener en su dispositivo local los últimos commits subidos. 
  Para solucionarlo, deberá usar el comando “git pull” para descargar en su dispositivo local los últimos commits y ya tras esto, si no hay no hay ningún conflicto   entre commits, podrá hacer el push sin problema.

12. ¿Qué tipo de Conventional Commit (feat, fix, docs, test…) usarías para: añadir un índice de
rendimiento a una tabla, corregir una restricción mal definida, y actualizar el README?

  1.	Añadir un índice de rendimiento a una tabla: usaría perf, porque se trata de un índice con intención de optimizar el rendimiento.
  2.	Corregir una restricción mal definida: eligiría fix, ya que se tratade un error, el cual se quiere solventar.
  3.	Actualizar el README: usaría docs, ya que se trata de un cambio en la documentación.
