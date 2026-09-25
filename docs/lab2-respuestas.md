1. ¿Por qué un Issue sin criterios de aceptación es un problema, aunque la descripción general parezca clara?

Porque debe haber una checklist objetiva describiendo las tareas, sino el reviewer no puede comprobar si el trabajo está realmente hecho ni que condiciones debe comprobar antes de aprobarlo.

2. Explica la diferencia entre "Refs #N" y "Closes #N" en un mensaje de commit o en la descripción de un Pull Request.

Refs #N crea una referencia visible en el Issue pero lo mantiene abierto. Closes #N cierra automáticamente el Issue #N tras hacer el merge entre el pull request (o el commit) y la rama.

3. ¿Qué ocurre exactamente si intentas hacer git push directamente sobre una branch main
protegida? ¿Es un error tuyo o un fallo del sistema?

GitHub rechaza la operación mostrandonos el error “GH006: Protected branch update failed”, no es error del sistema ni nuestro, se trata de la regla de protección que nosotros mismos hemos establecido funcionando correctamente, impidiendo que entren cambios que no han pasado por un pull request.

4. Un compañero te dice: "he aprobado el PR sin mirar los archivos, total ya me fío". ¿Qué riesgo tiene esa forma de revisar?

Al no estar realizando su trabajo correctamente y aprobar los cambios ciegamente sin revisarlos puede estar aprobando cambios erróneos y/o con fallos de seguridad.

5. Si el reviewer pide un cambio y tú ya habías hecho push de tu branch, ¿tienes que abrir un Pull Request nuevo? Explica qué ocurre técnicamente con el PR existente cuando haces un nuevo commit.

No, al hacer un nuevo commit y push sobre la misma rama, el PR existente se actualiza automáticamente incorporando los cambios del commit sin perder el hilo de la conversación.

6. Describe con tus palabras la diferencia entre Merge commit, Squash and merge y Rebase and merge. ¿Cuál usarías para una branch con commits "wip", "fix", "fix2", "ok ya"?

Merge commit: mantiene todos los commits individuales y crea un commit merge adicional.
Squash and merge: Combina todos los commits de la rama en un unico limpio sobre main.
Rebase and merge: replica los commits en orden linealmente sobre main.
Elección: condensa todos los commits temporales de trabajo ("wip", "fix", etc.) en un commit limpio.

7. ¿Por qué borrar una branch después del merge no elimina el trabajo realizado en ella?

Porque todos los cambios y commits ya han sido integrados en historial de cambios de la rama main, borrar esa rama solamente elimina el puntero temporal.

8. ¿Qué información debería contener siempre la descripción de un Pull Request, como mínimo?

Un Pull Request debería contener, un resumen del cambio realizado, una referencia al problema que se ha resuelto, explicación de como probar el cambio y evidencias visuales.

9. Un reviewer escribe solo "esto está mal" como comentario. ¿Qué le falta a ese comentario para ser útil? Reescríbelo tú con un ejemplo inventado.

Decir solo "esto está mal" no sirve porque no explica dónde está el error ni cómo arreglarlo, lo que hace que el autor no sepa qué hacer y se ponga a la defensiva. Para que un comentario sea útil de verdad, debe decir qué pasa, por qué es un problema y dar una idea clara para solucionarlo.

Ejemplo:

issue (blocking): En esta línea estás usando una coma para los decimales, pero el sistema solo entiende puntos. Te sugiero cambiarlo por un punto para que no dé error al guardar el formulario.

10. ¿Qué diferencia hay entre que main esté protegida y que simplemente el equipo "se ponga de acuerdo" en no hacer push directo?

Un acuerdo depende únicamente de la disciplina del equipo, pero al proteger la rama “main”, GitHub bloquea el sistema automáticamente. De esta forma, te aseguras de que nadie haga un push directo por accidente.

11. Explica con un ejemplo propio la diferencia entre un comentario issue: (blocking) y uno nitpick: (if-minor) en formato Conventional Comments.

Ejemplo: issue (blocking): La contraseña está escrita directamente en el código.

Es de este tipo porque un issue: (blocking) define un error grave que impide aprobar el código. En el ejemplo, al ser un fallo de seguridad, bloquea obligatoriamente la fusión del trabajo hasta que el autor lo solucione

Ejemplo: nitpick (if-minor): Te falta un punto final en esta frase.

Es de este tipo porque un nitpick: (if-minor) señala un detalle menor (como algo de estilo o formato) que no afecta al funcionamiento. En el ejemplo, al ser solo un tema de puntuación, se sugiere la mejora, pero no frena la aprobación del trabajo.


12. Si tu próximo commit es feat!: cambia la firma de la función principal de la API, ¿qué tipo de versión SemVer se dispara y por qué?

Se dispara un incremento de versión de tipo MAJOR. Esto sucede porque añadir el símbolo “!” justo después del tipo de commit (feat!) indica a las herramientas automatizadas que el código contiene un BREAKING CHANGE el cual se trata de un cambio que rompe la compatibilidad con versiones anteriores.

13. ¿Por qué abrir un Draft PR desde el primer commit estructural puede ahorrar tiempo al equipo, aunque parezca más lento para el autor individual?

Abrir un Draft PR al principio sirve para que el equipo valide tu idea general antes de que te pongas a escribir todo el código al detalle.  De esta forma ahorras tiempo porque, si te estás equivocando de enfoque, te avisan rápido y evitas tener que borrar horas de trabajo tiradas a la basura.
