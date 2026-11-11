import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../utils/contact_launcher.dart';
import '../utils/time_ago.dart';
import '../widgets/match_attachments_panel.dart';
import '../widgets/profile_modals.dart';
import 'create_post_screen.dart';

enum _MatchSectionFilter { all, createdByMe, likedByMe, confirmed, recommended }

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  _MatchSectionFilter _selectedFilter = _MatchSectionFilter.all;

  Future<void> _openCreateMatch(BuildContext context) async {
    final appState = context.read<AppState>();
    if (!appState.hasProfile) {
      final ok = await showProfileEditorModal(context);
      if (!ok || !context.mounted) return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }

  Future<void> _handleLikeRecommended(
    BuildContext context,
    Posting posting,
  ) async {
    final appState = context.read<AppState>();
    if (!appState.hasProfile) {
      final created = await showProfileEditorModal(context);
      if (!created || !context.mounted) return;
    }
    appState.applyToPost(posting);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '❤️ Añadiste "${posting.title}" a los Matches que te gustan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // 1. Matches creados exclusivamente con esta cuenta
    final myCreatedMatches = appState.myPostings;
    // 2. Matches a los que esta cuenta les ha dado Like ("Me interesa")
    final myLikedMatches = appState.myApplications;
    // 3. Matches confirmados (conexión mutua: me aceptaron o acepté en mis avisos)
    final myConfirmedMatches = appState.allMutualMatches;
    // 4. Matches y personas que le pueden interesar según su perfil
    final recommendedMatches = appState.recommendedPostings;
    final recommendedPeers = appState.recommendedPeers;

    final showCreated = _selectedFilter == _MatchSectionFilter.all ||
        _selectedFilter == _MatchSectionFilter.createdByMe;
    final showLiked = _selectedFilter == _MatchSectionFilter.all ||
        _selectedFilter == _MatchSectionFilter.likedByMe;
    final showConfirmed = _selectedFilter == _MatchSectionFilter.all ||
        _selectedFilter == _MatchSectionFilter.confirmed;
    final showRecommended = _selectedFilter == _MatchSectionFilter.all ||
        _selectedFilter == _MatchSectionFilter.recommended;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        return Scaffold(
          backgroundColor: scheme.surfaceContainerLowest,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: scheme.surface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mis Matches y Conexiones',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 17 : 20,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  appState.hasProfile
                      ? 'Cuenta activa: ${appState.currentUser.name} · ${appState.currentUser.career}'
                      : 'Universidad de La Guajira · Tu actividad personal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilledButton.tonalIcon(
                  onPressed: () => _openCreateMatch(context),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 14,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
                  label: Text(isMobile ? 'Crear' : 'Crear Match'),
                ),
              ),
              if (appState.hasProfile)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: isMobile
                      ? IconButton(
                          tooltip: 'Cerrar sesión',
                          onPressed: () {
                            appState.logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sesión cerrada. Ahora estás como usuario nuevo.',
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.logout_rounded,
                            color: scheme.error,
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            appState.logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sesión cerrada. Ahora estás como usuario nuevo.',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.error,
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Cerrar sesión'),
                        ),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: scheme.primary,
            backgroundColor: scheme.surface,
            onRefresh: () async {
              final ok = await appState.refreshFromCloud();
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Matches y conexiones sincronizados'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                  // CABECERA RESUMEN + FILTROS RÁPIDOS EN ORDEN
                  _MatchesOverviewBanner(
                    user: appState.currentUser,
                    hasProfile: appState.hasProfile,
                    createdCount: myCreatedMatches.length,
                    likedCount: myLikedMatches.length,
                    confirmedCount: myConfirmedMatches.length,
                    recommendedCount: recommendedMatches.length,
                    selectedFilter: _selectedFilter,
                    onSelectFilter: (f) => setState(() => _selectedFilter = f),
                    onCreateMatch: () => _openCreateMatch(context),
                    onConfigureProfile: () => showProfileEditorModal(context),
                  ),

                  // ============================================================
                  // 1. MATCHES QUE HAS CREADO CON TU CUENTA
                  // ============================================================
                  if (showCreated) ...[
                    _SectionHeader(
                      stepNumber: '1',
                      icon: Icons.post_add_rounded,
                      accentColor: scheme.primary,
                      title: 'Matches que has creado',
                      badgeCount: myCreatedMatches.length,
                      subtitle:
                          'Convocatorias publicadas únicamente desde tu cuenta. Aquí ves tus avisos y aceptas a quienes les interesó.',
                      trailingAction: TextButton.icon(
                        onPressed: () => _openCreateMatch(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Nuevo Match'),
                      ),
                    ),
                    if (myCreatedMatches.isEmpty)
                      _EmptyHint(
                        icon: Icons.campaign_outlined,
                        message:
                            'Aún no has creado ningún Match con esta cuenta. Publica tu primera convocatoria de estudio, proyecto o evento.',
                        actionLabel: 'Crear mi primer Match',
                        onAction: () => _openCreateMatch(context),
                      )
                    else
                      ...myCreatedMatches.map(
                        (post) => _MyCreatedMatchCard(posting: post),
                      ),
                    const _SectionDivider(),
                  ],

                  // ============================================================
                  // 2. MATCHES QUE TE GUSTAN (A LOS QUE LES DISTE LIKE)
                  // ============================================================
                  if (showLiked) ...[
                    _SectionHeader(
                      stepNumber: '2',
                      icon: Icons.favorite_rounded,
                      accentColor: const Color(0xFFEA6A00),
                      title: 'Matches que te gustan',
                      badgeCount: myLikedMatches.length,
                      subtitle:
                          'Convocatorias del campus a las que les diste "Me interesa" (Like) con tu cuenta.',
                    ),
                    if (myLikedMatches.isEmpty)
                      const _EmptyHint(
                        icon: Icons.favorite_border_rounded,
                        message:
                            'Todavía no le has dado "Me interesa" a ningún Match. Revisa las recomendaciones abajo o explora el Tablero.',
                      )
                    else
                      ...myLikedMatches.map(
                        (post) => _LikedMatchCard(posting: post),
                      ),
                    const _SectionDivider(),
                  ],

                  // ============================================================
                  // 3. MATCHES CONFIRMADOS (¡HICIERON MATCH!)
                  // ============================================================
                  if (showConfirmed) ...[
                    _SectionHeader(
                      stepNumber: '3',
                      icon: Icons.handshake_rounded,
                      accentColor: const Color(0xFF10B981),
                      title: 'Matches confirmados (¡Hicieron Match!)',
                      badgeCount: myConfirmedMatches.length,
                      subtitle:
                          'Conexiones mutuas exitosas donde tú aceptaste a un compañero o el autor te aceptó a ti. ¡WhatsApp y correo desbloqueados!',
                    ),
                    if (myConfirmedMatches.isEmpty)
                      const _EmptyHint(
                        icon: Icons.handshake_outlined,
                        message:
                            'Cuando aceptes a un interesado en tus Matches creados o un autor confirme tu Like, aquí aparecerá su WhatsApp directo.',
                      )
                    else
                      ...myConfirmedMatches.map(
                        (post) => _ConfirmedCard(posting: post),
                      ),
                    const _SectionDivider(),
                  ],

                  // ============================================================
                  // 4. MATCHES Y PERSONAS QUE TE PUEDEN INTERESAR
                  // ============================================================
                  if (showRecommended) ...[
                    _SectionHeader(
                      stepNumber: '4',
                      icon: Icons.auto_awesome_rounded,
                      accentColor: const Color(0xFF7C3AED),
                      title: 'Matches y personas que te pueden interesar',
                      badgeCount: recommendedMatches.length,
                      subtitle: appState.hasProfile
                          ? 'Seleccionados según tu carrera (${appState.currentUser.career}), habilidades e intereses para conectar hoy.'
                          : 'Oportunidades destacadas y compañeros compatibles en Uniguajira para que conectes.',
                    ),
                    if (recommendedMatches.isEmpty)
                      const _EmptyHint(
                        icon: Icons.explore_outlined,
                        message:
                            '¡Ya interactuaste con todas las convocatorias actuales! Crea una nueva para seguir conectando.',
                      )
                    else
                      ...recommendedMatches.map(
                        (post) => _RecommendedMatchCard(
                          posting: post,
                          affinityScore: appState.affinityScoreFor(post),
                          affinityReason: appState.affinityReasonFor(post),
                          onLike: () => _handleLikeRecommended(context, post),
                        ),
                      ),
                    if (recommendedPeers.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: scheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.people_alt_rounded,
                                size: 17,
                                color: scheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personas con las que puedes conectar',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  Text(
                                    'Compañeros de Uniguajira afines a tu perfil académico y semilleros.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: recommendedPeers.map((peer) {
                            final cardWidth = isMobile
                                ? constraints.maxWidth - 28
                                : (constraints.maxWidth.clamp(0, 980) - 48) / 2;
                            return SizedBox(
                              width: cardWidth,
                              child: _RecommendedPeerCard(
                                peer: peer,
                                affinityScore: appState.peerAffinityScore(peer),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

class _MatchesOverviewBanner extends StatelessWidget {
  const _MatchesOverviewBanner({
    required this.user,
    required this.hasProfile,
    required this.createdCount,
    required this.likedCount,
    required this.confirmedCount,
    required this.recommendedCount,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.onCreateMatch,
    required this.onConfigureProfile,
  });

  final UserProfile user;
  final bool hasProfile;
  final int createdCount;
  final int likedCount;
  final int confirmedCount;
  final int recommendedCount;
  final _MatchSectionFilter selectedFilter;
  final ValueChanged<_MatchSectionFilter> onSelectFilter;
  final VoidCallback onCreateMatch;
  final VoidCallback onConfigureProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.10),
            scheme.tertiaryContainer.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: user, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasProfile
                          ? 'Resumen de Matches de ${user.name}'
                          : 'Tu Panel Personal de Matches',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasProfile
                          ? 'Revisa en orden lo que has creado, lo que te gusta, tus matches mutuos y sugerencias para ti.'
                          : 'Personaliza tu perfil para recibir mejores recomendaciones y guardar toda tu actividad.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasProfile)
                FilledButton.tonalIcon(
                  onPressed: onConfigureProfile,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: const Text('Mi Perfil'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterPill(
                  label: 'Ver todo en orden',
                  icon: Icons.view_agenda_outlined,
                  selected: selectedFilter == _MatchSectionFilter.all,
                  onTap: () => onSelectFilter(_MatchSectionFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: '1. Creados por mí ($createdCount)',
                  icon: Icons.post_add_rounded,
                  selected: selectedFilter == _MatchSectionFilter.createdByMe,
                  onTap: () => onSelectFilter(_MatchSectionFilter.createdByMe),
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: '2. Me gustan ($likedCount)',
                  icon: Icons.favorite_rounded,
                  selected: selectedFilter == _MatchSectionFilter.likedByMe,
                  onTap: () => onSelectFilter(_MatchSectionFilter.likedByMe),
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: '3. Matcheados ($confirmedCount)',
                  icon: Icons.handshake_rounded,
                  selected: selectedFilter == _MatchSectionFilter.confirmed,
                  onTap: () => onSelectFilter(_MatchSectionFilter.confirmed),
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: '4. Para ti ($recommendedCount)',
                  icon: Icons.auto_awesome_rounded,
                  selected: selectedFilter == _MatchSectionFilter.recommended,
                  onTap: () => onSelectFilter(_MatchSectionFilter.recommended),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? scheme.onPrimary : scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 2),
      child: Divider(
        height: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
        color: Theme.of(context)
            .colorScheme
            .outlineVariant
            .withValues(alpha: 0.4),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.stepNumber,
    required this.icon,
    required this.accentColor,
    required this.title,
    this.badgeCount,
    this.subtitle,
    this.trailingAction,
  });

  final String stepNumber;
  final IconData icon;
  final Color accentColor;
  final String title;
  final int? badgeCount;
  final String? subtitle;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.32),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stepNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(icon, color: accentColor, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (badgeCount != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailingAction,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 10),
              FilledButton.tonal(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 1. Tarjeta para los Matches que el usuario actual ha creado con su cuenta.
class _MyCreatedMatchCard extends StatelessWidget {
  const _MyCreatedMatchCard({required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final applicants = appState.applicantsFor(posting);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${posting.type.emoji} ${posting.type.label}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeAgo(posting.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: applicants.isNotEmpty
                        ? const Color(0xFFEA6A00).withValues(alpha: 0.14)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    applicants.isEmpty
                        ? 'Sin solicitudes aún'
                        : '${applicants.length} interesado${applicants.length == 1 ? "" : "s"}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: applicants.isNotEmpty
                          ? const Color(0xFFEA6A00)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Eliminar mi convocatoria',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    appState.deletePost(posting);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Eliminaste "${posting.title}".'),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: scheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              posting.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              posting.description,
              style: TextStyle(
                fontSize: 12.5,
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (posting.targetCareer != null || posting.location != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (posting.targetCareer != null)
                    _MiniInfoTag(
                      icon: Icons.school_outlined,
                      text: 'Busca: ${posting.targetCareer}',
                    ),
                  if (posting.location != null &&
                      posting.location!.trim().isNotEmpty)
                    _MiniInfoTag(
                      icon: Icons.place_outlined,
                      text: posting.location!,
                    ),
                ],
              ),
            ],
            MatchAttachmentsPanel(posting: posting),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            if (applicants.isEmpty)
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 15,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tu Match está publicado en el Tablero. Cuando un estudiante pulse "Me interesa", aparecerá aquí para que lo aceptes.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              Text(
                'Estudiantes que le dieron Like a tu Match:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              ...applicants.map((applicant) {
                final accepted = posting.acceptedIds.contains(applicant.id);
                return _ApplicantTile(
                  applicant: applicant,
                  accepted: accepted,
                  onAccept: () =>
                      appState.acceptApplicant(posting, applicant.id),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniInfoTag extends StatelessWidget {
  const _MiniInfoTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  const _ApplicantTile({
    required this.applicant,
    required this.accepted,
    required this.onAccept,
  });

  final UserProfile applicant;
  final bool accepted;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accepted
            ? const Color(0xFF10B981).withValues(alpha: 0.05)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accepted
              ? const Color(0xFF10B981).withValues(alpha: 0.35)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: applicant, radius: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    Text(
                      '${applicant.career} · Sem. ${applicant.semester}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (accepted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Aceptado',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          showStudentProfileModal(context, applicant),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      child:
                          const Text('Perfil', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEA6A00),
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (accepted) ...[
            const SizedBox(height: 10),
            _ContactBox(profile: applicant),
          ],
        ],
      ),
    );
  }
}

/// 2. Tarjeta para los Matches a los que el usuario les dio Like ("Me interesa").
class _LikedMatchCard extends StatelessWidget {
  const _LikedMatchCard({required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final isConfirmed =
        posting.acceptedIds.contains(appState.currentUser.id);
    final author = appState.profileById(posting.authorId);
    final affinity = appState.affinityScoreFor(posting);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF10B981).withValues(alpha: 0.45)
              : const Color(0xFFEA6A00).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEA6A00).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConfirmed
                          ? Icons.handshake_rounded
                          : Icons.favorite_rounded,
                      size: 13,
                      color: isConfirmed
                          ? const Color(0xFF047857)
                          : const Color(0xFFEA6A00),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConfirmed
                          ? '¡Ya hicieron Match!'
                          : 'Te gusta · Esperando respuesta',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isConfirmed
                            ? const Color(0xFF047857)
                            : const Color(0xFFEA6A00),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${posting.type.emoji} ${posting.type.label}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$affinity% afín',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            posting.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            posting.description,
            style: TextStyle(
              fontSize: 12.5,
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: author != null
                ? () => showStudentProfileModal(context, author)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Publicado por ${posting.authorName} (${posting.authorCareer})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          MatchAttachmentsPanel(posting: posting),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isConfirmed && appState.isMockEnabled)
                FilledButton.tonalIcon(
                  onPressed: () => appState.simulateAuthorAcceptsMe(posting),
                  icon: const Icon(Icons.bolt_rounded, size: 17),
                  label: const Text('Simular que me aceptan el Match'),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  appState.withdrawApplication(posting);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Quitaste "${posting.title}" de tus Likes.',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.heart_broken_outlined, size: 15),
                label: const Text('Quitar Like'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3. Tarjeta para los Matches confirmados (tanto donde me aceptaron como donde acepté).
class _ConfirmedCard extends StatelessWidget {
  const _ConfirmedCard({required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final isMyPost = appState.isOwner(posting);
    final author = appState.profileById(posting.authorId);
    final acceptedProfiles = appState.acceptedContactsFor(posting);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.handshake_rounded,
                        size: 14,
                        color: Color(0xFF047857),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '¡Match Confirmado!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isMyPost
                        ? 'En tu convocatoria creada'
                        : 'Te aceptaron en esta convocatoria',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${posting.type.emoji} ${posting.type.label}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              posting.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isMyPost
                  ? 'Aceptaste a ${acceptedProfiles.length} compañero${acceptedProfiles.length == 1 ? "" : "s"} en tu aviso.'
                  : 'Publicado por ${posting.authorName} (${posting.authorCareer})',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (isMyPost) ...[
              for (final acceptedUser in acceptedProfiles) ...[
                const SizedBox(height: 10),
                _ContactBox(profile: acceptedUser),
              ],
            ] else if (author != null) ...[
              const SizedBox(height: 12),
              _ContactBox(profile: author),
            ],
            MatchAttachmentsPanel(posting: posting),
          ],
        ),
      ),
    );
  }
}

/// 4A. Tarjeta para los Matches recomendados que le pueden interesar al usuario.
class _RecommendedMatchCard extends StatelessWidget {
  const _RecommendedMatchCard({
    required this.posting,
    required this.affinityScore,
    required this.affinityReason,
    required this.onLike,
  });

  final Posting posting;
  final int affinityScore;
  final String affinityReason;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.read<AppState>();
    final author = appState.profileById(posting.authorId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$affinityScore% compatible contigo',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  affinityReason,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              Text(
                '${posting.type.emoji} ${posting.type.label}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            posting.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            posting.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          MatchAttachmentsPanel(posting: posting),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: author != null
                      ? () => showStudentProfileModal(context, author)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      if (author != null) ...[
                        ProfileAvatar(profile: author, radius: 14),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posting.authorName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              posting.authorCareer,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: onLike,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA6A00),
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.favorite_rounded, size: 15),
                label: const Text(
                  'Me interesa',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
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

/// 4B. Tarjeta de compañero recomendado con quien el estudiante puede conectar.
class _RecommendedPeerCard extends StatelessWidget {
  const _RecommendedPeerCard({
    required this.peer,
    required this.affinityScore,
  });

  final UserProfile peer;
  final int affinityScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(profile: peer, radius: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peer.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${peer.career} · Sem. ${peer.semester}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$affinityScore% afín',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          if (peer.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: peer.skills.take(3).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showStudentProfileModal(context, peer),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.person_search_rounded, size: 15),
              label: const Text(
                'Ver perfil y conectar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBox extends StatelessWidget {
  const _ContactBox({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWhatsApp = profile.contactChannel == ContactChannel.whatsapp;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isWhatsApp
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWhatsApp
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWhatsApp
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWhatsApp ? Icons.chat_rounded : Icons.mail_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.name} · ${profile.contactChannel.label} desbloqueado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isWhatsApp
                        ? const Color(0xFF047857)
                        : theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                Text(
                  profile.contactValue,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isWhatsApp
                        ? const Color(0xFF065F46)
                        : theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => launchDirectContact(context, profile),
            style: FilledButton.styleFrom(
              backgroundColor: isWhatsApp
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
            icon: Icon(
              isWhatsApp
                  ? Icons.send_rounded
                  : Icons.open_in_new_rounded,
              size: 14,
            ),
            label: Text(isWhatsApp ? 'Escribir' : 'Contactar'),
          ),
        ],
      ),
    );
  }
}
