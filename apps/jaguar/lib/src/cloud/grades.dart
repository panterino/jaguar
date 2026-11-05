import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/pro_widgets.dart';
import 'cloud_backend.dart';

/// The grades of a class as a table: a row per student, a column per task and
/// a last one with how many tasks are complete. The numbers are the ones Jaguar
/// checked, not what each student reported.
class GradesTable {
  GradesTable({
    required List<Assignment> assignments,
    required List<Member> members,
    required Map<String, Map<String, Submission>> submissions,
  }) {
    header = ['Alumno', for (final a in assignments) a.title, 'Tareas completas', 'Avance'];
    for (final m in members) {
      var done = 0;
      final cells = <GradeCell>[];
      for (final a in assignments) {
        final s = submissions[a.id]?[m.uid];
        if (s == null) {
          cells.add(const GradeCell.empty());
        } else {
          cells.add(GradeCell(s.passed, s.total));
          if (s.complete) done++;
        }
      }
      rows.add(GradeRow(m.name, cells, done, assignments.length));
    }
  }

  late final List<String> header;
  final List<GradeRow> rows = [];

  /// Excel opens it with the right accents (the BOM) and does not turn "4 de 4"
  /// into a date, which "4/4" would become.
  String toCsv() {
    String quote(String text) => '"${text.replaceAll('"', '""')}"';
    final lines = [header.map(quote).join(',')];
    for (final r in rows) {
      lines.add(
        [
          quote(r.name),
          for (final c in r.cells) quote(c.text),
          '${r.done}',
          r.total == 0 ? '' : '${(r.done * 100 / r.total).round()} %',
        ].join(','),
      );
    }
    return '﻿${lines.join('\r\n')}\r\n';
  }

  /// With tabs, which a spreadsheet takes as columns when pasted.
  String toTsv() {
    String cell(String text) => text.replaceAll(RegExp(r'[\t\r\n]+'), ' ');
    final lines = [header.map(cell).join('\t')];
    for (final r in rows) {
      lines.add(
        [
          cell(r.name),
          for (final c in r.cells) c.text,
          '${r.done}',
          r.total == 0 ? '' : '${(r.done * 100 / r.total).round()} %',
        ].join('\t'),
      );
    }
    return lines.join('\n');
  }
}

class GradeRow {
  GradeRow(this.name, this.cells, this.done, this.total);

  final String name;
  final List<GradeCell> cells;
  final int done;
  final int total;
}

class GradeCell {
  const GradeCell(this.passed, this.total) : delivered = true;
  const GradeCell.empty() : passed = 0, total = 0, delivered = false;

  final int passed;
  final int total;
  final bool delivered;

  bool get complete => delivered && total > 0 && passed == total;
  String get text => delivered ? '$passed de $total' : '';
}

/// Saves the grades as a `.csv` file. Returns false if the teacher cancelled.
Future<bool> saveGradesCsv(String className, GradesTable table) async {
  final safe = className.replaceAll(RegExp(r'[^\w\- ]+', unicode: true), '').trim();
  final path = await FilePicker.saveFile(
    dialogTitle: 'Guardar calificaciones',
    fileName: 'Calificaciones ${safe.isEmpty ? 'clase' : safe}.csv',
    type: FileType.custom,
    allowedExtensions: const ['csv'],
    bytes: Uint8List.fromList(utf8.encode(table.toCsv())),
  );
  // On the web the browser downloads the file and there is no path.
  return path != null || kIsWeb;
}

/// The grades on screen like a spreadsheet, with the way out: download it for
/// Excel, or copy it to paste into one.
Future<void> showGrades(BuildContext context, {required String className, required GradesTable table}) =>
    showDialog<void>(
      context: context,
      builder: (context) => _GradesDialog(className: className, table: table),
    );

class _GradesDialog extends StatelessWidget {
  const _GradesDialog({required this.className, required this.table});

  final String className;
  final GradesTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calificaciones', style: theme.textTheme.titleLarge),
                Text(
                  className,
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(tooltip: 'Cerrar', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      content: SizedBox(
        width: 900,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cada número es lo que Jaguar comprobó al correr el programa de cada alumno contra todas las pruebas, '
              'las ocultas incluidas. Aquí lo ves como en una hoja de cálculo; descárgalo para abrirlo en Excel.',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
                      dataRowMinHeight: 44,
                      dataRowMaxHeight: 52,
                      columnSpacing: 24,
                      columns: [
                        for (final h in table.header)
                          DataColumn(
                            label: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(h, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                      ],
                      rows: [
                        for (final r in table.rows)
                          DataRow(
                            cells: [
                              DataCell(Text(r.name)),
                              for (final c in r.cells)
                                DataCell(
                                  c.delivered
                                      ? StatusPill(
                                          label: c.text,
                                          tone: c.complete
                                              ? PillTone.good
                                              : c.passed == 0
                                              ? PillTone.bad
                                              : PillTone.warn,
                                        )
                                      : Text('—', style: TextStyle(color: scheme.outline)),
                                ),
                              DataCell(Text('${r.done} de ${r.total}')),
                              DataCell(Text(r.total == 0 ? '' : '${(r.done * 100 / r.total).round()} %')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: table.toTsv()));
            say('Copiado. Pégalo en una hoja de cálculo.');
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copiar'),
        ),
        FilledButton.icon(
          onPressed: () async {
            try {
              if (await saveGradesCsv(className, table)) say('Calificaciones descargadas.');
            } on Object catch (e) {
              say('No se pudo guardar el archivo: $e');
            }
          },
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Descargar para Excel'),
        ),
      ],
    );
  }
}
