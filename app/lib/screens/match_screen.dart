import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../widgets/profile_modals.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final myPostsWithApplicants = appState.myPostings
        .where((p) => p.applicantCount > 0)
        .toList();
    final pendingApps = appState.pendingApplications;
    final matches = appState.confirmedMatches;
    final campusMatches = appState.campusMatches;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Matches', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
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
                            color: Theme.of(context).colorScheme.error,
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
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Cerrar sesión'),
                        ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // 1. SOLICITUDES RECIBIDAS (INTERESADOS EN MIS CONVOCATORIAS)
              _SectionHeader(
                icon: Icons.mark_email_unread_outlined,
                title: 'Solicitudes recibidas',
                badgeCount: myPostsWithApplicants.isEmpty
                    ? null
                    : myPostsWithApplicants.fold<int>(
                        0,
                        (sum, p) => sum + p.applicantCount,
                      ),
                subtitle:
                    'Estudiantes interesados en tus avisos. Acéptalos para revelar WhatsApp.',
              ),
              if (myPostsWithApplicants.isEmpty)
                const _EmptyHint(
                  message:
                      'Aún no tienes solicitudes en tus avisos. Publica en el Tablero para recibir compañeros.',
                  icon: Icons.mark_email_read_outlined,
                )
              else
                ...myPostsWithApplicants.map(
                  (post) => _ApplicantsCard(posting: post),
                ),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.35),
              ),

              // 2. MIS MATCHES CONFIRMADOS (CONEXIÓN MUTUA CON WHATSAPP DESBLOQUEADO)
              _SectionHeader(
                icon: Icons.handshake_rounded,
                title: 'Mis Matches confirmados',
                badgeCount: matches.isEmpty ? null : matches.length,
                subtitle:
                    '¡Conexiones mutuas exitosas! Ya puedes hablar directamente con tu compañero.',
              ),
              if (matches.isEmpty)
                const _EmptyHint(
                  message:
                      'Cuando aceptes a un interesado o un autor te acepte a ti, aquí verás el botón de WhatsApp directo.',
                  icon: Icons.handshake_outlined,
                )
              else
                ...matches.map((post) => _ConfirmedCard(posting: post)),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.35),
              ),

              // 3. SOLICITUDES ENVIADAS POR MÍ (EN ESPERA DE RESPUESTA)
              _SectionHeader(
                icon: Icons.send_rounded,
                title: 'Solicitudes que enviaste',
                badgeCount: pendingApps.isEmpty ? null : pendingApps.length,
                subtitle:
                    'Avisos donde pulsaste "Me interesa". El autor debe aceptar para conectar.',
              ),
              if (pendingApps.isEmpty)
                const _EmptyHint(
                  message:
                      'No tienes solicitudes pendientes. Explora el Tablero y pulsa "Me interesa" en avisos.',
                  icon: Icons.outgoing_mail,
                )
              else
                ...pendingApps
                    .map((post) => _PendingApplicationCard(posting: post)),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.35),
              ),

              // 4. ACTIVIDAD Y MATCHES EN EL CAMPUS
              const _SectionHeader(
                icon: Icons.groups_2_rounded,
                title: 'Comunidad Uniguajira',
                subtitle:
                    'Matches y conexiones colaborativas recientes entre facultades.',
              ),
              ...campusMatches.map(
                (post) => _CampusMatchCard(posting: post),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.badgeCount,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final int? badgeCount;
  final String? subtitle;

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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: scheme.primary, size: 18),
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
                          color: scheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 36),
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
  });

  final String message;
  final IconData icon;

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
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
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
          ],
        ),
      ),
    );
  }
}

class _ApplicantsCard extends StatelessWidget {
  const _ApplicantsCard({required this.posting});

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
          color: scheme.outlineVariant.withValues(alpha: 0.55),
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
                Text(posting.type.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    posting.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${applicants.length} aspirante${applicants.length == 1 ? "" : "s"}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 6),
            ...applicants.map((applicant) {
              final accepted = posting.acceptedIds.contains(applicant.id);
              return _ApplicantTile(
                applicant: applicant,
                accepted: accepted,
                onAccept: () => appState.acceptApplicant(posting, applicant.id),
              );
            }),
          ],
        ),
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

class _PendingApplicationCard extends StatelessWidget {
  const _PendingApplicationCard({required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.read<AppState>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(posting.type.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posting.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⏳ Esperando respuesta del autor',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Publicado por ${posting.authorName} (${posting.authorCareer})',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => appState.simulateAuthorAcceptsMe(posting),
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Simular que me aceptan el Match'),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedCard extends StatelessWidget {
  const _ConfirmedCard({required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final author = context.read<AppState>().profileById(posting.authorId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
          width: 1.2,
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
                const SizedBox(width: 8),
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
              'Publicado por ${posting.authorName} (${posting.authorCareer})',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (author != null) ...[
              const SizedBox(height: 12),
              _ContactBox(profile: author),
            ],
          ],
        ),
      ),
    );
  }
}

class _CampusMatchCard extends StatelessWidget {
  const _CampusMatchCard({required this.posting});

  final Posting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final acceptedProfiles = appState.acceptedContactsFor(posting);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.handshake_rounded,
                  size: 15,
                  color: scheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  posting.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Iniciativa de ${posting.authorName} (${posting.authorCareer})',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (acceptedProfiles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in acceptedProfiles)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: scheme.primaryContainer,
                          child: Text(
                            p.initials,
                            style: TextStyle(
                              fontSize: 8,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${p.name} (${p.career})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
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
                  '${profile.contactChannel.label} desbloqueado',
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Abriendo ${profile.contactChannel.label}: ${profile.contactValue}',
                  ),
                ),
              );
            },
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
