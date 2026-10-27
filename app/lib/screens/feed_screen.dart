import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posting.dart';
import '../state/app_state.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'landing_screen.dart';
import 'profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  PostType? _filter;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final posts = _filter == null
        ? appState.feed
        : appState.feed.where((p) => p.type == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tablero de Oportunidades'),
            Text(
              'Universidad de La Guajira',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ver inicio / Acerca de Match Universitario',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreatePost(context),
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
      body: Column(
        children: [
          if (!appState.hasProfile)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.waving_hand_rounded,
                    size: 20,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Estás explorando como usuario nuevo (sin sesión). Crea tu perfil para postularte o publicar.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => _openProfileModal(context),
                    child: const Text('Crear perfil'),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'Todo',
                  selected: _filter == null,
                  onSelected: () => setState(() => _filter = null),
                ),
                for (final type in PostType.values)
                  _FilterChip(
                    label: '${type.emoji} ${type.label}',
                    selected: _filter == type,
                    onSelected: () => setState(() => _filter = type),
                  ),
              ],
            ),
          ),
          Expanded(
            child: posts.isEmpty
                ? const _EmptyFeed()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 96),
                    itemCount: posts.length,
                    itemBuilder: (context, index) =>
                        PostCard(posting: posts[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool> _openProfileModal(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(popOnSave: true),
      ),
    );
    return result ?? false;
  }

  Future<void> _openCreatePost(BuildContext context) async {
    final appState = context.read<AppState>();
    if (!appState.hasProfile) {
      final created = await _openProfileModal(context);
      if (!created || !context.mounted) return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48),
            SizedBox(height: 12),
            Text('No hay publicaciones con este filtro.'),
          ],
        ),
      ),
    );
  }
}
