// Genera las guías de la página (sitio/guias/*.html) con el mismo encabezado,
// datos estructurados y cierre. Correr desde la raíz:
//   dart run tool/guias_html.dart
// Los ejemplos de código llevan data-entradas y data-salida: una prueba
// (apps/jaguar/test/guias_test.dart) los ejecuta con el intérprete de Jaguar.
import 'dart:io';

const sitio = 'https://jaguarcode.org';
const fecha = '2026-10-27';

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
    this.publicada = fecha,
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

  /// Fecha de publicación (AAAA-MM-DD), para los datos estructurados y el mapa del sitio.
  final String publicada;
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
<p>Si cambias el orden (verter el agua antes de hervirla) el resultado ya no es el mismo. Esa es la primera idea: <b>el orden de los pasos importa</b>.</p>''',
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
<p>Antes de escribir un programa conviene responder estas tres preguntas. En la escuela se le llama <i>planteamiento</i> del problema.</p>''',
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
</ul>''',
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
<p>Con base 4 y altura 3 muestra <code>Área: 12</code>. Cambia los datos y el mismo algoritmo da otro resultado.</p>''',
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
<p>Son formas distintas de contar lo mismo. Para comprobar que un algoritmo funciona, puedes hacer su <a href="/guias/prueba-de-escritorio">prueba de escritorio</a>.</p>''',
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
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Un algoritmo es lo mismo que un programa?',
        'No. El algoritmo es la idea: los pasos para resolver el problema. El programa es esa idea escrita en un lenguaje que una computadora entiende.',
      ),
      (
        '¿Necesito una computadora para hacer un algoritmo?',
        'No. Puedes escribirlo en papel, con frases o con un diagrama. La computadora hace falta cuando quieres ejecutarlo y ver el resultado.',
      ),
      (
        '¿Cuántos pasos debe tener un algoritmo?',
        'Los que hagan falta, pero siempre un número finito. Un buen algoritmo es tan corto como se pueda sin dejar pasos ambiguos.',
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
<p>No hay un pseudocódigo oficial; cada escuela usa pequeñas variaciones. Lo importante es que se lea con claridad y que cada paso sea preciso. En esta guía se usa el estilo que se enseña en las materias de lógica de programación, con palabras en español.</p>''',
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
<p><code>Escribir</code> muestra algo en pantalla. <code>Leer</code> pide un dato y lo guarda en una <b>variable</b>: una caja con nombre donde se guarda un valor.</p>''',
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
        ])}''',
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
''', entradas: ['8'], salida: 'Aprobado')}
<p>Las decisiones tienen su propia guía, con <code>SiNo</code>, <code>Si</code> anidados y <code>Segun</code>: <a href="/guias/condicionales-si-y-segun">condicionales en pseudocódigo</a>.</p>''',
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
''', entradas: ['3', '4', '0'], salida: 'Total: 7')}
<p>Las diferencias entre <code>Para</code>, <code>Mientras</code> y <code>Repetir</code>, con contadores y acumuladores, están en la guía de <a href="/guias/ciclos-mientras-para-repetir">ciclos</a>.</p>''',
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
''', entradas: ['100'], salida: 'Total con IVA: 116')}
<p>Los operadores, la prioridad de las operaciones y las funciones como <code>Raiz</code> o <code>Redon</code> están en la guía de <a href="/guias/variables-y-tipos-de-datos">variables y tipos de datos</a>.</p>''',
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
<p>Cambian las palabras (<code>Si</code> por <code>if</code>, <code>Escribir</code> por <code>print</code>), pero la idea es la misma. Por eso conviene dominar primero la lógica. Hay una guía completa para <a href="/guias/de-pseudocodigo-a-python">pasar de pseudocódigo a Python</a>.</p>''',
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
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Existe un pseudocódigo oficial?',
        'No. No hay un estándar: cada libro y cada escuela usa su estilo. Si lo escribes con claridad y con pasos precisos, cualquiera lo puede seguir.',
      ),
      (
        '¿El pseudocódigo se puede ejecutar?',
        'Escrito en papel, no. Pero con un programa que lo entienda, como Jaguar, lo ejecutas y ves el resultado, y también puedes ver su diagrama de flujo.',
      ),
      (
        '¿Es mejor empezar por pseudocódigo o por Python?',
        'Depende de quién lo enseñe, pero empezar por pseudocódigo permite concentrarte en la lógica sin pelear con la sintaxis. Después el paso a Python, C o Java es más corto.',
      ),
    ],
    relacionadas: ['que-es-un-algoritmo', 'variables-y-tipos-de-datos', 'prueba-de-escritorio'],
  ),
  Guia(
    slug: 'variables-y-tipos-de-datos',
    titulo: 'Variables, tipos de datos y operadores en pseudocódigo (con ejemplos)',
    h1: 'Variables, tipos de datos y operadores',
    descripcion:
        'Qué es una variable, cómo se asigna un valor, los tipos de datos (entero, real, texto y lógico) y los operadores en pseudocódigo, con ejemplos que puedes ejecutar.',
    resumen:
        'Una variable es un espacio con nombre donde el programa guarda un dato. Cada dato tiene un tipo, como entero, real, texto o lógico, y los operadores sirven para calcular y comparar con esos datos.',
    publicada: '2026-11-03',
    secciones: [
      (
        'variable',
        'Qué es una variable',
        '''
<p>Imagina una caja con una etiqueta. La etiqueta es el <b>nombre</b> de la variable y lo que hay dentro es su <b>valor</b>. El programa puede ver qué hay en la caja, cambiarlo o usarlo para calcular otra cosa.</p>
${codigo('''
Algoritmo area
    base <- 5
    altura <- 3
    area <- base * altura
    Escribir "El área es ", area
FinAlgoritmo
''', salida: 'El área es 15')}
<p>Aquí hay tres variables: <code>base</code>, <code>altura</code> y <code>area</code>. La flecha <code>&lt;-</code> se lee «guarda»: «guarda 5 en base». Una variable guarda un solo valor a la vez. Si le asignas otro, el anterior se pierde.</p>
<p>Los nombres pueden llevar letras, números y guion bajo, pero deben empezar con una letra y no llevar espacios: <code>precio_total</code> sí, <code>precio total</code> no. Conviene que digan qué guardan: <code>edad</code> se entiende mejor que <code>x</code>.</p>''',
      ),
      (
        'asignar-y-leer',
        'Dar valor a una variable: asignar y leer',
        '''
<p>Una variable recibe valor de dos formas. Con <code>&lt;-</code>, el programa lo calcula o lo pone. Con <code>Leer</code>, se lo pide a quien usa el programa.</p>
${codigo('''
Algoritmo doble
    Escribir "Escribe un número:"
    Leer n
    doble <- n * 2
    Escribir "El doble es ", doble
FinAlgoritmo
''', entradas: ['21'], salida: 'Escribe un número:\nEl doble es 42')}
<p>Una asignación también puede usar el valor viejo de la misma variable. <code>contador &lt;- contador + 1</code> significa: toma lo que vale <code>contador</code>, súmale 1 y guarda el resultado otra vez en <code>contador</code>. En matemáticas eso no tiene sentido, pero en programación es de lo más común.</p>''',
      ),
      (
        'tipos',
        'Tipos de datos',
        '''
${tabla('Los tipos de datos del pseudocódigo', ['Tipo', 'Qué guarda', 'Ejemplos'], [
          ['<b>Entero</b>', 'Números sin decimales', '<code>7</code>, <code>-3</code>, <code>2026</code>'],
          ['<b>Real</b>', 'Números con decimales', '<code>3.5</code>, <code>0.16</code>, <code>-2.75</code>'],
          ['<b>Caracter</b> (o Texto)', 'Letras, palabras, frases', '<code>"Ana"</code>, <code>"A"</code>, <code>"5 de mayo"</code>'],
          ['<b>Lógico</b>', 'Verdadero o falso', '<code>Verdadero</code>, <code>Falso</code>'],
        ])}
<p>Con <code>Definir</code> dices de qué tipo será una variable antes de usarla. En el pseudocódigo flexible que usan la mayoría de las escuelas no es obligatorio, pero ayuda: si defines una variable como <code>Entero</code> e intentas guardar un número con decimales, Jaguar te avisa.</p>
${codigo('''
Algoritmo con_tipos
    Definir nombre Como Caracter
    Definir edad Como Entero
    Definir estatura Como Real
    nombre <- "Luis"
    edad <- 16
    estatura <- 1.72
    Escribir nombre, " tiene ", edad, " años y mide ", estatura
FinAlgoritmo
''', salida: 'Luis tiene 16 años y mide 1.72')}
<p>Los textos siempre van entre comillas. <code>"7"</code> es un texto (el carácter siete) y <code>7</code> es un número. La diferencia importa: <code>"7" + "3"</code> da <code>"73"</code>, y <code>7 + 3</code> da <code>10</code>.</p>''',
      ),
      (
        'aritmeticos',
        'Operadores aritméticos',
        '''
${tabla('Operadores para calcular', ['Operador', 'Qué hace', 'Ejemplo', 'Resultado'], [
          ['<code>+</code>', 'Suma', '<code>7 + 3</code>', '10'],
          ['<code>-</code>', 'Resta', '<code>7 - 3</code>', '4'],
          ['<code>*</code>', 'Multiplicación', '<code>7 * 3</code>', '21'],
          ['<code>/</code>', 'División', '<code>10 / 4</code>', '2.5'],
          ['<code>MOD</code>', 'Residuo de la división', '<code>10 MOD 4</code>', '2'],
          ['<code>^</code>', 'Potencia', '<code>2 ^ 10</code>', '1024'],
        ])}
<p><code>MOD</code> merece atención porque aparece en muchos ejercicios. Da lo que sobra de una división: 10 entre 4 es 2 y sobran 2. Sirve para saber si un número es par (<code>n MOD 2 = 0</code>), si es múltiplo de otro o para separar los dígitos de un número.</p>
<p>Como en matemáticas, primero se calculan las potencias, luego multiplicaciones y divisiones, y al final sumas y restas. Los paréntesis cambian ese orden:</p>
${codigo('''
Algoritmo prioridad
    Escribir 2 + 3 * 4
    Escribir (2 + 3) * 4
    promedio <- (8 + 9 + 10) / 3
    Escribir "Promedio: ", promedio
FinAlgoritmo
''', salida: '14\n20\nPromedio: 9')}
<p>Un error clásico es escribir <code>8 + 9 + 10 / 3</code> para un promedio: sin paréntesis solo se divide el 10.</p>''',
      ),
      (
        'comparacion-y-logicos',
        'Operadores de comparación y lógicos',
        '''
<p>Comparar dos valores da un resultado lógico: verdadero o falso. Es lo que usan las decisiones (<code>Si</code>) y los ciclos (<code>Mientras</code>).</p>
${tabla('Comparación', ['Operador', 'Significa', 'Ejemplo verdadero'], [
          ['<code>=</code>', 'Igual a', '<code>5 = 5</code>'],
          ['<code>&lt;&gt;</code>', 'Distinto de', '<code>5 &lt;&gt; 3</code>'],
          ['<code>&lt;</code> / <code>&gt;</code>', 'Menor que / mayor que', '<code>3 &lt; 5</code>'],
          ['<code>&lt;=</code> / <code>&gt;=</code>', 'Menor o igual / mayor o igual', '<code>5 &gt;= 5</code>'],
        ])}
<p>Para combinar comparaciones están <code>Y</code>, <code>O</code> y <code>NO</code>. Con <code>Y</code>, las dos partes deben cumplirse. Con <code>O</code>, basta una. <code>NO</code> invierte el resultado.</p>
${codigo('''
Algoritmo rango
    Leer calificacion
    valida <- calificacion >= 0 Y calificacion <= 10
    Escribir "¿Es válida? ", valida
FinAlgoritmo
''', entradas: ['12'], salida: '¿Es válida? FALSO')}
<p>Las decisiones con estos operadores están explicadas a fondo en la guía de <a href="/guias/condicionales-si-y-segun">condicionales</a>.</p>''',
      ),
      (
        'funciones',
        'Funciones útiles',
        '''
<p>El pseudocódigo trae funciones listas para cálculos comunes. Se escribe el nombre y, entre paréntesis, el dato:</p>
${tabla('Funciones de uso frecuente', ['Función', 'Qué hace', 'Ejemplo', 'Resultado'], [
          ['<code>Raiz(x)</code>', 'Raíz cuadrada', '<code>Raiz(81)</code>', '9'],
          ['<code>Abs(x)</code>', 'Valor absoluto', '<code>Abs(-4)</code>', '4'],
          ['<code>Redon(x)</code>', 'Redondea al entero más cercano', '<code>Redon(3.6)</code>', '4'],
          ['<code>Trunc(x)</code>', 'Quita los decimales', '<code>Trunc(3.6)</code>', '3'],
          ['<code>Azar(n)</code>', 'Número al azar de 0 a n-1', '<code>Azar(6) + 1</code>', 'Un dado: de 1 a 6'],
          ['<code>Longitud(t)</code>', 'Cuántos caracteres tiene un texto', '<code>Longitud("jaguar")</code>', '6'],
          ['<code>Mayusculas(t)</code>', 'Pasa un texto a mayúsculas', '<code>Mayusculas("hola")</code>', 'HOLA'],
          ['<code>Subcadena(t, i, f)</code>', 'Parte de un texto, de la posición i a la f', '<code>Subcadena("jaguar", 1, 3)</code>', 'jag'],
        ])}${codigo('''
Algoritmo hipotenusa
    Leer a, b
    c <- Raiz(a ^ 2 + b ^ 2)
    Escribir "La hipotenusa mide ", c
FinAlgoritmo
''', entradas: ['3', '4'], salida: 'La hipotenusa mide 5')}''',
      ),
      (
        'intercambiar',
        'Ejemplo: intercambiar dos variables',
        '''
