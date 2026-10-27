import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../utils/photo_picker.dart';
import '../widgets/profile_modals.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.popOnSave = false});

  final bool popOnSave;

  Future<void> _uploadPhotoDirectly(BuildContext context) async {
    final bytes = await pickProfileImageBytes();
    if (bytes != null && bytes.isNotEmpty && context.mounted) {
      final appState = context.read<AppState>();
      appState.registerOrUpdateProfile(
        appState.currentUser.copyWith(photoBytes: bytes),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Foto de perfil actualizada!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si fue abierto como ruta modal desde "Me interesa" / "Publicar",
    // mostramos directamente el editor elegante por pestañas.
    if (popOnSave) {
      return ProfileEditorSheet(
        isEmbedded: false,
        onSaved: () => Navigator.of(context).pop(true),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final hasProfile = appState.hasProfile;
    final gradient =
        kBannerGradients[user.bannerPreset % kBannerGradients.length];

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Dashboard de Mi Perfil'),
        actions: [
          if (!hasProfile)
            TextButton.icon(
              onPressed: () {
                appState.registerOrUpdateProfile(
                  kMockDirectory.first.copyWith(id: 'me'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil de demostración cargado'),
                  ),
                );
              },
              icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
              label: const Text('Probar con datos demo'),
            ),
          if (hasProfile) ...[
            IconButton(
              tooltip: 'Ver cómo me ven otros estudiantes',
              onPressed: () => showStudentProfileModal(
                context,
                user,
                isCurrentUser: true,
                onEditRequested: () => showProfileEditorModal(context),
              ),
              icon: const Icon(Icons.visibility_outlined),
            ),
            TextButton.icon(
              onPressed: () {
                appState.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Sesión cerrada. Ahora estás como usuario nuevo.'),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Cerrar sesión'),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. CABECERA ESTRUCTURADA DEL PERFIL (PORTADA + AVATAR + ACCIONES)
                _HeroProfileHeaderCard(
                  user: user,
                  hasProfile: hasProfile,
                  gradient: gradient,
                  onUploadPhoto: () => _uploadPhotoDirectly(context),
                  onOpenEditor: ({int tab = 0}) =>
                      showProfileEditorModal(context, initialTab: tab),
                  onPreviewPublic: () => showStudentProfileModal(
                    context,
                    user,
                    isCurrentUser: true,
                    onEditRequested: () => showProfileEditorModal(context),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. FILA DE KPI / MÉTRICAS DEL ESTUDIANTE
                _KpiMetricsRow(appState: appState, user: user),
                const SizedBox(height: 20),

                // 3. GRID ESTRUCTURADO DE 2 COLUMNAS (ACADÉMICO / DIPLOMADOS / SKILLS / CONTACTO)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;
                    final leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DiplomasAndSemillerosCard(
                          diplomas: user.diplomas,
                          onAddTap: () =>
                              showProfileEditorModal(context, initialTab: 1),
                        ),
                        const SizedBox(height: 16),
                        _ProjectsAndAchievementsCard(
                          projects: user.projects,
                          portfolioUrl: user.portfolioUrl,
                          onAddTap: () =>
                              showProfileEditorModal(context, initialTab: 1),
                        ),
                      ],
                    );

                    final rightColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SkillsAndLanguagesCard(
                          skills: user.skills,
                          languages: user.languages,
                          onEditTap: () =>
                              showProfileEditorModal(context, initialTab: 1),
                        ),
                        const SizedBox(height: 16),
                        _AcademicAndContactCard(
                          user: user,
                          hasProfile: hasProfile,
                          onEditTap: () =>
                              showProfileEditorModal(context, initialTab: 2),
                        ),
                      ],
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: leftColumn),
                          const SizedBox(width: 18),
                          Expanded(flex: 5, child: rightColumn),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        leftColumn,
                        const SizedBox(height: 16),
                        rightColumn,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroProfileHeaderCard extends StatelessWidget {
  const _HeroProfileHeaderCard({
    required this.user,
    required this.hasProfile,
    required this.gradient,
    required this.onUploadPhoto,
    required this.onOpenEditor,
    required this.onPreviewPublic,
  });

  final UserProfile user;
  final bool hasProfile;
  final List<Color> gradient;
  final VoidCallback onUploadPhoto;
  final void Function({int tab}) onOpenEditor;
  final VoidCallback onPreviewPublic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Portada con degradado y etiquetas de campus
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 140,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Universidad de La Guajira · ${user.campus}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.availability,
                            style: const TextStyle(
                              color: Color(0xFF1F130B),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -44,
                left: 24,
                child: Stack(
                  children: [
                    ProfileAvatar(profile: user, radius: 48),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Material(
                        color: scheme.primary,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onUploadPhoto,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.add_a_photo_rounded,
                              size: 18,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 54, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                hasProfile
                                    ? user.name
                                    : 'Estudiante Nuevo · Sin sesión iniciada',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (hasProfile) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.verified_rounded,
                                color: scheme.primary,
                                size: 22,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasProfile
                              ? (user.headline.isNotEmpty
                                  ? user.headline
                                  : '${user.career} · Semestre ${user.semester}')
                              : 'Personaliza tu foto, carrera, diplomados, semilleros y habilidades para destacar en el campus.',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: hasProfile
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onUploadPhoto,
                          icon: const Icon(Icons.photo_camera_outlined, size: 18),
                          label: const Text('Subir foto'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onPreviewPublic,
                          icon: const Icon(Icons.badge_outlined, size: 18),
                          label: const Text('Vista pública'),
                        ),
                        FilledButton.icon(
                          onPressed: () => onOpenEditor(tab: 0),
                          icon: Icon(
                            hasProfile
                                ? Icons.edit_note_rounded
                                : Icons.rocket_launch_rounded,
                            size: 20,
                          ),
                          label: Text(
                            hasProfile
                                ? 'Editar Perfil Completo'
                                : 'Configurar mi Perfil',
                          ),
                        ),
                        if (hasProfile)
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<AppState>().logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sesión cerrada. Ahora estás como usuario nuevo.',
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.error,
                              side: BorderSide(color: scheme.error),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Cerrar sesión'),
                          ),
                      ],
                    ),
                  ],
                ),

                if (hasProfile && user.bio.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    user.bio,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _HeaderInfoTag(
                      icon: Icons.school_outlined,
                      label: hasProfile
                          ? '${user.career} · Semestre ${user.semester}'
                          : 'Carrera por definir',
                    ),
                    _HeaderInfoTag(
                      icon: Icons.account_balance_outlined,
                      label: user.faculty,
                    ),
                    if (user.universityEmail.isNotEmpty)
                      _HeaderInfoTag(
                        icon: Icons.alternate_email_rounded,
                        label: user.universityEmail,
                      ),
                    if (user.portfolioUrl.isNotEmpty)
                      _HeaderInfoTag(
                        icon: Icons.link_rounded,
                        label: user.portfolioUrl,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfoTag extends StatelessWidget {
  const _HeaderInfoTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiMetricsRow extends StatelessWidget {
  const _KpiMetricsRow({required this.appState, required this.user});

  final AppState appState;
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final completenessPct = (user.completeness * 100).round();
    final items = [
      (
        icon: Icons.verified_user_outlined,
        value: '$completenessPct%',
        label: 'Nivel del perfil',
        caption: completenessPct >= 80
            ? 'Perfil destacado en el campus'
            : 'Añade foto y diplomados',
      ),
      (
        icon: Icons.workspace_premium_outlined,
        value: '${user.diplomas.length}',
        label: 'Diplomados y Semilleros',
        caption: 'Formación complementaria',
      ),
      (
        icon: Icons.campaign_outlined,
        value: '${appState.myPostings.length}',
        label: 'Mis convocatorias',
        caption: '${appState.incomingInterestCount} interesados pendientes',
      ),
      (
        icon: Icons.handshake_outlined,
        value: '${appState.confirmedMatches.length}',
        label: 'Mis Matches',
        caption: '${appState.myApplications.length} postulaciones enviadas',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 860
            ? 4
            : (constraints.maxWidth >= 520 ? 2 : 1);
        final cardWidth = (constraints.maxWidth - ((cols - 1) * 14)) / cols;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _KpiBentoCard(
                  icon: item.icon,
                  value: item.value,
                  label: item.label,
                  caption: item.caption,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KpiBentoCard extends StatelessWidget {
  const _KpiBentoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.caption,
  });

  final IconData icon;
  final String value;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
              ),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiplomasAndSemillerosCard extends StatelessWidget {
  const _DiplomasAndSemillerosCard({
    required this.diplomas,
    required this.onAddTap,
  });

  final List<String> diplomas;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Diplomados, Semilleros y Certificaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (diplomas.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.school_outlined, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Agrega tus diplomados, semilleros de investigación, monitorías o cursos para que otros equipos conozcan tu perfil.',
                    ),
                  ),
                ],
              ),
            )
          else
            for (final d in diplomas)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.military_tech_rounded,
                        color: scheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Formación verificada · Uniguajira',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _ProjectsAndAchievementsCard extends StatelessWidget {
  const _ProjectsAndAchievementsCard({
    required this.projects,
    required this.portfolioUrl,
    required this.onAddTap,
  });

  final List<String> projects;
  final String portfolioUrl;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Proyectos & Logros Académicos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Añadir'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '¿Has participado en hackathons, ferias de emprendimiento o tienes proyectos de semestre? Agrégalos aquí.',
              ),
            )
          else
            for (final p in projects)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: scheme.tertiary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          if (portfolioUrl.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.link_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Portafolio / GitHub: $portfolioUrl',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillsAndLanguagesCard extends StatelessWidget {
  const _SkillsAndLanguagesCard({
    required this.skills,
    required this.languages,
    required this.onEditTap,
  });

  final List<String> skills;
  final List<String> languages;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Habilidades & Idiomas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onEditTap,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (skills.isEmpty)
            const Text(
              'Aún no has agregado habilidades (ej: Flutter, Diseño UX, Finanzas, Python).',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in skills)
                  Chip(
                    avatar: Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: scheme.primary,
                    ),
                    label: Text(
                      s,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          const Divider(height: 28),
          Text(
            'Idiomas y Lenguas',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lang in languages)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '🗣️ $lang',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcademicAndContactCard extends StatelessWidget {
  const _AcademicAndContactCard({
    required this.user,
    required this.hasProfile,
    required this.onEditTap,
  });

  final UserProfile user;
  final bool hasProfile;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Canal de Match & Privacidad',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onEditTap,
                child: const Text('Configurar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  user.contactChannel == ContactChannel.whatsapp
                      ? Icons.chat_outlined
                      : Icons.mail_outline_rounded,
                  color: scheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Canal preferido: ${user.contactChannel.label}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasProfile && user.contactValue.isNotEmpty
                            ? user.contactValue
                            : 'Sin configurar (pulsa Configurar para añadir tu WhatsApp o correo)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '🔒 Tu número o correo permanece oculto en el Tablero y solo se revela cuando tú o el autor del aviso confirman el Match.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
