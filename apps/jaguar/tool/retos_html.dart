// Genera las páginas de retos de la landing (sitio/retos/*.html) y el mapa del
// sitio (sitio/sitemap.xml). Una página por reto: planteamiento, diagrama de
// flujo, pseudocódigo, cómo pensarlo, errores comunes y el mismo programa en
// Python. Correr desde apps/jaguar:
//   dart run tool/retos_html.dart
// Los ejemplos llevan data-entradas y data-salida: una prueba
// (packages/jaguar_core/test/guias_test.dart) los ejecuta con el intérprete.
import 'dart:convert';
import 'dart:io';

import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/challenges/soluciones.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../../../tool/guias_html.dart' as g;
import 'retos_texto.dart';

/// El orden de la Ruta: los textos van después de las operaciones.
const _orden = [
  'reto-1-01',
  'reto-1-02',
  'reto-1-03',
  'reto-1-04',
  'reto-1-11',
  'reto-1-12',
  'reto-1-05',
  'reto-1-06',
  'reto-1-07',
  'reto-1-08',
  'reto-1-09',
  'reto-1-10',
];

String _ruta(String id) => '/retos/${retosTexto[id]!.slug}';

/// El nombre corto del reto, sin "Reto 3 · ".
String _nombre(Challenge c) => c.exercise.title.replaceFirst(RegExp(r'^Reto \d+ · '), '');

// Diagrama ---------------------------------------------------------------

/// El diagrama de flujo del programa, como SVG que usa los colores de la
/// página (las clases de .diagrama en estilos.css).
String _diagrama(Program programa, String titulo) =>
    flowchartSvg(flowchartsFor(programa, metrics: const FlowMetrics(charWidth: 7.6, margin: 16)).first, title: titulo);

// Páginas ----------------------------------------------------------------

String _parrafos(String statement) => statement.split('\n\n').map((p) => '<p>${g.esc(p).replaceAll('\n', '<br>')}</p>').join('\n        ');

String _pagina(String id) {
  final c = challengeById(id)!;
  final t = retosTexto[id]!;
  final fuente = soluciones[id]!;
  final programa = parse(fuente);
  final python = toPython(programa);
  final ruta = _ruta(id);
  final visibles = c.exercise.cases.where((x) => !x.hidden).toList();
  final primero = visibles.first;
  final nombreDiagrama = 'Diagrama de flujo del algoritmo ${_nombre(c).toLowerCase()}';

  final faq = t.preguntas
      .map((p) => '{"@type":"Question","name":"${g.json(p.$1)}","acceptedAnswer":{"@type":"Answer","text":"${g.json(p.$2)}"}}')
      .join(',');
  final datos =
      '''
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": ["Article", "LearningResource"],
      "@id": "${g.sitio}$ruta#articulo",
      "headline": "${g.json(t.titulo)}",
      "description": "${g.json(t.descripcion)}",
      "inLanguage": "es-MX",
      "datePublished": "${g.fecha}",
      "dateModified": "${g.fecha}",
      "mainEntityOfPage": "${g.sitio}$ruta",
      "image": "${g.sitio}/compartir.png",
      "learningResourceType": "ejercicio",
      "educationalLevel": "Bachillerato",
      "teaches": "${g.json(c.topic)}",
      "author": { "@type": "Organization", "name": "Panterino", "url": "${g.sitio}/" },
      "publisher": { "@type": "Organization", "name": "Panterino", "logo": { "@type": "ImageObject", "url": "${g.sitio}/icono.png" } }
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "${g.sitio}/" },
        { "@type": "ListItem", "position": 2, "name": "Retos", "item": "${g.sitio}/retos" },
        { "@type": "ListItem", "position": 3, "name": "${g.json(t.h1)}", "item": "${g.sitio}$ruta" }
      ]
    },
    { "@type": "FAQPage", "mainEntity": [$faq] }
  ]
}
</script>''';

  final b = StringBuffer(g.cabeza(titulo: t.titulo, descripcion: t.descripcion, ruta: ruta, extra: datos));
  b.write('''
<main class="guia">
  <div class="ancho angosto">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › <a href="/retos">Retos</a> › ${g.esc(_nombre(c))}</nav>
    <h1>${g.esc(t.h1)}</h1>
    <p class="resumen">${g.esc(t.resumen)}</p>
    <nav class="contenido" aria-label="Contenido de la página"><b>En esta página</b>
      <ol>
        <li><a href="#planteamiento">El problema y su planteamiento</a></li>
        <li><a href="#diagrama">Diagrama de flujo</a></li>
        <li><a href="#pseudocodigo">Pseudocódigo</a></li>
        <li><a href="#como-pensarlo">Cómo pensarlo</a></li>
        <li><a href="#errores">Errores comunes</a></li>
        <li><a href="#python">El mismo programa en Python</a></li>
        <li><a href="#preguntas">Preguntas frecuentes</a></li>
      </ol>
    </nav>
    <article>
      <section id="planteamiento">
        <h2>El problema y su planteamiento</h2>
        ${_parrafos(c.exercise.statement)}
        ${g.tabla('Planteamiento: entrada, proceso y salida', ['Entrada', 'Proceso', 'Salida'], [
    [g.esc(t.entrada), g.esc(t.proceso), g.esc(t.salida)],
  ])}
      </section>
      <section id="diagrama">
        <h2>Diagrama de flujo</h2>
        <p>Así se dibuja el algoritmo: el óvalo marca el inicio y el fin, el paralelogramo es una entrada o una salida, el rectángulo es un proceso y el rombo es una decisión.</p>
        <figure class="diagrama" style="margin:0">
          ${_diagrama(programa, nombreDiagrama)}
        </figure>
      </section>
      <section id="pseudocodigo">
        <h2>Pseudocódigo</h2>
        <p>Esta es una solución. Léela línea por línea con el diagrama al lado y compara con lo que tú escribirías.</p>
        ${g.codigo(fuente, entradas: primero.inputs, salida: primero.expected)}
        ${g.tabla('Pruebas del reto', ['Entrada', 'Salida esperada'], [
    for (final x in visibles) [g.esc(x.inputs.join(', ')), g.esc(x.expected).replaceAll('\n', '<br>')],
  ], nota: 'Con estas entradas, el programa debe mostrar exactamente esa salida.')}
      </section>
      <section id="como-pensarlo">
        <h2>Cómo pensarlo</h2>
        ${t.pensarlo.map((p) => '<p>${g.esc(p)}</p>').join('\n        ')}
      </section>
      <section id="errores">
        <h2>Errores comunes</h2>
        <ul>
          ${t.errores.map((e) => '<li>${g.esc(e)}</li>').join('\n          ')}
        </ul>
      </section>
      <section id="python">
        <h2>El mismo programa en Python</h2>
        <p>Si más adelante pasas a Python, así se ve la misma lógica. Cambian las palabras (<code>print</code>, <code>input</code>, <code>if</code>) y los bloques se marcan con sangría en lugar de <code>FinSi</code> o <code>FinPara</code>.</p>
        <pre class="codigo" tabindex="0"><code>${g.esc(python.trimRight())}</code></pre>
      </section>
      <section id="preguntas">
        <h2>Preguntas frecuentes</h2>
        ${t.preguntas.map((p) => '<details><summary>${g.esc(p.$1)}</summary><p>${g.esc(p.$2)}</p></details>').join('\n        ')}
      </section>
    </article>
    <aside class="cta-guia" aria-labelledby="cta-t">
      <h2 id="cta-t">Pruébalo paso a paso en tu celular</h2>
      <p>En Jaguar Code escribes este algoritmo, lo ejecutas, ves su diagrama y haces la prueba de escritorio. El reto trae pistas y pruebas que te dicen si está bien. Gratis, sin anuncios y sin cuenta.</p>
      <div class="botones"><a class="boton principal" href="https://app.jaguarcode.org/">Abrir Jaguar Code</a></div>
    </aside>
    <h2 style="margin-top:44px">Sigue con otro reto</h2>
    <div class="relacionadas">
''');
  for (final r in t.relacionados) {
    final o = challengeById(r)!;
    final ot = retosTexto[r]!;
    b.writeln('      <a href="${_ruta(r)}">${g.esc(ot.h1)}<small>${g.esc(ot.resumen)}</small></a>');
    // Lee el reto para que el enlace nunca apunte a uno que no existe.
    assert(o.id == r);
  }
  b.writeln('    </div>\n  </div>\n</main>');
  b.write(g.pie);
  return b.toString();
}