<p>Un ejercicio que aparece en casi todos los cursos: intercambiar los valores de <code>a</code> y <code>b</code>. Si escribes <code>a &lt;- b</code> y luego <code>b &lt;- a</code>, pierdes el valor original de <code>a</code>. La solución es una variable auxiliar que lo guarde mientras tanto:</p>
${codigo('''
Algoritmo intercambiar
    a <- 3
    b <- 8
    aux <- a
    a <- b
    b <- aux
    Escribir "a = ", a, ", b = ", b
FinAlgoritmo
''', salida: 'a = 8, b = 3')}
<p>En la prueba de escritorio se ve cómo <code>aux</code> rescata el 3 antes de que se pierda. Las celdas resaltadas son las que acaban de cambiar:</p>
<div class="tabla"><table><caption>Prueba de escritorio de intercambiar</caption><thead><tr><th scope="col">Paso</th><th scope="col">Línea</th><th scope="col">Instrucción</th><th scope="col">a</th><th scope="col">b</th><th scope="col">aux</th><th scope="col">Pantalla</th></tr></thead><tbody><tr><td>1</td><td>3</td><td class="instr">a &lt;- 3</td><td class="cambio">3</td><td></td><td></td><td></td></tr><tr><td>2</td><td>4</td><td class="instr">b &lt;- 8</td><td>3</td><td class="cambio">8</td><td></td><td></td></tr><tr><td>3</td><td>5</td><td class="instr">aux &lt;- a</td><td>3</td><td>8</td><td class="cambio">3</td><td></td></tr><tr><td>4</td><td>6</td><td class="instr">a &lt;- b</td><td class="cambio">8</td><td>8</td><td>3</td><td></td></tr><tr><td>5</td><td>7</td><td class="instr">b &lt;- aux</td><td>8</td><td class="cambio">3</td><td>3</td><td></td></tr><tr><td>6</td><td>8</td><td class="instr">Escribir "a = ", a, ", b = ", b</td><td>8</td><td>3</td><td>3</td><td>a = 8, b = 3</td></tr></tbody></table></div>''',
      ),
      (
        'errores',
        'Errores comunes',
        '''
