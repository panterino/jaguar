// Las páginas de /errores para los errores AL EJECUTAR: el programa se entiende,
// pero algo falla mientras corre (lib/src/interpreter.dart y builtins.dart del
// paquete jaguar_core). Cada ejemplo con `error:` lo comprueba la prueba del
// sitio (apps/jaguar/test/sitio_test.dart) con el mensaje exacto.
import 'guias_html.dart';

const _publicada = '2026-11-05';

/// El aviso tal como lo ve quien usa Jaguar.
String aviso(int linea, String mensaje, [String? sugerencia]) =>
    '<p class="aviso-error" role="note"><b>Error al ejecutar en la línea $linea</b><br>${esc(mensaje)}${sugerencia == null ? '' : ' ${esc(sugerencia)}'}</p>';

final erroresEjecucion = <Guia>[
  Guia(
    carpeta: 'errores',
    slug: 'variable-sin-valor',
    titulo: 'Error «No encuentro la variable» o «todavía no tiene valor»: qué significa y cómo arreglarlo',
    h1: '«No encuentro la variable» y «todavía no tiene valor»',
    descripcion:
        'Qué significan los errores «No encuentro la variable …» y «La variable … todavía no tiene valor en este punto» en pseudocódigo, por qué aparecen y cómo arreglarlos.',
    resumen:
        'Estos errores aparecen cuando el programa usa una variable que todavía no existe o que existe pero aún no guarda nada. Se arreglan dándole un valor antes de usarla, con una asignación o con Leer.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(2, "No encuentro la variable 'total'.", "Revisa cómo la escribiste. Si es nueva, créala antes con 'total <- 0' o con 'Leer total'.")}
<p>Una variable es una caja con nombre. Para usarla, primero tiene que existir y tener algo adentro. Jaguar te avisa en dos situaciones parecidas:</p>
<ul>
  <li><b>«No encuentro la variable»:</b> el nombre no existe. O nunca la creaste, o la escribiste distinto (<code>total</code> y <code>totall</code> son dos variables diferentes).</li>
  <li><b>«Todavía no tiene valor en este punto»:</b> la variable existe, por ejemplo porque la declaraste con <code>Definir</code>, pero hasta esa línea nadie le guardó un dato.</li>
</ul>
<p>En los dos casos el programa se detiene en la línea donde se usa, porque no sabe qué valor poner ahí.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>La variable nunca se creó</h3>
${codigo('''
Algoritmo suma
    suma <- total + 1
    Escribir suma
FinAlgoritmo
''', error: "No encuentro la variable 'total'.")}
${aviso(2, "No encuentro la variable 'total'.", "Revisa cómo la escribiste. Si es nueva, créala antes con 'total <- 0' o con 'Leer total'.")}
<p>Se arregla dándole un valor a <code>total</code> en una línea de arriba:</p>
${codigo('''
Algoritmo suma
    total <- 0
    suma <- total + 1
    Escribir suma
FinAlgoritmo
''', salida: '1')}
<h3>Declarada, pero sin valor</h3>
<p><code>Definir</code> solo reserva la caja y su tipo; no le pone nada adentro:</p>
${codigo('''
Algoritmo edad
    Definir n Como Entero
    Escribir n
FinAlgoritmo
''', error: "La variable 'n' todavía no tiene valor en este punto.")}
${aviso(3, "La variable 'n' todavía no tiene valor en este punto.", "Antes de usarla dale un valor, con 'n <- 0' o con 'Leer n'. Esa línea debe estar más arriba que esta.")}
<p>Pídele el dato a la persona con <code>Leer</code>, o asígnale un valor:</p>
${codigo('''
Algoritmo edad
    Definir n Como Entero
    Leer n
    Escribir "Tienes ", n, " años"
FinAlgoritmo
''', entradas: ['15'], salida: 'Tienes 15 años')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>Escribiste el nombre distinto en dos lugares: una mayúscula no importa, pero una letra de más o de menos sí.</li>
  <li>Usas la variable antes de la línea donde le das valor.</li>
  <li>Declaraste la variable con <code>Definir</code> y olvidaste el <code>Leer</code> o la asignación.</li>
  <li>El valor se asigna dentro de un <code>Si</code> que no siempre se cumple, y luego se usa afuera.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Da un valor inicial a toda variable en cuanto la creas: <code>total &lt;- 0</code> para los acumuladores, y un <code>Leer</code> para lo que viene de la persona. Con la prueba de escritorio ves en qué fila aparece cada variable: si una columna sigue vacía cuando la necesitas, ahí está el problema. Hay una guía en <a href="/guias/prueba-de-escritorio">la prueba de escritorio</a>.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Importan las mayúsculas en el nombre de una variable?',
        'No. Jaguar no distingue mayúsculas ni acentos: Total, total y TOTAL son la misma variable. Lo que sí importa es que las letras sean las mismas.',
      ),
      (
        '¿Una variable sin valor vale cero?',
        'No. En Jaguar una variable sin valor no vale nada, y por eso usarla es un error. Si necesitas que empiece en cero, asígnalo tú: total <- 0.',
      ),
      (
        '¿Este error sale también en PSeInt?',
        'PSeInt avisa de este problema con otro mensaje, pero la causa es la misma: se usa una variable que no tiene valor. El código arreglado de esta página funciona igual en PSeInt.',
      ),
    ],
    relacionadas: ['variables-y-tipos-de-datos', 'prueba-de-escritorio', 'valor-que-no-corresponde-al-tipo'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'posicion-fuera-del-arreglo',
    titulo: 'Error «La posición … está fuera del arreglo»: qué significa y cómo arreglarlo',
    h1: '«La posición … está fuera del arreglo»',
    descripcion:
        'Qué significa el error «La posición 4 está fuera del arreglo», «Esa posición todavía no tiene valor» y «no es un arreglo» en pseudocódigo, y cómo arreglarlo con ejemplos.',
    resumen:
        'Este error aparece cuando el programa usa una posición que el arreglo no tiene. En Jaguar las posiciones empiezan en 1 y terminan en el tamaño con el que creaste el arreglo.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(3, "La posición 4 está fuera del arreglo 'notas'.", 'Las posiciones válidas van de 1 a 3.')}
<p>Un arreglo es una fila de casillas numeradas. Si lo creas con <code>Dimension notas[3]</code>, tiene tres casillas: la 1, la 2 y la 3. Pedir la 4 es como buscar un asiento que no existe, y Jaguar se detiene para avisarte.</p>
<p>En Jaguar las posiciones empiezan en <b>1</b>, no en 0. El mensaje siempre te dice cuáles son las válidas.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>Una posición de más</h3>
${codigo('''
Algoritmo lista
    Dimension notas[3]
    notas[4] <- 10
FinAlgoritmo
''', error: "La posición 4 está fuera del arreglo 'notas'.")}
${aviso(3, "La posición 4 está fuera del arreglo 'notas'.", 'Las posiciones válidas van de 1 a 3.')}
<p>Usa una posición que exista, o crea el arreglo con más casillas:</p>
${codigo('''
Algoritmo lista
    Dimension notas[4]
    notas[4] <- 10
    Escribir notas[4]
FinAlgoritmo
''', salida: '10')}
<h3>Empezar en 0</h3>
<p>Si vienes de otro lenguaje, es normal empezar en 0. En Jaguar la primera casilla es la 1:</p>
${codigo('''
Algoritmo lista
    Dimension notas[3]
    notas[0] <- 10
FinAlgoritmo
''', error: "La posición 0 está fuera del arreglo 'notas'.")}
<p>Con un ciclo, que vaya de 1 al tamaño:</p>
${codigo('''
Algoritmo lista
    Dimension notas[3]
    Para i <- 1 Hasta 3 Hacer
        notas[i] <- i * 10
    FinPara
    Escribir notas[1], " ", notas[3]
FinAlgoritmo
''', salida: '10 30')}
<h3>Una posición que nunca se llenó</h3>
${codigo('''
Algoritmo lista
    Dimension notas[3]
    notas[1] <- 8
    Escribir notas[2]
FinAlgoritmo
''', error: "Esa posición del arreglo 'notas' todavía no tiene valor.")}
<p>La posición existe, pero está vacía. Llénala antes de leerla:</p>
${codigo('''
Algoritmo lista
    Dimension notas[3]
    notas[1] <- 8
    notas[2] <- 9
    Escribir notas[1] + notas[2]
FinAlgoritmo
''', salida: '17')}
<h3>Usar como arreglo algo que no lo es</h3>
${codigo('''
Algoritmo lista
    n <- 5
    n[1] <- 3
FinAlgoritmo
''', error: "'n' no es un arreglo.")}
<p>Para que una variable sea arreglo hay que crearla con <code>Dimension</code> antes: <code>Dimension n[5]</code>. Más sobre esto en la guía de <a href="/guias/arreglos-en-pseudocodigo">arreglos</a>.</p>
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>El ciclo llega más lejos que el arreglo: <code>Para i &lt;- 1 Hasta 4</code> con un arreglo de tres casillas.</li>
  <li>Se empieza en 0, como en otros lenguajes, o se calcula una posición que se sale por uno.</li>
  <li>El tamaño se escribió mal en <code>Dimension</code>, o cambió el dato que lo define.</li>
  <li>Se lee una casilla antes de llenarla.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Que el ciclo y el arreglo usen el mismo número: guarda el tamaño en una variable (<code>n &lt;- 3</code>), crea el arreglo con <code>Dimension notas[n]</code> y recorre con <code>Para i &lt;- 1 Hasta n</code>. Así, si cambias el tamaño, cambia todo junto. Y en la prueba de escritorio, mira qué valor tiene <code>i</code> en la última fila.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Por qué las posiciones empiezan en 1 y no en 0?',
        'Porque así lo hace el pseudocódigo de PSeInt, que Jaguar sigue. En muchos lenguajes de programación (Python, Java, C) empiezan en 0; la guía de pseudocódigo a Python explica cómo cambian los números.',
      ),
      (
        '¿Puedo agrandar un arreglo después de crearlo?',
        'No. Un arreglo tiene un tamaño fijo desde Dimension. Si necesitas más casillas, créalo más grande desde el principio, y Jaguar avisa si intentas dimensionar el mismo arreglo dos veces.',
      ),
      (
        '¿Y si el tamaño lo escribe la persona?',
        'Puedes leerlo con Leer y usarlo en Dimension: Leer n, Dimension notas[n]. Jaguar exige que sea al menos 1.',
      ),
    ],
    relacionadas: ['arreglos-en-pseudocodigo', 'de-pseudocodigo-a-python', 'ciclos-mientras-para-repetir'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'valor-que-no-corresponde-al-tipo',
    titulo: 'Error «No se puede guardar el número … porque es de tipo Entero» y «Se esperaba un número»: cómo arreglarlo',
    h1: 'Un valor que no corresponde al tipo de la variable',
    descripcion:
        'Qué significan los errores «No se puede guardar el número 2.5 en n porque es de tipo Entero» y «Se esperaba un número entero para n, pero se escribió …» en pseudocódigo, y cómo arreglarlos.',
    resumen:
        'Estos errores aparecen cuando una variable con tipo (Entero, Real, Texto o Lógico) recibe un valor de otro tipo: un decimal en un Entero, un número en un Texto o letras donde se esperaba un número.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(3, "No se puede guardar el número 2.5 en 'n' porque es de tipo Entero.", 'Usa Trunc() o Redon(), o define la variable como Real.')}
<p>Cuando declaras una variable con <code>Definir</code> y un tipo, Jaguar vigila que solo guarde valores de ese tipo: <code>Entero</code> acepta números sin decimales, <code>Real</code> cualquier número, <code>Texto</code> palabras y <code>Logico</code> Verdadero o Falso. Si intentas guardar otra cosa, el programa se detiene.</p>
<p>El mismo cuidado se aplica a <code>Leer</code>: si la variable es entera y la persona escribe «hola», aparece «Se esperaba un número entero…».</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>Un decimal en un Entero</h3>
${codigo('''
Algoritmo a
    Definir n Como Entero
    n <- 2.5
FinAlgoritmo
''', error: "No se puede guardar el número 2.5 en 'n' porque es de tipo Entero.")}
${aviso(3, "No se puede guardar el número 2.5 en 'n' porque es de tipo Entero.", 'Usa Trunc() o Redon(), o define la variable como Real.')}
<p>Si necesitas decimales, define la variable como <code>Real</code>. Si quieres un entero, redondea o corta el decimal:</p>
${codigo('''
Algoritmo a
    Definir n Como Entero
    n <- Redon(2.5)
    Escribir n
FinAlgoritmo
''', salida: '3')}
<h3>Un número en un Texto</h3>
${codigo('''
Algoritmo a
    Definir t Como Texto
    t <- 5
FinAlgoritmo
''', error: "No se puede guardar el número 5 en 't' porque es de tipo Texto.")}
<p>Para guardar un número como texto, conviértelo:</p>
${codigo('''
Algoritmo a
    Definir t Como Texto
    t <- ConvertirATexto(5)
    Escribir "Número: " + t
FinAlgoritmo
''', salida: 'Número: 5')}
<h3>Leer un entero y escribir letras</h3>
${codigo('''
Algoritmo a
    Definir n Como Entero
    Leer n
FinAlgoritmo
''', entradas: ['hola'], error: 'Se esperaba un número entero para \'n\', pero se escribió "hola".')}
<p>El programa está bien; el dato es el que no corresponde. Con un número, funciona:</p>
${codigo('''
Algoritmo a
    Definir n Como Entero
    Leer n
    Escribir n * 2
FinAlgoritmo
''', entradas: ['7'], salida: '14')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>Una división o un promedio da decimales y la variable se definió como <code>Entero</code>.</li>
  <li>Se mezclan números y textos en la misma variable.</li>
  <li>La persona escribió un dato que no es del tipo que pide el <code>Leer</code>: letras donde va un número, o un decimal donde va un entero.</li>
  <li>Se escribió <code>Logico</code> y se esperaba Verdadero o Falso, pero llegó otra palabra.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Elige el tipo según lo que vas a guardar: <code>Entero</code> para contar, <code>Real</code> para medir o promediar, <code>Texto</code> para palabras. Si dudas, <code>Real</code> acepta enteros también. En <a href="/guias/variables-y-tipos-de-datos">la guía de variables y tipos</a> está la tabla completa.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Tengo que usar Definir para cada variable?',
        'No. Sin Definir, Jaguar decide el tipo con el primer valor que recibe y no exige nada más. Si usas Definir, entonces sí vigila el tipo.',
      ),
      (
        '¿Qué diferencia hay entre Trunc y Redon?',
        'Trunc corta los decimales (3.9 queda en 3) y Redon redondea al entero más cercano (3.9 queda en 4).',
      ),
      (
        '¿Este error sale también en PSeInt?',
        'PSeInt trata los tipos de otra manera, más permisiva en algunos casos. La causa es la misma: el valor no corresponde al tipo definido.',
      ),
    ],
    relacionadas: ['variables-y-tipos-de-datos', 'variable-sin-valor', 'operacion-con-texto-y-numero'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'no-hay-mas-datos-para-leer',
    titulo: 'Error «El programa pidió un dato con Leer, pero ya no hay datos de entrada»: qué significa',
    h1: '«Pidió un dato con Leer, pero ya no hay datos de entrada»',
    descripcion:
        'Qué significa el error «El programa pidió un dato con Leer, pero ya no hay datos de entrada» en pseudocódigo y cómo arreglarlo: faltan datos en la prueba o en la entrada.',
    resumen:
        'Este error aparece cuando el programa tiene más instrucciones Leer que datos de entrada. Pasa en las pruebas, en la prueba de escritorio y en los ejercicios con casos de prueba.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(3, 'El programa pidió un dato con Leer, pero ya no hay datos de entrada.')}
<p>Cada <code>Leer</code> necesita un dato. Cuando usas Jaguar normalmente, el programa se detiene y te espera a que lo escribas. Pero cuando el programa se ejecuta con datos ya escritos, como en la <a href="/herramientas/prueba-de-escritorio">herramienta de prueba de escritorio</a> o en las pruebas de un ejercicio, los datos se acaban: si hay tres <code>Leer</code> y solo diste dos datos, el tercero no tiene nada que leer.</p>
<p>El programa no está mal escrito: le faltan datos.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlo',
        '''
<h3>Faltan datos</h3>
${codigo('''
Algoritmo suma
    Leer n
    Leer m
    Escribir n + m
FinAlgoritmo
''', entradas: ['5'], error: 'El programa pidió un dato con Leer, pero ya no hay datos de entrada.')}
${aviso(3, 'El programa pidió un dato con Leer, pero ya no hay datos de entrada.')}
<p>Hay dos <code>Leer</code>, así que hacen falta dos datos, uno por renglón y en el orden en que el programa los pide:</p>
${codigo('''
Algoritmo suma
    Leer n
    Leer m
    Escribir n + m
FinAlgoritmo
''', entradas: ['5', '3'], salida: '8')}
<h3>Un ciclo que lee de más</h3>
<p>Si un <code>Leer</code> está dentro de un ciclo, se repite en cada vuelta. Con tres vueltas se necesitan tres datos:</p>
${codigo('''
Algoritmo total
    suma <- 0
    Para i <- 1 Hasta 3 Hacer
        Leer x
        suma <- suma + x
    FinPara
    Escribir suma
FinAlgoritmo
''', entradas: ['4', '6', '10'], salida: '20')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>En la herramienta de prueba de escritorio, el cuadro de datos de entrada tiene menos renglones que <code>Leer</code>.</li>
  <li>Un ejercicio tiene una prueba con menos datos de los que pide la solución.</li>
  <li>Un ciclo con <code>Leer</code> dentro da más vueltas de las que supones.</li>
  <li>Un <code>Mientras</code> que lee hasta un valor final nunca recibe ese valor.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Cuenta los <code>Leer</code> que va a ejecutar el programa (incluidos los de los ciclos) y escribe un dato por cada uno, un valor por renglón. Si el programa lee hasta que llegue un valor de salida, como un 0, no olvides ponerlo al final de los datos.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Este error sale cuando uso Jaguar normalmente?',
        'No. En el uso normal, el programa te espera y tú escribes el dato. Solo aparece cuando los datos ya están escritos de antemano y se acaban.',
      ),
      (
        '¿En qué orden va cada dato?',
        'En el mismo orden en que el programa ejecuta los Leer. El primer renglón es para el primer Leer, el segundo para el segundo, y así.',
      ),
    ],
    relacionadas: ['prueba-de-escritorio', 'variable-sin-valor', 'demasiados-pasos-ciclo-infinito'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'demasiados-pasos-ciclo-infinito',
    titulo: 'Error «El programa se detuvo porque llevaba demasiados pasos»: ciclo infinito, cómo arreglarlo',
    h1: '«El programa se detuvo porque llevaba demasiados pasos»',
    descripcion:
        'Qué significa el error «El programa se detuvo porque llevaba demasiados pasos» en pseudocódigo: un ciclo infinito en Mientras o Repetir, por qué pasa y cómo arreglarlo.',
    resumen:
        'Este error aparece cuando un ciclo nunca termina, casi siempre porque dentro del ciclo no cambia nada que haga falsa la condición. Jaguar lo detiene para que el programa no se quede trabajando para siempre.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(4, 'El programa se detuvo porque llevaba demasiados pasos (1000000).', 'Parece un ciclo que no termina. Dentro del Mientras o del Repetir debe cambiar algo, por ejemplo n <- n - 1, para que la condición deje de cumplirse.')}
<p>Un ciclo repite sus instrucciones mientras se cumpla una condición. Si dentro del ciclo nada cambia lo que la condición revisa, la condición se cumple siempre y el ciclo nunca termina. Para que el programa no se quede trabajando para siempre, Jaguar cuenta los pasos y, al llegar a un límite, lo detiene y te avisa.</p>
<p>El número entre paréntesis es ese límite. Puede variar según dónde ejecutes el programa.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>El contador no avanza</h3>
${codigo('''
Algoritmo contar
    i <- 1
    Mientras i < 5 Hacer
        Escribir i
    FinMientras
FinAlgoritmo
''', error: 'El programa se detuvo porque llevaba demasiados pasos (1000000).')}
<p>La condición pregunta si <code>i</code> es menor que 5, pero <code>i</code> siempre vale 1. Hay que hacerla crecer dentro del ciclo:</p>
${codigo('''
Algoritmo contar
    i <- 1
    Mientras i < 5 Hacer
        Escribir i
        i <- i + 1
    FinMientras
FinAlgoritmo
''', salida: '1\n2\n3\n4')}
<h3>Una condición que nunca se logra</h3>
<p>Con <code>Repetir</code> pasa igual: la condición de <code>Hasta Que</code> debe poder cumplirse algún día.</p>
${codigo('''
Algoritmo cuenta
    n <- 1
    Repetir
        n <- n + 1
    Hasta Que n = 0
FinAlgoritmo
''', error: 'El programa se detuvo porque llevaba demasiados pasos (1000000).')}
<p>Aquí <code>n</code> solo crece, así que nunca llega a 0. Se arregla con una condición que sí se alcance:</p>
${codigo('''
Algoritmo cuenta
    n <- 1
    Repetir
        n <- n + 1
    Hasta Que n >= 5
    Escribir n
FinAlgoritmo
''', salida: '5')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>Falta la instrucción que hace avanzar el ciclo: <code>i &lt;- i + 1</code>.</li>
  <li>El contador cambia en la dirección contraria a la condición: sube cuando debía bajar.</li>
  <li>La condición revisa una variable distinta de la que cambia dentro del ciclo.</li>
  <li>Un <code>Mientras</code> o un <code>Repetir</code> espera un dato con <code>Leer</code> que nunca llega al valor de salida.</li>
  <li>Más raro: el programa sí termina, pero hace tantísimos pasos que supera el límite.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Antes de escribir un ciclo, responde: ¿qué variable cambia en cada vuelta y hacia dónde? Esa es la que debe estar en la condición. La prueba de escritorio lo muestra enseguida: si el valor de la variable de la condición es el mismo en todas las filas, el ciclo no avanza. Hay más sobre ciclos en la guía de <a href="/guias/ciclos-mientras-para-repetir">Mientras, Para y Repetir</a>.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Puedo cambiar el límite de pasos?',
        'El límite lo pone cada lugar donde se ejecuta el programa, y no lo eliges tú. En la herramienta de prueba de escritorio, un ciclo infinito no da este error: la tabla se corta en las primeras filas y avisa. Si tu programa es legítimo y muy pesado, revisa antes que no haya un ciclo infinito, porque casi siempre es eso.',
      ),
      (
        '¿Pasa con el ciclo Para?',
        'Casi nunca, porque Para avanza solo. Solo puede pasar si el paso es 0, y en ese caso Jaguar avisa con otro mensaje.',
      ),
      (
        '¿Qué pasa si detengo el programa yo mismo?',
        'En la app, el botón rojo de detener corta el programa en cualquier momento. El error de esta página es el que ponen las pruebas automáticas cuando nadie puede detenerlo.',
      ),
    ],
    relacionadas: ['ciclos-mientras-para-repetir', 'prueba-de-escritorio', 'no-hay-mas-datos-para-leer'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'division-entre-cero',
    titulo: 'Error «No se puede dividir entre cero» (y MOD entre cero): qué significa y cómo arreglarlo',
    h1: '«No se puede dividir entre cero»',
    descripcion:
        'Qué significa el error «No se puede dividir entre cero» y «No se puede calcular MOD entre cero» en pseudocódigo, y cómo evitarlo preguntando antes con un Si.',
    resumen:
        'Este error aparece cuando una división, o un MOD, tiene un divisor que vale 0 al llegar a esa línea. Se evita preguntando antes si el divisor es distinto de cero.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(3, 'No se puede dividir entre cero.', 'El divisor valía 0 al llegar aquí. Revisa de dónde sale ese valor, o pregunta antes: Si divisor <> 0 Entonces ... FinSi')}
<p>Dividir entre cero no tiene resultado. Jaguar se detiene en la línea de la división y te dice que el divisor valía 0 justo en ese momento. Lo mismo pasa con <code>MOD</code>, que calcula el residuo de una división: <code>10 MOD 0</code> tampoco existe.</p>
<p>El programa puede estar bien para casi todos los datos y fallar solo cuando alguien escribe un 0, o cuando un cálculo anterior deja el divisor en 0.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>El divisor llega en 0</h3>
${codigo('''
Algoritmo dividir
    Leer b
    Escribir 10 / b
FinAlgoritmo
''', entradas: ['0'], error: 'No se puede dividir entre cero.')}
${aviso(3, 'No se puede dividir entre cero.', 'El divisor valía 0 al llegar aquí. Revisa de dónde sale ese valor, o pregunta antes: Si divisor <> 0 Entonces ... FinSi')}
<p>Pregunta antes de dividir y avisa si el valor no sirve:</p>
${codigo('''
Algoritmo dividir
    Leer b
    Si b <> 0 Entonces
        Escribir 10 / b
    SiNo
        Escribir "No se puede dividir entre cero"
    FinSi
FinAlgoritmo
''', entradas: ['0'], salida: 'No se puede dividir entre cero')}
<h3>MOD entre cero</h3>
${codigo('''
Algoritmo residuo
    Escribir 10 MOD 0
FinAlgoritmo
''', error: 'No se puede calcular MOD entre cero.')}
<p>Se arregla igual: asegura que el número de la derecha de <code>MOD</code> no sea cero.</p>
<h3>Un promedio sin datos</h3>
<p>Un caso muy común: promediar cuando no hubo ningún dato, porque el contador quedó en 0.</p>
${codigo('''
Algoritmo promedio
    suma <- 0
    cuenta <- 0
    Leer c
    Mientras c <> -1 Hacer
        suma <- suma + c
        cuenta <- cuenta + 1
        Leer c
    FinMientras
    Si cuenta = 0 Entonces
        Escribir "Sin datos"
    SiNo
        Escribir "Promedio: ", suma / cuenta
    FinSi
FinAlgoritmo
''', entradas: ['-1'], salida: 'Sin datos')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>La persona escribió 0 donde iba el divisor.</li>
  <li>Un contador que sirve de divisor nunca avanzó, porque no hubo datos.</li>
  <li>Una resta deja el divisor en 0: <code>x / (a - b)</code> cuando <code>a</code> y <code>b</code> son iguales.</li>
  <li>El divisor es una variable que se usa antes de recibir su valor real.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Antes de cualquier división cuyo divisor venga de un dato o de un cálculo, pregunta con un <code>Si divisor &lt;&gt; 0</code>. Y piensa en los datos «raros»: el cero, el vacío, el valor más chico. Los retos de Jaguar traen casos ocultos con esos valores límite justo para eso.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Dividir entre cero da infinito?',
        'En matemáticas no tiene resultado, y en pseudocódigo es un error. Jaguar no da infinito: se detiene y te muestra la línea.',
      ),
      (
        '¿Qué es MOD?',
        'Es el residuo de una división: 10 MOD 3 da 1, porque 10 entre 3 es 3 y sobra 1. Sirve, por ejemplo, para saber si un número es par: n MOD 2 = 0.',
      ),
    ],
    relacionadas: ['condicionales-si-y-segun', 'variable-sin-valor', 'valor-no-valido-en-una-funcion-o-un-ciclo'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'la-condicion-debe-ser-verdadero-o-falso',
    titulo: 'Error «La condición del Si debe ser Verdadero o Falso»: qué significa y cómo arreglarlo',
    h1: '«La condición debe ser Verdadero o Falso»',
    descripcion:
        'Qué significa el error «La condición del Si debe ser Verdadero o Falso, pero es el número…» en pseudocódigo, por qué aparece y cómo escribir una condición con una comparación.',
    resumen:
        'Este error aparece cuando después de Si, Mientras o Hasta Que va un valor que no es una comparación, por ejemplo solo un número o un texto. Una condición tiene que dar Verdadero o Falso.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(3, "La condición del 'Si' debe ser Verdadero o Falso, pero es el número 5.", 'Usa una comparación, por ejemplo: x > 0')}
<p>Las decisiones y los ciclos preguntan algo que se pueda contestar con sí o no: ¿<code>n &gt; 0</code>?, ¿<code>clave = "jaguar"</code>? Esa pregunta es la condición, y su resultado es Verdadero o Falso. Si en su lugar escribes solo un número o un texto, no hay pregunta, y Jaguar te dice qué recibió.</p>
<p>El mensaje nombra la estructura (<code>Si</code>, <code>Mientras</code>, <code>Repetir</code>) y dice qué valor encontró.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlo',
        '''
<h3>Un número donde va una comparación</h3>
${codigo('''
Algoritmo revisar
    Leer n
    Si n Entonces
        Escribir "x"
    FinSi
FinAlgoritmo
''', entradas: ['5'], error: "La condición del 'Si' debe ser Verdadero o Falso, pero es el número 5.")}
${aviso(3, "La condición del 'Si' debe ser Verdadero o Falso, pero es el número 5.", 'Usa una comparación, por ejemplo: x > 0')}
<p>Compara <code>n</code> con algo para que la condición dé Verdadero o Falso:</p>
${codigo('''
Algoritmo revisar
    Leer n
    Si n > 0 Entonces
        Escribir "Positivo"
    FinSi
FinAlgoritmo
''', entradas: ['5'], salida: 'Positivo')}
<h3>Una sola variable lógica sí funciona</h3>
<p>Una variable que guarda Verdadero o Falso se puede usar tal cual como condición, porque ya es una respuesta de sí o no:</p>
${codigo('''
Algoritmo lleno
    lleno <- Falso
    Si NO lleno Entonces
        Escribir "Hay lugar"
    FinSi
FinAlgoritmo
''', salida: 'Hay lugar')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>Se escribió una variable numérica o de texto sola, como si fuera una pregunta.</li>
  <li>Se usó una asignación en lugar de una comparación: <code>Si n &lt;- 5</code> en vez de <code>Si n = 5</code>.</li>
  <li>Se olvidó el operador de la comparación y quedó solo el valor.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Lee la condición en voz alta como pregunta: «¿n es mayor que 0?». Si no suena a pregunta, falta la comparación. En <a href="/guias/condicionales-si-y-segun">la guía de condicionales</a> están todos los operadores: <code>=</code>, <code>&lt;&gt;</code>, <code>&lt;</code>, <code>&gt;</code>, <code>&lt;=</code>, <code>&gt;=</code>, y los conectores <code>Y</code>, <code>O</code> y <code>NO</code>.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Cuál es la diferencia entre = y <-?',
        'La flecha <- guarda un valor en una variable. El = dentro de una condición compara dos valores. En una condición siempre se usa la comparación.',
      ),
      (
        '¿Esto cambia en un Mientras?',
        'Es igual: la condición del Mientras, del Repetir y del Hasta Que también debe dar Verdadero o Falso. El mensaje nombra la estructura que falló.',
      ),
    ],
    relacionadas: ['condicionales-si-y-segun', 'ciclos-mientras-para-repetir', 'operacion-con-texto-y-numero'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'operacion-con-texto-y-numero',
    titulo: 'Error «necesita números, pero recibió el texto» y «No se puede comparar el texto con el número»',
    h1: 'Una operación mezcla texto y números',
    descripcion:
        'Qué significan los errores «La resta necesita números, pero recibió el texto…» y «No se puede comparar el texto … con el número …» en pseudocódigo, y cómo arreglarlos.',
    resumen:
        'Estos errores aparecen cuando una cuenta o una comparación mezcla un texto con un número. Se arreglan convirtiendo el texto a número, o comparando cosas del mismo tipo.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(3, 'La resta \'-\' necesita números, pero recibió el texto "Ana".')}
