import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'home_shell.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _enterApp(BuildContext context, {int initialIndex = 0}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeShell(initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appState = context.watch<AppState>();
    final totalPosts = appState.feed.length;
    final totalCareers = appState.feed
        .map((p) => p.authorCareer)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school_rounded,
                color: scheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Match Universitario',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Universidad de La Guajira',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: () => _enterApp(context),
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Ir al Tablero'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroBanner(
                    totalPosts: totalPosts,
                    totalCareers: totalCareers,
                    onStartMatch: () => _enterApp(context, initialIndex: 0),
                    onConfigureProfile: () =>
                        _enterApp(context, initialIndex: 2),
                  ),
                  const SizedBox(height: 36),
                  const _SectionHeader(
                    eyebrow: '¿QUÉ HACE Y DE QUÉ ES CAPAZ?',
                    title: 'Todo el talento de Uniguajira en un solo tablero',
                    subtitle:
                        'Diseñado para conectar estudiantes de distintas facultades '
                        'sin burocracia ni chats interminables.',
                  ),
                  const SizedBox(height: 20),
                  const _CapabilitiesGrid(),
                  const SizedBox(height: 36),
                  const _SectionHeader(
                    eyebrow: 'ASÍ DE SIMPLE',
                    title: '¿Cómo funciona el Match en el campus?',
                    subtitle:
                        'Tres pasos para pasar de una idea a un equipo real en la '
                        'Universidad de La Guajira.',
                  ),
                  const SizedBox(height: 20),
                  const _HowItWorksSection(),
                  const SizedBox(height: 36),
                  _BottomCtaCard(
                    onStartMatch: () => _enterApp(context, initialIndex: 0),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.totalPosts,
    required this.totalCareers,
    required this.onStartMatch,
    required this.onConfigureProfile,
  });

  final int totalPosts;
  final int totalCareers;
  final VoidCallback onStartMatch;
  final VoidCallback onConfigureProfile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer,
            scheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Comunidad Estudiantil · Universidad de La Guajira',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Conecta con compañeros, arma tu equipo y empieza a hacer Match ya en la Universidad de La Guajira',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onPrimaryContainer,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Match Universitario es el punto de encuentro para estudiantes de '
            'Uniguajira. Encuentra el perfil ideal de otra carrera para tu '
            'proyecto de grado o hackathon, únete a grupos de estudio para '
            'parciales y entérate de los eventos del campus en tiempo real.',
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onStartMatch,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.tertiary,
                  foregroundColor: scheme.onTertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.favorite_rounded),
                label: const Text('Empieza a hacer Match ya'),
              ),
              OutlinedButton.icon(
                onPressed: onConfigureProfile,
                style: OutlinedButton.styleFrom(
                  backgroundColor: scheme.surface.withValues(alpha: 0.75),
                  foregroundColor: scheme.onPrimaryContainer,
                  side: BorderSide(color: scheme.onPrimaryContainer),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Configurar mi perfil'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(
                icon: Icons.campaign_rounded,
                value: '$totalPosts avisos activos',
                caption: 'En el tablero del campus',
              ),
              _StatPill(
                icon: Icons.hub_rounded,
                value: '$totalCareers programas conectados',
                caption: 'Ingenierías, Diseño, Admin y más',
              ),
              const _StatPill(
                icon: Icons.verified_user_rounded,
                value: 'Contacto directo',
                caption: 'WhatsApp o correo al aceptar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                caption,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: textTheme.labelMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CapabilitiesGrid extends StatelessWidget {
  const _CapabilitiesGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _CapabilityItem(
        emoji: '🛠️',
        title: 'Busco Equipo Interdisciplinario',
        description:
            '¿Eres de Ingeniería y necesitas alguien de Diseño, Administración '
            'o Comunicación Social? Publica tu idea de tesis, semillero o '
            'hackathon y filtra por carrera objetivo.',
        badge: 'Proyectos y Tesis',
      ),
      _CapabilityItem(
        emoji: '📚',
        title: 'Grupos de Estudio en el Campus',
        description:
            'Prepara parciales de Cálculo, Finanzas, Programación o Estadística '
            'indicando el bloque, salón o sala de la biblioteca donde se '
            'reunirán.',
        badge: 'Éxito Académico',
      ),
      _CapabilityItem(
        emoji: '📅',
        title: 'Cartelera de Eventos Uniguajira',
        description:
            'Difunde y descubre talleres, ferias de emprendimiento, charlas '
            'académicas y actividades culturales dentro de la universidad.',
        badge: 'Vida Universitaria',
      ),
      _CapabilityItem(
        emoji: '🤝',
        title: 'Sistema de Match con Contacto Seguro',
        description:
            'Postúlate con un solo toque en "Me interesa". Tu WhatsApp o correo '
            'solo se revela cuando el creador del aviso acepta hacer Match '
            'contigo.',
        badge: 'Privacidad y Rapidez',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final cardWidth = isWide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _CapabilityCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _CapabilityItem {
  const _CapabilityItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.badge,
  });

  final String emoji;
  final String title;
  final String description;
  final String badge;
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({required this.item});

  final _CapabilityItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.badge,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        number: '1',
        title: 'Crea tu perfil ligero',
        detail:
            'Indica tu carrera en Uniguajira, semestre, tus habilidades clave '
            'y tu canal de contacto preferido (WhatsApp o correo).',
      ),
      (
        number: '2',
        title: 'Explora o publica una oportunidad',
        detail:
            'Revisa el Tablero de Oportunidades o publica lo que necesitas en '
            'menos de un minuto.',
      ),
      (
        number: '3',
        title: 'Haz Match y coordina al instante',
        detail:
            'Pulsa "Me interesa". Al ser aceptado, se desbloquea el contacto '
            'directo para que hablen y trabajen juntos.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final width = isWide
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final step in steps)
              SizedBox(
                width: width,
                child: _StepCard(
                  number: step.number,
                  title: step.title,
                  detail: step.detail,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.detail,
  });

  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCtaCard extends StatelessWidget {
  const _BottomCtaCard({required this.onStartMatch});

  final VoidCallback onStartMatch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.diversity_3_rounded,
            size: 40,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            '¿Listo para conectar con tu próximo equipo en Uniguajira?',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora las convocatorias abiertas hoy en la Universidad de La Guajira '
            'o publica tu propio aviso en segundos.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondaryContainer.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onStartMatch,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text(
              'Empieza a hacer Match ya en la Universidad de La Guajira',
            ),
          ),
        ],
      ),
    );
  }
}
