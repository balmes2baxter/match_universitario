import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../utils/time_ago.dart';
import 'profile_modals.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final isOwner = appState.isOwner(posting);
    final applied = appState.hasApplied(posting);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypeBanner(type: posting.type),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final author = appState.profileById(posting.authorId);
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          _initials(posting.authorName),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    posting.authorName,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '· Ver perfil',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${posting.authorCareer} · ${timeAgo(posting.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isOwner)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.person_outline, size: 16),
                          label: const Text('Tu publicación'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  posting.title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  posting.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (posting.targetCareer != null)
                      _InfoChip(
                        icon: Icons.school_outlined,
                        label: posting.targetCareer!,
                      ),
                    if (posting.location != null)
                      _InfoChip(
                        icon: Icons.place_outlined,
                        label: posting.location!,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _Footer(
                  posting: posting,
                  isOwner: isOwner,
                  applied: applied,
                ),
              ],
            ),
          ),
        ],
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

class _TypeBanner extends StatelessWidget {
  const _TypeBanner({required this.type});

  final PostType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(type.emoji),
          const SizedBox(width: 8),
          Text(
            type.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: theme.textTheme.labelMedium,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
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

    if (isOwner) {
      return Row(
        children: [
          Icon(Icons.people_alt_outlined,
              size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            posting.applicantCount == 0
                ? 'Aún no hay interesados'
                : '${posting.applicantCount} interesado${posting.applicantCount == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall,
          ),
          if (posting.acceptedCount > 0) ...[
            const SizedBox(width: 12),
            Icon(Icons.check_circle_outline,
                size: 18, color: theme.colorScheme.tertiary),
            const SizedBox(width: 6),
            Text(
              '${posting.acceptedCount} aceptado${posting.acceptedCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FilledButton.icon(
          onPressed: applied ? null : () => _handleApply(context),
          icon: Icon(applied ? Icons.check : Icons.favorite_border, size: 18),
          label: Text(applied ? 'Interesado' : 'Me interesa'),
        ),
        if (posting.acceptedCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.handshake_outlined,
                size: 16,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '${posting.acceptedCount} match activo${posting.acceptedCount == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
