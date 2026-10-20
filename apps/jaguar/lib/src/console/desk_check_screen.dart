import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../theme.dart';

final _readsInput = RegExp(r'^\s*leer\b', caseSensitive: false, multiLine: true);

/// The "prueba de escritorio": a table with one row per instruction and one
/// column per variable. Jaguar fills it, or the student fills it first
/// (Practicar) and Jaguar marks what they got right.
class DeskCheckScreen extends StatefulWidget {
  const DeskCheckScreen({super.key, required this.name, required this.source});

  final String name;
  final String source;

  @override
  State<DeskCheckScreen> createState() => _DeskCheckScreenState();
}

class _DeskCheckScreenState extends State<DeskCheckScreen> {
  final _inputs = TextEditingController();
  DeskCheck? _check;
  bool _busy = false;

  /// Practice: the values are hidden until the student checks.
  bool _practice = false;
  bool _revealed = false;
  final _guesses = <(int, String), TextEditingController>{};

  bool get _needsInput => _readsInput.hasMatch(widget.source);

  @override
  void initState() {
    super.initState();
    if (!_needsInput) _fill();
  }

  @override
  void dispose() {
    _inputs.dispose();
    for (final c in _guesses.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fill() async {
    setState(() => _busy = true);
    final inputs = _inputs.text.split(RegExp(r'[\n,]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final check = await deskCheck(widget.source, inputs: inputs);
    if (!mounted) return;
    for (final c in _guesses.values) {
      c.dispose();
    }
    _guesses.clear();
    setState(() {
      _check = check;
      _busy = false;
      _revealed = false;
    });
  }

  TextEditingController _guess(int row, String variable) =>
      _guesses.putIfAbsent((row, variable), TextEditingController.new);

  static String _plain(String value) => value.replaceAll('"', '').trim().toLowerCase();

  bool _right(int row, String variable) => _plain(_guess(row, variable).text) == _plain(_check!.value(row, variable));

  void _copy() {
    Clipboard.setData(ClipboardData(text: _check!.toTsv()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tabla copiada: pégala en una hoja de cálculo o un documento')));
  }

  @override
  Widget build(BuildContext context) {
    final check = _check;
    return Scaffold(
      appBar: AppBar(
        title: Text('Prueba de escritorio · ${widget.name}', overflow: TextOverflow.ellipsis),
        actions: [
          if (check != null) IconButton(tooltip: 'Copiar tabla', icon: const Icon(Icons.copy_all), onPressed: _copy),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_needsInput)
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _inputs,
                      // The table needs the data first: start typing right away.
                      autofocus: check == null,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Datos de entrada',
                        helperText: 'Separados por comas, en el orden en que se leen',
                        helperMaxLines: 2,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _fill(),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: _busy ? null : _fill,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(check == null ? 'Hacer la tabla' : 'Volver a hacer'),
                ),
                FilterChip(
                  label: const Text('Practicar: yo la lleno'),
                  selected: _practice,
                  onSelected: (on) => setState(() {
                    _practice = on;
                    _revealed = false;
                  }),
                ),
                if (_practice && check != null)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _revealed = true),
                    icon: const Icon(Icons.done_all),
                    label: const Text('Revisar'),
                  ),
              ],
            ),
          ),
          if (check?.error case final error?)
            _Notice(color: Theme.of(context).colorScheme.errorContainer, text: 'Línea ${error.line}: ${error.message}'),
          if (check != null && check.truncated)
            _Notice(
              color: Theme.of(context).colorScheme.secondaryContainer,
              text: 'La tabla muestra los primeros ${check.rows.length} pasos.',
            ),
          if (_practice && _revealed && check != null) _score(check),
          Expanded(
            child: check == null
                ? const Center(child: Text('Escribe los datos que va a leer el programa y haz la tabla.'))
                : _table(check),
          ),
        ],
      ),
    );
  }

  Widget _score(DeskCheck check) {
    var total = 0, right = 0;
    for (var r = 0; r < check.rows.length; r++) {
      for (final v in check.variables) {
        if (!check.changed(r, v)) continue;
        total++;
        if (_right(r, v)) right++;
      }
    }
    return _Notice(
      color: right == total ? Colors.green.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHigh,
      text: right == total
          ? '¡Todo correcto! $right de $total valores.'
          : 'Acertaste $right de $total valores. En rojo, los que no coinciden.',
    );
  }

  Widget _table(DeskCheck check) {
    final scheme = Theme.of(context).colorScheme;
    final mono = monoStyle.copyWith(fontSize: 13);
    final header = TextStyle(fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant);
    final phone = MediaQuery.sizeOf(context).width < 600;

    Widget cell(Widget child, {Color? color}) => Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: Alignment.centerLeft,
      child: child,
    );

    Widget valueCell(int row, String variable) {
      final changed = check.changed(row, variable);
      final value = check.value(row, variable);
      if (!_practice) {
        return cell(
          Text(value, style: mono.copyWith(fontWeight: changed ? FontWeight.bold : null)),
          color: changed ? jaguarYellow.withValues(alpha: 0.18) : null,
        );
      }
      // Practice: only the cells where the value changes are asked.
      if (!changed) return cell(Text(value.isEmpty ? '' : '·', style: mono));
      final right = _right(row, variable);
      return cell(
        SizedBox(
          width: 90,
          child: TextField(
            controller: _guess(row, variable),
            style: mono,
            decoration: InputDecoration(
              isDense: true,
              hintText: '?',
              helperText: _revealed && !right ? value : null,
              helperStyle: mono.copyWith(color: scheme.error, fontSize: 11),
            ),
          ),
        ),
        color: !_revealed ? null : (right ? Colors.green.withValues(alpha: 0.2) : scheme.errorContainer),
      );
    }

    return Scrollbar(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: scheme.outlineVariant),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
                children: [
                  cell(Text('Paso', style: header)),
                  cell(Text('Instrucción', style: header)),
                  for (final v in check.variables) cell(Text(v, style: header.copyWith(fontFamily: monoFamily))),
                  cell(Text('Pantalla', style: header)),
                ],
              ),
              for (var r = 0; r < check.rows.length; r++)
                TableRow(
                  children: [
                    cell(Text('${r + 1}', style: TextStyle(color: scheme.onSurfaceVariant))),
                    cell(
                      // On a phone the variables matter more than the whole line.
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: phone ? 150 : 420),
                        child: Text('${check.rows[r].line}: ${check.rows[r].instruction}', style: mono),
                      ),
                    ),
                    for (final v in check.variables) valueCell(r, v),
                    cell(Text(check.rows[r].output.trimRight(), style: mono)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
    child: Text(text),
  );
}
