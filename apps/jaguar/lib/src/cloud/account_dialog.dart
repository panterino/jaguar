import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.cloud.user;
    if (user != null) return _signedIn(context, user);
    final teacher = _role == CloudRole.profesor;
    return AlertDialog(
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
              SegmentedButton<CloudRole>(
                segments: const [
                  ButtonSegment(value: CloudRole.alumno, label: Text('Alumno'), icon: Icon(Icons.backpack_outlined)),
                  ButtonSegment(value: CloudRole.profesor, label: Text('Profesor'), icon: Icon(Icons.school_outlined)),
                  ButtonSegment(
                    value: CloudRole.autodidacta,
                    label: Text('Por mi cuenta'),
                    icon: Icon(Icons.explore_outlined),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() {
                  _role = s.single;
                  _error = null;
                }),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _teacherHasAccount = !_teacherHasAccount),
                    child: Text(_teacherHasAccount ? '¿Primera vez? Crear cuenta de profesor' : 'Ya tengo cuenta'),
                  ),
                ),
              ],
              if (!teacher)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tu cuenta vive en este dispositivo: si borras los datos del navegador se pierde. '
                    'Tus programas siguen guardados aquí aunque no entres.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
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
    return AlertDialog(
      title: Text(user.alias),
      content: Text(switch (user.role) {
        CloudRole.profesor => 'Cuenta de profesor${user.email == null ? '' : ' (${user.email})'}.',
        CloudRole.alumno => 'Cuenta de alumno en este dispositivo.',
        CloudRole.autodidacta => 'Aprendes por tu cuenta, en este dispositivo.',
      }),
      actions: [
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
