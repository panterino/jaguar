// Genera las páginas de retos de la landing (sitio/retos/*.html) y el mapa del
// sitio (sitio/sitemap.xml). Una página por reto: planteamiento, diagrama de
// flujo, pseudocódigo, cómo pensarlo, errores comunes y el mismo programa en
// Python. Correr desde apps/jaguar:
//   dart run tool/retos_html.dart
// Los ejemplos llevan data-entradas y data-salida: una prueba
// (packages/jaguar_core/test/guias_test.dart) los ejecuta con el intérprete.
import 'dart:io';
import 'dart:math' as math;

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

String _f(num n) => n.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

/// El diagrama de flujo del programa, como SVG que usa los colores de la
/// página (las clases de .diagrama en estilos.css).
String _diagrama(Program programa, String titulo) {
  final chart = flowchartsFor(programa, metrics: const FlowMetrics(charWidth: 7.6, margin: 16)).first;
  final w = chart.width;
  final h = chart.height;
  final b = StringBuffer(
    '<svg viewBox="0 0 ${_f(w)} ${_f(h)}" width="${_f(math.min(w, 520))}" role="img" aria-labelledby="diag-tit">'
    '<title id="diag-tit">${g.esc(titulo)}</title>',
  );
  b.write('<g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round">');
  final cabezas = StringBuffer();
  for (final line in chart.lines) {
    final p = line.points;
    b.write('<path d="M${_f(p.first.$1)} ${_f(p.first.$2)}${[for (final q in p.skip(1)) 'L${_f(q.$1)} ${_f(q.$2)}'].join()}"/>');
    if (line.arrow && p.length >= 2) {
      final (x, y) = p.last;
      final (px, py) = p[p.length - 2];
      final dx = x - px;
      final dy = y - py;
      final largo = math.sqrt(dx * dx + dy * dy);
      if (largo > 0) {
        final ux = dx / largo;
        final uy = dy / largo;
        // Una punta de flecha de 8 de largo y 4 de cada lado.
        final bx = x - ux * 8;
        final by = y - uy * 8;
        cabezas.write(
          '<path d="M${_f(x)} ${_f(y)}L${_f(bx - uy * 4)} ${_f(by + ux * 4)}L${_f(bx + uy * 4)} ${_f(by - ux * 4)}z" style="fill:var(--fig-linea);stroke:none"/>',
        );
      }
    }
  }
  b.write('</g>$cabezas');
  for (final block in chart.blocks) {
    final r = block.rect;
    final l = _f(r.left);
    final t = _f(r.top);
    final shape = switch (block.shape) {
      BlockShape.terminal => '<rect class="ini fig" x="$l" y="$t" width="${_f(r.width)}" height="${_f(r.height)}" rx="${_f(r.height / 2)}"/>',
      BlockShape.process || BlockShape.call => '<rect class="proc fig" x="$l" y="$t" width="${_f(r.width)}" height="${_f(r.height)}" rx="3"/>',
      BlockShape.input || BlockShape.output =>
        '<path class="${block.shape == BlockShape.input ? 'io' : 'sal'} fig" d="M${_f(r.left + r.height * 0.35)} $t H${_f(r.right)} L${_f(r.right - r.height * 0.35)} ${_f(r.bottom)} H${_f(r.left)} z"/>',
      BlockShape.decision =>
        '<path class="dec fig" d="M${_f(r.centerX)} $t L${_f(r.right)} ${_f(r.centerY)} L${_f(r.centerX)} ${_f(r.bottom)} L$l ${_f(r.centerY)} z"/>',
      BlockShape.loop =>
        '<path class="dec fig" d="M${_f(r.left + r.height * 0.4)} $t H${_f(r.right - r.height * 0.4)} L${_f(r.right)} ${_f(r.centerY)} L${_f(r.right - r.height * 0.4)} ${_f(r.bottom)} H${_f(r.left + r.height * 0.4)} L$l ${_f(r.centerY)} z"/>',
    };
    b.write(shape);
    b.write('<text x="${_f(r.centerX)}" y="${_f(r.centerY + 4.5)}" text-anchor="middle">${g.esc(block.text)}</text>');
  }
  for (final label in chart.labels) {
    b.write('<text x="${_f(label.x)}" y="${_f(label.y)}" font-size="11">${g.esc(label.text)}</text>');
  }
  b.write('</svg>');
  return b.toString();
}

// Páginas ----------------------------------------------------------------

String _parrafos(String statement) => statement
    .split('\n\n')
    .map((p) => '<p>${g.esc(p).replaceAll('\n', '<br>')}</p>')
    .join('\n        ');

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
  final datos = '''
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
  final datos = '''
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

// Mapa del sitio ---------------------------------------------------------

String _mapa() {
  String url(String ruta, String frecuencia, String prioridad) =>
      '  <url><loc>${g.sitio}$ruta</loc><lastmod>${g.fecha}</lastmod><changefreq>$frecuencia</changefreq><priority>$prioridad</priority></url>';
  final lineas = [
    url('/', 'weekly', '1.0'),
    url('/guias', 'monthly', '0.8'),
    for (final guia in g.guias) url('/guias/${guia.slug}', 'monthly', '0.8'),
    url('/retos', 'monthly', '0.8'),
    for (final id in _orden) url(_ruta(id), 'monthly', '0.8'),
    url('/profes', 'monthly', '0.7'),
    url('/manual', 'monthly', '0.6'),
  ];
  return '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${lineas.join('\n')}\n</urlset>\n';
}

void main() {
  final retos = Directory('../../sitio/retos')..createSync(recursive: true);
  for (final id in _orden) {
    assert(retosTexto.containsKey(id) && soluciones.containsKey(id), 'Falta el texto o la solución de $id');
  }
  File('${retos.path}/index.html').writeAsStringSync(_indice());
  for (final id in _orden) {
    File('${retos.path}/${retosTexto[id]!.slug}.html').writeAsStringSync(_pagina(id));
  }
  File('../../sitio/sitemap.xml').writeAsStringSync(_mapa());
  stdout.writeln('Listo: ${_orden.length + 1} páginas en sitio/retos y el mapa del sitio');
}
