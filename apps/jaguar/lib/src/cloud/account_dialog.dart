import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../help/privacy.dart';
import 'cloud.dart';

/// Entering Jaguar online. Students and self-learners only choose an alias
/// (no email, nothing personal); teachers use an email so their classes
/// are not lost when they change computer.
Future<void> showAccountDialog(BuildContext context, Cloud cloud) => showDialog<void>(
  context: context,
  builder: (context) => _AccountDialog(cloud: cloud),
);

class _AccountDialog extends StatefulWidget {
  const _AccountDialog({required this.cloud});

  final Cloud cloud;

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  CloudRole _role = CloudRole.alumno;
  bool _teacherHasAccount = true;
  final _alias = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  String? _notice;
  bool _busy = false;

  @override
  void dispose() {
    _alias.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cloud = widget.cloud;
    final alias = _alias.text.trim();
    final email = _email.text.trim();
    final teacher = _role == CloudRole.profesor;
    if ((!teacher || !_teacherHasAccount) && alias.isEmpty) {
      setState(() => _error = teacher ? 'Escribe cómo te verán tus alumnos.' : 'Escribe un alias.');
      return;
    }
    if (teacher && (email.isEmpty || _password.text.isEmpty)) {
      setState(() => _error = 'Escribe tu correo y tu contraseña.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!teacher) {
        await cloud.signInAnonymously(alias: alias, role: _role);
      } else if (_teacherHasAccount) {
        await cloud.signInTeacher(email: email, password: _password.text);
      } else {
        await cloud.registerTeacher(email: email, password: _password.text, alias: alias);
      }
      if (mounted) Navigator.pop(context);
    } on CloudException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Escribe tu correo y te mandamos un enlace para cambiar la contraseña.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.cloud.resetPassword(email);
      if (mounted) setState(() => _notice = 'Te mandamos un correo a $email para cambiar tu contraseña.');
    } on CloudException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount(CloudUser user) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar tu cuenta?'),
        content: Text(
          user.isTeacher
              ? 'Se borran tu cuenta, tus clases con las entregas de tus alumnos y lo que publicaste. '
                    'No se puede deshacer. Tus programas en este dispositivo se quedan.'
              : 'Se borran tu cuenta, tu lugar en tus clases, tus entregas y lo que publicaste. '
                    'No se puede deshacer. Tus programas en este dispositivo se quedan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar cuenta'),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.cloud.deleteAccount();
      if (mounted) Navigator.pop(context);
    } on CloudException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.cloud.user;
    if (user != null) return _signedIn(context, user);
    final teacher = _role == CloudRole.profesor;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Entrar a Jaguar en línea'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Para unirte a una clase, compartir en la comunidad y guardar tu progreso en línea.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Chips wrap on a phone; three segments did not fit.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (role, label, icon) in const [
                    (CloudRole.alumno, 'Alumno', Icons.backpack_outlined),
                    (CloudRole.profesor, 'Profesor', Icons.school_outlined),
                    (CloudRole.autodidacta, 'Por mi cuenta', Icons.explore_outlined),
                  ])
                    ChoiceChip(
                      avatar: Icon(icon, size: 18),
                      label: Text(label),
                      selected: _role == role,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _role = role;
                        _error = null;
                        _notice = null;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (!teacher) ...[
                TextField(
                  controller: _alias,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Alias',
                    hintText: 'Como quieres que te vean',
                    helperText: 'No uses tu nombre completo ni datos personales.',
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ] else ...[
                if (!_teacherHasAccount)
                  TextField(
                    controller: _alias,
                    decoration: const InputDecoration(
                      labelText: 'Nombre que verán tus alumnos',
                      hintText: 'Profa. López',
                    ),
                  ),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  onSubmitted: (_) => _submit(),
                ),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _teacherHasAccount = !_teacherHasAccount),
                      child: Text(_teacherHasAccount ? '¿Primera vez? Crear cuenta de profesor' : 'Ya tengo cuenta'),
                    ),
                    if (_teacherHasAccount)
                      TextButton(onPressed: _busy ? null : _resetPassword, child: const Text('Olvidé mi contraseña')),
                  ],
                ),
              ],
              if (!teacher)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    kIsWeb
                        ? 'Tu cuenta vive en este navegador: si borras sus datos se pierde. '
                              'Tus programas siguen guardados aquí aunque no entres.'
                        : 'Tu cuenta vive en este teléfono: si desinstalas Jaguar o borras sus datos se pierde. '
                              'Tus programas siguen guardados aquí aunque no entres.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PrivacyScreen())),
                  child: const Text('Al entrar aceptas el aviso de privacidad'),
                ),
              ),
              if (_notice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_notice!, style: TextStyle(color: theme.colorScheme.primary)),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ahora no')),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(teacher && !_teacherHasAccount ? 'Crear cuenta' : 'Entrar'),
        ),
      ],
    );
  }

  Widget _signedIn(BuildContext context, CloudUser user) {
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(user.alias),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(switch (user.role) {
            CloudRole.profesor => 'Cuenta de profesor${user.email == null ? '' : ' (${user.email})'}.',
            CloudRole.alumno => 'Cuenta de alumno en este dispositivo.',
            CloudRole.autodidacta => 'Aprendes por tu cuenta, en este dispositivo.',
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error, padding: EdgeInsets.zero),
            onPressed: _busy ? null : () => _deleteAccount(user),
            icon: const Icon(Icons.delete_forever_outlined, size: 18),
            label: const Text('Borrar mi cuenta'),
          ),
          if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
      ),
      actions: [
        if (!user.isTeacher)
          TextButton(
            // Leaves this account and shows the teacher sign-in.
            onPressed: () async {
              await widget.cloud.signOut();
              setState(() {
                _role = CloudRole.profesor;
                _error = null;
              });
            },
            child: const Text('Entrar como profesor'),
          ),
        TextButton(
          onPressed: () async {
            await widget.cloud.signOut();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Salir'),
        ),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Listo')),
      ],
    );
  }
}