<p>Estos son los errores con variables que más se repiten, con el mensaje que da Jaguar en cada caso:</p>
<ul>
  <li><b>Usar una variable que no tiene valor.</b> Si escribes <code>p &lt;- (a + b) / 2</code> y nunca leíste <code>b</code>, Jaguar dice: «No encuentro la variable 'b'». Si hay una parecida, sugiere: «¿Quisiste decir 'a'?».</li>
  <li><b>Guardar decimales en un Entero.</b> Con <code>Definir e Como Entero</code> y luego <code>e &lt;- 5 / 2</code>, el mensaje es: «No se puede guardar el número 2.5 en 'e' porque es de tipo Entero», con la sugerencia de usar <code>Trunc()</code> o <code>Redon()</code>.</li>
  <li><b>Confundir <code>=</code> con <code>&lt;-</code>.</b> La flecha guarda; el igual compara. Algunas escuelas aceptan <code>=</code> para asignar, pero usar la flecha evita confusiones.</li>
  <li><b>Olvidar las comillas.</b> <code>Escribir Hola</code> busca una variable llamada Hola. Lo que quieres es <code>Escribir "Hola"</code>.</li>
  <li><b>Escribir el nombre de dos formas.</b> <code>Promedio</code> y <code>promedio</code> son la misma variable en PSeInt y en Jaguar, pero <code>promedio</code> y <code>promedo</code> no.</li>
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Qué es una variable en pseudocódigo?',
        'Es un espacio con nombre donde el programa guarda un dato, como un número o un texto. Su valor puede cambiar mientras el programa se ejecuta, por eso se llama variable.',
      ),
      (
        '¿Qué diferencia hay entre una variable y una constante?',
        'Una variable puede cambiar de valor durante el programa. Una constante es un valor que no cambia, como PI o el porcentaje del IVA. En pseudocódigo, una constante suele ser una variable a la que le das valor una sola vez al inicio.',
      ),
      (
        '¿Es obligatorio usar Definir?',
        'En el pseudocódigo flexible de PSeInt, que es el que usan la mayoría de las escuelas, no. Pero si tu profe pide el perfil estricto, sí hay que definir cada variable. Definirla siempre es una buena costumbre.',
      ),
      (
        '¿Para qué sirve MOD?',
        'Da el residuo de una división entera. Por ejemplo, 17 MOD 5 es 2, porque 17 entre 5 es 3 y sobran 2. Se usa para saber si un número es par, si es múltiplo de otro o para separar dígitos.',
      ),
    ],
    relacionadas: ['que-es-el-pseudocodigo', 'condicionales-si-y-segun', 'prueba-de-escritorio'],
  ),
  Guia(
    slug: 'condicionales-si-y-segun',
    titulo: 'Condicionales en pseudocódigo: Si, SiNo y Segun con ejemplos',
    h1: 'Condicionales en pseudocódigo: Si y Segun',
    descripcion:
        'Cómo tomar decisiones en pseudocódigo con Si, SiNo, Si anidados y Segun. Ejemplos ejecutables, su diagrama de flujo, condiciones con Y y O, y los errores más comunes.',
    resumen:
        'Una condicional hace que el programa elija qué hacer según un dato. Con Si … Entonces … SiNo eliges entre dos caminos, y con Segun eliges entre varias opciones de una misma variable.',
    publicada: '2026-11-03',
    secciones: [
      (
        'que-es',
        'Qué es una condicional',
        '''
<p>Hasta ahora, un programa hace todos sus pasos, uno tras otro. Pero muchas veces la respuesta depende de un dato: si llueve, llevas paraguas; si no, no. Una <b>condicional</b> (también llamada estructura de decisión o selectiva) hace justo eso: revisa una condición y, según el resultado, sigue un camino u otro.</p>
<p>La condición siempre es una pregunta que se responde con verdadero o falso, como <code>edad &gt;= 18</code> o <code>respuesta = "si"</code>. Los operadores de comparación están en la guía de <a href="/guias/variables-y-tipos-de-datos">variables y operadores</a>.</p>''',
      ),
      (
        'si-simple',
        'Si simple: hacer algo solo cuando se cumple',
        '''
<p>Lo que está entre <code>Si … Entonces</code> y <code>FinSi</code> solo se ejecuta cuando la condición es verdadera. Si es falsa, el programa se lo salta y sigue después del <code>FinSi</code>. En este ejemplo, una compra de más de 500 pesos tiene 10 % de descuento:</p>
${codigo('''
Algoritmo descuento
    Leer total
    Si total > 500 Entonces
        total <- total * 0.9
    FinSi
    Escribir "A pagar: ", total
FinAlgoritmo
''', entradas: ['800'], salida: 'A pagar: 720')}
<p>Con 800 se cumple la condición y se aplica el descuento. Con 300 no se cumple: el programa salta directo al <code>Escribir</code> y muestra 300.</p>''',
      ),
      (
        'si-sino',
        'Si … SiNo: elegir entre dos caminos',
        '''
<p>Cuando hay algo que hacer en los dos casos, se agrega <code>SiNo</code>. Siempre se ejecuta exactamente uno de los dos bloques, nunca ambos:</p>
${codigo('''
Algoritmo par_o_impar
    Leer n
    Si n MOD 2 = 0 Entonces
        Escribir n, " es par"
    SiNo
        Escribir n, " es impar"
    FinSi
FinAlgoritmo
''', entradas: ['7'], salida: '7 es impar')}
<p>En el diagrama de flujo, la condición es un rombo con dos salidas: una para «Sí» y otra para «No». Las dos ramas se vuelven a juntar antes de seguir.</p>
<figure class="diagrama" style="max-width:563px;overflow-x:auto"><svg style="max-width:523px;min-width:418px" viewBox="0 0 522.4 365.6" width="520" role="img" aria-labelledby="diag-1"><title id="diag-1">Diagrama de flujo de Algoritmo par_o_impar</title><g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round"><path d="M268.8 56L268.8 84"/><path d="M268.8 124L268.8 152"/><path d="M184.4 180L133.4 180L133.4 224.8"/><path d="M353.2 180L396.6 180L396.6 224.8"/><path d="M133.4 264.8L133.4 281.6L268.8 281.6"/><path d="M396.6 264.8L396.6 281.6L268.8 281.6"/><path d="M268.8 281.6L268.8 309.6"/></g><path d="M268.8 84L264.8 76L272.8 76z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M268.8 152L264.8 144L272.8 144z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M133.4 224.8L129.4 216.8L137.4 216.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M396.6 224.8L392.6 216.8L400.6 216.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M268.8 309.6L264.8 301.6L272.8 301.6z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><rect class="ini fig" x="223.8" y="16" width="90" height="40" rx="20"/><text x="268.8" y="40.5" text-anchor="middle">Inicio</text><path class="io fig" d="M230 84 H321.6 L307.6 124 H216 z"/><text x="268.8" y="108.5" text-anchor="middle">Leer n</text><path class="dec fig" d="M268.8 152 L353.2 180 L268.8 208 L184.4 180 z"/><text x="268.8" y="184.5" text-anchor="middle">n MOD 2 = 0</text><path class="sal fig" d="M30 224.8 H250.8 L236.8 264.8 H16 z"/><text x="133.4" y="249.3" text-anchor="middle">Escribir n, " es impar"</text><path class="sal fig" d="M300.8 224.8 H506.4 L492.4 264.8 H286.8 z"/><text x="396.6" y="249.3" text-anchor="middle">Escribir n, " es par"</text><rect class="ini fig" x="223.8" y="309.6" width="90" height="40" rx="20"/><text x="268.8" y="334.1" text-anchor="middle">Fin</text><text x="162.4" y="164" font-size="11">No</text><text x="359.2" y="164" font-size="11">Sí</text></svg></figure>''',
      ),
      (
        'compuestas',
        'Condiciones compuestas: Y, O, NO',
        '''
<p>A veces una sola comparación no alcanza. Para entrar a un concierto quizá necesitas boleto <i>y</i> ser mayor de edad. Para eso se combinan condiciones:</p>
<ul>
  <li><code>Y</code>: se cumple si <b>las dos</b> partes son verdaderas.</li>
  <li><code>O</code>: se cumple si <b>al menos una</b> es verdadera.</li>
  <li><code>NO</code>: invierte el resultado.</li>
</ul>
${codigo('''
Algoritmo rango_valido
    Leer calificacion
    Si calificacion >= 0 Y calificacion <= 10 Entonces
        Escribir "Calificación válida"
    SiNo
        Escribir "Fuera de rango"
    FinSi
FinAlgoritmo
''', entradas: ['11'], salida: 'Fuera de rango')}
<p>Un error frecuente es escribir <code>0 &lt;= calificacion &lt;= 10</code>, como en matemáticas. En pseudocódigo hay que escribir las dos comparaciones completas y unirlas con <code>Y</code>.</p>''',
      ),
      (
        'anidados',
        'Si anidados: más de dos opciones',
        '''
<p>Un <code>Si</code> puede ir dentro de otro. Así se resuelven decisiones con tres o más resultados. Este programa clasifica una calificación:</p>
${codigo('''
Algoritmo calificacion_letra
    Leer calificacion
    Si calificacion >= 9 Entonces
        Escribir "Excelente"
    SiNo
        Si calificacion >= 6 Entonces
            Escribir "Aprobado"
        SiNo
            Escribir "Reprobado"
        FinSi
    FinSi
FinAlgoritmo
''', entradas: ['7'], salida: 'Aprobado')}
<p>El orden de las preguntas importa. Primero se pregunta por el caso más alto (9 o más). Si no se cumple, ya sabes que es menor que 9 y solo falta distinguir entre aprobado y reprobado. Fíjate también en la sangría: cada <code>FinSi</code> cierra el <code>Si</code> que está a su misma altura.</p>
<p>En el diagrama se ve que hay tres caminos posibles y que, para cada dato, el programa recorre solo uno:</p>
<figure class="diagrama" style="max-width:773px;overflow-x:auto"><svg style="max-width:733px;min-width:586px" viewBox="0 0 732.4 455.2" width="520" role="img" aria-labelledby="diag-2"><title id="diag-2">Diagrama de flujo de Algoritmo calificacion_letra</title><g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round"><path d="M486.4 56L486.4 84"/><path d="M486.4 124L486.4 152"/><path d="M371.2 180L246 180L246 224.8"/><path d="M130.8 252.8L122 252.8L122 297.6"/><path d="M361.2 252.8L366.2 252.8L366.2 297.6"/><path d="M122 337.6L122 354.4L246 354.4"/><path d="M366.2 337.6L366.2 354.4L246 354.4"/><path d="M601.6 180L610.4 180L610.4 224.8"/><path d="M246 354.4L246 371.2L486.4 371.2"/><path d="M610.4 264.8L610.4 371.2L486.4 371.2"/><path d="M486.4 371.2L486.4 399.2"/></g><path d="M486.4 84L482.4 76L490.4 76z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M486.4 152L482.4 144L490.4 144z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M246 224.8L242 216.8L250 216.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M122 297.6L118 289.6L126 289.6z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M366.2 297.6L362.2 289.6L370.2 289.6z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M610.4 224.8L606.4 216.8L614.4 216.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M486.4 399.2L482.4 391.2L490.4 391.2z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><rect class="ini fig" x="441.4" y="16" width="90" height="40" rx="20"/><text x="486.4" y="40.5" text-anchor="middle">Inicio</text><path class="io fig" d="M405.8 84 H581 L567 124 H391.8 z"/><text x="486.4" y="108.5" text-anchor="middle">Leer calificacion</text><path class="dec fig" d="M486.4 152 L601.6 180 L486.4 208 L371.2 180 z"/><text x="486.4" y="184.5" text-anchor="middle">calificacion &gt;= 9</text><path class="dec fig" d="M246 224.8 L361.2 252.8 L246 280.8 L130.8 252.8 z"/><text x="246" y="257.3" text-anchor="middle">calificacion &gt;= 6</text><path class="sal fig" d="M30 297.6 H228 L214 337.6 H16 z"/><text x="122" y="322.1" text-anchor="middle">Escribir "Reprobado"</text><path class="sal fig" d="M278 297.6 H468.4 L454.4 337.6 H264 z"/><text x="366.2" y="322.1" text-anchor="middle">Escribir "Aprobado"</text><path class="sal fig" d="M518.4 224.8 H716.4 L702.4 264.8 H504.4 z"/><text x="610.4" y="249.3" text-anchor="middle">Escribir "Excelente"</text><rect class="ini fig" x="441.4" y="399.2" width="90" height="40" rx="20"/><text x="486.4" y="423.7" text-anchor="middle">Fin</text><text x="349.2" y="164" font-size="11">No</text><text x="108.8" y="236.8" font-size="11">No</text><text x="367.2" y="236.8" font-size="11">Sí</text><text x="607.6" y="164" font-size="11">Sí</text></svg></figure>''',
      ),
      (
        'segun',
        'Segun: elegir entre varias opciones',
        '''
<p>Cuando la decisión depende de los valores exactos de <b>una sola variable</b>, <code>Segun</code> es más claro que muchos <code>Si</code> anidados. Cada opción lleva el valor, dos puntos y lo que hay que hacer. <code>De Otro Modo</code> atrapa cualquier valor que no esté en la lista:</p>
${codigo('''
Algoritmo dia_de_la_semana
    Leer dia
    Segun dia Hacer
        1: Escribir "Lunes"
        2: Escribir "Martes"
        3: Escribir "Miércoles"
        4: Escribir "Jueves"
        5: Escribir "Viernes"
        6, 7: Escribir "Fin de semana"
        De Otro Modo: Escribir "Ese día no existe"
    FinSegun
FinAlgoritmo
''', entradas: ['6'], salida: 'Fin de semana')}
<p>Una opción puede tener varios valores separados por comas, como <code>6, 7</code>. <code>Segun</code> sirve para valores exactos (1, 2, 3 o "a", "b"), no para rangos: si necesitas «de 6 a 8», usa <code>Si</code>. Hay un reto completo con esta estructura: <a href="/retos/dia-de-la-semana-con-segun-en-pseudocodigo">día de la semana con Segun</a>.</p>''',
      ),
      (
        'si-o-segun',
        '¿Si o Segun?',
        '''
${tabla('Cuándo usar cada uno', ['Situación', 'Usa', 'Ejemplo'], [
          ['Dos caminos', '<code>Si … SiNo</code>', '¿Aprobó o no?'],
          ['Rangos de valores', '<code>Si</code> anidados', 'Calificación: 9-10, 6-8, 0-5'],
          ['Condiciones con Y / O', '<code>Si</code>', 'Tiene boleto y es mayor de edad'],
          ['Valores exactos de una variable', '<code>Segun</code>', 'Opción de un menú: 1, 2, 3'],
        ])}''',
      ),
      (
        'probar',
        'Cómo probar una condicional',
        '''
<p>Un programa con decisiones necesita varios datos de prueba: al menos uno por cada camino, y los valores justo en el límite. Para el programa de calificaciones, prueba 10, 9, 8, 6, 5 y 0. Si la regla dice «6 o más», el 6 es el dato que descubre si escribiste <code>&gt;</code> en lugar de <code>&gt;=</code>.</p>
<p>La prueba de escritorio muestra qué camino tomó el programa. Con 800 en el ejemplo del descuento, se ve que entra al <code>Si</code> y <code>total</code> cambia:</p>
<div class="tabla"><table><caption>Prueba de escritorio de descuento con total = 800</caption><thead><tr><th scope="col">Paso</th><th scope="col">Línea</th><th scope="col">Instrucción</th><th scope="col">total</th><th scope="col">Pantalla</th></tr></thead><tbody><tr><td>1</td><td>3</td><td class="instr">Leer total</td><td class="cambio">800</td><td></td></tr><tr><td>2</td><td>4</td><td class="instr">Si total &gt; 500 Entonces</td><td>800</td><td></td></tr><tr><td>3</td><td>5</td><td class="instr">total &lt;- total * 0.9</td><td class="cambio">720</td><td></td></tr><tr><td>4</td><td>7</td><td class="instr">Escribir "A pagar: ", total</td><td>720</td><td>A pagar: 720</td></tr></tbody></table></div>''',
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li><b>Olvidar el <code>FinSi</code></b>, sobre todo en los anidados. Cada <code>Si</code> necesita el suyo.</li>
  <li><b>Usar <code>&lt;-</code> en la condición.</b> <code>Si edad &lt;- 18</code> no compara: lo correcto es <code>Si edad &gt;= 18</code>.</li>
  <li><b>Condiciones que se enciman.</b> Si preguntas primero <code>calificacion &gt;= 6</code> y luego <code>calificacion &gt;= 9</code>, un 10 nunca llegará a «Excelente». Ordena de lo más específico a lo más general.</li>
  <li><b>Comparar textos sin comillas.</b> <code>Si respuesta = si</code> busca una variable llamada si. Lo correcto es <code>Si respuesta = "si"</code>.</li>
  <li><b>Escribir el rango como en matemáticas</b> (<code>0 &lt;= x &lt;= 10</code>) en lugar de <code>x &gt;= 0 Y x &lt;= 10</code>.</li>
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Qué es una estructura condicional en pseudocódigo?',
        'Es una instrucción que hace que el programa elija qué pasos ejecutar según si una condición es verdadera o falsa. Las más comunes son Si … Entonces … SiNo … FinSi y Segun … FinSegun.',
      ),
      (
        '¿Cuál es la diferencia entre Si y Segun?',
        'Si evalúa cualquier condición verdadera o falsa, incluidas comparaciones y rangos. Segun compara una sola variable contra valores exactos. Para un menú de opciones Segun es más claro; para rangos o condiciones combinadas se usa Si.',
      ),
      (
        '¿Es obligatorio poner SiNo?',
        'No. Si solo hay que hacer algo cuando la condición se cumple, basta con Si … Entonces … FinSi. El SiNo se agrega cuando también hay algo que hacer en el caso contrario.',
      ),
      (
        '¿Cuántos Si puedo poner uno dentro de otro?',
        'Los que necesites, pero con más de tres niveles el programa se vuelve difícil de leer. Si todas las preguntas son sobre el valor exacto de una variable, conviene usar Segun.',
      ),
    ],
    relacionadas: ['variables-y-tipos-de-datos', 'ciclos-mientras-para-repetir', 'como-hacer-un-diagrama-de-flujo'],
  ),
  Guia(
    slug: 'ciclos-mientras-para-repetir',
    titulo: 'Ciclos en pseudocódigo: Mientras, Para y Repetir (diferencias y ejemplos)',
    h1: 'Ciclos en pseudocódigo: Mientras, Para y Repetir',
    descripcion:
        'Cómo repetir pasos en pseudocódigo con Para, Mientras y Repetir: diferencias, cuándo usar cada uno, contadores, acumuladores y cómo evitar un ciclo infinito.',
    resumen:
        'Un ciclo repite un grupo de instrucciones. Para se usa cuando sabes cuántas veces repetir, Mientras cuando repites mientras algo sea cierto, y Repetir cuando los pasos deben hacerse al menos una vez.',
    publicada: '2026-11-03',
    secciones: [
      (
        'que-es',
        'Qué es un ciclo',
        '''
<p>Mostrar la tabla del 7 escribiendo diez veces <code>Escribir</code> funciona, pero ¿y si fuera la tabla hasta el 100? Un <b>ciclo</b> (también llamado bucle o estructura repetitiva) escribe los pasos una vez y los repite las veces que haga falta.</p>
<p>Cada repetición se llama <b>vuelta</b> o iteración. Todo ciclo tiene una condición que decide si se da otra vuelta o si ya se termina. Hay tres formas de escribirlo, y la diferencia está en cuándo y cómo se revisa esa condición.</p>''',
      ),
      (
        'para',
        'Para: cuando sabes cuántas veces',
        '''
<p><code>Para</code> usa una variable que cuenta sola. Empieza en un valor, avanza de uno en uno y se detiene al llegar al final:</p>
${codigo('''
Algoritmo tabla_del_7
    Para i <- 1 Hasta 10 Hacer
        Escribir "7 x ", i, " = ", 7 * i
    FinPara
FinAlgoritmo
''', salida: '7 x 1 = 7\n7 x 2 = 14\n7 x 3 = 21\n7 x 4 = 28\n7 x 5 = 35\n7 x 6 = 42\n7 x 7 = 49\n7 x 8 = 56\n7 x 9 = 63\n7 x 10 = 70')}
<p>Con <code>Con Paso</code> cambias cuánto avanza en cada vuelta. Un paso negativo cuenta hacia atrás:</p>
${codigo('''
Algoritmo cuenta_regresiva
    Para i <- 10 Hasta 0 Con Paso -2 Hacer
        Escribir i
    FinPara
    Escribir "¡Despegue!"
FinAlgoritmo
''', salida: '10\n8\n6\n4\n2\n0\n¡Despegue!')}
<p>El final también puede ser una variable. Este programa calcula el factorial de un número (5! = 1 × 2 × 3 × 4 × 5):</p>
${codigo('''
Algoritmo factorial
    Leer n
    resultado <- 1
    Para i <- 1 Hasta n Hacer
        resultado <- resultado * i
    FinPara
    Escribir n, "! = ", resultado
FinAlgoritmo
''', entradas: ['5'], salida: '5! = 120')}
<p>No cambies el valor de <code>i</code> dentro de un <code>Para</code>: el ciclo lo maneja solo, y modificarlo a mano lleva a resultados confusos.</p>''',
      ),
      (
        'mientras',
        'Mientras: repetir mientras algo sea cierto',
        '''
<p><code>Mientras</code> revisa la condición <b>antes</b> de cada vuelta. Si es verdadera, ejecuta los pasos y vuelve a revisar. Si es falsa, sale del ciclo. Sirve cuando no sabes de antemano cuántas vueltas habrá. Por ejemplo, sumar números hasta que el usuario escriba 0:</p>
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
''', entradas: ['5', '3', '2', '0'], salida: 'Total: 10')}
<p>Hay un <code>Leer n</code> antes del ciclo y otro al final de cada vuelta. El primero da el valor que se revisa la primera vez; el segundo da el siguiente. Si el primer número es 0, el ciclo no da ni una vuelta: <code>Mientras</code> puede repetirse cero veces.</p>
<p>En el diagrama de flujo, un ciclo es una flecha que regresa a la condición:</p>
<figure class="diagrama" style="max-width:315px;overflow-x:auto"><svg style="max-width:275px;min-width:220px" viewBox="0 0 274.4 608.8" width="274.4" role="img" aria-labelledby="diag-3"><title id="diag-3">Diagrama de flujo de Algoritmo suma_hasta_cero</title><g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round"><path d="M137.2 56L137.2 84"/><path d="M137.2 124L137.2 152"/><path d="M137.2 192L137.2 220"/><path d="M137.2 220L137.2 234"/><path d="M137.2 290L137.2 318"/><path d="M137.2 358L137.2 386"/><path d="M137.2 426L137.2 440L42.4 440L42.4 227L137.2 227"/><path d="M196 262L232 262L232 456.8L137.2 456.8"/><path d="M137.2 456.8L137.2 484.8"/><path d="M137.2 524.8L137.2 552.8"/></g><path d="M137.2 84L133.2 76L141.2 76z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 152L133.2 144L141.2 144z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 220L133.2 212L141.2 212z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 234L133.2 226L141.2 226z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 318L133.2 310L141.2 310z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 386L133.2 378L141.2 378z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 227L129.2 231L129.2 223z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 484.8L133.2 476.8L141.2 476.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M137.2 552.8L133.2 544.8L141.2 544.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><rect class="ini fig" x="92.2" y="16" width="90" height="40" rx="20"/><text x="137.2" y="40.5" text-anchor="middle">Inicio</text><rect class="proc fig" x="87" y="84" width="100.4" height="40" rx="3"/><text x="137.2" y="108.5" text-anchor="middle">suma &lt;- 0</text><path class="io fig" d="M98.4 152 H190 L176 192 H84.4 z"/><text x="137.2" y="176.5" text-anchor="middle">Leer n</text><path class="dec fig" d="M137.2 234 L196 262 L137.2 290 L78.4 262 z"/><text x="137.2" y="266.5" text-anchor="middle">n &lt;&gt; 0</text><rect class="proc fig" x="60.4" y="318" width="153.6" height="40" rx="3"/><text x="137.2" y="342.5" text-anchor="middle">suma &lt;- suma + n</text><path class="io fig" d="M98.4 386 H190 L176 426 H84.4 z"/><text x="137.2" y="410.5" text-anchor="middle">Leer n</text><path class="sal fig" d="M30 484.8 H258.4 L244.4 524.8 H16 z"/><text x="137.2" y="509.3" text-anchor="middle">Escribir "Total: ", suma</text><rect class="ini fig" x="92.2" y="552.8" width="90" height="40" rx="20"/><text x="137.2" y="577.3" text-anchor="middle">Fin</text><text x="143.2" y="292" font-size="11">Sí</text><text x="202" y="246" font-size="11">No</text></svg></figure>''',
      ),
      (
        'repetir',
        'Repetir: al menos una vez',
        '''
<p><code>Repetir … Hasta Que</code> revisa la condición <b>después</b> de cada vuelta, así que los pasos siempre se hacen por lo menos una vez. Es ideal para pedir un dato hasta que sea correcto:</p>
${codigo('''
Algoritmo contrasena
    Repetir
        Escribir "Contraseña:"
        Leer clave
    Hasta Que clave = "jaguar"
    Escribir "Bienvenido"
FinAlgoritmo
''', entradas: ['gato', 'tigre', 'jaguar'], salida: 'Contraseña:\nContraseña:\nContraseña:\nBienvenido')}
<p>Ojo con la lógica de la condición: <code>Mientras</code> sigue <i>mientras</i> sea verdadera, y <code>Repetir … Hasta Que</code> sigue <i>hasta que</i> sea verdadera. Son opuestas. Puedes practicar esta estructura en el reto de <a href="/retos/algoritmo-de-contrasena-con-repetir">contraseña con Repetir</a>.</p>''',
      ),
      (
        'comparacion',
        'Diferencias entre Para, Mientras y Repetir',
        '''
${tabla('Los tres ciclos', ['', 'Para', 'Mientras', 'Repetir'], [
          ['<b>Úsalo cuando</b>', 'Sabes cuántas vueltas', 'Repites mientras algo sea cierto', 'Debe hacerse al menos una vez'],
          ['<b>Revisa la condición</b>', 'Antes de cada vuelta', 'Antes de cada vuelta', 'Después de cada vuelta'],
          ['<b>Vueltas mínimas</b>', '0', '0', '1'],
          ['<b>Termina cuando</b>', 'El contador pasa del final', 'La condición es falsa', 'La condición es verdadera'],
          ['<b>Ejemplo típico</b>', 'Tabla de multiplicar', 'Sumar hasta que escriban 0', 'Pedir una contraseña'],
        ])}
<p>Cualquier ciclo se puede escribir con <code>Mientras</code>, pero usar el adecuado hace el programa más corto y más claro.</p>''',
      ),
      (
        'contador-acumulador',
        'Contadores y acumuladores',
        '''
<p>Casi todos los ejercicios de ciclos usan estas dos variables:</p>
<ul>
  <li>Un <b>contador</b> suma 1 en cada vuelta en la que pasa algo: <code>aprobados &lt;- aprobados + 1</code>. Sirve para contar cuántos.</li>
  <li>Un <b>acumulador</b> suma un valor que cambia: <code>suma &lt;- suma + calificacion</code>. Sirve para totales y promedios.</li>
</ul>
<p>Los dos deben empezar en 0 <b>antes</b> del ciclo. Este programa lee 4 calificaciones, cuenta las aprobadas y calcula el promedio:</p>
${codigo('''
Algoritmo calificaciones
    aprobados <- 0
    suma <- 0
    Para i <- 1 Hasta 4 Hacer
        Leer calificacion
        suma <- suma + calificacion
        Si calificacion >= 6 Entonces
            aprobados <- aprobados + 1
        FinSi
    FinPara
    Escribir "Promedio: ", suma / 4
    Escribir "Aprobados: ", aprobados
FinAlgoritmo
''', entradas: ['8', '5', '10', '9'], salida: 'Promedio: 8\nAprobados: 3')}''',
      ),
      (
        'prueba',
        'Un ciclo en la prueba de escritorio',
        '''
<p>La prueba de escritorio es la mejor forma de entender un ciclo, porque «desenrolla» las vueltas: la misma línea aparece una vez por cada repetición. Así se ve el factorial de 4:</p>
<div class="tabla"><table><caption>Prueba de escritorio de factorial con n = 4</caption><thead><tr><th scope="col">Paso</th><th scope="col">Línea</th><th scope="col">Instrucción</th><th scope="col">n</th><th scope="col">resultado</th><th scope="col">i</th><th scope="col">Pantalla</th></tr></thead><tbody><tr><td>1</td><td>3</td><td class="instr">Leer n</td><td class="cambio">4</td><td></td><td></td><td></td></tr><tr><td>2</td><td>4</td><td class="instr">resultado &lt;- 1</td><td>4</td><td class="cambio">1</td><td></td><td></td></tr><tr><td>3</td><td>5</td><td class="instr">Para i &lt;- 1 Hasta n Hacer</td><td>4</td><td>1</td><td class="cambio">1</td><td></td></tr><tr><td>4</td><td>6</td><td class="instr">resultado &lt;- resultado * i</td><td>4</td><td>1</td><td>1</td><td></td></tr><tr><td>5</td><td>5</td><td class="instr">Para i &lt;- 1 Hasta n Hacer</td><td>4</td><td>1</td><td class="cambio">2</td><td></td></tr><tr><td>6</td><td>6</td><td class="instr">resultado &lt;- resultado * i</td><td>4</td><td class="cambio">2</td><td>2</td><td></td></tr><tr><td>7</td><td>5</td><td class="instr">Para i &lt;- 1 Hasta n Hacer</td><td>4</td><td>2</td><td class="cambio">3</td><td></td></tr><tr><td>8</td><td>6</td><td class="instr">resultado &lt;- resultado * i</td><td>4</td><td class="cambio">6</td><td>3</td><td></td></tr><tr><td>9</td><td>5</td><td class="instr">Para i &lt;- 1 Hasta n Hacer</td><td>4</td><td>6</td><td class="cambio">4</td><td></td></tr><tr><td>10</td><td>6</td><td class="instr">resultado &lt;- resultado * i</td><td>4</td><td class="cambio">24</td><td>4</td><td></td></tr><tr><td>11</td><td>5</td><td class="instr">Para i &lt;- 1 Hasta n Hacer</td><td>4</td><td>24</td><td>4</td><td></td></tr><tr><td>12</td><td>8</td><td class="instr">Escribir n, "! = ", resultado</td><td>4</td><td>24</td><td>4</td><td>4! = 24</td></tr></tbody></table></div>
<p>Las celdas resaltadas muestran cómo <code>i</code> avanza y <code>resultado</code> crece en cada vuelta: 1, 2, 6, 24. Más sobre esta técnica en la guía de <a href="/guias/prueba-de-escritorio">prueba de escritorio</a>.</p>''',
      ),
      (
        'infinito',
        'El ciclo infinito',
        '''
<p>Si nada dentro del ciclo cambia la condición, el ciclo nunca termina. Es el error más común con <code>Mientras</code>:</p>
${codigo('''
Algoritmo nunca_termina
    i <- 1
    Mientras i <= 3 Hacer
        Escribir i
    FinMientras
FinAlgoritmo
''')}
<p>Aquí <code>i</code> vale 1 para siempre, porque falta <code>i &lt;- i + 1</code> dentro del ciclo. En papel no te das cuenta hasta que haces la prueba de escritorio. Jaguar detiene el programa cuando lleva demasiados pasos y te avisa, en vez de congelarse.</p>
<p>Antes de escribir un <code>Mientras</code>, pregúntate: ¿qué cambia en cada vuelta para que algún día la condición sea falsa?</p>''',
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li><b>No inicializar</b> el contador o el acumulador antes del ciclo, o inicializarlo <i>dentro</i> (se reinicia en cada vuelta).</li>
  <li><b>Olvidar actualizar</b> la variable de la condición en un <code>Mientras</code>: ciclo infinito.</li>
  <li><b>Dar una vuelta de más o de menos.</b> <code>Para i &lt;- 1 Hasta 10</code> da 10 vueltas; <code>Para i &lt;- 0 Hasta 10</code> da 11.</li>
  <li><b>Invertir la condición del Repetir.</b> «Repetir hasta que la clave sea correcta» se escribe <code>Hasta Que clave = "jaguar"</code>, no con <code>&lt;&gt;</code>.</li>
  <li><b>Poner el <code>Escribir</code> del resultado dentro del ciclo</b>, cuando solo debía mostrarse una vez al final.</li>
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Cuál es la diferencia entre Mientras y Repetir?',
        'Mientras revisa la condición antes de cada vuelta, así que puede no ejecutarse ninguna vez. Repetir la revisa al final, así que siempre se ejecuta al menos una vez. Además, Mientras sigue mientras la condición sea verdadera y Repetir sigue hasta que lo sea.',
      ),
      (
        '¿Cuándo uso Para y cuándo Mientras?',
        'Usa Para cuando sabes cuántas veces se repite, aunque ese número venga en una variable. Usa Mientras cuando la repetición depende de algo que no sabes de antemano, como que el usuario escriba 0.',
      ),
      (
        '¿Qué es un ciclo infinito?',
        'Es un ciclo cuya condición nunca deja de cumplirse, normalmente porque olvidaste cambiar la variable que se revisa. El programa se repite sin terminar. Jaguar lo detiene y te avisa.',
      ),
      (
        '¿Qué es un acumulador?',
        'Es una variable que va sumando valores en cada vuelta de un ciclo, como el total de una compra o la suma de calificaciones. Debe empezar en 0 antes del ciclo.',
      ),
    ],
    relacionadas: ['condicionales-si-y-segun', 'arreglos-en-pseudocodigo', 'prueba-de-escritorio'],
  ),
  Guia(
    slug: 'arreglos-en-pseudocodigo',
    titulo: 'Arreglos en pseudocódigo: Dimension, recorrer, sumar y buscar (con ejemplos)',
    h1: 'Arreglos en pseudocódigo',
    descripcion:
        'Qué es un arreglo (vector) en pseudocódigo, cómo crearlo con Dimension, llenarlo, recorrerlo con Para, sumar, buscar el mayor y usar matrices. Ejemplos ejecutables.',
    resumen:
        'Un arreglo es una variable que guarda varios valores del mismo tipo, cada uno en una posición numerada. Se crea con Dimension y se recorre con un ciclo Para.',
    publicada: '2026-11-03',
    secciones: [
      (
        'que-es',
        'Qué es un arreglo',
        '''
<p>Si un programa necesita las calificaciones de 30 alumnos, crear 30 variables (<code>c1</code>, <code>c2</code>, …, <code>c30</code>) es impráctico. Un <b>arreglo</b> (también llamado vector) es una sola variable con muchas casillas numeradas. Cada casilla guarda un valor y se identifica por su <b>posición</b> o índice.</p>
${tabla('El arreglo calif con 5 casillas', ['Posición', '1', '2', '3', '4', '5'], [
          ['<b>Valor</b>', '8', '10', '6', '9', '7'],
        ])}
<p><code>calif[3]</code> se lee «calif en la posición 3» y vale 6. En PSeInt y en Jaguar las posiciones empiezan en 1. En lenguajes como Python, C o Java empiezan en 0: tenlo en cuenta cuando pases tu algoritmo a uno de ellos.</p>''',
      ),
      (
        'dimension',
        'Crear un arreglo con Dimension',
        '''
<p>Antes de usar un arreglo hay que decir cuántas casillas tiene, con <code>Dimension</code>. Después, cada casilla se usa como una variable normal:</p>
${codigo('''
Algoritmo primer_arreglo
    Dimension dias[3]
    dias[1] <- "lunes"
    dias[2] <- "martes"
    dias[3] <- "miércoles"
    Escribir "El segundo día es ", dias[2]
FinAlgoritmo
''', salida: 'El segundo día es martes')}
<p>Si usas una posición que no existe, como <code>dias[4]</code>, Jaguar se detiene con el mensaje «La posición 4 está fuera del arreglo 'dias'» y te recuerda que las posiciones válidas van de 1 a 3.</p>''',
      ),
      (
        'recorrer',
        'Llenar y recorrer con Para',
        '''
<p>Lo que hace útiles a los arreglos es combinarlos con un ciclo <code>Para</code>. La variable del ciclo sirve de posición, así que con tres líneas lees o muestras todas las casillas:</p>
${codigo('''
Algoritmo promedio_grupo
    Dimension calif[5]
    suma <- 0
    Para i <- 1 Hasta 5 Hacer
        Escribir "Calificación ", i, ":"
        Leer calif[i]
        suma <- suma + calif[i]
    FinPara
    promedio <- suma / 5
    Escribir "Promedio: ", promedio
    Escribir "Arriba del promedio:"
    Para i <- 1 Hasta 5 Hacer
        Si calif[i] > promedio Entonces
            Escribir calif[i]
        FinSi
    FinPara
FinAlgoritmo
''', entradas: ['8', '10', '6', '9', '7'], salida: 'Calificación 1:\nCalificación 2:\nCalificación 3:\nCalificación 4:\nCalificación 5:\nPromedio: 8\nArriba del promedio:\n10\n9')}
<p>Este ejemplo muestra por qué se necesita el arreglo: para saber qué calificaciones están arriba del promedio, primero hay que conocerlas todas. Sin arreglo, al leer la quinta ya habrías perdido las anteriores.</p>
<p>Para solo leer los valores, sin necesitar la posición, también existe <code>Para Cada</code>:</p>
${codigo('''
Algoritmo para_cada
    Dimension precios[3]
    precios[1] <- 15
    precios[2] <- 22
    precios[3] <- 8
    total <- 0
    Para Cada p de precios Hacer
        total <- total + p
    FinPara
    Escribir "Total: ", total
FinAlgoritmo
''', salida: 'Total: 45')}''',
      ),
      (
        'mayor',
        'Ejemplo: encontrar el mayor',
        '''
<p>Un ejercicio clásico: encontrar el valor más alto. La idea es suponer que el primero es el mayor y compararlo con cada uno de los demás. Si aparece uno más grande, se vuelve el nuevo mayor:</p>
${codigo('''
Algoritmo mayor_del_arreglo
    Dimension temp[5]
    Para i <- 1 Hasta 5 Hacer
        Leer temp[i]
    FinPara
    mayor <- temp[1]
    Para i <- 2 Hasta 5 Hacer
        Si temp[i] > mayor Entonces
            mayor <- temp[i]
        FinSi
    FinPara
    Escribir "La más alta: ", mayor
FinAlgoritmo
''', entradas: ['24', '31', '28', '35', '30'], salida: 'La más alta: 35')}
<p>¿Por qué empezar con <code>temp[1]</code> y no con 0? Porque si todas las temperaturas fueran negativas, 0 sería «el mayor» sin estar en el arreglo. Empezar con un valor del propio arreglo funciona siempre. Para el menor, es igual pero con <code>&lt;</code>.</p>''',
      ),
      (
        'buscar',
        'Ejemplo: buscar un valor',
        '''
<p>Para saber si un valor está en el arreglo, se recorre casilla por casilla. Una variable lógica recuerda si ya se encontró:</p>
${codigo('''
Algoritmo buscar
    Dimension nombres[4]
    nombres[1] <- "Ana"
    nombres[2] <- "Luis"
    nombres[3] <- "Sofía"
    nombres[4] <- "Mateo"
    Leer buscado
    encontrado <- Falso
    Para i <- 1 Hasta 4 Hacer
        Si nombres[i] = buscado Entonces
            Escribir "Está en la posición ", i
            encontrado <- Verdadero
        FinSi
    FinPara
    Si NO encontrado Entonces
        Escribir "No está en la lista"
    FinSi
FinAlgoritmo
''', entradas: ['Sofía'], salida: 'Está en la posición 3')}
<p>A esto se le llama <b>búsqueda lineal</b> o secuencial. Es la más sencilla y funciona aunque el arreglo no esté ordenado.</p>''',
      ),
      (
        'matrices',
        'Matrices: arreglos de dos dimensiones',
        '''
<p>Un arreglo también puede tener filas y columnas, como una tabla. Se crea con dos tamaños, <code>Dimension m[filas, columnas]</code>, y se recorre con un <code>Para</code> dentro de otro:</p>
${codigo('''
Algoritmo tablas_de_multiplicar
    Dimension m[3, 4]
    Para f <- 1 Hasta 3 Hacer
        Para c <- 1 Hasta 4 Hacer
            m[f, c] <- f * c
        FinPara
    FinPara
    Para f <- 1 Hasta 3 Hacer
        Escribir m[f, 1], " ", m[f, 2], " ", m[f, 3], " ", m[f, 4]
    FinPara
FinAlgoritmo
''', salida: '1 2 3 4\n2 4 6 8\n3 6 9 12')}
<p>El ciclo de afuera recorre las filas y el de adentro las columnas de cada fila. Por cada vuelta del <code>Para</code> externo, el interno da todas las suyas.</p>''',
      ),
      (
        'errores',
        'Errores comunes',
        '''
<ul>
  <li><b>Usar el arreglo sin <code>Dimension</code>.</b> Primero se crea y luego se usa.</li>
  <li><b>Empezar en 0.</b> En PSeInt flexible y en Jaguar, la primera posición es 1. <code>Para i &lt;- 0 Hasta 5</code> sobre un arreglo de 5 se sale de los límites.</li>
  <li><b>Dimensionar dos veces</b> el mismo arreglo. Jaguar avisa: «El arreglo 'calif' ya fue dimensionado».</li>
  <li><b>Escribir el arreglo completo</b> con <code>Escribir calif</code>. Hay que mostrar casilla por casilla, con un ciclo.</li>
  <li><b>Confundir la posición con el valor.</b> En <code>calif[3]</code>, el 3 es la posición; el valor es lo que hay guardado ahí.</li>
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Qué es un arreglo en pseudocódigo?',
        'Es una variable que guarda varios valores del mismo tipo, cada uno en una posición numerada. Por ejemplo, un arreglo de 30 casillas puede guardar las calificaciones de todo un grupo.',
      ),
      (
        '¿Arreglo y vector son lo mismo?',
        'Sí. Un arreglo de una dimensión también se llama vector. Uno de dos dimensiones, con filas y columnas, se llama matriz.',
      ),
      (
        '¿Los arreglos empiezan en 0 o en 1?',
        'En PSeInt (perfil flexible) y en Jaguar empiezan en 1. En la mayoría de los lenguajes de programación, como Python, C y Java, empiezan en 0. Al traducir un algoritmo hay que ajustar las posiciones.',
      ),
      (
        '¿Puedo guardar textos en un arreglo?',
        'Sí. Un arreglo puede guardar números, textos o valores lógicos. Lo normal es que todas las casillas sean del mismo tipo.',
      ),
    ],
    relacionadas: ['ciclos-mientras-para-repetir', 'variables-y-tipos-de-datos', 'de-pseudocodigo-a-python'],
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
<p>Los libros de cada materia pueden usar variaciones (por ejemplo, otra figura para repetir), pero estas cinco bastan para casi todos los ejercicios de un primer curso.</p>
<p>Para ver el diagrama de un algoritmo ya escrito, usa el <a href="/herramientas/diagrama-de-flujo-online">generador de diagramas de flujo online</a>: pegas el pseudocódigo y lo descargas como imagen.</p>''',
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
</ol>''',
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
<p>Fíjate que cada línea del programa tiene su figura: <code>Leer</code> es el paralelogramo de entrada, la asignación es el rectángulo, el <code>Si</code> es el rombo y cada <code>Escribir</code> es un paralelogramo de salida.</p>''',
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
''', salida: '3\n2\n1\n¡Despegue!')}''',
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
</ul>''',
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
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Qué programa uso para hacer un diagrama de flujo?',
        'Puedes dibujarlo a mano o con cualquier programa de dibujo. Con Jaguar lo armas con las figuras y la app escribe el pseudocódigo, o escribes el pseudocódigo y te muestra el diagrama.',
      ),
      (
        '¿Cuál es la diferencia entre un diagrama de flujo y el pseudocódigo?',
        'Dicen lo mismo con otra forma. El diagrama es visual y deja ver las decisiones y los ciclos de un vistazo; el pseudocódigo es texto y se acerca más a un programa real.',
      ),
      (
        '¿Todos los diagramas llevan las mismas figuras?',
        'Las más importantes son las mismas en casi todos lados: óvalo, paralelogramo, rectángulo, rombo y flechas. Algunas materias agregan figuras para ciclos o conectores; sigue las de tu profesor.',
      ),
    ],
    relacionadas: ['pseudocodigo-diagrama-de-flujo-y-bloques', 'que-es-el-pseudocodigo', 'prueba-de-escritorio'],
  ),
  Guia(
    slug: 'pseudocodigo-diagrama-de-flujo-y-bloques',
    titulo: 'Pseudocódigo, diagrama de flujo y bloques: diferencias y cuándo usar cada uno',
    h1: 'Pseudocódigo, diagramas de flujo y bloques',
    descripcion:
        'Las tres formas de escribir un algoritmo: en qué se parecen, en qué se diferencian, cuándo conviene cada una y por qué aprender con las tres a la vez.',
    resumen:
        'El pseudocódigo, el diagrama de flujo y los bloques son tres formas de escribir el mismo algoritmo. Cada una deja ver algo distinto, y usarlas juntas hace más fácil entender qué hace un programa y por qué.',
    publicada: '2026-11-03',
    secciones: [
      (
        'tres-formas',
        'Un algoritmo, tres formas',
        '''
<p>Este algoritmo pregunta tu edad y te dice si ya puedes votar. Primero, en <b>pseudocódigo</b>: palabras en español, una instrucción por línea.</p>
${codigo('''
Algoritmo puede_votar
    Escribir "¿Tu edad?"
    Leer edad
    Si edad >= 18 Entonces
        Escribir "Puedes votar"
    SiNo
        Escribir "Faltan ", 18 - edad
    FinSi
FinAlgoritmo
''', entradas: ['15'], salida: '¿Tu edad?\nFaltan 3')}
<p>El mismo algoritmo como <b>diagrama de flujo</b>. Cada figura es un tipo de paso y las flechas marcan el camino. En el rombo, el camino se divide en dos.</p>
<figure class="diagrama" style="max-width:624px;overflow-x:auto"><svg style="max-width:584px;min-width:467px" viewBox="0 0 583.2 433.6" width="520" role="img" aria-labelledby="diag-4"><title id="diag-4">Diagrama de flujo de Algoritmo puede_votar</title><g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round"><path d="M314.4 56L314.4 84"/><path d="M314.4 124L314.4 152"/><path d="M314.4 192L314.4 220"/><path d="M235.1 248L156.2 248L156.2 292.8"/><path d="M393.7 248L449.8 248L449.8 292.8"/><path d="M156.2 332.8L156.2 349.6L314.4 349.6"/><path d="M449.8 332.8L449.8 349.6L314.4 349.6"/><path d="M314.4 349.6L314.4 377.6"/></g><path d="M314.4 84L310.4 76L318.4 76z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M314.4 152L310.4 144L318.4 144z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M314.4 220L310.4 212L318.4 212z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M156.2 292.8L152.2 284.8L160.2 284.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M449.8 292.8L445.8 284.8L453.8 284.8z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><path d="M314.4 377.6L310.4 369.6L318.4 369.6z" style="fill:var(--fig-linea);stroke:none" stroke="none"/><rect class="ini fig" x="269.4" y="16" width="90" height="40" rx="20"/><text x="314.4" y="40.5" text-anchor="middle">Inicio</text><path class="sal fig" d="M222.4 84 H420.4 L406.4 124 H208.4 z"/><text x="314.4" y="108.5" text-anchor="middle">Escribir "¿Tu edad?"</text><path class="io fig" d="M264.2 152 H378.6 L364.6 192 H250.2 z"/><text x="314.4" y="176.5" text-anchor="middle">Leer edad</text><path class="dec fig" d="M314.4 220 L393.7 248 L314.4 276 L235.1 248 z"/><text x="314.4" y="252.5" text-anchor="middle">edad &gt;= 18</text><path class="sal fig" d="M30 292.8 H296.4 L282.4 332.8 H16 z"/><text x="156.2" y="317.3" text-anchor="middle">Escribir "Faltan ", 18 - edad</text><path class="sal fig" d="M346.4 292.8 H567.2 L553.2 332.8 H332.4 z"/><text x="449.8" y="317.3" text-anchor="middle">Escribir "Puedes votar"</text><rect class="ini fig" x="269.4" y="377.6" width="90" height="40" rx="20"/><text x="314.4" y="402.1" text-anchor="middle">Fin</text><text x="213.1" y="232" font-size="11">No</text><text x="399.7" y="232" font-size="11">Sí</text></svg></figure>
<p>Y como <b>bloques</b>: piezas de colores que encajan unas dentro de otras. Cada color es un tipo de instrucción, y lo que va dentro del <code>Si</code> queda abrazado por él.</p>
<figure class="bloques" style="max-width:420px;margin:18px auto"><svg viewBox="0 0 420 312" width="420" role="img" aria-labelledby="bloq-1" style="display:block;width:100%;height:auto"><title id="bloq-1">El algoritmo puede_votar en bloques</title><rect x="6" y="9" width="408" height="40" rx="12" fill="#1B5E20"/><rect x="6" y="6" width="408" height="40" rx="12" fill="#2E7D32"/><text x="20" y="31" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">Escribir</text><rect x="90.8" y="14" width="99.6" height="24" rx="7" fill="#fff"/><text x="98.8" y="31" fill="#2E7D32" font-size="13" font-family="ui-monospace, Menlo, Consolas, monospace">&quot;¿Tu edad?&quot;</text><rect x="6" y="57" width="408" height="40" rx="12" fill="#005A8C"/><rect x="6" y="54" width="408" height="40" rx="12" fill="#0077B6"/><text x="20" y="79" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">Leer</text><rect x="60.4" y="62" width="46.4" height="24" rx="7" fill="#fff"/><text x="68.4" y="79" fill="#0060A0" font-size="13" font-family="ui-monospace, Menlo, Consolas, monospace">edad</text><rect x="6" y="105" width="408" height="198" rx="12" fill="#633500"/><rect x="6" y="102" width="408" height="198" rx="12" fill="#8A4B00"/><text x="20" y="127" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">Si</text><rect x="45.2" y="110" width="92.0" height="24" rx="7" fill="#fff"/><text x="53.2" y="127" fill="#1F1B13" font-size="13" font-family="ui-monospace, Menlo, Consolas, monospace">edad &gt;= 18</text><text x="147.2" y="127" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">Entonces</text><rect x="28" y="146" width="386" height="48" rx="8" style="fill:var(--fondo)"/><rect x="28" y="153" width="386" height="40" rx="12" fill="#1B5E20"/><rect x="28" y="150" width="386" height="40" rx="12" fill="#2E7D32"/><text x="42" y="175" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">Escribir</text><rect x="112.8" y="158" width="122.4" height="24" rx="7" fill="#fff"/><text x="120.8" y="175" fill="#2E7D32" font-size="13" font-family="ui-monospace, Menlo, Consolas, monospace">&quot;Puedes votar&quot;</text><text x="20" y="219" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">SiNo</text><rect x="28" y="232" width="386" height="48" rx="8" style="fill:var(--fondo)"/><rect x="28" y="239" width="386" height="40" rx="12" fill="#1B5E20"/><rect x="28" y="236" width="386" height="40" rx="12" fill="#2E7D32"/><text x="42" y="261" fill="#fff" font-weight="800" font-size="13" font-family="Nunito, system-ui, sans-serif">Escribir</text><rect x="112.8" y="244" width="168.0" height="24" rx="7" fill="#fff"/><text x="120.8" y="261" fill="#2E7D32" font-size="13" font-family="ui-monospace, Menlo, Consolas, monospace">&quot;Faltan &quot;, 18 - edad</text></svg></figure>
<p>Los tres dicen exactamente lo mismo. No son tres programas: son tres maneras de mirar uno solo. Lo que cambia es <i>qué se ve más fácil</i> en cada una.</p>''',
      ),
      (
        'pseudocodigo',
        'El pseudocódigo: preciso y cerca de programar',
        '''
<p>El pseudocódigo es la forma más compacta. Un programa de 30 pasos cabe en una pantalla, se corrige borrando una palabra y se comparte copiando y pegando. Además, se parece mucho a los lenguajes de verdad: <code>Si</code> es <code>if</code>, <code>Mientras</code> es <code>while</code>. Por eso es el formato que más acerca a programar en Python, C o Java.</p>
<p><b>Lo difícil:</b> hay que escribir bien. Una comilla que falta o un <code>FinSi</code> olvidado detienen todo, y al principio esos errores distraen de lo importante, que es la lógica. También cuesta ver de un vistazo cuántos caminos tiene el programa: un <code>Si</code> dentro de otro <code>Si</code> se nota solo por la sangría.</p>
<p><b>Conviene cuando:</b> ya entiendes la idea y quieres escribirla completa, cuando el programa es largo o cuando te preparas para pasar a un lenguaje de programación. Si quieres conocerlo a fondo, está la guía <a href="/guias/que-es-el-pseudocodigo">qué es el pseudocódigo</a>.</p>''',
      ),
      (
        'diagrama',
        'El diagrama de flujo: ver el camino',
        '''
<p>El diagrama dibuja lo que el pseudocódigo solo dice. Las decisiones se ven como bifurcaciones y los ciclos como flechas que regresan. Con el dedo puedes seguir el camino que tomaría el programa con cierto dato, y eso es justo lo que hace falta para entenderlo.</p>
<p>Esto tiene respaldo. En un experimento clásico, David Scanlan comparó a estudiantes que leían algoritmos como diagramas de flujo estructurados contra otros que los leían en pseudocódigo. Con los diagramas los entendieron en menos tiempo, se equivocaron menos al responder preguntas sobre ellos y confiaron más en su respuesta. La ventaja creció conforme los algoritmos se hacían más complicados (Scanlan, 1989).</p>
<p><b>Lo difícil:</b> los diagramas crecen rápido. A mano, un programa con varios ciclos llena una hoja, y corregir un paso en medio obliga a redibujar. Ojo también con lo que mide ese estudio: <i>leer</i> y entender un algoritmo, no escribirlo.</p>
<p><b>Conviene cuando:</b> estás aprendiendo una estructura nueva (decisiones, ciclos), cuando explicas un algoritmo a alguien o cuando no entiendes por qué tu programa toma el camino que toma. Para aprender a dibujarlos, revisa <a href="/guias/como-hacer-un-diagrama-de-flujo">cómo hacer un diagrama de flujo</a>.</p>''',
      ),
      (
        'bloques',
        'Los bloques: armar sin errores de escritura',
        '''
<p>Con bloques no escribes: eliges una pieza y la llenas. No hay comillas que olvidar ni cierres que faltan, porque cada <code>Si</code> ya viene con su forma de C y su <code>SiNo</code>. Además, todas las instrucciones están a la vista: no tienes que recordar cómo se escribe <code>Repetir</code>, la ves en la lista.</p>
<p>En un estudio de cinco semanas con estudiantes de bachillerato, David Weintrop y Uri Wilensky compararon una versión con bloques y otra con texto del mismo entorno de programación. Quienes usaron bloques aprendieron más conceptos en ese tiempo. Los de texto, en cambio, sentían que lo suyo se parecía más a programar de verdad (Weintrop y Wilensky, 2017). Después, ambos grupos pasaron a Java y, tras 10 semanas, la diferencia desapareció: empezar con bloques no los dejó atrás (Weintrop y Wilensky, 2019).</p>
<p><b>Lo difícil:</b> armar un programa grande pieza por pieza es más lento que escribirlo, y tarde o temprano hay que pasar a texto. Los bloques son una rampa, no el destino.</p>
<p><b>Conviene cuando:</b> estás empezando y los errores de escritura te frenan, o cuando quieres concentrarte en el orden de los pasos sin pelear con la sintaxis.</p>''',
      ),
      (
        'comparacion',
        'Comparación rápida',
        '''
${tabla('Pseudocódigo, diagrama de flujo y bloques', ['', 'Pseudocódigo', 'Diagrama de flujo', 'Bloques'], [
          ['<b>Lo que se ve mejor</b>', 'Cada paso, completo y en orden', 'Los caminos: decisiones y ciclos', 'Qué va dentro de qué'],
          ['<b>Error típico</b>', 'De escritura: comillas, cierres', 'Flechas que no llegan a ningún lado', 'Pieza en el lugar equivocado'],
          ['<b>Programas largos</b>', 'Bien: es compacto', 'Difícil: crece mucho', 'Lento de armar'],
          ['<b>Más útil para</b>', 'Escribir y pasar a otro lenguaje', 'Entender y explicar', 'Empezar sin trabarse'],
          ['<b>En papel</b>', 'Fácil de escribir', 'Tardado de corregir', 'No se usa'],
        ])}''',
      ),
      (
        'juntos',
        'Por qué aprender con los tres a la vez',
        '''
<p>La investigación sobre aprender con varias representaciones, como la de Shaaron Ainsworth, explica por qué juntarlas ayuda (Ainsworth, 2006). Cuando ves la misma idea de varias formas, pasan tres cosas:</p>
<ul>
  <li><b>Se complementan.</b> Cada formato muestra algo que el otro esconde: el pseudocódigo da el detalle, el diagrama da la forma.</li>
  <li><b>Se aclaran entre sí.</b> Lo que ya conoces ayuda a leer lo nuevo. Si dudas de qué hace un <code>SiNo</code> escrito, el rombo del diagrama te lo dice.</li>
  <li><b>Construyen una idea más profunda.</b> Al relacionarlas entiendes lo que tienen en común: el algoritmo, que no es ni el texto ni el dibujo.</li>
</ul>
<p>La misma investigación advierte algo: tener varias representaciones no ayuda solo. Lo más difícil para quien empieza es <i>traducir</i> de una a otra, y si nadie lo apoya en eso, más representaciones pueden confundir en vez de ayudar.</p>
<p>Por eso en Jaguar las tres vistas están conectadas. Cambias una línea de pseudocódigo y el diagrama y los bloques cambian con ella. Tocas una figura del diagrama y ves qué línea es. La traducción que en papel tendrías que hacer tú, aquí la ves hecha y puedes comprobarla. Y cuando ya no la necesitas, usas solo una vista.</p>
<p>Hay una cuarta forma de mirar el programa: <b>en el tiempo</b>. La <a href="/guias/prueba-de-escritorio">prueba de escritorio</a> muestra qué vale cada variable en cada paso. Así se ve el algoritmo puede_votar cuando escribes 15:</p>
<div class="tabla"><table><caption>Prueba de escritorio con edad = 15</caption><thead><tr><th scope="col">Paso</th><th scope="col">Línea</th><th scope="col">Instrucción</th><th scope="col">edad</th><th scope="col">Pantalla</th></tr></thead><tbody><tr><td>1</td><td>3</td><td class="instr">Escribir "¿Tu edad?"</td><td></td><td>¿Tu edad?</td></tr><tr><td>2</td><td>4</td><td class="instr">Leer edad</td><td class="cambio">15</td><td></td></tr><tr><td>3</td><td>5</td><td class="instr">Si edad &gt;= 18 Entonces</td><td>15</td><td></td></tr><tr><td>4</td><td>8</td><td class="instr">Escribir "Faltan ", 18 - edad</td><td>15</td><td>Faltan 3</td></tr></tbody></table></div>
<p>El pseudocódigo dice qué hacer, el diagrama muestra por dónde va, los bloques muestran qué contiene qué, y la prueba de escritorio enseña lo que pasó de verdad.</p>''',
      ),
      (
        'como-usarlos',
        'Cómo usarlos al estudiar o en clase',
        '''
<ol>
  <li><b>Al empezar un tema</b>, mira primero el diagrama: te da la forma general antes de los detalles.</li>
  <li><b>Si los errores de escritura te frenan</b>, arma el programa en bloques y luego mira cómo queda escrito.</li>
  <li><b>Para la tarea o el examen</b>, escribe en pseudocódigo: es lo que más se pide y lo más cercano a programar.</li>
  <li><b>Cuando algo no sale</b>, haz la prueba de escritorio: casi siempre muestra en qué paso se rompe la lógica.</li>
</ol>
<p>Si das clase, tres actividades que funcionan bien:</p>
<ul>
  <li><b>Del diagrama al código.</b> Muestra un diagrama y pide el pseudocódigo. Luego comparan con la vista de Jaguar.</li>
  <li><b>Del código al diagrama, a mano.</b> Pide dibujar el diagrama en papel y después revisarlo contra el que genera Jaguar. Las diferencias son la discusión.</li>
  <li><b>Predecir antes de ejecutar.</b> Con la prueba de escritorio en modo Practicar, cada quien llena la tabla y Jaguar revisa cada celda.</li>
</ul>''',
      ),
      (
        'fuentes',
        'Fuentes',
        '''
<ul class="fuentes">
  <li>Ainsworth, S. (2006). DeFT: A conceptual framework for considering learning with multiple representations. <i>Learning and Instruction, 16</i>(3), 183–198. <a href="https://doi.org/10.1016/j.learninstruc.2006.03.001">doi.org/10.1016/j.learninstruc.2006.03.001</a></li>
  <li>Scanlan, D. A. (1989). Structured flowcharts outperform pseudocode: an experimental comparison. <i>IEEE Software, 6</i>(5), 28–36. <a href="https://doi.org/10.1109/52.35587">doi.org/10.1109/52.35587</a></li>
  <li>Weintrop, D. y Wilensky, U. (2017). Comparing block-based and text-based programming in high school computer science classrooms. <i>ACM Transactions on Computing Education, 18</i>(1), artículo 3. <a href="https://ccl.northwestern.edu/2017/a3_weintrop_wilensky.pdf">PDF</a></li>
  <li>Weintrop, D. y Wilensky, U. (2019). Transitioning from introductory block-based and text-based environments to professional programming languages in high school computer science classrooms. <i>Computers &amp; Education, 142</i>, 103646. <a href="https://www.terpconnect.umd.edu/~weintrop/papers/Weintrop&amp;Wilensky_2019_C&amp;E.pdf">PDF</a></li>
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Qué es mejor, el diagrama de flujo o el pseudocódigo?',
        'Ninguno es mejor siempre. El diagrama ayuda a entender por dónde va un algoritmo, sobre todo con decisiones y ciclos. El pseudocódigo es más rápido de escribir y corregir, y se parece más a un lenguaje de programación. Lo ideal es saber pasar de uno a otro.',
      ),
      (
        '¿Cuál es la diferencia entre un diagrama de flujo y el pseudocódigo?',
        'Dicen lo mismo de formas distintas. El pseudocódigo escribe los pasos con palabras, uno por línea. El diagrama de flujo los dibuja con figuras (óvalos, rectángulos, rombos) unidas por flechas que muestran el orden.',
      ),
      (
        '¿Los bloques son solo para niños?',
        'No. Sirven a cualquiera que esté empezando, porque quitan los errores de escritura y dejan ver la estructura. En un estudio con estudiantes de bachillerato, quienes empezaron con bloques aprendieron más conceptos en las primeras semanas y no tuvieron desventaja al pasar a Java.',
      ),
      (
        'En el examen me piden el diagrama a mano. ¿Me sirve Jaguar?',
        'Sí. Practica dibujándolo en papel y después escribe el mismo algoritmo en Jaguar para comparar tu dibujo con el diagrama que genera. Si no coinciden, encontraste un error o una forma distinta de resolverlo.',
      ),
      (
        '¿Tengo que aprender los tres?',
        'Lo que se pide casi siempre es pseudocódigo y diagrama de flujo. Los bloques son opcionales: úsalos si te ayudan a empezar. Lo importante no es el formato, sino entender el algoritmo que está detrás de los tres.',
      ),
    ],
    relacionadas: ['que-es-el-pseudocodigo', 'como-hacer-un-diagrama-de-flujo', 'prueba-de-escritorio'],
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
<p>También es una forma de comprobar tu algoritmo <i>antes</i> de escribirlo en un lenguaje, y es un ejercicio frecuente en las materias de lógica de programación.</p>
<p>Si quieres ver una tabla ya hecha para tu propio algoritmo, pruébala en la <a href="/herramientas/prueba-de-escritorio">herramienta de prueba de escritorio online</a>: escribes el pseudocódigo, pones los datos y la tabla sale sola.</p>''',
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
</ol>''',
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
<p>La tabla confirma que el resultado es 10, y de paso muestra cómo va creciendo <code>suma</code>.</p>''',
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
<p>Aquí la tabla tiene una columna para la condición. Con dos datos distintos viste las dos ramas del <code>Si</code>.</p>''',
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
<p>Muchos errores aparecen justo en los límites: en un <code>&gt;</code> que debía ser <code>&gt;=</code>.</p>''',
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
</ul>''',
      ),
      (
        'jaguar',
        'La prueba de escritorio con Jaguar',
        '''
<p>En Jaguar puedes hacerla de dos formas: dejar que la app arme la tabla sola con los datos que le des, paso a paso, o llenarla tú y que la app te marque qué acertaste. Así practicas la técnica y verificas con la computadora.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Por qué se llama prueba de escritorio?',
        'Porque se hace «en el escritorio», con lápiz y papel, sin necesidad de una computadora: tú haces el papel de la máquina que ejecuta el programa.',
      ),
      (
        '¿La prueba de escritorio sirve con diagramas de flujo?',
        'Sí. Sigues las flechas del diagrama en lugar de las líneas del programa y anotas lo mismo: el valor de cada variable en cada paso.',
      ),
      (
        '¿Cuántos datos de prueba debo usar?',
        'Los que cubran todos los caminos del programa: al menos un dato por cada rama de cada decisión, y casos límite como el cero.',
      ),
    ],
    relacionadas: ['que-es-un-algoritmo', 'ciclos-mientras-para-repetir', 'que-es-el-pseudocodigo'],
  ),
  Guia(
    slug: 'de-pseudocodigo-a-python',
    titulo: 'De pseudocódigo a Python: equivalencias y ejemplos para pasar tu algoritmo',
    h1: 'De pseudocódigo a Python',
    descripcion:
        'Cómo traducir pseudocódigo (estilo PSeInt) a Python: tabla de equivalencias, Leer e input, Si e if, ciclos Para y range, arreglos y listas, y los errores típicos al pasar.',
    resumen:
        'Si ya sabes pseudocódigo, ya sabes la parte difícil de programar: la lógica. Pasar a Python es cambiar las palabras y aprender unas cuantas reglas nuevas, como la sangría obligatoria y que las listas empiezan en 0.',
    publicada: '2026-11-03',
    secciones: [
      (
        'por-que',
        'Lo que ya sabes sirve',
        '''
<p>Una crítica común al pseudocódigo es que «no sirve fuera de la escuela». No es así: variables, decisiones, ciclos y arreglos funcionan igual en todos los lenguajes. Lo que cambia es cómo se escriben. Python es una buena primera opción porque su forma de escribir es de las más parecidas al pseudocódigo.</p>
<p>Compara el mismo programa en los dos:</p>
${codigo('''
Algoritmo aprobado
    Leer calificacion
    Si calificacion >= 6 Entonces
        Escribir "Aprobado"
    SiNo
        Escribir "Reprobado"
    FinSi
FinAlgoritmo
''', entradas: ['8'], salida: 'Aprobado')}<pre class="codigo" tabindex="0"><code>calificacion = float(input())
if calificacion &gt;= 6:
    print("Aprobado")
else:
    print("Reprobado")</code></pre>
<p>Cambian las palabras (<code>Si</code> por <code>if</code>, <code>Escribir</code> por <code>print</code>), pero el algoritmo es el mismo.</p>''',
      ),
      (
        'equivalencias',
        'Tabla de equivalencias',
        '''
${tabla('Pseudocódigo y Python', ['Pseudocódigo', 'Python'], [
          ['<code>Algoritmo nombre … FinAlgoritmo</code>', 'No hace falta: el programa empieza en la primera línea'],
          ['<code>x &lt;- 5</code>', '<code>x = 5</code>'],
          ['<code>Leer n</code> (número)', '<code>n = int(input())</code> o <code>n = float(input())</code>'],
          ['<code>Leer nombre</code> (texto)', '<code>nombre = input()</code>'],
          ['<code>Escribir "Hola ", nombre</code>', '<code>print("Hola", nombre)</code>'],
          ['<code>Si … Entonces … SiNo … FinSi</code>', '<code>if …:</code> / <code>else:</code>'],
          ['<code>Segun x Hacer</code>', '<code>if</code> / <code>elif</code> / <code>else</code>'],
          ['<code>Mientras … Hacer … FinMientras</code>', '<code>while …:</code>'],
          ['<code>Para i &lt;- 1 Hasta 10 Hacer</code>', '<code>for i in range(1, 11):</code>'],
          ['<code>Repetir … Hasta Que …</code>', '<code>while True:</code> … <code>if …: break</code>'],
          ['<code>=</code> (comparar)', '<code>==</code>'],
          ['<code>&lt;&gt;</code>', '<code>!=</code>'],
          ['<code>Y</code>, <code>O</code>, <code>NO</code>', '<code>and</code>, <code>or</code>, <code>not</code>'],
          ['<code>MOD</code>', '<code>%</code>'],
          ['<code>^</code>', '<code>**</code>'],
          ['<code>Verdadero</code>, <code>Falso</code>', '<code>True</code>, <code>False</code>'],
          ['<code>Dimension a[5]</code>', '<code>a = [0] * 5</code>'],
          ['<code>// comentario</code>', '<code># comentario</code>'],
        ])}''',
      ),
      (
        'sangria',
        'La regla más importante: la sangría',
        '''
<p>En pseudocódigo, la sangría ayuda a leer, pero lo que cierra un bloque es <code>FinSi</code> o <code>FinMientras</code>. En Python no hay palabras de cierre: <b>la sangría es lo que define qué está dentro de qué</b>. Después de los dos puntos (<code>:</code>) de un <code>if</code>, <code>while</code> o <code>for</code>, las líneas de adentro van con 4 espacios. Cuando regresas a la orilla, el bloque terminó.</p>
<p>Si en pseudocódigo ya acomodas bien la sangría, esta regla no te va a costar trabajo.</p>''',
      ),
      (
        'leer',
        'Leer datos: input() siempre da texto',
        '''
<p>Esta es la trampa más común. En pseudocódigo, <code>Leer n</code> guarda un número si escribes un número. En Python, <code>input()</code> <b>siempre</b> devuelve texto. Si lo usas para sumar, junta los textos en vez de sumar:</p>
<pre class="codigo" tabindex="0"><code>a = input()
b = input()
print(a + b)</code></pre>
<p>Hay que convertirlo: <code>int()</code> para enteros y <code>float()</code> para números con decimales.</p>
<pre class="codigo" tabindex="0"><code>a = int(input())
b = int(input())
print(a + b)</code></pre>
<p>Otro detalle: en Python, una división con <code>/</code> siempre da un número con decimales. <code>10 / 2</code> da <code>5.0</code>, no <code>5</code>. Si necesitas el entero, usa <code>//</code> o <code>int()</code>.</p>''',
      ),
      (
        'ciclos',
        'Ciclos: el range que no incluye el final',
        '''
<p>El <code>Para</code> se traduce con <code>for</code> y <code>range()</code>. El detalle es que <code>range(1, 11)</code> va del 1 al <b>10</b>: el número final no se incluye. Por eso <code>Para i &lt;- 1 Hasta 10</code> se escribe con 11.</p>
${codigo('''
Algoritmo tabla_del_3
    Para i <- 1 Hasta 5 Hacer
        Escribir "3 x ", i, " = ", 3 * i
    FinPara
FinAlgoritmo
''', salida: '3 x 1 = 3\n3 x 2 = 6\n3 x 3 = 9\n3 x 4 = 12\n3 x 5 = 15')}<pre class="codigo" tabindex="0"><code>for i in range(1, 6):
    print("3 x", i, "=", 3 * i)</code></pre>
<p><code>Mientras</code> se traduce casi palabra por palabra con <code>while</code>. Python no tiene <code>Repetir … Hasta Que</code>, así que se usa un ciclo que se repite siempre y se rompe con <code>break</code> cuando se cumple la condición:</p>
<pre class="codigo" tabindex="0"><code>while True:
    clave = input("Contraseña: ")
    if clave == "jaguar":
        break
print("Bienvenido")</code></pre>''',
      ),
      (
        'segun',
        'Segun: if y elif',
        '''
<p>El <code>Segun</code> se traduce con una cadena de <code>if</code>, <code>elif</code> (abreviatura de «else if») y <code>else</code> para el <code>De Otro Modo</code>:</p>
<pre class="codigo" tabindex="0"><code>dia = int(input())
if dia == 1:
    print("Lunes")
elif dia == 2:
    print("Martes")
elif dia == 6 or dia == 7:
    print("Fin de semana")
else:
    print("Otro día")</code></pre>
<p>Las versiones recientes de Python también tienen <code>match</code>, que se parece más al <code>Segun</code>, pero <code>if</code>/<code>elif</code> funciona en todas y es lo más común.</p>''',
      ),
      (
        'listas',
        'Arreglos y listas: empiezan en 0',
        '''
<p>Los arreglos de pseudocódigo son <b>listas</b> en Python. La diferencia clave: en PSeInt la primera posición es 1, y en Python es <b>0</b>. Una lista de 5 elementos va de la posición 0 a la 4.</p>
${codigo('''
Algoritmo suma_arreglo
    Dimension v[3]
    v[1] <- 10
    v[2] <- 20
    v[3] <- 30
    suma <- 0
    Para i <- 1 Hasta 3 Hacer
        suma <- suma + v[i]
    FinPara
    Escribir "Suma: ", suma
    Escribir "El primero: ", v[1]
FinAlgoritmo
''', salida: 'Suma: 60\nEl primero: 10')}<pre class="codigo" tabindex="0"><code>v = [10, 20, 30]
suma = 0
for i in range(0, 3):
    suma = suma + v[i]
print("Suma:", suma)
print("El primero:", v[0])</code></pre>
<p>En Python también puedes recorrer la lista sin posiciones, como el <code>Para Cada</code>: <code>for x in v:</code>. Y para sumarla hay una función lista: <code>sum(v)</code>.</p>''',
      ),
      (
        'completo',
        'Un ejemplo completo',
        '''
<p>Un programa que lee calificaciones hasta que escribas -1 y muestra el promedio. Primero en pseudocódigo:</p>
${codigo('''
Algoritmo promedio_hasta_menos_uno
    suma <- 0
    cuantos <- 0
    Leer c
    Mientras c <> -1 Hacer
        suma <- suma + c
        cuantos <- cuantos + 1
        Leer c
    FinMientras
    Si cuantos > 0 Entonces
        Escribir "Promedio: ", suma / cuantos
    SiNo
        Escribir "No hubo calificaciones"
    FinSi
FinAlgoritmo
''', entradas: ['8', '9', '10', '-1'], salida: 'Promedio: 9')}
<p>Y en Python, línea por línea:</p>
<pre class="codigo" tabindex="0"><code>suma = 0
cuantos = 0
c = float(input())
while c != -1:
    suma = suma + c
    cuantos = cuantos + 1
    c = float(input())
if cuantos &gt; 0:
    print("Promedio:", suma / cuantos)
else:
    print("No hubo calificaciones")</code></pre>
<p>La única diferencia en el resultado es el <code>9.0</code>: en Python, dividir siempre da decimales.</p>''',
      ),
      (
        'en-jaguar',
        'Ver tu programa en Python con Jaguar',
        '''
<p>Jaguar tiene una vista de Python que muestra tu pseudocódigo traducido mientras lo escribes. Viene apagada para que al principio te concentres en la lógica: se activa en los ajustes de la app. Al prenderla, ves lado a lado las dos versiones del mismo programa, y la traducción elige cosas como <code>int(input())</code> o <code>float(input())</code> según cómo usas cada variable.</p>
<p>Úsala como apoyo para leer, no para copiar. El ejercicio que más enseña es escribir tú la versión en Python y después compararla con la de Jaguar.</p>''',
      ),
      (
        'errores',
        'Errores comunes al pasar a Python',
        '''
<ul>
  <li><b>No convertir el <code>input()</code></b> a número: <code>"2" + "3"</code> da <code>"23"</code>.</li>
  <li><b>Usar <code>=</code> para comparar.</b> En Python se compara con <code>==</code>; un solo <code>=</code> asigna.</li>
  <li><b>Olvidar los dos puntos</b> al final de <code>if</code>, <code>else</code>, <code>while</code> y <code>for</code>.</li>
  <li><b>Sangría desigual.</b> Mezclar 2 y 4 espacios, o tabuladores y espacios, da error.</li>
  <li><b>El final del <code>range</code>.</b> <code>range(1, 10)</code> llega a 9, no a 10.</li>
  <li><b>Posiciones de listas desde 1.</b> En Python, <code>v[1]</code> es el segundo elemento.</li>
</ul>''',
      ),
    ],
    preguntas: [
      (
        '¿Es difícil pasar de pseudocódigo a Python?',
        'No mucho, si ya entiendes la lógica. La mayoría de las instrucciones tienen un equivalente directo. Lo nuevo es que la sangría es obligatoria, que input() siempre da texto y que las listas empiezan en 0.',
      ),
      (
        '¿Cómo se escribe Leer en Python?',
        'Con input(). Como siempre devuelve texto, para números se convierte: int(input()) para enteros y float(input()) para números con decimales.',
      ),
      (
        '¿Cómo se escribe Para en Python?',
        'Con for y range. Para i <- 1 Hasta 10 se escribe for i in range(1, 11), porque range no incluye el número final.',
      ),
      (
        '¿Python tiene Repetir … Hasta Que?',
        'No. Se usa while True: con un if que hace break cuando se cumple la condición. Así los pasos se hacen al menos una vez, igual que en Repetir.',
      ),
    ],
    relacionadas: ['que-es-el-pseudocodigo', 'arreglos-en-pseudocodigo', 'ciclos-mientras-para-repetir'],
  ),
  Guia(
    slug: 'pseint-en-el-celular',
    titulo: 'PSeInt en el celular: cómo programar pseudocódigo en Android',
    h1: 'PSeInt en el celular: cómo programar pseudocódigo en Android',
    descripcion:
        'PSeInt se instala en computadora. Si solo tienes celular, esto es lo que debe tener una app de pseudocódigo en Android y cómo usar Jaguar Code, gratis y sin cuenta.',
    resumen:
        'PSeInt es un programa de escritorio para Windows, macOS y Linux. Si tu práctica la haces desde el celular, necesitas una app que corra pseudocódigo en Android o en el navegador, y que abra tus archivos .psc.',
    secciones: [
      (
        'que-es',
        'Qué es PSeInt y dónde se instala',
        '''
<p>PSeInt es un programa gratuito y de código abierto para aprender a programar con pseudocódigo en español. Se descarga de su <a href="https://pseint.sourceforge.net/" rel="noopener">sitio oficial</a> y se instala en computadoras con Windows, macOS o Linux. Muchas escuelas lo usan en la materia de lógica de programación.</p>
<p>Su archivo de trabajo es el <code>.psc</code>: un texto con el algoritmo. Ese formato es el que otras herramientas pueden abrir y guardar.</p>''',
      ),
      (
        'solo-celular',
        'Si solo tienes celular',
        '''
<p>Para muchos estudiantes el celular es el único aparato propio: la computadora es de la sala de cómputo o de la familia. Si la tarea es un algoritmo, lo que necesitas es una aplicación que corra pseudocódigo en el celular, ya sea instalada en Android o abierta desde el navegador.</p>
<p>No toda app de pseudocódigo sirve igual. Antes de elegir una, revisa estos puntos.</p>''',
      ),
      (
        'que-buscar',
        'Qué buscar en una app de pseudocódigo para celular',
        '''
${tabla('Lista para comparar cualquier opción', ['Qué revisar', 'Por qué importa'], [
          ['Entiende el pseudocódigo en español', 'Que acepte Algoritmo, Leer, Escribir, Si, Mientras, Para y Segun como los pide tu profesor.'],
          ['Abre y guarda archivos <code>.psc</code>', 'Para pasar tus programas de la computadora al celular y entregarlos.'],
          ['Funciona sin internet', 'Para practicar en el camión o donde no hay datos.'],
          ['No pide cuenta ni muestra anuncios', 'Para empezar en un minuto y sin distracciones.'],
          ['Los errores salen en español', 'Para saber en qué línea y cómo arreglarlo.'],
          ['Diagrama de flujo y prueba de escritorio', 'Porque en clase casi siempre piden las dos cosas junto con el código.'],
        ])}''',
      ),
      (
        'jaguar-code',
        'Jaguar Code como opción para el celular',
        '''
<p>Jaguar Code es una app gratuita para aprender lógica de programación que cumple esa lista: escribes pseudocódigo en español, lo ejecutas y ves la consola; abre y guarda archivos <code>.psc</code>; funciona sin internet, no pide cuenta ni muestra anuncios, y es software libre con licencia AGPL. Se instala en Android o se abre en el navegador, y también corre en la computadora.</p>
<p>Además del código, trae el diagrama de flujo de tu programa, una vista de bloques, la prueba de escritorio hecha sola, doce retos con pistas y lecciones cortas. Los errores salen en español, con la línea y una sugerencia.</p>
<p>Este es un ejemplo sencillo, como los que se hacen en clase:</p>
${codigo('''
Algoritmo promedio
    Escribir "Primera calificación:"
    Leer a
    Escribir "Segunda calificación:"
    Leer b
    p <- (a + b) / 2
    Escribir "Promedio: ", p
FinAlgoritmo
''', entradas: ['8', '10'], salida: 'Primera calificación:\nSegunda calificación:\nPromedio: 9')}
<p>Jaguar Code es un proyecto independiente: no es PSeInt ni está afiliado a él. Lo mencionamos porque el pseudocódigo básico que se enseña con PSeInt es el mismo que Jaguar Code entiende.</p>''',
      ),
      (
        'tus-archivos',
        'Cómo llevar tus programas al celular',
        '''
<ol>
  <li>En la computadora, guarda tu algoritmo como archivo <code>.psc</code>.</li>
  <li>Mándatelo por correo, WhatsApp o Google Drive.</li>
  <li>En el celular, abre Jaguar Code, entra al Taller y elige <b>Abrir archivo (.psc)</b>.</li>
  <li>Toca Ejecutar y revisa la consola.</li>
</ol>
<p>Jaguar Code entiende el pseudocódigo básico (variables, decisiones, ciclos, arreglos y funciones). Si un programa usa algo muy particular de otra herramienta, la app te dice en qué línea no lo entendió. Más detalles en la guía para <a href="/guias/abrir-archivos-psc-en-android">abrir archivos .psc en Android</a>.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿En qué dispositivos se instala PSeInt?',
        'Su sitio oficial ofrece descargas para computadoras con Windows, macOS y Linux. En el celular se usan otras aplicaciones de pseudocódigo.',
      ),
      (
        '¿Puedo abrir en Jaguar Code los archivos .psc que hice en la computadora?',
        'Sí. Jaguar Code abre y guarda archivos .psc. Entiende el pseudocódigo básico; si algo no lo entiende, te dice la línea.',
      ),
      (
        '¿Jaguar Code es gratis y necesita cuenta?',
        'Es gratis, no tiene anuncios, no pide cuenta para usarse y es software libre con licencia AGPL.',
      ),
      (
        '¿Funciona sin internet?',
        'Sí. Escribir, ejecutar, ver el diagrama y hacer la prueba de escritorio funcionan sin conexión. Solo las clases en línea necesitan internet.',
      ),
    ],
    relacionadas: ['abrir-archivos-psc-en-android', 'que-es-el-pseudocodigo'],
  ),
  Guia(
    slug: 'abrir-archivos-psc-en-android',
    titulo: 'Cómo abrir un archivo .psc en el celular (Android)',
    h1: 'Cómo abrir un archivo .psc en el celular',
    descripcion:
        'Un archivo .psc es un algoritmo en pseudocódigo. Aprende a abrirlo, ejecutarlo y guardarlo desde Android con Jaguar Code, sin cuenta y sin internet.',
    resumen:
        'Un archivo .psc es un texto con un algoritmo en pseudocódigo. Para abrirlo en el celular necesitas una app que lo entienda: con Jaguar Code se abre desde el Taller y se ejecuta al momento.',
    secciones: [
      (
        'que-es',
        'Qué es un archivo .psc',
        '''
<p>Un <code>.psc</code> es un archivo de texto que guarda un algoritmo escrito en pseudocódigo, por ejemplo el de un promedio o el de una tabla de multiplicar. Varias herramientas de pseudocódigo en español lo usan, así que sirve para pasar un programa de un aparato a otro. Si lo abres con un editor de texto, lo ves como cualquier texto; para ejecutarlo hace falta una app de pseudocódigo.</p>''',
      ),
      (
        'pasos',
        'Pasos para abrirlo en Android',
        '''
<ol>
  <li><b>Consigue el archivo en el celular.</b> Descárgalo de tu correo, de WhatsApp o de Google Drive. Si lo tienes en la computadora, mándatelo a ti mismo.</li>
  <li><b>Abre Jaguar Code.</b> Instálala en Android o ábrela desde el navegador en <code>app.jaguarcode.org</code>.</li>
  <li><b>Entra al Taller</b> y toca los tres puntos de arriba a la derecha.</li>
  <li><b>Elige «Abrir archivo (.psc)»</b> y selecciona el archivo.</li>
  <li><b>Toca Ejecutar.</b> La consola te muestra lo que hace el programa y te pide los datos que haga falta.</li>
</ol>
<p>El programa se guarda en tu Taller: puedes cambiarlo y volver a ejecutarlo cuando quieras, aunque no tengas internet.</p>''',
      ),
      (
        'guardar',
        'Cómo guardar tu programa como .psc',
        '''
<p>Para entregar o llevar tu trabajo a otra computadora, en el mismo menú de los tres puntos elige <b>Guardar como archivo (.psc)</b>. Si quieres todos tus programas a la vez, el Taller tiene <b>Guardar todos mis programas</b>, que arma un solo archivo comprimido con un <code>.psc</code> por programa.</p>''',
      ),
      (
        'si-falla',
        'Si el archivo no abre bien',
        '''
<ul>
  <li><b>Las letras con acento salen raras.</b> Pasa cuando el archivo se guardó con otra codificación de texto. Jaguar Code intenta leerlo bien, pero si falla, vuelve a guardarlo en la herramienta original como texto con acentos.</li>
  <li><b>Aparece un error en una línea.</b> El programa usa algo que Jaguar Code no entiende. El mensaje dice la línea y una sugerencia; cambia esa instrucción por una equivalente.</li>
  <li><b>El archivo es muy largo.</b> Funciona, pero conviene revisar primero que ejecute con datos pequeños.</li>
</ul>
<p>Prueba con este programa, que puedes copiar a un archivo de texto y guardar como <code>promedio.psc</code>:</p>
${codigo('''
Algoritmo suma
    Leer a, b
    Escribir "Suma: ", a + b
FinAlgoritmo
''', entradas: ['3', '4'], salida: 'Suma: 7')}''',
      ),
    ],
    preguntas: [
      (
        '¿Qué app abre archivos .psc en Android?',
        'Jaguar Code abre y guarda archivos .psc en Android y en el navegador. Es gratis, no pide cuenta y funciona sin internet.',
      ),
      (
        '¿Necesito internet para abrir un .psc?',
        'No. Una vez que tienes el archivo en el celular, abrirlo, ejecutarlo y guardarlo funciona sin conexión.',
      ),
      (
        '¿Puedo convertir un .psc a otro formato?',
        'Jaguar Code muestra tu programa como diagrama de flujo, como bloques y, si activas esa vista, traducido a Python. El diagrama se puede guardar como imagen.',
      ),
    ],
    relacionadas: ['pseint-en-el-celular', 'que-es-el-pseudocodigo'],
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
      <a href="/retos">Retos</a>
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
    <a href="/retos">Retos</a>
    <a href="/descargas">Descargas</a>
    <a href="/manual">Manual</a>
    <a href="https://www.facebook.com/jaguareducation">Facebook</a>
    <a href="https://github.com/panterino/jaguar">Código en GitHub</a>
    <a href="#" data-analitica-cambiar>Analítica</a>
  </div>
</footer>
<script src="/acceso.js" defer></script>
<script src="/analitica.js" defer></script>
</body>
</html>
''';

String cta() => '''
<aside class="cta-guia" aria-labelledby="cta-t">
  <h2 id="cta-t">Practica esto en Jaguar Code</h2>
  <p>Escribe pseudocódigo, mira su diagrama y haz la prueba de escritorio desde el celular. Gratis, sin anuncios y sin cuenta.</p>
  <div class="botones"><a class="boton principal" href="https://app.jaguarcode.org/">Abrir la app</a></div>
  <p class="aviso-prueba"><b>Versión de prueba.</b> Puede tener errores y cambiar. Tus programas se guardan solo en tu dispositivo.</p>
</aside>''';

String json(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', ' ');

String pagina(Guia g) {
  final ruta = '/guias/${g.slug}';
  final faq = g.preguntas
      .map((p) => '{"@type":"Question","name":"${json(p.$1)}","acceptedAnswer":{"@type":"Answer","text":"${json(p.$2)}"}}')
      .join(',');
  final datos =
      '''
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
      "datePublished": "${g.publicada}",
      "dateModified": "${g.publicada}",
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
    b.writeln(
      '      <section id="${s.$1}">\n        <h2>${esc(s.$2)}</h2>\n${s.$3.replaceAll('@@DIAGRAMA@@', diagramaPromedio)}\n      </section>',
    );
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
  final datos =
      '''
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
    <p class="resumen">Guías cortas, con ejemplos que puedes copiar y ejecutar en Jaguar. Empieza por la primera y sigue en orden, o salta a lo que necesites.</p>
    <div class="tarjetas">
''');
  var i = 0;
  for (final g in guias) {
    b.writeln(
      '      <article class="tarjeta revela" style="--d:${i++ % 3}"><h2 style="font-size:20px;margin:0 0 8px"><a href="/guias/${g.slug}">${esc(g.h1)}</a></h2><p>${esc(g.resumen)}</p></article>',
    );
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
