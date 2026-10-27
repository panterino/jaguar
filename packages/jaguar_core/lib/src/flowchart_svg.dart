import 'dart:math' as math;

import 'flowchart.dart';

String _f(num n) => n.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

String _esc(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// A flowchart as an SVG, for the web pages. With [standalone] it carries its
/// own colors and font, so it can be saved as a file or turned into an image;
/// otherwise it uses the classes of the page's stylesheet (`.diagrama`).
String flowchartSvg(Flowchart chart, {required String title, bool standalone = false, double maxWidth = 520}) {
  final w = chart.width;
  final h = chart.height;
  const colors = {'ini': '#F7D995', 'io': '#F4E3C4', 'proc': '#EFE6DC', 'dec': '#CDEBC5', 'sal': '#DCEFD7'};
  const line = '#7A6450';
  const ink = '#2A1A0B';

  String shape(String kind, String tag, String attributes) {
    if (!standalone) return '<$tag class="$kind fig" $attributes/>';
    return '<$tag fill="${colors[kind]}" stroke="$line" $attributes/>';
  }

  final b = StringBuffer();
  if (standalone) {
    b.write(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${_f(w)} ${_f(h)}" width="${_f(w)}" height="${_f(h)}" '
      'font-family="ui-monospace, Menlo, Consolas, monospace" font-size="13">'
      '<title>${_esc(title)}</title><rect width="${_f(w)}" height="${_f(h)}" fill="#FFFBF6"/>',
    );
  } else {
    b.write(
      '<svg viewBox="0 0 ${_f(w)} ${_f(h)}" width="${_f(math.min(w, maxWidth))}" role="img" aria-labelledby="diag-tit">'
      '<title id="diag-tit">${_esc(title)}</title>',
    );
  }
  b.write(
    standalone
        ? '<g stroke="$line" stroke-width="1.5" fill="none" stroke-linejoin="round">'
        : '<g class="linea" stroke-width="1.5" fill="none" stroke-linejoin="round">',
  );
  final heads = StringBuffer();
  for (final l in chart.lines) {
    final p = l.points;
    b.write(
      '<path d="M${_f(p.first.$1)} ${_f(p.first.$2)}${[for (final q in p.skip(1)) 'L${_f(q.$1)} ${_f(q.$2)}'].join()}"/>',
    );
    if (l.arrow && p.length >= 2) {
      final (x, y) = p.last;
      final (px, py) = p[p.length - 2];
      final dx = x - px;
      final dy = y - py;
      final length = math.sqrt(dx * dx + dy * dy);
      if (length > 0) {
        final ux = dx / length;
        final uy = dy / length;
        final bx = x - ux * 8;
        final by = y - uy * 8;
        heads.write(
          '<path d="M${_f(x)} ${_f(y)}L${_f(bx - uy * 4)} ${_f(by + ux * 4)}L${_f(bx + uy * 4)} ${_f(by - ux * 4)}z" '
          '${standalone ? 'fill="$line"' : 'style="fill:var(--fig-linea);stroke:none"'} stroke="none"/>',
        );
      }
    }
  }
  b.write('</g>$heads');
  for (final block in chart.blocks) {
    final r = block.rect;
    final left = _f(r.left);
    final top = _f(r.top);
    final skew = r.height * 0.35;
    b.write(switch (block.shape) {
      BlockShape.terminal => shape(
        'ini',
        'rect',
        'x="$left" y="$top" width="${_f(r.width)}" height="${_f(r.height)}" rx="${_f(r.height / 2)}"',
      ),
      BlockShape.process || BlockShape.call => shape(
        'proc',
        'rect',
        'x="$left" y="$top" width="${_f(r.width)}" height="${_f(r.height)}" rx="3"',
      ),
      BlockShape.input || BlockShape.output => shape(
        block.shape == BlockShape.input ? 'io' : 'sal',
        'path',
        'd="M${_f(r.left + skew)} $top H${_f(r.right)} L${_f(r.right - skew)} ${_f(r.bottom)} H$left z"',
      ),
      BlockShape.decision => shape(
        'dec',
        'path',
        'd="M${_f(r.centerX)} $top L${_f(r.right)} ${_f(r.centerY)} L${_f(r.centerX)} ${_f(r.bottom)} L$left ${_f(r.centerY)} z"',
      ),
      BlockShape.loop => shape(
        'dec',
        'path',
        'd="M${_f(r.left + r.height * 0.4)} $top H${_f(r.right - r.height * 0.4)} L${_f(r.right)} ${_f(r.centerY)} '
            'L${_f(r.right - r.height * 0.4)} ${_f(r.bottom)} H${_f(r.left + r.height * 0.4)} L$left ${_f(r.centerY)} z"',
      ),
    });
    b.write(
      '<text x="${_f(r.centerX)}" y="${_f(r.centerY + 4.5)}" text-anchor="middle"${standalone ? ' fill="$ink"' : ''}>${_esc(block.text)}</text>',
    );
  }
  for (final label in chart.labels) {
    b.write(
      '<text x="${_f(label.x)}" y="${_f(label.y)}" font-size="11"${standalone ? ' fill="$ink"' : ''}>${_esc(label.text)}</text>',
    );
  }
  b.write('</svg>');
  return b.toString();
}