String _indice() {
  const titulo = 'Retos de pseudocódigo resueltos paso a paso | Jaguar Code';
  const desc =
      'Doce retos de lógica de programación con planteamiento, diagrama de flujo, pseudocódigo y Python: saludo, área, IVA, condiciones, ciclos y textos.';
  final lista = [
    for (final (i, id) in _orden.indexed)
      '{"@type":"ListItem","position":${i + 1},"url":"${g.sitio}${_ruta(id)}","name":"${g.json(retosTexto[id]!.h1)}"}',
  ].join(',');
  final datos =
      '''
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "CollectionPage", "name": "${g.json(titulo)}", "url": "${g.sitio}/retos", "inLanguage": "es-MX" },
    { "@type": "ItemList", "itemListElement": [$lista] },
    { "@type": "BreadcrumbList", "itemListElement": [
      { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "${g.sitio}/" },
      { "@type": "ListItem", "position": 2, "name": "Retos", "item": "${g.sitio}/retos" }
    ] }
  ]
}
</script>''';
  final b = StringBuffer(g.cabeza(titulo: titulo, descripcion: desc, ruta: '/retos', tipo: 'website', extra: datos));
  b.write('''
<main class="guia">
  <div class="ancho">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › Retos</nav>
    <h1>Retos de pseudocódigo resueltos paso a paso</h1>
    <p class="resumen">Doce problemas de lógica de programación, de lo más sencillo a ciclos. Cada uno trae el planteamiento, el diagrama de flujo, el pseudocódigo explicado y el mismo programa en Python. En la app los resuelves con pistas y pruebas.</p>
    <div class="tarjetas">
''');
  for (final (i, id) in _orden.indexed) {
    final c = challengeById(id)!;
    final t = retosTexto[id]!;
    b.writeln(
      '      <article class="tarjeta revela" style="--d:${i % 3}"><p class="eti" style="margin:0 0 4px">${g.esc(c.subject)}</p><h2 style="font-size:20px;margin:0 0 8px"><a href="${_ruta(id)}">${g.esc(t.h1)}</a></h2><p>${g.esc(t.resumen)}</p></article>',
    );
  }
  b.writeln('    </div>');
  b.writeln(g.cta());
  b.writeln('  </div>\n</main>');
  b.write(g.pie);
  return b.toString();
}

