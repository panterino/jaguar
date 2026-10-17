import 'package:flutter/material.dart';

import '../theme.dart';
import 'syntax_controller.dart';

/// A label and the snippet it inserts. `§` marks the cursor position.
typedef Snippet = (String label, String text);

const _snippets = <Snippet>[
  ('<-', ' <- '),
  ('" "', '"§"'),
  ('( )', '(§)'),
  ('[ ]', '[§]'),
  ('=', ' = '),
  ('<', ' < '),
  ('>', ' > '),
  ('+', ' + '),
  ('-', ' - '),
  ('*', ' * '),
  ('/', ' / '),
  ('Escribir', 'Escribir §'),
  ('Leer', 'Leer §'),
  ('Definir', 'Definir § Como Entero'),
  ('Si', 'Si § Entonces\n    \nFinSi'),
  ('SiNo', 'SiNo\n    §'),
  ('Para', 'Para i <- 1 Hasta § Hacer\n    \nFinPara'),
  ('Mientras', 'Mientras § Hacer\n    \nFinMientras'),
  ('Repetir', 'Repetir\n    §\nHasta Que '),
  ('Segun', 'Segun § Hacer\n    1:\n        \n    De Otro Modo:\n        \nFinSegun'),
  ('Dimension', 'Dimension §[10]'),
  ('<>', ' <> '),
  ('<=', ' <= '),
  ('>=', ' >= '),
  ('Y', ' Y '),
  ('O', ' O '),
  ('NO', 'NO '),
  ('MOD', ' MOD '),
  (',', ', '),
  (':', ':'),
  (';', ';'),
  ('^', '^'),
];

/// A row of keywords above the keyboard. Typing `FinMientras` or `<-` on a
/// phone keyboard is slow and error-prone.
class KeywordBar extends StatelessWidget {
  const KeywordBar({super.key, required this.controller, required this.focusNode});

  final SyntaxController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Phones get two rows of bigger keys: symbols on top, instructions
    // below. Larger screens keep one compact row.
    final phone = MediaQuery.sizeOf(context).width < 600;
    final keys = [
      _KeyButton(icon: Icons.keyboard_arrow_left, tooltip: 'Mover a la izquierda', onTap: () => _move(-1)),
      _KeyButton(icon: Icons.keyboard_arrow_right, tooltip: 'Mover a la derecha', onTap: () => _move(1)),
      _KeyButton(icon: Icons.keyboard_tab, tooltip: 'Sangría', onTap: () => _insert('    ')),
    ];
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SizedBox(
        height: phone ? 104 : 44,
        child: Row(
          children: [
            // Moving the cursor with a finger is the hardest part of
            // editing on a phone.
            if (phone)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: keys.take(2).toList()),
                  keys.last,
                ],
              )
            else
              ...keys,
            VerticalDivider(width: 1, indent: 8, endIndent: 8, color: scheme.outlineVariant),
            Expanded(child: phone ? _snippetGrid() : _snippetList()),
          ],
        ),
      ),
    );
  }

  Widget _snippetGrid() {
    Widget key((String, String) snippet) => Padding(
      padding: const EdgeInsets.all(3),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 42),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _insert(snippet.$2),
        child: Text(snippet.$1, style: monoStyle.copyWith(fontSize: 15)),
      ),
    );
    // Instructions (Escribir, Si…) below; symbols and operators (Y, MOD…) on top.
    final words = _snippets.where((s) => RegExp('[a-z]').hasMatch(s.$1)).toList();
    final symbols = _snippets.where((s) => !words.contains(s)).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [for (final s in symbols) key(s)]),
          Row(children: [for (final s in words) key(s)]),
        ],
      ),
    );
  }

  void _insert(String text) {
    controller.insertSnippet(text);
    focusNode.requestFocus();
  }

  void _move(int by) {
    final selection = controller.selection;
    final at = (selection.isValid ? (by < 0 ? selection.start : selection.end) : controller.text.length) + by;
    controller.selection = TextSelection.collapsed(offset: at.clamp(0, controller.text.length));
    focusNode.requestFocus();
  }

  Widget _snippetList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: _snippets.length,
      separatorBuilder: (_, _) => const SizedBox(width: 6),
      itemBuilder: (context, index) {
        final (label, text) = _snippets[index];
        return ActionChip(
          label: Text(label, style: monoStyle.copyWith(fontSize: 13)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
          onPressed: () => _insert(text),
        );
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: tooltip, icon: Icon(icon, size: 22), visualDensity: VisualDensity.compact, onPressed: onTap);
}
