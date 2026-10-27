import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../utils/time_ago.dart';
import 'profile_modals.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.posting});

  final Posting posting;

  Color _typeAccentColor(PostType type, ColorScheme scheme) {
    switch (type) {
      case PostType.buscaEquipo:
        return const Color(0xFFEA6A00);
      case PostType.grupoEstudio:
        return const Color(0xFFD97706);
      case PostType.evento:
        return const Color(0xFFE11D48);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final isOwner = appState.isOwner(posting);
    final applied = appState.hasApplied(posting);
    final author = appState.profileById(posting.authorId);
    final accent = _typeAccentColor(posting.type, scheme);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. CABECERA: Autor + Badge de Categoría + Hora
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar del autor
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        if (author != null) {
                          showStudentProfileModal(
                            context,
                            author,
                            isCurrentUser: isOwner,
                            revealContact: posting.acceptedIds
                                .contains(appState.currentUser.id),
                          );
                        }
                      },
                      child: author != null
                          ? ProfileAvatar(
                              profile: author,
                              radius: 19,
                              showBorder: false,
                            )
                          : CircleAvatar(
                              radius: 19,
                              backgroundColor: scheme.primaryContainer,
                              child: Text(
                                _initials(posting.authorName),
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),

                    // Nombre y Carrera
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (author != null) {
                            showStudentProfileModal(
                              context,
                              author,
                              isCurrentUser: isOwner,
                              revealContact: posting.acceptedIds
                                  .contains(appState.currentUser.id),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posting.authorName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              author != null
                                  ? '${posting.authorCareer} · Sem. ${author.semester}'
                                  : posting.authorCareer,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tag de Categoría compacto
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            posting.type.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            posting.type.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. TÍTULO
                Text(
                  posting.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // 3. DESCRIPCIÓN
                Text(
                  posting.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // 4. METADATOS: Perfil buscado / Lugar del campus
                if (posting.targetCareer != null || posting.location != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (posting.targetCareer != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                size: 14,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Busca: ${posting.targetCareer!}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (posting.location != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 14,
                                color: scheme.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  posting.location!,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // 5. PIE DE TARJETA: Tiempo + Postulados + Botón de Acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tiempo relativo + postulados
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              posting.applicantCount > 0
                                  ? '${timeAgo(posting.createdAt)} · ${posting.applicantCount} postulado${posting.applicantCount == 1 ? '' : 's'}'
                                  : timeAgo(posting.createdAt),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: posting.applicantCount > 0
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                                fontWeight: posting.applicantCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Botón de acción
                    _FooterAction(
                      posting: posting,
                      isOwner: isOwner,
                      applied: applied,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.posting,
    required this.isOwner,
    required this.applied,
  });

  final Posting posting;
  final bool isOwner;
  final bool applied;

  Future<void> _handleApply(BuildContext context) async {
    final appState = context.read<AppState>();
    if (!appState.hasProfile) {
      final created = await showProfileEditorModal(context);
      if (!created || !context.mounted) return;
    }
    appState.applyToPost(posting);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Te postulaste a "${posting.title}". Revisa la pestaña Matches.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (isOwner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_pin_circle_outlined, size: 14, color: scheme.primary),
            const SizedBox(width: 5),
            Text(
              'Tu aviso',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (applied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF10B981)),
            SizedBox(width: 5),
            Text(
              'Postulado',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    }

    return FilledButton.icon(
      onPressed: () => _handleApply(context),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEA6A00),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      icon: const Icon(Icons.favorite_rounded, size: 14),
      label: const Text('Me interesa'),
    );
  }
}