// Herramienta de prueba de escritorio --------------------------------------

/// Los ejemplos del selector: se prueba que ninguno falle antes de publicar.
const _ejemplosPrueba = <(String, String, String)>[
  (
    'Promedio de dos calificaciones',
    'Algoritmo promedio\n    Leer a, b\n    p <- (a + b) / 2\n    Escribir "Promedio: ", p\nFinAlgoritmo\n',
    '8\n10',
  ),
  (
    'Par o impar',
    'Algoritmo par_o_impar\n    Leer n\n    Si n MOD 2 = 0 Entonces\n        Escribir "Par"\n    SiNo\n        Escribir "Impar"\n    FinSi\nFinAlgoritmo\n',
    '7',
  ),
  (
    'Tabla de multiplicar (Para)',
    'Algoritmo tabla\n    Leer n\n    Para i <- 1 Hasta 4 Hacer\n        Escribir n, " x ", i, " = ", n * i\n    FinPara\nFinAlgoritmo\n',
    '3',
  ),
  (
    'Suma hasta el cero (Mientras)',
    'Algoritmo suma_hasta_cero\n    suma <- 0\n    Leer n\n    Mientras n <> 0 Hacer\n        suma <- suma + n\n        Leer n\n    FinMientras\n    Escribir "Suma: ", suma\nFinAlgoritmo\n',
    '4\n6\n10\n0',
  ),
  (
    'Contraseña (Repetir)',
    'Algoritmo contrasena\n    Definir clave Como Texto\n    intentos <- 0\n    Repetir\n        Leer clave\n        intentos <- intentos + 1\n    Hasta Que clave = "jaguar"\n    Escribir "Entraste en ", intentos, " intentos"\nFinAlgoritmo\n',
    'gato\njaguar',
  ),
];

/// La tabla del primer ejemplo, ya hecha, para quien no tiene JavaScript y
/// para que el buscador lea un resultado de verdad.
String _tablaEstatica(DeskCheck check) {
  final b = StringBuffer('<div class="tabla"><table><caption>Ejemplo: promedio de 8 y 10</caption><thead><tr>');
  for (final c in ['Paso', 'Línea', 'Instrucción', ...check.variables, 'Pantalla']) {
    b.write('<th scope="col">${g.esc(c)}</th>');
  }
  b.write('</tr></thead><tbody>');
  for (final (i, row) in check.rows.indexed) {
    b.write('<tr><td>${i + 1}</td><td>${row.line}</td><td class="instr">${g.esc(row.instruction)}</td>');
    for (final v in check.variables) {
      final ahora = row.values[v] ?? '';
      final antes = i > 0 ? (check.rows[i - 1].values[v] ?? '') : '';
      b.write('<td${ahora.isNotEmpty && ahora != antes ? ' class="cambio"' : ''}>${g.esc(ahora)}</td>');
    }
    b.write('<td>${g.esc(row.output.trimRight())}</td></tr>');
  }
  b.write('</tbody></table></div>');
  return b.toString();
}

const _rutaHerramienta = '/herramientas/prueba-de-escritorio';

