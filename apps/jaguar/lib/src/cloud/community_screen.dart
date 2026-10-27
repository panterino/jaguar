import 'package:flutter/material.dart';

import '../programs/examples.dart';
import '../theme.dart';
import 'account_dialog.dart';
import 'cloud.dart';

/// What the community shares: programs to try and remix, and exercises for
/// the shared bank. Without a connection it shows Jaguar's own examples.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, required this.cloud, required this.onOpenSource, this.currentProgram});

  /// Null when Jaguar is offline.
  final Cloud? cloud;

  /// Opens a copy of a program in the editor.
  final ValueChanged<String> onOpenSource;

  /// The program in the editor, offered to publish.
  final String? currentProgram;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  PublicationKind? _kind;
  Future<List<Publication>>? _items;

  Cloud? get _cloud => widget.cloud;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final items = _cloud?.backend.publications(kind: _kind);
    setState(() {
      _items = items;
    });
  }

  void _open(String source) {
    Navigator.popUntil(context, (route) => route.isFirst);
    widget.onOpenSource(source);
  }

  Future<void> _publish() async {
    final cloud = _cloud!;
    if (!cloud.signedIn) {
      await showAccountDialog(context, cloud);
      if (!cloud.signedIn) return;
    }
    if (!mounted) return;
    final published = await showDialog<bool>(
      context: context,
      builder: (_) => PublishDialog(cloud: cloud, source: widget.currentProgram ?? ''),
    );
    if (published == true) _reload();
  }

  Future<void> _details(Publication publication) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PublicationSheet(cloud: _cloud!, publication: publication, onOpen: _open),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        actions: [
          if (_cloud != null) IconButton(tooltip: 'Actualizar', icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      floatingActionButton: _cloud != null && widget.currentProgram != null
          ? FloatingActionButton.extended(
              onPressed: _publish,
              icon: const Icon(Icons.ios_share),
              label: const Text('Compartir mi programa'),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              if (_cloud != null) ...[
                SegmentedButton<PublicationKind?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todo')),
                    ButtonSegment(value: PublicationKind.programa, label: Text('Programas')),
                    ButtonSegment(value: PublicationKind.ejercicio, label: Text('Ejercicios')),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (s) {
                    _kind = s.single;
                    _reload();
                  },
                ),
                const SizedBox(height: 12),
                FutureBuilder(
                  future: _items,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _Note('No se pudo cargar la comunidad: ${snapshot.error}');
                    }
                    final items = snapshot.data;
                    if (items == null) return const LinearProgressIndicator();
                    if (items.isEmpty) {
                      return const _Note('Todavía no hay nada aquí. ¡Sé la primera persona en compartir un programa!');
                    }
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [for (final p in items) _PublicationCard(publication: p, onTap: () => _details(p))],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ] else
                const _Note(
                  'Sin conexión: la comunidad aparece cuando Jaguar se conecta. Mientras, prueba los ejemplos.',
                ),
              Text('Ejemplos de Jaguar Code', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (title, source) in examples)
                    ActionChip(
                      avatar: const Icon(Icons.lightbulb_outline, size: 18),
                      label: Text(title),
                      onPressed: () => _open(source),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicationCard extends StatelessWidget {
  const _PublicationCard({required this.publication, required this.onTap});

  final Publication publication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = publication;
    return SizedBox(
      width: 280,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      p.kind == PublicationKind.ejercicio ? Icons.assignment_outlined : Icons.code,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.topic,
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(p.title, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  p.description.isEmpty ? 'Sin descripción' : p.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text('de ${p.authorAlias}', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PublicationSheet extends StatefulWidget {
  const _PublicationSheet({required this.cloud, required this.publication, required this.onOpen});

  final Cloud cloud;
  final Publication publication;
  final ValueChanged<String> onOpen;

  @override
  State<_PublicationSheet> createState() => _PublicationSheetState();
}

class _PublicationSheetState extends State<_PublicationSheet> {
  int? _count;
  bool _useful = false;

  Publication get _p => widget.publication;

  @override
  void initState() {
    super.initState();
    _loadUseful();
  }

  Future<void> _loadUseful() async {
    try {
      final count = await widget.cloud.backend.usefulCount(_p.id);
      final mine = widget.cloud.signedIn && await widget.cloud.backend.isUseful(_p.id);
      if (mounted) {
        setState(() {
          _count = count;
          _useful = mine;
        });
      }
    } on Object {
      // Counting is a nicety; the program still opens.
    }
  }

  Future<void> _toggleUseful() async {
    if (!widget.cloud.signedIn) {
      await showAccountDialog(context, widget.cloud);
      if (!widget.cloud.signedIn) return;
    }
    await widget.cloud.backend.setUseful(_p.id, useful: !_useful);
    await _loadUseful();
  }

  Future<void> _report() async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _ReportDialog());
    if (reason == null) return;
    if (!widget.cloud.signedIn) {
      if (!mounted) return;
      await showAccountDialog(context, widget.cloud);
      if (!widget.cloud.signedIn) return;
    }
    await widget.cloud.backend.report(_p.id, reason);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gracias. Una persona del equipo lo va a revisar.')));
    }
  }

  /// A copy with credit to the author: remixing keeps the chain visible.
  String get _remix {
    final source = _p.source ?? _p.exercise?.statement ?? '';
    return '// Basado en «${_p.title}» de ${_p.authorAlias} (Comunidad Jaguar, CC BY-SA)\n$source';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = _p.exercise;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(_p.title, style: theme.textTheme.headlineSmall),
          Text('${_p.topic} · de ${_p.authorAlias}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          if (_p.description.isNotEmpty) Text(_p.description),
          const SizedBox(height: 12),
          if (_p.source != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(_p.source!, style: monoStyle.copyWith(fontSize: 13, letterSpacing: 0)),
            ),
          if (exercise != null) ...[
            Text(exercise.statement),
            const SizedBox(height: 4),
            Text('${exercise.cases.length} pruebas', style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_p.source != null)
                FilledButton.icon(
                  onPressed: () => widget.onOpen(_remix),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Abrir y probar'),
                ),
              OutlinedButton.icon(
                onPressed: _toggleUseful,
                icon: Icon(_useful ? Icons.favorite : Icons.favorite_border),
                label: Text(_count == null ? 'Me sirvió' : 'Me sirvió · $_count'),
              ),
              TextButton.icon(onPressed: _report, icon: const Icon(Icons.flag_outlined), label: const Text('Reportar')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shares a program (or an exercise) with the community.
class PublishDialog extends StatefulWidget {
  const PublishDialog({super.key, required this.cloud, required this.source, this.exercise});

  final Cloud cloud;
  final String source;

  /// When set, it is published to the shared bank of exercises.
  final Map<String, Object?>? exercise;

  @override
  State<PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<PublishDialog> {
  late final _title = TextEditingController(text: widget.exercise?['t'] as String? ?? '');
  final _description = TextEditingController();
  String _topic = topics.first;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Ponle un título.');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.cloud.backend.publish(
        kind: widget.exercise == null ? PublicationKind.programa : PublicationKind.ejercicio,
        title: _title.text.trim(),
        description: _description.text.trim(),
        topic: _topic,
        content: widget.exercise == null ? {'source': widget.source} : {'exercise': widget.exercise},
      );
      if (mounted) Navigator.pop(context, true);
    } on CloudException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExercise = widget.exercise != null;
    return AlertDialog(
      title: Text(isExercise ? 'Compartir en el banco de ejercicios' : 'Compartir en la comunidad'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título', hintText: 'Adivina el número'),
            ),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción', hintText: '¿Qué hace? ¿Qué aprendiste?'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _topic,
              decoration: const InputDecoration(labelText: 'Tema'),
              items: [for (final t in topics) DropdownMenuItem(value: t, child: Text(t))],
              onChanged: (t) => setState(() => _topic = t ?? _topic),
            ),
            const SizedBox(height: 12),
            Text(
              isExercise
                  ? 'Se comparten el enunciado y las pruebas; tu solución no.'
                  : 'Se publica con tu alias, bajo licencia CC BY-SA: cualquiera puede usarlo y remezclarlo dándote crédito.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: _busy ? null : _publish, child: const Text('Publicar')),
      ],
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  static const _reasons = [
    'Tiene contenido inapropiado',
    'Comparte datos personales',
    'Es copia de otra persona',
    'No funciona o es spam',
  ];
  String _reason = _reasons.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar'),
      content: RadioGroup<String>(
        groupValue: _reason,
        onChanged: (r) => setState(() => _reason = r ?? _reason),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (final r in _reasons) RadioListTile<String>(value: r, title: Text(r))],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, _reason), child: const Text('Reportar')),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}
