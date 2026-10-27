import 'package:flutter/material.dart';

import '../theme.dart';
import 'privacy.dart';
import '../widgets/mascota.dart';

const jaguarVersion = '0.6.1';

/// Acerca de: what Jaguar is, where it comes from and what it stands for.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de Jaguar Code')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  const Mascota(pose: MascotPose.hola, size: 100),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jaguar Code', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                        Text('Un proyecto de Panterino · versión $jaguarVersion', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Jaguar Code es un lugar para aprender lógica de programación: escribes pseudocódigo o dibujas diagramas de flujo, '
                'resuelves ejercicios que se revisan solos y compartes con una comunidad. '
                'Funciona en la computadora del laboratorio, en el navegador y en el celular, sin internet y sin cuenta.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Text('Nuestra historia', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              const _Milestone(
                year: '2019',
                title: 'Nace en la prepa',
                text:
                    'En septiembre de 2019, un grupo de estudiantes de preparatoria fundó Panterino con una idea: '
                    'un "Duolingo de programación" para que cualquiera pudiera aprender lógica, sin importar '
                    'cuánto dinero, internet o computadora tuviera. Así nació Jaguar, y con él su mascota.',
              ),
              const _Milestone(
                year: '2019–2021',
                title: 'Siete comienzos',
                text:
                    'Lo intentamos muchas veces, con tecnologías distintas. Cada intento se quedó en la pantalla '
                    'de inicio de sesión: nos faltaban experiencia y contenido. Aun así, la página de Jaguar '
                    'reunió a sus primeras cien personas, y la idea nunca se fue.',
              ),
              const _Milestone(
                year: '2026',
                title: 'Jaguar regresa',
                text:
                    'Con lo aprendido en estos años, Jaguar vuelve para cumplir lo que prometió: aprender lógica '
                    'con diagramas y pseudocódigo en una sola app, que funciona en cualquier equipo y que '
                    'une a estudiantes, profesores y gente que aprende por su cuenta. Abre también los archivos '
                    '.psc de otros programas de pseudocódigo.',
                last: true,
              ),
              const SizedBox(height: 20),
              Text('En qué creemos', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final (icon, text) in const [
                (Icons.volunteer_activism_outlined, 'Gratis para estudiantes, siempre.'),
                (Icons.wifi_off_outlined, 'Primero sin internet: lo importante funciona en cualquier equipo.'),
                (
                  Icons.lock_outline,
                  'Sin pedir datos personales. Muchas personas que aprenden aquí son menores de edad.',
                ),
                (
                  Icons.psychology_outlined,
                  'IA al final: primero algoritmos probados; la IA solo donde de verdad ayuda.',
                ),
                (Icons.diversity_3_outlined, 'Abierto y en comunidad: lo que uno aprende puede servirle a otro.'),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, color: scheme.primary),
                  title: Text(text),
                ),
              const SizedBox(height: 20),
              Card(
                color: scheme.secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Gracias a los compañeros de la prepa que creyeron en la idea desde 2019, a los profesores '
                    'que enseñan lógica con lo que tienen a la mano y a todas las personas que han hecho '
                    'herramientas para aprender a programar.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lo que se publica en la comunidad se comparte bajo licencia CC BY-SA.',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PrivacyScreen())),
                  icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                  label: const Text('Aviso de privacidad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One step of the story, on a vertical line.
class _Milestone extends StatelessWidget {
  const _Milestone({required this.year, required this.title, required this.text, this.last = false});

  final String year;
  final String title;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: jaguarYellow, shape: BoxShape.circle),
                ),
                if (!last) Expanded(child: Container(width: 2, color: jaguarYellow.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$year · $title', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