Future<String> _herramienta() async {
  const titulo = 'Prueba de escritorio online: tabla de variables gratis';
  const desc =
      'Escribe un algoritmo en pseudocódigo, pon los datos de entrada y obtén al momento su prueba de escritorio: una fila por instrucción y una columna por variable.';
  for (final (nombre, fuente, entradas) in _ejemplosPrueba) {
    final r = await deskCheck(fuente, inputs: entradas.split('\n'));
    if (r.error != null) throw StateError('El ejemplo "$nombre" falla: ${r.error!.message}');
  }
  final primero = _ejemplosPrueba.first;
  final estatica = _tablaEstatica(await deskCheck(primero.$2, inputs: primero.$3.split('\n')));
  final preguntas = <(String, String)>[
    (
      '¿Qué es la prueba de escritorio?',
      'Es seguir un programa paso a paso anotando en una tabla cuánto vale cada variable después de cada instrucción. Sirve para entender qué hace un algoritmo y para encontrar errores.',
    ),
    (
      '¿Esta herramienta necesita internet o guarda mi código?',
      'Solo necesita internet para cargar la página. El programa se ejecuta en tu navegador y no se envía a ningún servidor: tu código y tus datos no salen de tu equipo.',
    ),
    (
      '¿Qué pseudocódigo entiende?',
      'Algoritmo, Definir, Leer, Escribir, Si, Segun, Mientras, Repetir, Para, arreglos y funciones, con las palabras en español. Si algo no lo entiende, te dice la línea del error y una sugerencia.',
    ),
    (
      '¿Cómo pongo los datos que pide Leer?',
      'En el cuadro de datos de entrada, un valor por renglón y en el mismo orden en que el programa los pide.',
    ),
  ];
  final faq = preguntas
      .map((p) => '{"@type":"Question","name":"${g.json(p.$1)}","acceptedAnswer":{"@type":"Answer","text":"${g.json(p.$2)}"}}')
      .join(',');
  final datos =
      """
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebApplication",
      "@id": "${g.sitio}$_rutaHerramienta#herramienta",
      "name": "Prueba de escritorio online",
      "description": "${g.json(desc)}",
      "url": "${g.sitio}$_rutaHerramienta",
      "applicationCategory": "EducationalApplication",
      "operatingSystem": "Cualquiera con navegador",
      "browserRequirements": "Requiere JavaScript",
      "inLanguage": "es-MX",
      "isAccessibleForFree": true,
      "offers": { "@type": "Offer", "price": "0", "priceCurrency": "MXN" },
      "publisher": { "@type": "Organization", "name": "Panterino", "url": "${g.sitio}/" }
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "${g.sitio}/" },
        { "@type": "ListItem", "position": 2, "name": "Prueba de escritorio online", "item": "${g.sitio}$_rutaHerramienta" }
      ]
    },
    { "@type": "FAQPage", "mainEntity": [$faq] }
  ]
}
</script>""";
  final ejemplosJson = jsonEncode([
    for (final e in _ejemplosPrueba) {'nombre': e.$1, 'fuente': e.$2, 'entradas': e.$3},
  ]).replaceAll('<', r'<');
  final b = StringBuffer(g.cabeza(titulo: titulo, descripcion: desc, ruta: _rutaHerramienta, tipo: 'website', extra: datos));
  b.write("""
<main class="guia">
  <div class="ancho angosto">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › Prueba de escritorio online</nav>
    <h1>Prueba de escritorio online para tu algoritmo</h1>
    <p class="resumen">Escribe tu pseudocódigo, pon los datos de entrada y mira cómo cambia cada variable, instrucción por instrucción. Gratis, sin registro y sin salir de tu navegador.</p>

    <div class="herramienta" role="region" aria-labelledby="herr-t">
      <h2 id="herr-t" style="margin-top:0">Genera tu prueba de escritorio</h2>
      <label for="fuente">Pseudocódigo</label>
      <textarea id="fuente" rows="13" spellcheck="false" autocapitalize="off" autocomplete="off">${g.esc(primero.$2)}</textarea>
      <label for="entradas">Datos de entrada (uno por renglón, en el orden en que los pide Leer)</label>
      <textarea id="entradas" rows="3" spellcheck="false" autocapitalize="off" autocomplete="off">${g.esc(primero.$3)}</textarea>
      <div class="acciones">
        <button class="boton principal" type="button" id="generar">Generar prueba de escritorio</button>
        <label for="ejemplo">Ejemplos:
          <select id="ejemplo">
            <option value="" selected disabled>Elige uno</option>
            ${[for (final (i, e) in _ejemplosPrueba.indexed) '<option value="$i">${g.esc(e.$1)}</option>'].join('\n            ')}
          </select>
        </label>
      </div>
      <p class="estado" id="estado-herramienta" role="status" aria-live="polite"></p>
      <div id="resultado" class="resultado" aria-live="polite">
        $estatica
      </div>
      <noscript><p class="nota-tabla">Para generar tu propia tabla hace falta JavaScript. Mientras, arriba ves el resultado del ejemplo.</p></noscript>
    </div>
    <script type="application/json" id="ejemplos-datos">$ejemplosJson</script>

    <article>
      <section id="como-leerla">
        <h2>Cómo leer la tabla</h2>
        <ul>
          <li><b>Cada fila es una instrucción</b> que se ejecutó, en el orden real: si hay un ciclo, la misma línea aparece varias veces.</li>
          <li><b>Cada columna es una variable.</b> Una celda vacía significa que la variable todavía no tenía valor en ese momento.</li>
          <li><b>El valor resaltado es el que acaba de cambiar</b> con esa instrucción.</li>
          <li><b>La última columna es lo que el programa mostró en pantalla</b> con Escribir.</li>
        </ul>
      </section>
      <section id="que-es">
        <h2>Para qué sirve la prueba de escritorio</h2>
        <p>En clase te piden la prueba de escritorio para comprobar que un algoritmo hace lo que debe antes de pasarlo a una computadora, o para encontrar en qué paso se equivoca. Hacerla a mano es lento y es fácil equivocarse al copiar valores; aquí la tabla sale sola. Si quieres aprender a hacerla tú, lee la guía de <a href="/guias/prueba-de-escritorio">la prueba de escritorio paso a paso</a>.</p>
      </section>
      <section id="preguntas">
        <h2>Preguntas frecuentes</h2>
        ${preguntas.map((p) => '<details><summary>${g.esc(p.$1)}</summary><p>${g.esc(p.$2)}</p></details>').join('\n        ')}
      </section>
    </article>
    <aside class="cta-guia" aria-labelledby="cta-t">
      <h2 id="cta-t">En el celular, con diagrama y retos</h2>
      <p>Jaguar Code hace esta misma prueba de escritorio en la app, la deja llenar a mano para practicar y la combina con el diagrama de flujo, los bloques y doce retos con pistas. Gratis, sin anuncios y sin cuenta.</p>
      <div class="botones"><a class="boton principal" href="https://app.jaguarcode.org/">Abrir Jaguar Code</a></div>
    </aside>
    <h2 style="margin-top:44px">Sigue aprendiendo</h2>
    <div class="relacionadas">
      <a href="/guias/prueba-de-escritorio">La prueba de escritorio<small>Cómo seguir un programa a mano con una tabla, con un ejemplo completo.</small></a>
      <a href="/herramientas/diagrama-de-flujo-online">Diagrama de flujo online<small>Pega tu pseudocódigo y descarga el diagrama.</small></a>
      <a href="/retos">Retos resueltos paso a paso<small>Doce problemas con planteamiento, diagrama y pseudocódigo.</small></a>
      <a href="/guias/pseint-en-el-celular">Pseudocódigo en el celular<small>Qué buscar en una app para Android.</small></a>
    </div>
  </div>
</main>
<script src="/herramientas/herramienta.js" defer></script>
""");
  b.write(g.pie);
  return b.toString();
}

