import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final myPostsWithApplicants = appState.myPostings
        .where((p) => p.applicantCount > 0)
        .toList();
    final matches = appState.confirmedMatches;

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _SectionHeader(
            icon: Icons.mark_email_unread_outlined,
            title: 'Interesados en mis publicaciones',
          ),
          if (myPostsWithApplicants.isEmpty)
            const _EmptyHint('Todavía nadie marca "Me interesa" en tus avisos.')
          else
            ...myPostsWithApplicants.map(
              (post) => _ApplicantsCard(posting: post),
            ),
          const SizedBox(height: 8),
          const _SectionHeader(
            icon: Icons.handshake_outlined,
            title: 'Mis coincidencias',
          ),
          if (matches.isEmpty)
            const _EmptyHint('Cuando te acepten, aquí verás el contacto.')
          else
            ...matches.map((post) => _ConfirmedCard(posting: post)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
    final appState = context.watch<AppState>();
    final applicants = appState.applicantsFor(posting);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              posting.title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${posting.type.emoji} ${posting.type.label}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 20),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(applicant.initials),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${applicant.career} · Semestre ${applicant.semester}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (accepted)
                Icon(Icons.check_circle,
                    color: theme.colorScheme.tertiary)
              else
                FilledButton.tonal(
                  onPressed: onAccept,
                  child: const Text('Aceptar'),
                ),
            ],
          ),
          if (accepted) ...[
            const SizedBox(height: 8),
            _ContactBox(profile: applicant),
          ],
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
    final author = context.read<AppState>().profileById(posting.authorId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(posting.type.emoji),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    posting.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.handshake,
                    color: theme.colorScheme.tertiary),
              ],
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

class _ContactBox extends StatelessWidget {
  const _ContactBox({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            profile.contactChannel == ContactChannel.whatsapp
                ? Icons.chat_outlined
                : Icons.mail_outline,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.contactChannel.label} revelado',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                Text(
                  profile.contactValue,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
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