<p>Las cuentas (<code>-</code>, <code>*</code>, <code>/</code>) solo se hacen con números, y las comparaciones de orden (<code>&lt;</code>, <code>&gt;</code>) solo entre cosas del mismo tipo: números con números, textos con textos. Si en una de ellas aparece un texto donde va un número, Jaguar se detiene y dice cuál fue.</p>
<p>Ojo con el <code>+</code>: con números suma y con textos los une. Por eso <code>"Ana" + 1</code> no es una cuenta, y las cuentas con <code>-</code> no tienen versión para textos.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>Restar un texto</h3>
${codigo('''
Algoritmo a
    nombre <- "Ana"
    Escribir nombre - 1
FinAlgoritmo
''', error: 'La resta \'-\' necesita números, pero recibió el texto "Ana".')}
<p>Si lo que tienes es un texto con un número adentro, conviértelo con <code>ConvertirANumero</code>:</p>
${codigo('''
Algoritmo a
    texto <- "5"
    Escribir ConvertirANumero(texto) - 1
FinAlgoritmo
''', salida: '4')}
<h3>Comparar un texto con un número</h3>
${codigo('''
Algoritmo a
    texto <- "abc"
    Si texto > 3 Entonces
        Escribir "largo"
    FinSi
FinAlgoritmo
''', error: 'No se puede comparar el texto "abc" con el número 3.')}
<p>Casi siempre lo que querías era comparar el <i>largo</i> del texto, que sí es un número:</p>
${codigo('''
Algoritmo a
    texto <- "abcd"
    Si Longitud(texto) > 3 Entonces
        Escribir "largo"
    FinSi
FinAlgoritmo
''', salida: 'largo')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>Una variable de texto, como un nombre, se usa en una cuenta.</li>
  <li>Se lee con <code>Leer</code> una palabra y se la compara con un número.</li>
  <li>Se confunde el texto <code>"5"</code>, entre comillas, con el número <code>5</code>.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Pregúntate qué tipo tiene cada cosa que usas: lo que va entre comillas es texto, aunque parezca un número. Usa <code>ConvertirANumero</code> y <code>ConvertirATexto</code> para pasar de uno a otro, y <code>Longitud</code> para convertir un texto en un número que se pueda comparar. La guía de <a href="/guias/variables-y-tipos-de-datos">variables y tipos de datos</a> lo explica con ejemplos.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Por qué "5" no es lo mismo que 5?',
        'Entre comillas es un texto: una palabra que se parece a un número. Sin comillas es un número y se puede usar en cuentas. ConvertirANumero pasa de uno al otro.',
      ),
      (
        '¿Puedo comparar dos textos con < o >?',
        'Sí, se comparan por orden alfabético. Lo que no se puede es comparar un texto con un número.',
      ),
    ],
    relacionadas: ['variables-y-tipos-de-datos', 'valor-que-no-corresponde-al-tipo', 'la-condicion-debe-ser-verdadero-o-falso'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'errores-de-funciones-al-ejecutar',
    titulo: 'Error «Demasiadas llamadas a funciones» y «terminó sin darle un valor»: cómo arreglarlo',
    h1: 'Errores de funciones al ejecutar: recursión sin fin y funciones sin valor',
    descripcion:
        'Qué significan los errores «Demasiadas llamadas a funciones, una dentro de otra» y «La función … terminó sin darle un valor a …» en pseudocódigo, y cómo arreglarlos.',
    resumen:
        'Estos errores aparecen cuando una función se llama a sí misma sin parar (le falta el caso base) o cuando una función termina sin haberle dado valor a lo que debía devolver.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(2, 'Demasiadas llamadas a funciones, una dentro de otra.', '¿Una función recursiva que nunca llega a su caso base?')}
<p>Una función puede llamarse a sí misma; a eso se le llama <b>recursión</b>. Para que funcione, necesita un <b>caso base</b>: una situación en la que ya no se llama más y responde directo. Sin caso base, las llamadas se apilan una dentro de otra sin fin, y Jaguar se detiene al llegar a un límite.</p>
<p>El otro error es más sencillo: una función con valor de retorno (<code>Funcion r &lt;- doble(n)</code>) tiene que darle un valor a <code>r</code> antes de terminar.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>Recursión sin caso base</h3>
${codigo('''
Funcion r <- f(n)
    r <- f(n + 1)
FinFuncion

Algoritmo a
    Escribir f(1)
FinAlgoritmo
''', error: 'Demasiadas llamadas a funciones, una dentro de otra.')}
<p>Esta función siempre se llama a sí misma. Agrega el caso base, el momento en que responde sin llamar de nuevo:</p>
${codigo('''
Funcion r <- suma(n)
    Si n = 0 Entonces
        r <- 0
    SiNo
        r <- n + suma(n - 1)
    FinSi
FinFuncion

Algoritmo a
    Escribir suma(4)
FinAlgoritmo
''', salida: '10')}
<h3>Una función que no devuelve nada</h3>
${codigo('''
Funcion r <- doble(n)
    n <- n * 2
FinFuncion

Algoritmo a
    Escribir doble(4)
FinAlgoritmo
''', error: "La función 'doble' terminó sin darle un valor a 'r'.")}
${aviso(5, "La función 'doble' terminó sin darle un valor a 'r'.")}
<p>El resultado hay que guardarlo en <code>r</code>, el nombre que va después de <code>Funcion</code>:</p>
${codigo('''
Funcion r <- doble(n)
    r <- n * 2
FinFuncion

Algoritmo a
    Escribir doble(4)
FinAlgoritmo
''', salida: '8')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>La recursión no tiene caso base, o el caso base nunca se alcanza porque el valor se aleja en vez de acercarse.</li>
  <li>Se llama a la función con el mismo dato una y otra vez.</li>
  <li>Se escribió el resultado en otra variable y no en la que nombra la función.</li>
  <li>El valor se asigna dentro de un <code>Si</code> que no siempre se cumple.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Escribe primero el caso base y después el caso que se llama a sí mismo, y comprueba que cada llamada se acerca un paso al caso base: <code>n - 1</code> se acerca a 0, <code>n + 1</code> se aleja. Para las funciones normales, que el nombre del resultado siempre reciba un valor, con un <code>SiNo</code> si hace falta.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Cuántas llamadas aguanta Jaguar?',
        'Hasta 200 llamadas, una dentro de otra. Una recursión legítima, como sumar hasta 190, funciona sin problema.',
      ),
      (
        '¿Puedo evitar la recursión?',
        'Casi siempre sí: un ciclo Para o Mientras hace lo mismo. La recursión es una forma más corta de escribir ciertos problemas, pero no es obligatoria.',
      ),
    ],
    relacionadas: ['errores-al-usar-funciones', 'funciones-y-subprocesos-en-pseudocodigo', 'demasiados-pasos-ciclo-infinito'],
  ),
  Guia(
    carpeta: 'errores',
    slug: 'valor-no-valido-en-una-funcion-o-un-ciclo',
    titulo: 'Errores de valores no válidos: raíz de un negativo, Ln, tamaño de arreglo y paso de Para',
    h1: 'Un valor no válido en una función, un arreglo o un ciclo',
    descripcion:
        'Qué significan los errores «No se puede sacar la raíz cuadrada de un número negativo», «Ln solo funciona con números mayores que cero», «El tamaño del arreglo debe ser al menos 1» y «El paso del ciclo Para no puede ser 0».',
    resumen:
        'Estos errores aparecen cuando una función matemática recibe un valor para el que no existe resultado, o cuando un arreglo o un ciclo reciben un tamaño o un paso imposible.',
    publicada: _publicada,
    secciones: [
      (
        'que-significa',
        'Qué significa',
        '''
${aviso(2, 'No se puede sacar la raíz cuadrada de un número negativo (-4).')}
<p>Algunas operaciones no tienen resultado para ciertos valores: no hay raíz cuadrada (real) de un número negativo, ni logaritmo de cero, ni arreglos de cero casillas, ni ciclos que avancen de cero en cero. En esos casos Jaguar se detiene y te dice qué valor no sirve, porque casi siempre es un dato que llegó de una cuenta o de la persona.</p>''',
      ),
      (
        'ejemplos',
        'Ejemplos y cómo arreglarlos',
        '''
<h3>La raíz de un negativo</h3>
${codigo('''
Algoritmo a
    Escribir Raiz(-4)
FinAlgoritmo
''', error: 'No se puede sacar la raíz cuadrada de un número negativo (-4).')}
<p>Revisa que el número no sea negativo antes de sacar la raíz:</p>
${codigo('''
Algoritmo a
    Leer x
    Si x >= 0 Entonces
        Escribir Raiz(x)
    SiNo
        Escribir "No hay raíz de un negativo"
    FinSi
FinAlgoritmo
''', entradas: ['-4'], salida: 'No hay raíz de un negativo')}
<h3>Logaritmo de cero</h3>
${codigo('''
Algoritmo a
    Escribir Ln(0)
FinAlgoritmo
''', error: 'Ln solo funciona con números mayores que cero.')}
<h3>Un arreglo sin casillas</h3>
${codigo('''
Algoritmo a
    Dimension v[0]
FinAlgoritmo
''', error: 'El tamaño del arreglo debe ser al menos 1, pero es 0.')}
<p>Si el tamaño lo escribe la persona, revisa que sea al menos 1 antes de crear el arreglo.</p>
<h3>Un Para que no avanza</h3>
${codigo('''
Algoritmo a
    Para i <- 1 Hasta 5 Con Paso 0 Hacer
        Escribir i
    FinPara
FinAlgoritmo
''', error: 'El paso del ciclo Para no puede ser 0.')}
<p>El paso es lo que suma el ciclo en cada vuelta. Con 0 no avanzaría nunca, así que debe ser distinto de cero, positivo para subir y negativo para bajar:</p>
${codigo('''
Algoritmo a
    Para i <- 1 Hasta 5 Con Paso 2 Hacer
        Escribir i
    FinPara
FinAlgoritmo
''', salida: '1\n3\n5')}
''',
      ),
      (
        'causas',
        'Por qué aparece',
        '''
<ul>
  <li>El número viene de un dato de la persona o de un cálculo previo que dio un valor inesperado.</li>
  <li>Una resta deja un valor negativo donde se esperaba positivo.</li>
  <li>El tamaño o el paso se calculan con una variable que vale cero.</li>
</ul>''',
      ),
      (
        'evitarlo',
        'Cómo evitarlo',
        '''
<p>Valida los datos antes de usarlos con un <code>Si</code>: que el número sea mayor o igual que cero, mayor que cero, o distinto de cero según la función. Es el mismo hábito que para <a href="/errores/division-entre-cero">la división entre cero</a>.</p>''',
      ),
    ],
    preguntas: [
      (
        '¿Hay raíz cuadrada de un número negativo?',
        'En matemáticas existen los números complejos, pero Jaguar trabaja con números reales, y ahí no existe. Por eso lo avisa.',
      ),
      (
        '¿Puede el paso del Para ser negativo?',
        'Sí. Un paso negativo hace que el ciclo cuente hacia atrás: Para i <- 5 Hasta 1 Con Paso -1.',
      ),
    ],
    relacionadas: ['division-entre-cero', 'condicionales-si-y-segun', 'ciclos-mientras-para-repetir'],
  ),
];