// Herramienta de diagramas de flujo -----------------------------------------

const _ejemplosDiagrama = <(String, String)>[
  (
    'Promedio y decisión',
    'Algoritmo promedio\n    Leer a, b\n    p <- (a + b) / 2\n    Si p >= 6 Entonces\n        Escribir "Pasaste"\n    SiNo\n        Escribir "Casi"\n    FinSi\nFinAlgoritmo\n',
  ),
  (
    'Tabla de multiplicar (Para)',
    'Algoritmo tabla\n    Leer n\n    Para i <- 1 Hasta 10 Hacer\n        Escribir n, " x ", i, " = ", n * i\n    FinPara\nFinAlgoritmo\n',
  ),
  (
    'Suma hasta el cero (Mientras)',
    'Algoritmo suma_hasta_cero\n    suma <- 0\n    Leer n\n    Mientras n <> 0 Hacer\n        suma <- suma + n\n        Leer n\n    FinMientras\n    Escribir "Suma: ", suma\nFinAlgoritmo\n',
  ),
  (
    'Contraseña (Repetir)',
    'Algoritmo contrasena\n    Definir clave Como Texto\n    intentos <- 0\n    Repetir\n        Leer clave\n        intentos <- intentos + 1\n    Hasta Que clave = "jaguar"\n    Escribir "Entraste en ", intentos, " intentos"\nFinAlgoritmo\n',
  ),
  (
    'Día de la semana (Según)',
    'Algoritmo dia\n    Leer d\n    Segun d Hacer\n        1: Escribir "Lunes"\n        2: Escribir "Martes"\n        3: Escribir "Miércoles"\n        De Otro Modo: Escribir "Otro día"\n    FinSegun\nFinAlgoritmo\n',
  ),
];

const _rutaDiagrama = '/herramientas/diagrama-de-flujo-online';

