import 'package:flutter/material.dart';

import 'privacy_text.dart';

export 'privacy_text.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Aviso de privacidad')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Última actualización: $privacyUpdated',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              for (final (title, body) in privacySections) ...[
                const SizedBox(height: 18),
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                SelectableText(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
