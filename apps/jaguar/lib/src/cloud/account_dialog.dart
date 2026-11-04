import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../help/privacy.dart';
import '../widgets/pro_widgets.dart';
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
  late CloudRole _role = widget.cloud.prefersTeacher ? CloudRole.profesor : CloudRole.alumno;
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
    _privacyTap.dispose();
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

  late final _privacyTap = TapGestureRecognizer()
    ..onTap = () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PrivacyScreen()));
  bool _showPassword = false;

  static const _roles = [
    (CloudRole.alumno, 'Alumno', Icons.backpack_outlined, 'Entras con un alias, sin correo ni teléfono.'),
    (
      CloudRole.profesor,
      'Profesor',
      Icons.school_outlined,
      'Con tu correo, para que tus clases te sigan a cualquier equipo.',
    ),
    (
      CloudRole.autodidacta,
      'Por mi cuenta',
      Icons.explore_outlined,
      'Para compartir en la comunidad y guardar tu progreso en línea.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = widget.cloud.user;
    if (user != null) return _signedIn(context, user);
    final teacher = _role == CloudRole.profesor;
    final registering = teacher && !_teacherHasAccount;
    final role = _roles.firstWhere((r) => r.$1 == _role);
    // Outlined fields here: this is where people come in, and they read as
    // forms to fill in, not as lines on the page.
    final fields = theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: false),
    );
    return Theme(
      data: fields,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        title: const Text('Entrar a Jaguar Code en línea'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Para unirte a una clase, compartir en la comunidad y guardar tu progreso en línea.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, r) in _roles.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _RoleTile(
                            icon: r.$3,
                            label: r.$2,
                            selected: _role == r.$1,
                            onTap: () => setState(() {
                              _role = r.$1;
                              _error = null;
                              _notice = null;
                            }),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(role.$4, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),
                if (!teacher) ...[
                  TextField(
                    controller: _alias,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Alias',
                      hintText: 'Como quieres que te vean',
                      helperText: 'No uses tu nombre completo ni datos personales.',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kIsWeb
                        ? 'Tu cuenta vive en este navegador: si borras sus datos se pierde. '
                              'Tus programas siguen guardados aquí aunque no entres.'
                        : 'Tu cuenta vive en este teléfono: si desinstalas Jaguar o borras sus datos se pierde. '
                              'Tus programas siguen guardados aquí aunque no entres.',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ] else ...[
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: scheme.primaryContainer,
                      selectedForegroundColor: scheme.onPrimaryContainer,
                    ),
                    segments: const [
                      ButtonSegment(value: true, label: Text('Ya tengo cuenta')),
                      ButtonSegment(value: false, label: Text('Crear cuenta')),
                    ],
                    selected: {_teacherHasAccount},
                    onSelectionChanged: (value) => setState(() {
                      _teacherHasAccount = value.single;
                      _error = null;
                      _notice = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (registering) ...[
                    TextField(
                      controller: _alias,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre que verán tus alumnos',
                        hintText: 'Profa. López',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: [registering ? AutofillHints.newPassword : AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      helperText: registering ? 'Mínimo 6 caracteres.' : null,
                      suffixIcon: IconButton(
                        tooltip: _showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña',
                        icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (!registering)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _busy ? null : _resetPassword,
                        child: const Text('Olvidé mi contraseña'),
                      ),
                    ),
                ],
                if (_notice != null) ...[const SizedBox(height: 12), NoticeBox(text: _notice!, tone: PillTone.good)],
                if (_error != null) ...[const SizedBox(height: 12), NoticeBox(text: _error!, tone: PillTone.bad)],
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    text: 'Al entrar aceptas el ',
                    children: [
                      TextSpan(
                        text: 'aviso de privacidad',
                        recognizer: _privacyTap,
                        style: TextStyle(color: scheme.primary, decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ahora no')),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(registering ? 'Crear cuenta' : 'Entrar'),
          ),
        ],
      ),
    );
  }

  Widget _signedIn(BuildContext context, CloudUser user) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final roleLabel = switch (user.role) {
      CloudRole.profesor => 'Profesor',
      CloudRole.alumno => 'Alumno',
      CloudRole.autodidacta => 'Por mi cuenta',
    };
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InitialsAvatar(name: user.alias, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.alias, style: theme.textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      StatusPill(
                        label: roleLabel,
                        tone: user.isTeacher ? PillTone.info : PillTone.neutral,
                        icon: user.isTeacher ? Icons.school_outlined : Icons.person_outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(switch (user.role) {
              CloudRole.profesor =>
                user.email == null
                    ? 'Tus clases y ejercicios te siguen a cualquier equipo.'
                    : 'Entraste con ${user.email}. Tus clases y ejercicios te siguen a cualquier equipo.',
              CloudRole.alumno => 'Tu cuenta de alumno vive en este dispositivo.',
              CloudRole.autodidacta => 'Aprendes por tu cuenta; tu cuenta vive en este dispositivo.',
            }, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            if (_error != null) ...[const SizedBox(height: 12), NoticeBox(text: _error!, tone: PillTone.bad)],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: scheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _busy ? null : () => _deleteAccount(user),
                icon: const Icon(Icons.delete_forever_outlined, size: 18),
                label: const Text('Borrar mi cuenta'),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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

/// One of the three ways to come in: an icon and a name, with the chosen one
/// filled in.
class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