Future<String> _diagramaWeb() async {
  const titulo = 'Diagrama de flujo online desde pseudocódigo (gratis)';
  const desc =
      'Escribe pseudocódigo y mira al instante su diagrama de flujo. Descárgalo como imagen o SVG. Gratis, sin registro, y con la tabla para pasar del diagrama al código.';
  for (final (nombre, fuente) in _ejemplosDiagrama) {
    final programa = parse(fuente); // un ejemplo con error detendría la generación
    assert(flowchartsFor(programa).isNotEmpty, nombre);
  }
  final primero = _ejemplosDiagrama.first;
  final estatico = flowchartSvg(
    flowchartsFor(parse(primero.$2), metrics: const FlowMetrics(charWidth: 7.6, margin: 16)).first,
    title: 'Diagrama de flujo del algoritmo promedio',
  );
  final preguntas = <(String, String)>[
    (
      '¿Cómo paso un diagrama de flujo a pseudocódigo?',
      'Recorre el diagrama de arriba abajo y escribe una instrucción por símbolo: el óvalo de inicio es Algoritmo, el paralelogramo de entrada es Leer, el de salida es Escribir, el rectángulo es una asignación y el rombo es un Si o un Mientras. La tabla de esta página trae todas las equivalencias.',
    ),
    (
      '¿Esta herramienta convierte diagramas dibujados a pseudocódigo?',
      'Esta herramienta va del pseudocódigo al diagrama. Para el camino contrario, la app Jaguar Code te deja armar el diagrama con las figuras y el pseudocódigo se escribe solo.',
    ),
    (
      '¿Puedo descargar el diagrama?',
      'Sí, como imagen PNG o como archivo SVG, que se puede abrir en cualquier editor y escalar sin perder calidad.',
    ),
    ('¿Se guarda o se envía mi código?', 'No. El diagrama se dibuja en tu navegador y tu código no se envía a ningún servidor.'),
    (
      '¿Qué instrucciones entiende?',
      'Algoritmo, Definir, Leer, Escribir, Si, Segun, Mientras, Repetir, Para, arreglos y funciones. Si el código tiene un error, te dice la línea y conserva el último diagrama.',
    ),
  ];
  final faq = preguntas
      .map((p) => '{"@type":"Question","name":"${g.json(p.$1)}","acceptedAnswer":{"@type":"Answer","text":"${g.json(p.$2)}"}}')
      .join(',');
  final datos =
      """
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebApplication",
      "@id": "${g.sitio}$_rutaDiagrama#herramienta",
      "name": "Diagrama de flujo online desde pseudocódigo",
      "description": "${g.json(desc)}",
      "url": "${g.sitio}$_rutaDiagrama",
      "applicationCategory": "EducationalApplication",
      "operatingSystem": "Cualquiera con navegador",
      "browserRequirements": "Requiere JavaScript",
      "inLanguage": "es-MX",
      "isAccessibleForFree": true,
      "offers": { "@type": "Offer", "price": "0", "priceCurrency": "MXN" },
      "publisher": { "@type": "Organization", "name": "Panterino", "url": "${g.sitio}/" }
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "${g.sitio}/" },
        { "@type": "ListItem", "position": 2, "name": "Diagrama de flujo online", "item": "${g.sitio}$_rutaDiagrama" }
      ]
    },
    { "@type": "FAQPage", "mainEntity": [$faq] }
  ]
}
</script>""";
  final ejemplosJson = jsonEncode([
    for (final e in _ejemplosDiagrama) {'nombre': e.$1, 'fuente': e.$2},
  ]).replaceAll('<', r'<');
  final tabla = g.tabla(
    'De cada símbolo del diagrama a su instrucción',
    ['Símbolo', 'Qué significa', 'Se escribe así'],
    [
      ['Óvalo (Inicio y Fin)', 'Donde empieza y termina', '<code>Algoritmo nombre</code> y <code>FinAlgoritmo</code>'],
      ['Paralelogramo de entrada', 'Pide un dato', '<code>Leer a, b</code>'],
      ['Paralelogramo de salida', 'Muestra algo', '<code>Escribir "Promedio: ", p</code>'],
      ['Rectángulo', 'Una operación o asignación', '<code>p &lt;- (a + b) / 2</code>'],
      ['Rombo con dos salidas (Sí y No)', 'Una decisión', '<code>Si p &gt;= 6 Entonces … SiNo … FinSi</code>'],
      [
        'Rombo que regresa hacia arriba',
        'Un ciclo que se repite mientras se cumple algo',
        '<code>Mientras n &lt;&gt; 0 Hacer … FinMientras</code>',
      ],
      ['Hexágono', 'Un ciclo con contador', '<code>Para i &lt;- 1 Hasta 10 Hacer … FinPara</code>'],
    ],
  );
  final b = StringBuffer(g.cabeza(titulo: titulo, descripcion: desc, ruta: _rutaDiagrama, tipo: 'website', extra: datos));
  b.write("""
<main class="guia">
  <div class="ancho">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › Diagrama de flujo online</nav>
    <h1>Diagrama de flujo online a partir de tu pseudocódigo</h1>
    <p class="resumen">Escribe tu algoritmo a la izquierda y mira su diagrama de flujo al instante. Descárgalo como imagen o SVG para tu tarea. Gratis, sin registro y sin salir de tu navegador.</p>

    <div class="herramienta dos-columnas" role="region" aria-labelledby="herr-t">
      <h2 id="herr-t" style="margin-top:0">Genera tu diagrama</h2>
      <div class="acciones" style="margin:0 0 6px">
        <label for="ejemplo">Ejemplos:
          <select id="ejemplo">
            <option value="" selected disabled>Elige uno</option>
            ${[for (final (i, e) in _ejemplosDiagrama.indexed) '<option value="$i">${g.esc(e.$1)}</option>'].join('\n            ')}
          </select>
        </label>
      </div>
      <div class="cols">
        <div>
          <label for="fuente">Pseudocódigo</label>
          <textarea id="fuente" rows="16" spellcheck="false" autocapitalize="off" autocomplete="off">${g.esc(primero.$2)}</textarea>
        </div>
        <div>
          <p style="font-weight:700;margin:14px 0 6px">Diagrama de flujo</p>
          <div id="diagrama-salida" class="resultado" style="margin-top:0" aria-live="polite">
            <figure class="diagrama" style="margin:0">$estatico</figure>
          </div>
        </div>
      </div>
      <div class="acciones">
        <button class="boton linea" type="button" id="bajar-png">Descargar imagen (PNG)</button>
        <button class="boton linea" type="button" id="bajar-svg">Descargar SVG</button>
      </div>
      <p class="estado" id="estado-herramienta" role="status" aria-live="polite"></p>
      <noscript><p class="nota-tabla">Para dibujar tu propio diagrama hace falta JavaScript. Mientras, arriba ves el diagrama del ejemplo.</p></noscript>
    </div>
    <script type="application/json" id="ejemplos-datos">$ejemplosJson</script>

    <article>
      <section id="de-diagrama-a-pseudocodigo">
        <h2>Cómo pasar un diagrama de flujo a pseudocódigo</h2>
        <p>Si ya tienes un diagrama dibujado y necesitas el código, recórrelo de arriba abajo, siguiendo las flechas, y escribe una instrucción por cada símbolo. Esta es la equivalencia de cada figura:</p>
        $tabla
        <ol>
          <li>Empieza por el óvalo de inicio: escribe <code>Algoritmo</code> con el nombre del programa.</li>
          <li>Sigue las flechas. Cada paralelogramo y cada rectángulo es una línea de código, en el mismo orden.</li>
          <li>En cada rombo, escribe el <code>Si</code> con su condición. Lo que está en la salida <i>Sí</i> va dentro del <code>Si</code> y lo de la salida <i>No</i> dentro del <code>SiNo</code>.</li>
          <li>Si una flecha regresa a un rombo anterior, es un ciclo: lo que está en el camino de regreso va dentro del <code>Mientras</code>.</li>
          <li>Cierra con el óvalo de fin: <code>FinAlgoritmo</code>.</li>
        </ol>
        <p>Pega el resultado arriba para comprobar que el diagrama que dibuja es el tuyo. Si quieres practicar el camino completo, la guía de <a href="/guias/como-hacer-un-diagrama-de-flujo">cómo hacer un diagrama de flujo</a> lo explica con un ejemplo.</p>
      </section>
      <section id="preguntas">
        <h2>Preguntas frecuentes</h2>
        ${preguntas.map((p) => '<details><summary>${g.esc(p.$1)}</summary><p>${g.esc(p.$2)}</p></details>').join('\n        ')}
      </section>
    </article>
    <aside class="cta-guia" aria-labelledby="cta-t">
      <h2 id="cta-t">Arma el diagrama con figuras en tu celular</h2>
      <p>En Jaguar Code dibujas el diagrama tocando figuras y el pseudocódigo se escribe solo, y al revés. Trae también bloques, la prueba de escritorio y doce retos con pistas. Gratis, sin anuncios y sin cuenta.</p>
      <div class="botones"><a class="boton principal" href="https://app.jaguarcode.org/">Abrir Jaguar Code</a></div>
    </aside>
    <h2 style="margin-top:44px">Sigue aprendiendo</h2>
    <div class="relacionadas">
      <a href="/herramientas/prueba-de-escritorio">Prueba de escritorio online<small>La tabla de variables de tu algoritmo, paso a paso.</small></a>
      <a href="/guias/como-hacer-un-diagrama-de-flujo">Cómo hacer un diagrama de flujo<small>Los símbolos y un ejemplo paso a paso.</small></a>
      <a href="/retos">Retos resueltos paso a paso<small>Con su diagrama y su pseudocódigo.</small></a>
    </div>
  </div>
</main>
<script src="/herramientas/diagrama.js" defer></script>
""");
  b.write(g.pie);
  return b.toString();
}

