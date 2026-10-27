// Genera las guías de la página (sitio/guias/*.html) con el mismo encabezado,
// datos estructurados y cierre. Correr desde la raíz:
//   dart run tool/guias_html.dart
// Los ejemplos de código llevan data-entradas y data-salida: una prueba
// (apps/jaguar/test/guias_test.dart) los ejecuta con el intérprete de Jaguar.
import 'dart:io';

const sitio = 'https://jaguarcode.org';
const fecha = '2026-10-26';

class Guia {
  const Guia({
    required this.slug,
    required this.titulo,
    required this.h1,
    required this.descripcion,
    required this.resumen,
    required this.secciones,
    required this.preguntas,
    required this.relacionadas,
  });

  final String slug;
  final String titulo;
  final String h1;
  final String descripcion;
  final String resumen;

  /// (id, título, html)
  final List<(String, String, String)> secciones;
  final List<(String, String)> preguntas;
  final List<String> relacionadas;
}

String esc(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Un bloque de código de ejemplo que la prueba ejecuta.
String codigo(String fuente, {List<String> entradas = const [], String? salida}) {
  final atributos = [
    if (entradas.isNotEmpty) 'data-entradas="${entradas.map(esc).join('|')}"',
    if (salida != null) 'data-salida="${esc(salida).replaceAll('\n', '&#10;')}"',
  ].join(' ');
  return '<pre class="codigo" ${atributos.isEmpty ? '' : '$atributos '}tabindex="0"><code>${esc(fuente.trimRight())}</code></pre>';
}

String tabla(String titulo, List<String> cabeza, List<List<String>> filas, {String? nota}) {
  final b = StringBuffer('<div class="tabla"><table><caption>${esc(titulo)}</caption><thead><tr>');
  for (final c in cabeza) {
    b.write('<th scope="col">${esc(c)}</th>');
  }
  b.write('</tr></thead><tbody>');
  for (final f in filas) {
    b.write('<tr>');
    for (final c in f) {
      b.write('<td>$c</td>');
    }
    b.write('</tr>');
  }
  b.write('</tbody></table></div>');
  if (nota != null) b.write('<p class="nota-tabla">$nota</p>');
  return b.toString();
}

late final String diagramaPromedio;

final guias = <Guia>[
  Guia(
    slug: 'que-es-un-algoritmo',
    titulo: 'Qué es un algoritmo: definición, partes y ejemplos fáciles',
    h1: 'Qué es un algoritmo',
    descripcion:
        'Un algoritmo es una lista ordenada de pasos para resolver un problema. Conoce sus partes (entrada, proceso y salida), ejemplos de la vida diaria y uno en pseudocódigo.',
    resumen:
        'Un algoritmo es una lista ordenada y finita de pasos que resuelve un problema o hace una tarea. Tiene una entrada (lo que necesita), un proceso (lo que hace) y una salida (el resultado).',
    secciones: [
      (
        'vida-diaria',
        'Un ejemplo de la vida diaria',
        '''
<p>Una receta es un algoritmo. Para preparar un té, por ejemplo:</p>
<ol>
  <li>Hervir agua.</li>
  <li>Poner una bolsita de té en una taza.</li>
  <li>Verter el agua caliente en la taza.</li>
  <li>Esperar tres minutos.</li>
  <li>Retirar la bolsita.</li>
</ol>
<p>Si cambias el orden (verter el agua antes de hervirla) el resultado ya no es el mismo. Esa es la primera idea: <b>el orden de los pasos importa</b>.</p>'''
      ),
      (
        'partes',
        'Las tres partes de un algoritmo',
        '''
<p>Todo algoritmo se puede ver como una caja con tres partes:</p>
${tabla('Entrada, proceso y salida', ['Parte', 'Qué es', 'En el té', 'En un promedio'], [
          ['<b>Entrada</b>', 'Los datos con los que empieza', 'Agua, té y taza', 'Dos calificaciones'],
          ['<b>Proceso</b>', 'Lo que se hace con los datos', 'Hervir, verter, esperar', 'Sumar y dividir entre 2'],
          ['<b>Salida</b>', 'El resultado', 'Una taza de té', 'El promedio'],
        ])}
<p>Antes de escribir un programa conviene responder estas tres preguntas. En la escuela se le llama <i>planteamiento</i> del problema.</p>'''
      ),
      (
        'buen-algoritmo',
        'Qué debe cumplir un buen algoritmo',
        '''
<ul>
  <li><b>Ser preciso:</b> cada paso dice exactamente qué hacer. «Agrega un poco de sal» es ambiguo; «agrega una cucharadita de sal» no.</li>
  <li><b>Ser finito:</b> termina. Un algoritmo que se repite para siempre no resuelve nada.</li>
  <li><b>Estar ordenado:</b> los pasos van en una secuencia clara.</li>
  <li><b>Funcionar para varios datos:</b> el mismo algoritmo del promedio sirve para cualquier par de calificaciones, no solo para 7 y 10.</li>
</ul>'''
      ),
      (
        'en-programa',
        'De la idea al programa',
        '''
<p>Para que una computadora siga un algoritmo hay que escribirlo con reglas claras. Una forma de hacerlo es con <a href="/guias/que-es-el-pseudocodigo">pseudocódigo</a>. Este algoritmo calcula el área de un rectángulo: la entrada son la base y la altura, el proceso es multiplicarlas y la salida es el área.</p>
${codigo('''
Algoritmo area_rectangulo
    Escribir "Base:"
    Leer base
    Escribir "Altura:"
    Leer altura
    area <- base * altura
    Escribir "Área: ", area
FinAlgoritmo
''', entradas: ['4', '3'], salida: 'Base:\nAltura:\nÁrea: 12')}
<p>Con base 4 y altura 3 muestra <code>Área: 12</code>. Cambia los datos y el mismo algoritmo da otro resultado.</p>'''
      ),
      (
        'formas',
        'Formas de representar un algoritmo',
        '''
<ul>
  <li><b>Lenguaje natural:</b> frases como las de la receta.</li>
  <li><b><a href="/guias/que-es-el-pseudocodigo">Pseudocódigo</a>:</b> frases cortas con palabras como <code>Leer</code>, <code>Escribir</code> y <code>Si</code>.</li>
  <li><b><a href="/guias/como-hacer-un-diagrama-de-flujo">Diagrama de flujo</a>:</b> figuras unidas con flechas.</li>
  <li><b>Código:</b> un lenguaje de programación como Python, C o Java.</li>
</ul>
<p>Son formas distintas de contar lo mismo. Para comprobar que un algoritmo funciona, puedes hacer su <a href="/guias/prueba-de-escritorio">prueba de escritorio</a>.</p>'''
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li><b>Pasos ambiguos:</b> «calcula el total» sin decir de qué.</li>
  <li><b>Olvidar un caso:</b> dividir entre un número que puede ser cero.</li>
  <li><b>No terminar:</b> una repetición que nunca llega a su condición de salida.</li>
  <li><b>Mezclar el orden:</b> usar un dato antes de leerlo.</li>
</ul>'''
      ),
    ],
    preguntas: [
      (
        '¿Un algoritmo es lo mismo que un programa?',
        'No. El algoritmo es la idea: los pasos para resolver el problema. El programa es esa idea escrita en un lenguaje que una computadora entiende.'
      ),
      (
        '¿Necesito una computadora para hacer un algoritmo?',
        'No. Puedes escribirlo en papel, con frases o con un diagrama. La computadora hace falta cuando quieres ejecutarlo y ver el resultado.'
      ),
      (
        '¿Cuántos pasos debe tener un algoritmo?',
        'Los que hagan falta, pero siempre un número finito. Un buen algoritmo es tan corto como se pueda sin dejar pasos ambiguos.'
      ),
    ],
    relacionadas: ['que-es-el-pseudocodigo', 'como-hacer-un-diagrama-de-flujo'],
  ),
  Guia(
    slug: 'que-es-el-pseudocodigo',
    titulo: 'Qué es el pseudocódigo: reglas, palabras clave y ejemplos',
    h1: 'Qué es el pseudocódigo',
    descripcion:
        'El pseudocódigo describe un algoritmo con palabras parecidas a un lenguaje de programación, sin sintaxis estricta. Reglas, palabras clave y ejemplos que puedes copiar y ejecutar.',
    resumen:
        'El pseudocódigo es una forma de escribir un algoritmo con palabras parecidas a las de un lenguaje de programación, pero sin reglas estrictas de sintaxis. Sirve para pensar la solución antes de programar.',
    secciones: [
      (
        'para-que',
        'Para qué sirve',
        '''
<p>Programar directamente obliga a pensar en la solución y en las reglas del lenguaje al mismo tiempo. El pseudocódigo separa las dos cosas: primero decides <i>qué</i> hacer y después lo traduces a Python, C, Java o el lenguaje que uses.</p>
<p>No hay un pseudocódigo oficial; cada escuela usa pequeñas variaciones. Lo importante es que se lea con claridad y que cada paso sea preciso. En esta guía se usa el estilo que se enseña en las materias de lógica de programación, con palabras en español.</p>'''
      ),
      (
        'estructura',
        'La estructura de un programa',
        '''
<p>Un programa empieza con <code>Algoritmo</code> y un nombre, y termina con <code>FinAlgoritmo</code>. Entre los dos van las instrucciones, una por línea y de arriba hacia abajo. Las que están dentro de un <code>Si</code> o de un ciclo se escriben con sangría (unos espacios a la izquierda) para ver dónde empiezan y terminan.</p>
${codigo('''
Algoritmo saludo
    Escribir "¿Cómo te llamas?"
    Leer nombre
    Escribir "Hola, ", nombre
FinAlgoritmo
''', entradas: ['Ana'], salida: '¿Cómo te llamas?\nHola, Ana')}
<p><code>Escribir</code> muestra algo en pantalla. <code>Leer</code> pide un dato y lo guarda en una <b>variable</b>: una caja con nombre donde se guarda un valor.</p>'''
      ),
      (
        'palabras',
        'Las palabras que más se usan',
        '''
${tabla('Instrucciones básicas', ['Palabra', 'Para qué sirve', 'Ejemplo'], [
          ['<code>Leer</code>', 'Pedir un dato y guardarlo', '<code>Leer edad</code>'],
          ['<code>Escribir</code>', 'Mostrar un texto o un valor', '<code>Escribir "Hola"</code>'],
          ['<code>&lt;-</code>', 'Guardar un valor en una variable', '<code>total &lt;- precio * 2</code>'],
          ['<code>Si … Entonces … SiNo … FinSi</code>', 'Tomar una decisión', '<code>Si edad &gt;= 18 Entonces</code>'],
          ['<code>Mientras … FinMientras</code>', 'Repetir mientras algo sea cierto', '<code>Mientras n &gt; 0 Hacer</code>'],
          ['<code>Para … FinPara</code>', 'Repetir un número conocido de veces', '<code>Para i &lt;- 1 Hasta 10</code>'],
          ['<code>Repetir … Hasta Que</code>', 'Repetir al menos una vez', '<code>Hasta Que clave = "jaguar"</code>'],
          ['<code>Segun … FinSegun</code>', 'Elegir entre varias opciones', '<code>Segun dia Hacer</code>'],
        ])}'''
      ),
      (
        'decisiones',
        'Ejemplo: tomar una decisión',
        '''
<p>Este programa lee una calificación y dice si se aprobó. La flecha <code>&lt;-</code> guarda un valor; el <code>Si</code> compara.</p>
${codigo('''
Algoritmo aprobado
    Leer calificacion
    Si calificacion >= 6 Entonces
        Escribir "Aprobado"
    SiNo
        Escribir "Reprobado"
    FinSi
FinAlgoritmo
''', entradas: ['8'], salida: 'Aprobado')}'''
      ),
      (
        'ciclos',
        'Ejemplo: repetir pasos',
        '''
<p>Cuando sabes cuántas veces repetir algo se usa <code>Para</code>. Este programa muestra la tabla del 5:</p>
${codigo('''
Algoritmo tabla_del_5
    Para i <- 1 Hasta 5 Hacer
        Escribir "5 x ", i, " = ", 5 * i
    FinPara
FinAlgoritmo
''', salida: '5 x 1 = 5\n5 x 2 = 10\n5 x 3 = 15\n5 x 4 = 20\n5 x 5 = 25')}
<p>Y cuando no sabes cuántas veces, se usa <code>Mientras</code>: este suma números hasta que escribas 0.</p>
${codigo('''
Algoritmo suma_hasta_cero
    suma <- 0
    Leer n
    Mientras n <> 0 Hacer
        suma <- suma + n
        Leer n
    FinMientras
    Escribir "Total: ", suma
FinAlgoritmo
''', entradas: ['3', '4', '0'], salida: 'Total: 7')}'''
      ),
      (
        'tipos',
        'Variables y tipos de datos',
        '''
<p>Una variable guarda un dato, y cada dato tiene un tipo: un <b>entero</b> (7), un <b>real</b> (3.5), un <b>texto</b> ("hola") o un <b>lógico</b> (verdadero o falso). Para unir un texto con un valor se usa <code>+</code> o una coma dentro de <code>Escribir</code>.</p>
${codigo('''
Algoritmo precio
    Leer precio
    total <- precio * 1.16
    Escribir "Total con IVA: " + total
FinAlgoritmo
''', entradas: ['100'], salida: 'Total con IVA: 116')}'''
      ),
      (
        'a-codigo',
        'Del pseudocódigo a otros lenguajes',
        '''
<p>Una vez que el algoritmo funciona, traducirlo es casi mecánico. Por ejemplo, la decisión de las calificaciones en Python:</p>
<pre class="codigo" tabindex="0"><code>calificacion = float(input())
if calificacion &gt;= 6:
    print("Aprobado")
else:
    print("Reprobado")</code></pre>
<p>Cambian las palabras (<code>Si</code> por <code>if</code>, <code>Escribir</code> por <code>print</code>), pero la idea es la misma. Por eso conviene dominar primero la lógica.</p>'''
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li><b>Olvidar el cierre:</b> cada <code>Si</code> necesita su <code>FinSi</code>, y cada <code>Mientras</code> su <code>FinMientras</code>.</li>
  <li><b>Usar una variable sin darle valor:</b> hay que leerla o asignarla antes.</li>
  <li><b>Confundir <code>=</code> con <code>&lt;-</code>:</b> la flecha guarda un valor; el igual compara.</li>
  <li><b>Un ciclo que no termina:</b> si dentro del <code>Mientras</code> nada cambia la condición, se repite para siempre.</li>
</ul>'''
      ),
    ],
    preguntas: [
      (
        '¿Existe un pseudocódigo oficial?',
        'No. No hay un estándar: cada libro y cada escuela usa su estilo. Si lo escribes con claridad y con pasos precisos, cualquiera lo puede seguir.'
      ),
      (
        '¿El pseudocódigo se puede ejecutar?',
        'Escrito en papel, no. Pero con un programa que lo entienda, como Jaguar, lo ejecutas y ves el resultado, y también puedes ver su diagrama de flujo.'
      ),
      (
        '¿Es mejor empezar por pseudocódigo o por Python?',
        'Depende de quién lo enseñe, pero empezar por pseudocódigo permite concentrarte en la lógica sin pelear con la sintaxis. Después el paso a Python, C o Java es más corto.'
      ),
    ],
    relacionadas: ['que-es-un-algoritmo', 'prueba-de-escritorio'],
  ),
  Guia(
    slug: 'como-hacer-un-diagrama-de-flujo',
    titulo: 'Cómo hacer un diagrama de flujo paso a paso (símbolos y ejemplo)',
    h1: 'Cómo hacer un diagrama de flujo',
    descripcion:
        'Aprende a hacer un diagrama de flujo: los símbolos que se usan, los pasos para dibujarlo, un ejemplo completo con su pseudocódigo y los errores más comunes.',
    resumen:
        'Un diagrama de flujo representa un algoritmo con figuras unidas por flechas. Para hacerlo: marca el inicio, dibuja cada paso con su figura, usa un rombo en cada decisión y cierra con el fin.',
    secciones: [
      (
        'simbolos',
        'Los símbolos principales',
        '''
${tabla('Figuras del diagrama de flujo', ['Figura', 'Nombre', 'Se usa para'], [
          ['<svg viewBox="0 0 56 30" width="56" height="30" role="img" aria-label="Óvalo"><rect class="f" x="3" y="4" width="50" height="22" rx="11"/></svg>', 'Óvalo', 'Inicio y fin'],
          ['<svg viewBox="0 0 56 30" width="56" height="30" role="img" aria-label="Paralelogramo"><path class="f" d="M12 4h42l-10 22H2z"/></svg>', 'Paralelogramo', 'Entrada y salida de datos (Leer, Escribir)'],
          ['<svg viewBox="0 0 56 30" width="56" height="30" role="img" aria-label="Rectángulo"><rect class="f" x="4" y="4" width="48" height="22" rx="2"/></svg>', 'Rectángulo', 'Proceso: cálculos y asignaciones'],
          ['<svg viewBox="0 0 56 30" width="56" height="30" role="img" aria-label="Rombo"><path class="f" d="M28 2l25 13-25 13L3 15z"/></svg>', 'Rombo', 'Decisión: una pregunta con dos salidas, Sí y No'],
          ['<svg viewBox="0 0 56 30" width="56" height="30" role="img" aria-label="Flecha"><path class="l" d="M4 15h42M40 9l8 6-8 6"/></svg>', 'Flecha', 'Indica el orden en que se sigue el diagrama'],
        ])}
<p>Los libros de cada materia pueden usar variaciones (por ejemplo, otra figura para repetir), pero estas cinco bastan para casi todos los ejercicios de un primer curso.</p>'''
      ),
      (
        'pasos',
        'Cómo dibujarlo, paso a paso',
        '''
<ol>
  <li><b>Entiende el problema.</b> Escríbelo con tus palabras y decide qué entra y qué debe salir.</li>
  <li><b>Piensa los pasos</b> en una lista corta, en el orden en que ocurren.</li>
  <li><b>Dibuja el inicio</b> con un óvalo.</li>
  <li><b>Agrega cada paso con su figura:</b> paralelogramo para leer y escribir, rectángulo para calcular.</li>
  <li><b>Usa un rombo cuando haya una decisión.</b> Escribe la pregunta dentro y rotula las dos salidas con Sí y No.</li>
  <li><b>Une todo con flechas,</b> de arriba hacia abajo, y junta las ramas cuando terminen.</li>
  <li><b>Cierra con un óvalo de fin</b> y revisa que todo camino llegue a él.</li>
</ol>'''
      ),
      (
        'ejemplo',
        'Ejemplo: promedio de dos calificaciones',
        '''
<p>El problema: leer dos calificaciones, calcular el promedio y decir si el alumno pasó (promedio de 6 o más).</p>
<figure class="diagrama">
  @@DIAGRAMA@@
  <figcaption>El diagrama del programa del promedio: lectura, cálculo, decisión y dos salidas.</figcaption>
</figure>
<p>El mismo algoritmo en pseudocódigo, figura por figura:</p>
${codigo('''
Algoritmo promedio
    Leer a, b
    p <- (a + b) / 2
    Si p >= 6 Entonces
        Escribir "Pasaste con ", p
    SiNo
        Escribir "Casi, sacaste ", p
    FinSi
FinAlgoritmo
''', entradas: ['7', '10'], salida: 'Pasaste con 8.5')}
<p>Fíjate que cada línea del programa tiene su figura: <code>Leer</code> es el paralelogramo de entrada, la asignación es el rectángulo, el <code>Si</code> es el rombo y cada <code>Escribir</code> es un paralelogramo de salida.</p>'''
      ),
      (
        'ciclos',
        'Cómo se dibuja una repetición',
        '''
<p>Un ciclo se dibuja con un rombo y una flecha que <b>regresa</b>: mientras la pregunta se cumple (Sí), el flujo vuelve a la parte de arriba; cuando no (No), sigue hacia adelante. Por eso el rombo de un ciclo tiene siempre una flecha que sube.</p>
${codigo('''
Algoritmo cuenta
    n <- 3
    Mientras n > 0 Hacer
        Escribir n
        n <- n - 1
    FinMientras
    Escribir "¡Despegue!"
FinAlgoritmo
''', salida: '3\n2\n1\n¡Despegue!')}'''
      ),
      (
        'reglas',
        'Reglas para que se entienda',
        '''
<ul>
  <li>Un solo inicio y, normalmente, un solo fin.</li>
  <li>El flujo va de arriba hacia abajo y de izquierda a derecha.</li>
  <li>Cada rombo tiene dos salidas rotuladas.</li>
  <li>Dentro de cada figura, texto corto: <code>Leer a, b</code> y no «aquí el programa le pide al usuario dos números».</li>
  <li>Evita que las flechas se crucen; si pasa, reacomoda las figuras.</li>
</ul>'''
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li>Un rombo con una sola salida, o con salidas sin rotular.</li>
  <li>Una figura sin flecha de salida (el diagrama «se queda colgado»).</li>
  <li>Usar un rectángulo para leer datos en lugar del paralelogramo.</li>
  <li>Olvidar la flecha que regresa en un ciclo, de modo que solo se ejecuta una vez.</li>
</ul>'''
      ),
    ],
    preguntas: [
      (
        '¿Qué programa uso para hacer un diagrama de flujo?',
        'Puedes dibujarlo a mano o con cualquier programa de dibujo. Con Jaguar lo armas con las figuras y la app escribe el pseudocódigo, o escribes el pseudocódigo y te muestra el diagrama.'
      ),
      (
        '¿Cuál es la diferencia entre un diagrama de flujo y el pseudocódigo?',
        'Dicen lo mismo con otra forma. El diagrama es visual y deja ver las decisiones y los ciclos de un vistazo; el pseudocódigo es texto y se acerca más a un programa real.'
      ),
      (
        '¿Todos los diagramas llevan las mismas figuras?',
        'Las más importantes son las mismas en casi todos lados: óvalo, paralelogramo, rectángulo, rombo y flechas. Algunas materias agregan figuras para ciclos o conectores; sigue las de tu profesor.'
      ),
    ],
    relacionadas: ['que-es-el-pseudocodigo', 'prueba-de-escritorio'],
  ),
  Guia(
    slug: 'prueba-de-escritorio',
    titulo: 'Prueba de escritorio: qué es y cómo hacerla paso a paso',
    h1: 'La prueba de escritorio',
    descripcion:
        'La prueba de escritorio sigue un algoritmo a mano, línea por línea, con una tabla de variables. Aprende cómo hacerla con ejemplos resueltos de un ciclo y de una decisión.',
    resumen:
        'La prueba de escritorio es seguir un algoritmo a mano, línea por línea, anotando en una tabla cuánto vale cada variable en cada paso. Sirve para encontrar errores sin ejecutar el programa.',
    secciones: [
      (
        'para-que',
        'Para qué sirve',
        '''
<p>Cuando un programa no da el resultado esperado, a veces no se ve por qué. La prueba de escritorio te obliga a hacer lo que hace la computadora: una instrucción a la vez, sin saltarte nada. Así descubres dónde un valor deja de ser el que pensabas.</p>
<p>También es una forma de comprobar tu algoritmo <i>antes</i> de escribirlo en un lenguaje, y es un ejercicio frecuente en las materias de lógica de programación.</p>'''
      ),
      (
        'como',
        'Cómo se hace',
        '''
<ol>
  <li><b>Elige datos de prueba.</b> Con respuestas que sepas de antemano, para poder comparar.</li>
  <li><b>Arma la tabla:</b> una columna por cada variable, una para la condición si hay decisiones y una para la salida.</li>
  <li><b>Ejecuta línea por línea,</b> de arriba hacia abajo, sin adelantarte.</li>
  <li><b>Anota cada cambio.</b> Cada vez que una variable cambia de valor, agrega una fila.</li>
  <li><b>Compara</b> la salida de la tabla con lo que esperabas.</li>
</ol>'''
      ),
      (
        'ejemplo-ciclo',
        'Ejemplo 1: un ciclo que suma',
        '''
<p>Este programa suma los números del 1 al 4:</p>
${codigo('''
Algoritmo suma
    suma <- 0
    Para i <- 1 Hasta 4 Hacer
        suma <- suma + i
    FinPara
    Escribir suma
FinAlgoritmo
''', salida: '10')}
<p>La prueba de escritorio, con una fila cada vez que algo cambia:</p>
${tabla('Prueba de escritorio de suma', ['Paso', 'i', 'suma', 'Salida'], [
          ['<code>suma &lt;- 0</code>', '—', '0', ''],
          ['Primera vuelta', '1', '1', ''],
          ['Segunda vuelta', '2', '3', ''],
          ['Tercera vuelta', '3', '6', ''],
          ['Cuarta vuelta', '4', '10', ''],
          ['<code>Escribir suma</code>', '—', '10', '<b>10</b>'],
        ])}
<p>La tabla confirma que el resultado es 10, y de paso muestra cómo va creciendo <code>suma</code>.</p>'''
      ),
      (
        'ejemplo-si',
        'Ejemplo 2: una decisión',
        '''
<p>Un programa que dice si un número es par o impar, usando <code>MOD</code> (el residuo de la división):</p>
${codigo('''
Algoritmo par_impar
    Leer n
    Si n MOD 2 = 0 Entonces
        Escribir "Par"
    SiNo
        Escribir "Impar"
    FinSi
FinAlgoritmo
''', entradas: ['7'], salida: 'Impar')}
${tabla('Con n = 7 y con n = 10', ['n', 'n MOD 2', '¿Es 0?', 'Salida'], [
          ['7', '1', 'No', '<b>Impar</b>'],
          ['10', '0', 'Sí', '<b>Par</b>'],
        ])}
<p>Aquí la tabla tiene una columna para la condición. Con dos datos distintos viste las dos ramas del <code>Si</code>.</p>'''
      ),
      (
        'datos',
        'Qué datos conviene probar',
        '''
<ul>
  <li>Un caso <b>normal</b>, del que sepas la respuesta.</li>
  <li>Los <b>límites</b>: si la regla es «6 o más», prueba 5, 6 y 7.</li>
  <li>El <b>cero</b> y, si aplica, los negativos.</li>
  <li>En un ciclo, que se repita <b>cero veces</b> y <b>una vez</b>.</li>
</ul>
<p>Muchos errores aparecen justo en los límites: en un <code>&gt;</code> que debía ser <code>&gt;=</code>.</p>'''
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li>Adelantarse y anotar el resultado final en lugar de seguir cada línea.</li>
  <li>Olvidar una variable en la tabla.</li>
  <li>Probar solo un dato, que por casualidad sale bien.</li>
  <li>No volver a revisar el algoritmo cuando la tabla no da lo esperado: el error está en la lógica, no en la tabla.</li>
</ul>'''
      ),
      (
        'jaguar',
        'La prueba de escritorio con Jaguar',
        '''
<p>En Jaguar puedes hacerla de dos formas: dejar que la app arme la tabla sola con los datos que le des, paso a paso, o llenarla tú y que la app te marque qué acertaste. Así practicas la técnica y verificas con la computadora.</p>'''
      ),
    ],
    preguntas: [
      (
        '¿Por qué se llama prueba de escritorio?',
        'Porque se hace «en el escritorio», con lápiz y papel, sin necesidad de una computadora: tú haces el papel de la máquina que ejecuta el programa.'
      ),
      (
        '¿La prueba de escritorio sirve con diagramas de flujo?',
        'Sí. Sigues las flechas del diagrama en lugar de las líneas del programa y anotas lo mismo: el valor de cada variable en cada paso.'
      ),
      (
        '¿Cuántos datos de prueba debo usar?',
        'Los que cubran todos los caminos del programa: al menos un dato por cada rama de cada decisión, y casos límite como el cero.'
      ),
    ],
    relacionadas: ['que-es-un-algoritmo', 'que-es-el-pseudocodigo'],
  ),
];

String cabeza({required String titulo, required String descripcion, required String ruta, String tipo = 'article', String extra = ''}) =>
    '''<!doctype html>
<html lang="es-MX">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(titulo)}</title>
<meta name="description" content="${esc(descripcion).replaceAll('"', '&quot;')}">
<link rel="canonical" href="$sitio$ruta">
<meta name="robots" content="index, follow, max-image-preview:large">
<meta name="theme-color" content="#3B2410">
<meta name="color-scheme" content="light dark">
<link rel="icon" type="image/png" sizes="48x48" href="/favicon.png">
<link rel="icon" type="image/svg+xml" href="/logo.svg">
<link rel="apple-touch-icon" href="/icono.png">
<meta property="og:type" content="$tipo">
<meta property="og:site_name" content="Jaguar Code">
<meta property="og:locale" content="es_MX">
<meta property="og:url" content="$sitio$ruta">
<meta property="og:title" content="${esc(titulo)}">
<meta property="og:description" content="${esc(descripcion).replaceAll('"', '&quot;')}">
<meta property="og:image" content="$sitio/compartir.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="${esc(titulo)}">
<meta name="twitter:description" content="${esc(descripcion).replaceAll('"', '&quot;')}">
<meta name="twitter:image" content="$sitio/compartir.png">
$extra
<script>document.documentElement.classList.add("js")</script>
<link rel="preload" href="/fuentes/nunito.woff2" as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="/estilos.css">
</head>
<body>
<header class="sitio-barra">
  <div class="ancho">
    <div class="barra-sup">
      <img src="/logo.svg" alt="" width="46" height="40">
      <a class="nombre" href="/">Jaguar Code</a>
      <a href="/guias">Guías</a>
      <a href="/profes">Para profes</a>
      <a href="https://github.com/panterino/jaguar">GitHub</a>
    </div>
  </div>
</header>
''';

const pie = '''
<footer>
  <div class="ancho">
    <span class="quien"><img src="/logo.svg" alt="" width="30" height="26">Un proyecto de Panterino · hecho en México</span>
    <a href="/guias">Guías</a>
    <a href="/manual">Manual</a>
    <a href="https://www.facebook.com/jaguareducation">Facebook</a>
    <a href="https://github.com/panterino/jaguar">Código en GitHub</a>
  </div>
</footer>
<script src="/acceso.js" defer></script>
</body>
</html>
''';

String cta() => '''
<aside class="cta-guia" aria-labelledby="cta-t">
  <h2 id="cta-t">Practica esto en Jaguar Code</h2>
  <p>Escribe pseudocódigo, mira su diagrama y haz la prueba de escritorio desde el celular. Gratis y sin anuncios. Deja tu correo y te damos entrada a la app.</p>
  <div class="acceso" data-origen="guia">
    <form novalidate>
      <div class="fila">
        <label class="campo-correo"><span class="oculto">Tu correo</span>
          <input type="email" name="correo" placeholder="Tu correo" autocomplete="email" inputmode="email" maxlength="200" required></label>
        <button class="boton principal" type="submit">Quiero entrar primero</button>
      </div>
      <label class="oculto" aria-hidden="true">No llenar <input name="sitio" tabindex="-1" autocomplete="off"></label>
      <p class="estado" role="status" aria-live="polite"></p>
      <p class="letra-chica">Solo lo usamos para darte entrada a la app y avisarte de novedades. Sin spam. <a href="https://app.jaguarcode.org/privacidad">Aviso de privacidad</a>.</p>
    </form>
    <div class="dentro" hidden>
      <h3>¡Listo, ya estás dentro!</h3>
      <p>Ya puedes abrir la app. Te escribiremos cuando haya novedades.</p>
      <div class="botones"><a class="boton principal" href="https://app.jaguarcode.org/">Entrar a la app</a></div>
    </div>
  </div>
</aside>''';

String json(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', ' ');

String pagina(Guia g) {
  final ruta = '/guias/${g.slug}';
  final faq = g.preguntas
      .map((p) => '{"@type":"Question","name":"${json(p.$1)}","acceptedAnswer":{"@type":"Answer","text":"${json(p.$2)}"}}')
      .join(',');
  final datos = '''
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Article",
      "@id": "$sitio$ruta#articulo",
      "headline": "${json(g.titulo)}",
      "description": "${json(g.descripcion)}",
      "inLanguage": "es-MX",
      "datePublished": "$fecha",
      "dateModified": "$fecha",
      "mainEntityOfPage": "$sitio$ruta",
      "image": "$sitio/compartir.png",
      "author": { "@type": "Organization", "name": "Panterino", "url": "$sitio/" },
      "publisher": { "@type": "Organization", "name": "Panterino", "logo": { "@type": "ImageObject", "url": "$sitio/icono.png" } }
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "$sitio/" },
        { "@type": "ListItem", "position": 2, "name": "Guías", "item": "$sitio/guias" },
        { "@type": "ListItem", "position": 3, "name": "${json(g.h1)}", "item": "$sitio$ruta" }
      ]
    },
    { "@type": "FAQPage", "mainEntity": [$faq] }
  ]
}
</script>''';
  final b = StringBuffer(cabeza(titulo: g.titulo, descripcion: g.descripcion, ruta: ruta, extra: datos));
  b.write('''
<main class="guia">
  <div class="ancho angosto">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › <a href="/guias">Guías</a> › ${esc(g.h1)}</nav>
    <h1>${esc(g.h1)}</h1>
    <p class="resumen">${esc(g.resumen)}</p>
    <nav class="contenido" aria-label="Contenido de la guía"><b>En esta guía</b>
      <ol>
''');
  for (final s in g.secciones) {
    b.writeln('        <li><a href="#${s.$1}">${esc(s.$2)}</a></li>');
  }
  b.writeln('        <li><a href="#preguntas">Preguntas frecuentes</a></li>\n      </ol>\n    </nav>\n    <article>');
  for (final s in g.secciones) {
    b.writeln('      <section id="${s.$1}">\n        <h2>${esc(s.$2)}</h2>\n${s.$3.replaceAll('@@DIAGRAMA@@', diagramaPromedio)}\n      </section>');
  }
  b.writeln('      <section id="preguntas">\n        <h2>Preguntas frecuentes</h2>');
  for (final p in g.preguntas) {
    b.writeln('        <details><summary>${esc(p.$1)}</summary><p>${esc(p.$2)}</p></details>');
  }
  b.writeln('      </section>\n    </article>');
  b.writeln(cta());
  b.writeln('    <h2 style="margin-top:44px">Sigue aprendiendo</h2>\n    <div class="relacionadas">');
  for (final r in g.relacionadas) {
    final o = guias.firstWhere((x) => x.slug == r);
    b.writeln('      <a href="/guias/${o.slug}">${esc(o.h1)}<small>${esc(o.resumen.split('. ').first)}.</small></a>');
  }
  b.writeln('    </div>\n  </div>\n</main>');
  b.write(pie);
  return b.toString();
}

String indice() {
  const titulo = 'Guías para aprender a programar desde cero | Jaguar Code';
  const desc =
      'Guías cortas y con ejemplos para aprender lógica de programación: qué es un algoritmo, el pseudocódigo, los diagramas de flujo y la prueba de escritorio.';
  final lista = guias
      .map((g) => '{"@type":"ListItem","position":${guias.indexOf(g) + 1},"url":"$sitio/guias/${g.slug}","name":"${json(g.h1)}"}')
      .join(',');
  final datos = '''
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "CollectionPage", "name": "${json(titulo)}", "url": "$sitio/guias", "inLanguage": "es-MX" },
    { "@type": "ItemList", "itemListElement": [$lista] },
    { "@type": "BreadcrumbList", "itemListElement": [
      { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "$sitio/" },
      { "@type": "ListItem", "position": 2, "name": "Guías", "item": "$sitio/guias" }
    ] }
  ]
}
</script>''';
  final b = StringBuffer(cabeza(titulo: titulo, descripcion: desc, ruta: '/guias', tipo: 'website', extra: datos));
  b.write('''
<main class="guia">
  <div class="ancho">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › Guías</nav>
    <h1>Guías para aprender a programar desde cero</h1>
    <p class="resumen">Cuatro guías cortas, con ejemplos que puedes copiar y ejecutar en Jaguar. Empieza por la primera y sigue en orden, o salta a lo que necesites.</p>
    <div class="tarjetas">
''');
  var i = 0;
  for (final g in guias) {
    b.writeln('      <article class="tarjeta revela" style="--d:${i++ % 3}"><h2 style="font-size:20px;margin:0 0 8px"><a href="/guias/${g.slug}">${esc(g.h1)}</a></h2><p>${esc(g.resumen)}</p></article>');
  }
  b.writeln('    </div>');
  b.writeln(cta());
  b.writeln('  </div>\n</main>');
  b.write(pie);
  return b.toString();
}

void main() {
  final inicio = File('sitio/index.html').readAsStringSync();
  diagramaPromedio = RegExp(r'<svg viewBox="0 0 320 380".*?</svg>', dotAll: true).firstMatch(inicio)!.group(0)!;
  final carpeta = Directory('sitio/guias')..createSync(recursive: true);
  File('${carpeta.path}/index.html').writeAsStringSync(indice());
  for (final g in guias) {
    File('${carpeta.path}/${g.slug}.html').writeAsStringSync(pagina(g));
  }
  stdout.writeln('Listo: ${guias.length + 1} páginas en sitio/guias');
}