// Descargas ------------------------------------------------------------------

const _rutaDescargas = '/descargas';
const _bajar = 'https://github.com/panterino/jaguar/releases/latest/download';

String _descargas() {
  const titulo = 'Descargar Jaguar Code: Android, Windows, Mac y Linux';
  const desc =
      'Descarga Jaguar Code gratis para Android (APK), Windows, Mac (DMG) y Linux. También funciona sin instalar en el navegador. Sin anuncios y sin cuenta.';
  const preguntas = <(String, String)>[
    (
      '¿Es seguro instalar el APK fuera de Google Play?',
      'El APK está firmado por Panterino y su código es abierto en GitHub. Android pide permiso para instalar apps de fuera de la tienda; se da solo para el navegador o el administrador de archivos con el que lo abres. Cada descarga trae una suma de verificación SHA-256 en la página de la versión.',
    ),
    (
      '¿Por qué el Mac dice que no puede verificar la app?',
      'La app aún no está notarizada por Apple, un trámite de paga. La primera vez, haz clic derecho sobre Jaguar Code, elige Abrir y confirma. Después abre como cualquier otra.',
    ),
    (
      '¿Hay versión para iPhone o iPad?',
      'Todavía no como app instalable. Mientras tanto, la versión web funciona en el navegador de iPhone y iPad y se puede agregar a la pantalla de inicio.',
    ),
    (
      '¿Por qué Windows dice que protegió mi PC?',
      'Porque la app aún no está firmada con un certificado de pago. Toca Más información y luego Ejecutar de todas formas. El código es abierto y puedes revisarlo en GitHub.',
    ),
    (
      '¿Qué cambia entre la descarga y la versión web?',
      'Es la misma app. En Windows y Linux faltan las clases y la comunidad, que dependen de un servicio que todavía no está configurado para esos sistemas; todo lo demás funciona sin internet.',
    ),
  ];
  final faq = preguntas
      .map((p) => '{"@type":"Question","name":"${g.json(p.$1)}","acceptedAnswer":{"@type":"Answer","text":"${g.json(p.$2)}"}}')
      .join(',');
  final datos =
      """
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "SoftwareApplication",
      "name": "Jaguar Code",
      "applicationCategory": "EducationalApplication",
      "operatingSystem": "Android, Windows, macOS, Linux, Web",
      "inLanguage": "es-MX",
      "isAccessibleForFree": true,
      "offers": { "@type": "Offer", "price": "0", "priceCurrency": "MXN" },
      "downloadUrl": "${g.sitio}$_rutaDescargas",
      "publisher": { "@type": "Organization", "name": "Panterino", "url": "${g.sitio}/" }
    },
    {
      "@type": "BreadcrumbList",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Jaguar Code", "item": "${g.sitio}/" },
        { "@type": "ListItem", "position": 2, "name": "Descargas", "item": "${g.sitio}$_rutaDescargas" }
      ]
    },
    { "@type": "FAQPage", "mainEntity": [$faq] }
  ]
}
</script>""";
  final b = StringBuffer(g.cabeza(titulo: titulo, descripcion: desc, ruta: _rutaDescargas, tipo: 'website', extra: datos));
  b.write("""
<main class="guia">
  <div class="ancho angosto">
    <nav class="migas" aria-label="Ruta de navegación"><a href="/">Jaguar</a> › Descargas</nav>
    <h1>Descargar Jaguar Code</h1>
    <p class="resumen">Instálalo en tu celular o tu computadora, o ábrelo sin instalar nada en el navegador. Es gratis, sin anuncios y sin cuenta, y el código es abierto.</p>

    <div class="relacionadas descargas">
      <a href="https://app.jaguarcode.org/">Navegador<small>Sin instalar. Funciona en Windows, Mac, Linux, Android, iPhone y iPad.</small></a>
      <a href="$_bajar/JaguarCode-android.apk">Android (APK)<small>Para celulares y tabletas con Android.</small></a>
      <a href="$_bajar/JaguarCode-windows-x64.zip">Windows (ZIP)<small>Para Windows 10 y 11 de 64 bits. Se descomprime y se abre, sin instalador.</small></a>
      <a href="$_bajar/JaguarCode-macos.dmg">Mac (DMG)<small>Para Mac con chip de Apple o Intel.</small></a>
      <a href="$_bajar/JaguarCode-linux-x64.tar.gz">Linux (tar.gz)<small>Para Linux de 64 bits con escritorio GTK.</small></a>
    </div>
    <p class="nota-tabla">Todas las versiones y sus sumas de verificación están en <a href="https://github.com/panterino/jaguar/releases">la página de versiones</a>.</p>

    <article>
      <section id="android">
        <h2>Cómo instalarlo en Android</h2>
        <ol>
          <li>Descarga el archivo APK desde tu celular.</li>
          <li>Ábrelo. Si Android lo pide, permite instalar apps desde esa fuente (solo para el navegador o el administrador de archivos que usaste).</li>
          <li>Toca Instalar y abre Jaguar Code.</li>
        </ol>
      </section>
      <section id="windows">
        <h2>Cómo usarlo en Windows</h2>
        <ol>
          <li>Descarga el ZIP y descomprímelo completo (clic derecho, Extraer todo).</li>
          <li>Abre la carpeta y haz doble clic en <code>jaguar.exe</code>.</li>
          <li>Si Windows muestra «Windows protegió tu PC», toca Más información y luego Ejecutar de todas formas.</li>
        </ol>
        <p>En Windows no están las clases ni la comunidad; el resto funciona sin conexión.</p>
      </section>
      <section id="mac">
        <h2>Cómo instalarlo en Mac</h2>
        <ol>
          <li>Abre el archivo DMG y arrastra Jaguar Code a la carpeta Aplicaciones.</li>
          <li>La primera vez, haz clic derecho sobre la app, elige Abrir y confirma. Es necesario porque la app aún no está notarizada por Apple.</li>
        </ol>
      </section>
      <section id="linux">
        <h2>Cómo usarlo en Linux</h2>
        <ol>
          <li>Descomprime el archivo: <code>tar -xzf JaguarCode-linux-x64.tar.gz</code>.</li>
          <li>Entra a la carpeta y ejecuta <code>./jaguar</code>.</li>
          <li>Para tenerlo en el menú de aplicaciones, ejecuta <code>./instalar.sh</code> y no muevas la carpeta de lugar.</li>
        </ol>
        <p>En Linux no están las clases ni la comunidad; el resto funciona sin conexión.</p>
      </section>
      <section id="preguntas">
        <h2>Preguntas frecuentes</h2>
        ${preguntas.map((p) => '<details><summary>${g.esc(p.$1)}</summary><p>${g.esc(p.$2)}</p></details>').join('\n        ')}
      </section>
    </article>
    <h2 style="margin-top:44px">Antes de instalar</h2>
    <div class="relacionadas">
      <a href="/herramientas/prueba-de-escritorio">Prueba de escritorio online<small>La tabla de variables de tu algoritmo, en el navegador.</small></a>
      <a href="/herramientas/diagrama-de-flujo-online">Diagrama de flujo online<small>Pega tu pseudocódigo y descarga el diagrama.</small></a>
      <a href="/retos">Retos resueltos paso a paso<small>Con su diagrama y su pseudocódigo.</small></a>
    </div>
  </div>
</main>
""");
  b.write(g.pie);
  return b.toString();
}

// Mapa del sitio ---------------------------------------------------------

String _mapa() {
  String url(String ruta, String frecuencia, String prioridad) =>
      '  <url><loc>${g.sitio}$ruta</loc><lastmod>${g.fecha}</lastmod><changefreq>$frecuencia</changefreq><priority>$prioridad</priority></url>';
  final lineas = [
    url('/', 'weekly', '1.0'),
    url('/guias', 'monthly', '0.8'),
    for (final guia in g.guias) url('/guias/${guia.slug}', 'monthly', '0.8'),
    url('/descargas', 'monthly', '0.8'),
    url('/herramientas/prueba-de-escritorio', 'monthly', '0.9'),
    url('/herramientas/diagrama-de-flujo-online', 'monthly', '0.9'),
    url('/retos', 'monthly', '0.8'),
    for (final id in _orden) url(_ruta(id), 'monthly', '0.8'),
    url('/profes', 'monthly', '0.7'),
    url('/manual', 'monthly', '0.6'),
  ];
  return '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${lineas.join('\n')}\n</urlset>\n';
}

Future<void> main() async {
  final retos = Directory('../../sitio/retos')..createSync(recursive: true);
  for (final id in _orden) {
    assert(retosTexto.containsKey(id) && soluciones.containsKey(id), 'Falta el texto o la solución de $id');
  }
  File('${retos.path}/index.html').writeAsStringSync(_indice());
  for (final id in _orden) {
    File('${retos.path}/${retosTexto[id]!.slug}.html').writeAsStringSync(_pagina(id));
  }
  Directory('../../sitio/herramientas').createSync(recursive: true);
  File('../../sitio/herramientas/prueba-de-escritorio.html').writeAsStringSync(await _herramienta());
  File('../../sitio/herramientas/diagrama-de-flujo-online.html').writeAsStringSync(await _diagramaWeb());
  File('../../sitio/descargas.html').writeAsStringSync(_descargas());
  File('../../sitio/sitemap.xml').writeAsStringSync(_mapa());
  stdout.writeln('Listo: ${_orden.length + 1} páginas en sitio/retos y el mapa del sitio');
}
